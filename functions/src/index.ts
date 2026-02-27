import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import Anthropic from '@anthropic-ai/sdk';

const anthropicKey = defineSecret('ANTHROPIC_API_KEY');

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

type NotificationTiming = 'on-the-day' | '1-day' | '3-days' | '1-week' | '2-weeks';

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

const TIMING_TO_DAYS: Record<NotificationTiming, number> = {
  'on-the-day': 0,
  '1-day': 1,
  '3-days': 3,
  '1-week': 7,
  '2-weeks': 14,
};

function daysUntilBirthday(dateOfBirth: string): number {
  const today = new Date();
  const [, monthStr, dayStr] = dateOfBirth.split('-');
  const month = parseInt(monthStr, 10) - 1;
  const day = parseInt(dayStr, 10);

  const thisYear = today.getFullYear();
  let next = new Date(thisYear, month, day);
  if (next < today) {
    next = new Date(thisYear + 1, month, day);
  }

  const diffMs = next.getTime() - today.getTime();
  return Math.ceil(diffMs / (1000 * 60 * 60 * 24));
}

function timingLabel(timing: NotificationTiming): string {
  switch (timing) {
    case 'on-the-day': return 'today';
    case '1-day': return 'tomorrow';
    case '3-days': return 'in 3 days';
    case '1-week': return 'in 1 week';
    case '2-weeks': return 'in 2 weeks';
  }
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

interface GiftRequest {
  name: string;
  age: number | null;
  relationship: string;
  interests: string[];
  pastGifts: { year: number; description: string; rating: number | null }[];
  notes: string | null;
  giftIdeas: string[];
  country?: string;
}

interface CountryConfig {
  name: string;
  currency: string;
  retailers: string;
}

const COUNTRY_CONFIG: Record<string, CountryConfig> = {
  'AU': { name: 'Australia', currency: 'A$', retailers: 'Amazon Australia, Kmart, Big W, The Iconic, Myer' },
  'GB': { name: 'United Kingdom', currency: '£', retailers: 'Amazon UK, Etsy, Not On The High Street, John Lewis' },
  'US': { name: 'United States', currency: '$', retailers: 'Amazon, Etsy, Target, Nordstrom' },
  'CA': { name: 'Canada', currency: 'C$', retailers: 'Amazon Canada, Indigo, Canadian Tire, Hudson\'s Bay' },
  'IE': { name: 'Ireland', currency: '€', retailers: 'Amazon, Etsy, Brown Thomas, Arnotts' },
  'NZ': { name: 'New Zealand', currency: 'NZ$', retailers: 'Amazon, The Warehouse, Mighty Ape, Farmers' },
  'ZA': { name: 'South Africa', currency: 'R', retailers: 'Takealot, Superbalist, Mr Price, Woolworths' },
  'IN': { name: 'India', currency: '₹', retailers: 'Amazon India, Flipkart, Myntra, Nykaa' },
};

interface GiftSuggestion {
  name: string;
  description: string;
  estimatedPrice: string;
  purchaseUrl: string;
}

function buildGiftPrompt(data: GiftRequest): string {
  const countryCode = data.country || 'AU';
  const config = COUNTRY_CONFIG[countryCode] || COUNTRY_CONFIG['AU'];

  let prompt = `You are a gift recommendation expert. Based on the following information about a person, suggest exactly 3 thoughtful, purchasable gift ideas. Return ONLY a JSON array with no other text, no markdown fences, no explanation.

Each gift object must have these exact fields:
- "name": short product name
- "description": 2-3 sentence description of why this gift suits the person
- "estimatedPrice": price range as a string (e.g. "${config.currency}20-${config.currency}30")
- "purchaseUrl": a real, working URL where this can be purchased (use ${config.retailers}, or other major ${config.name} retailers)

Person details:
- Name: ${data.name}`;

  if (data.age !== null) prompt += `\n- Age: ${data.age}`;
  prompt += `\n- Relationship: ${data.relationship}`;
  prompt += `\n- Country: ${config.name}`;

  if (data.interests.length > 0) {
    prompt += `\n- Interests: ${data.interests.join(', ')}`;
  }

  if (data.pastGifts.length > 0) {
    prompt += `\n- Past gifts:`;
    for (const g of data.pastGifts) {
      prompt += `\n  - ${g.year}: ${g.description}`;
      if (g.rating !== null) prompt += ` (rated ${g.rating}/5)`;
    }
  }

  if (data.notes) prompt += `\n- Notes/preferences: ${data.notes}`;

  if (data.giftIdeas.length > 0) {
    prompt += `\n- Existing gift ideas to consider: ${data.giftIdeas.join(', ')}`;
  }

  prompt += `\n\nIMPORTANT: Suggest gifts that are different from past gifts. If a past gift had a high rating, use it as a signal of what they like. Use prices in ${config.currency} and provide real product URLs from major ${config.name} retailers. Return ONLY valid JSON array - no markdown, no explanation.`;

  return prompt;
}

function parseGiftResponse(text: string): GiftSuggestion[] {
  // Try direct JSON parse first
  try {
    return JSON.parse(text);
  } catch {
    // Try extracting from markdown code fences
    const fenceMatch = text.match(/```(?:json)?\s*([\s\S]*?)```/);
    if (fenceMatch) {
      return JSON.parse(fenceMatch[1].trim());
    }
    // Try finding array brackets
    const bracketMatch = text.match(/\[[\s\S]*\]/);
    if (bracketMatch) {
      return JSON.parse(bracketMatch[0]);
    }
    throw new Error('Could not parse gift suggestions from AI response');
  }
}

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

    const data = request.data as GiftRequest;
    if (!data.name) {
      throw new HttpsError('invalid-argument', 'Person name is required');
    }

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
      const suggestions = parseGiftResponse(text);

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
