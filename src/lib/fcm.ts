'use client';

import type { Messaging } from 'firebase/messaging';

let messaging: Messaging | null = null;

async function getMessagingInstance(): Promise<Messaging | null> {
  if (typeof window === 'undefined') return null;
  if (!messaging) {
    const { default: app } = await import('./firebase');
    if (!app) return null;
    const { getMessaging } = await import('firebase/messaging');
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

  const msg = await getMessagingInstance();
  if (!msg) return null;

  const { getToken } = await import('firebase/messaging');
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
export async function onForegroundMessage(callback: (payload: { title?: string; body?: string }) => void): Promise<() => void> {
  const msg = await getMessagingInstance();
  if (!msg) return () => {};

  const { onMessage } = await import('firebase/messaging');
  return onMessage(msg, (payload) => {
    callback({
      title: payload.notification?.title,
      body: payload.notification?.body,
    });
  });
}
