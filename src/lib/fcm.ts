'use client';

import { getMessaging, getToken, onMessage, type Messaging } from 'firebase/messaging';
import app from './firebase';

let messaging: Messaging | null = null;

function getMessagingInstance(): Messaging | null {
  if (typeof window === 'undefined') return null;
  if (!app) return null;
  if (!messaging) {
    messaging = getMessaging(app);
  }
  return messaging;
}

/**
 * Request notification permission and get FCM token.
 * Returns the token string or null if permission denied.
 */
export async function requestNotificationPermission(): Promise<string | null> {
  if (typeof window === 'undefined') return null;

  const permission = await Notification.requestPermission();
  if (permission !== 'granted') return null;

  const msg = getMessagingInstance();
  if (!msg) return null;

  const vapidKey = process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY;
  const token = await getToken(msg, {
    vapidKey,
    serviceWorkerRegistration: await navigator.serviceWorker.register('/firebase-messaging-sw.js'),
  });

  return token;
}

/**
 * Listen for foreground FCM messages. Returns an unsubscribe function.
 */
export function onForegroundMessage(callback: (payload: { title?: string; body?: string }) => void): () => void {
  const msg = getMessagingInstance();
  if (!msg) return () => {};

  return onMessage(msg, (payload) => {
    callback({
      title: payload.notification?.title,
      body: payload.notification?.body,
    });
  });
}
