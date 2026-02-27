import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import Anthropic from '@anthropic-ai/sdk';
import { z } from 'zod';
import {
  NotificationTiming,
  GiftRequest,
  TIMING_TO_DAYS,
  daysUntilBirthday,
  timingLabel,
  buildGiftPrompt,
  parseGiftResponse,
} from './utils';

// --- Zod schema for gift suggestion input validation ---

const PastGiftSchema = z.object({
  year: z.number().int().min(1900).max(2100),
  description: z.string(),
  rating: z.number().int().min(1).max(5).nullable(),
});

const GiftRequestSchema = z.object({
  name: z.string().min(1, 'Person name is required').max(100, 'Name must be 100 characters or less'),
  age: z.number().int().min(0).max(150).nullable(),
  relationship: z.string().min(1, 'Relationship is required'),
  interests: z.array(z.string()).max(20, 'Too many interests (max 20)'),
  pastGifts: z.array(PastGiftSchema).max(50, 'Too many past gifts (max 50)'),
  notes: z.string().max(1000, 'Notes must be 1000 characters or less').nullable(),
  giftIdeas: z.array(z.string()).max(20, 'Too many gift ideas (max 20)'),
  country: z.string().length(2).toUpperCase().optional(),
});

const anthropicKey = defineSecret('ANTHROPIC_API_KEY');

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

interface NotificationSettings {
  enabled: boolean;
  defaultTimings: NotificationTiming[];
  fcmToken?: string;
}

interface Person {
  name: string;
  dateOfBirth: string;
  notificationTimings?: NotificationTiming[];
}

const USER_BATCH_SIZE = 100;

/**
 * Process notifications for a single user. Extracted for error isolation.
 */
async function processUserNotifications(userId: string): Promise<void> {
  const settingsSnap = await db.doc(`users/${userId}/settings/notifications`).get();
  if (!settingsSnap.exists) return;

  const settings = settingsSnap.data() as NotificationSettings;
  if (!settings.enabled || !settings.fcmToken) return;

  // Fetch people with cursor-based pagination
  const notifications: { name: string; timing: NotificationTiming }[] = [];
  let lastPeopleDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;

  for (;;) {
    let peopleQuery = db.collection(`users/${userId}/people`)
      .orderBy('__name__')
      .limit(USER_BATCH_SIZE);

    if (lastPeopleDoc) {
      peopleQuery = peopleQuery.startAfter(lastPeopleDoc);
    }

    const peopleBatch = await peopleQuery.get();
    if (peopleBatch.empty) break;

    for (const personDoc of peopleBatch.docs) {
      const person = personDoc.data() as Person;
      if (!person.dateOfBirth) continue;

      const days = daysUntilBirthday(person.dateOfBirth);
      const timings = person.notificationTimings || settings.defaultTimings;

      for (const timing of timings) {
        if (TIMING_TO_DAYS[timing] === days) {
          notifications.push({ name: person.name, timing });
        }
      }
    }

    lastPeopleDoc = peopleBatch.docs[peopleBatch.docs.length - 1];
    if (peopleBatch.size < USER_BATCH_SIZE) break;
  }

  for (const notif of notifications) {
    try {
      await messaging.send({
        token: settings.fcmToken,
        notification: {
          title: `Birthday Reminder`,
          body: `${notif.name}'s birthday is ${timingLabel(notif.timing)}!`,
        },
        webpush: {
          fcmOptions: {
            link: '/',
          },
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'birthday_reminders',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      });
    } catch (err: unknown) {
      const error = err as { code?: string };
      if (error.code === 'messaging/registration-token-not-registered') {
        await db.doc(`users/${userId}/settings/notifications`).update({
          fcmToken: null,
          enabled: false,
        });
      }
      console.error(`Failed to send notification to user ${userId}:`, err);
    }
  }
}

/**
 * Runs daily at 8am UTC. Checks all users' people for upcoming birthdays
 * and sends push notifications based on their timing preferences.
 * Uses cursor-based pagination to handle large user bases.
 */
export const sendBirthdayNotifications = onSchedule(
  { schedule: 'every day 08:00', timeZone: 'Europe/London', region: 'europe-west2' },
  async () => {
    let lastUserDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;

    for (;;) {
      let usersQuery = db.collection('users')
        .orderBy('__name__')
        .limit(USER_BATCH_SIZE);

      if (lastUserDoc) {
        usersQuery = usersQuery.startAfter(lastUserDoc);
      }

      const usersBatch = await usersQuery.get();
      if (usersBatch.empty) break;

      for (const userDoc of usersBatch.docs) {
        try {
          await processUserNotifications(userDoc.id);
        } catch (err) {
          console.error(`Error processing user ${userDoc.id}:`, err);
        }
      }

      lastUserDoc = usersBatch.docs[usersBatch.docs.length - 1];
      if (usersBatch.size < USER_BATCH_SIZE) break;
    }
  }
);

// --- AI Gift Suggestions ---

const RATE_LIMIT_MAX = 50;
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000; // 1 hour

export const getGiftSuggestions = onCall(
  {
    region: 'europe-west2',
    secrets: [anthropicKey],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Must be signed in');
    }

    const parseResult = GiftRequestSchema.safeParse(request.data);
    if (!parseResult.success) {
      const errors = parseResult.error.issues
        .map((issue) => `${issue.path.join('.')}: ${issue.message}`)
        .join('; ');
      throw new HttpsError('invalid-argument', `Invalid request: ${errors}`);
    }
    const data: GiftRequest = parseResult.data;

    // --- Per-user rate limiting ---
    const uid = request.auth.uid;
    const rateLimitRef = db.collection('_rateLimits').doc(uid);
    const now = Date.now();

    const rateLimitSnap = await rateLimitRef.get();
    let timestamps: number[] = rateLimitSnap.exists
      ? (rateLimitSnap.data()?.timestamps as number[] ?? [])
      : [];

    // Filter to only timestamps within the last hour
    timestamps = timestamps.filter((t) => now - t < RATE_LIMIT_WINDOW_MS);

    if (timestamps.length >= RATE_LIMIT_MAX) {
      throw new HttpsError('resource-exhausted', 'Rate limit exceeded. Please try again later.');
    }

    // Record this call
    timestamps.push(now);
    await rateLimitRef.set({ timestamps });

    try {
      const client = new Anthropic({ apiKey: anthropicKey.value() });
      const prompt = buildGiftPrompt(data);

      const message = await client.messages.create({
        model: 'claude-opus-4-6',
        max_tokens: 1024,
        messages: [{ role: 'user', content: prompt }],
      });

      const text = message.content[0].type === 'text' ? message.content[0].text : '';
      const suggestions = parseGiftResponse(text, data.country || 'AU');

      return { suggestions };
    } catch (err: unknown) {
      // Handle Anthropic rate limit errors specifically
      if (err instanceof Anthropic.RateLimitError) {
        console.error('Anthropic rate limit hit:', err.message);
        throw new HttpsError('unavailable', 'AI service is temporarily busy. Please try again in a few minutes.');
      }
      console.error('Gift suggestion error:', err);
      const msg = err instanceof Error ? err.message : 'Unknown error';
      throw new HttpsError('internal', `Failed to get gift suggestions: ${msg}`);
    }
  }
);
