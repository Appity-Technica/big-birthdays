import type { NextConfig } from "next";

// Firebase App Hosting provides FIREBASE_WEBAPP_CONFIG with the full config JSON.
// Parse it and expose as NEXT_PUBLIC_ env vars so they're inlined into the client bundle.
const firebaseWebappConfig = process.env.FIREBASE_WEBAPP_CONFIG
  ? JSON.parse(process.env.FIREBASE_WEBAPP_CONFIG)
  : {};

const nextConfig: NextConfig = {
  reactCompiler: true,
  env: {
    NEXT_PUBLIC_FIREBASE_API_KEY:
      firebaseWebappConfig.apiKey || process.env.NEXT_PUBLIC_FIREBASE_API_KEY || "",
    NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN:
      firebaseWebappConfig.authDomain || process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN || "",
    NEXT_PUBLIC_FIREBASE_PROJECT_ID:
      firebaseWebappConfig.projectId || process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || "",
    NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET:
      firebaseWebappConfig.storageBucket || process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET || "",
    NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID:
      firebaseWebappConfig.messagingSenderId || process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID || "",
    NEXT_PUBLIC_FIREBASE_APP_ID:
      firebaseWebappConfig.appId || process.env.NEXT_PUBLIC_FIREBASE_APP_ID || "",
  },
};

export default nextConfig;
