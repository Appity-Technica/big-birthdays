import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onSchedule } from 'firebase-functions/v2/scheduler';

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

/**
 * Runs daily at 8am UTC. Checks all users' people for upcoming birthdays
 * and sends push notifications based on their timing preferences.
 */
export const sendBirthdayNotifications = onSchedule(
  { schedule: 'every day 08:00', timeZone: 'Europe/London', region: 'europe-west2' },
  async () => {
    const usersSnapshot = await db.collection('users').listDocuments();

    for (const userDoc of usersSnapshot) {
      const settingsSnap = await db.doc(`users/${userDoc.id}/settings/notifications`).get();
      if (!settingsSnap.exists) continue;

      const settings = settingsSnap.data() as NotificationSettings;
      if (!settings.enabled || !settings.fcmToken) continue;

      const peopleSnapshot = await db.collection(`users/${userDoc.id}/people`).get();
      const notifications: { name: string; timing: NotificationTiming }[] = [];

      for (const personDoc of peopleSnapshot.docs) {
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
            // Token expired — clear it
            await db.doc(`users/${userDoc.id}/settings/notifications`).update({
              fcmToken: null,
              enabled: false,
            });
          }
          console.error(`Failed to send notification to user ${userDoc.id}:`, err);
        }
      }
    }
  }
);
