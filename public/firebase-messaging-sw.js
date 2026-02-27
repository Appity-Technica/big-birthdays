/* global self, importScripts, firebase */
importScripts('https://www.gstatic.com/firebasejs/12.9.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/12.9.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: self.__FIREBASE_CONFIG__?.apiKey,
  authDomain: self.__FIREBASE_CONFIG__?.authDomain,
  projectId: self.__FIREBASE_CONFIG__?.projectId,
  storageBucket: self.__FIREBASE_CONFIG__?.storageBucket,
  messagingSenderId: self.__FIREBASE_CONFIG__?.messagingSenderId,
  appId: self.__FIREBASE_CONFIG__?.appId,
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || 'Birthday Reminder';
  const options = {
    body: payload.notification?.body || 'Someone has a birthday coming up!',
    icon: '/logo.png',
    badge: '/logo.png',
  };
  self.registration.showNotification(title, options);
});
