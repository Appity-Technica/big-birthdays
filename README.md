# Big Birthdays (Tiaras & Trains)

A cross-platform birthday tracking app with AI-powered gift suggestions.

## Tech Stack

- **Mobile:** Flutter (iOS & Android)
- **Web:** Next.js (TypeScript, Tailwind CSS, App Router)
- **Backend:** Firebase (Auth, Firestore, Cloud Functions, FCM, Analytics, Crashlytics)
- **AI:** Anthropic Claude API (gift suggestions)

## Prerequisites

- Flutter SDK
- Node.js 20+
- Firebase CLI (`npm install -g firebase-tools`)
- Android Studio (for Android) / Xcode (for iOS)

## Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/Appity-Technica/big-birthdays.git
   cd big-birthdays
   ```

2. **Firebase setup**
   ```bash
   firebase login
   ```
   The Firebase project is `big-birthdays`.

3. **Flutter setup**
   ```bash
   cd flutter && flutter pub get
   ```

4. **Web setup**
   ```bash
   npm install
   ```

5. **Functions setup**
   ```bash
   cd functions && npm install
   ```

6. **Environment**
   Copy `.env.example` to `.env.local` and fill in your Firebase config values.

## Development

- **Flutter:** `cd flutter && flutter run`
- **Web:** `npm run dev`
- **Functions:** `cd functions && npm run serve`

## Testing

```bash
cd flutter && flutter test
```

343 tests covering models, repositories, providers, and UI widgets.

## Deployment

- **Flutter:** Firebase App Distribution
  ```bash
  firebase appdistribution:distribute
  ```
- **Web:** Firebase App Hosting (auto-deploys from `main` branch)

## Project Structure

```
flutter/       Flutter mobile app (iOS & Android)
src/           Next.js web app
functions/     Firebase Cloud Functions
```
