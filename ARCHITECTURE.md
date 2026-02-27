# Big Birthdays - Architecture

## Overview

Big Birthdays is a birthday tracker with AI-powered gift suggestions. Users manage contacts and
their birthdays, receive push notification reminders, and get personalised gift ideas from an
AI assistant. The project comprises a Next.js web app, a Flutter mobile app, and a Firebase
backend with Cloud Functions.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Web App | Next.js 15 (App Router, TypeScript, Tailwind CSS) |
| Mobile App | Flutter (Dart, Riverpod, GoRouter) |
| Auth | Firebase Authentication (Email/Password, Google) |
| Database | Cloud Firestore (with offline persistence on mobile) |
| Functions | Firebase Cloud Functions v2 (Node 20, TypeScript) |
| Notifications | Firebase Cloud Messaging (FCM) |
| Analytics | Firebase Analytics, Firebase Crashlytics (mobile) |
| AI | Anthropic Claude API (`claude-opus-4-6`) |
| Web Hosting | Firebase App Hosting (europe-west4, 0-4 instances) |
| Mobile Distribution | Firebase App Distribution |

## Data Flow

```
                         +------------------+
                         |    User (Web)    |
                         +--------+---------+
                                  |
                         +--------v---------+
                         | Next.js App      |
                         | (App Hosting)    |
                         +--------+---------+
                                  |
          +-----------------------+-----------------------+
          |                       |                       |
+---------v--------+   +----------v---------+   +---------v--------+
| Firebase Auth    |   | Cloud Firestore    |   | Cloud Functions  |
| (sign-in)        |   | (people, settings) |   | (europe-west2)   |
+------------------+   +--------------------+   +---------+--------+
                                                          |
                                                +---------v--------+
                                                | Anthropic Claude |
                                                | API (gifts)      |
                                                +------------------+

          +------------------+
          |  User (Mobile)   |
          +--------+---------+
                   |
          +--------v---------+
          | Flutter App      |
          | (iOS / Android)  |
          +--------+---------+
                   |
          +--------v---------+     +--------------------+
          | Firebase Auth    +---->| Cloud Firestore    |
          | FCM, Crashlytics |     | Cloud Functions    |
          +------------------+     +--------------------+
```

## Firestore Schema

### `users/{uid}` (implicit)
Created automatically when a user first writes data. No explicit document fields.

### `users/{uid}/people/{personId}`
A person whose birthday is tracked.

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Display name |
| `dateOfBirth` | string | `YYYY-MM-DD` format (`0000` year = unknown) |
| `photo` | string? | Base64 or URL |
| `relationship` | string | `family`, `friend`, `colleague`, `other` |
| `connectedThrough` | string? | Name of mutual connection |
| `knownFrom` | string? | `school`, `dance`, `sports`, `scouts`, etc. |
| `knownFromCustom` | string? | Custom value when knownFrom is `other` |
| `notes` | string? | Free-text notes |
| `giftIdeas` | string[]? | User-entered gift ideas |
| `interests` | string[]? | Hobbies/interests for AI suggestions |
| `pastGifts` | array? | `{ year, description, url?, rating? }` |
| `parties` | array? | `{ year, date?, invitedNames?, notes? }` |
| `socialLinks` | array? | `{ platform, url }` |
| `notificationTimings` | string[]? | Per-person notification overrides |
| `createdAt` | string | ISO 8601 timestamp |
| `updatedAt` | string | ISO 8601 timestamp |

### `users/{uid}/settings/notifications`
Push notification preferences.

| Field | Type | Description |
|-------|------|-------------|
| `enabled` | boolean | Whether notifications are on |
| `defaultTimings` | string[] | Default timings for all people |
| `fcmToken` | string? | FCM registration token |

### `users/{uid}/settings/preferences`
User preferences.

| Field | Type | Description |
|-------|------|-------------|
| `country` | string | Two-letter country code (AU, GB, US, etc.) |

### `_rateLimits/{uid}`
Per-user rate limiting for AI gift suggestions.

| Field | Type | Description |
|-------|------|-------------|
| `timestamps` | number[] | Unix ms timestamps of recent API calls |

## Cloud Functions

All functions are deployed to `europe-west2`.

### `sendBirthdayNotifications`
- **Trigger:** Scheduled (`every day 08:00`, timezone `Europe/London`)
- **Purpose:** Iterates over all users, checks each person's birthday against the user's
  notification timing preferences, and sends FCM push notifications for upcoming birthdays.
- **Pagination:** Cursor-based batching (100 users/people per batch).
- **Error handling:** Clears invalid FCM tokens; isolates per-user errors.

### `getGiftSuggestions`
- **Trigger:** Callable (`onCall`), requires authentication
- **Secrets:** `ANTHROPIC_API_KEY`
- **Purpose:** Accepts a person's details (name, age, relationship, interests, past gifts,
  country) and returns 3 AI-generated gift suggestions via the Anthropic Claude API.
- **Rate limiting:** 50 requests per user per hour (stored in `_rateLimits` collection).
- **Input validation:** Zod schema validation on the request payload.
- **Response:** `{ suggestions: GiftSuggestion[] }` where each suggestion has
  `name`, `description`, `estimatedPrice`, `purchaseUrl`.

## Flutter Architecture

```
lib/
  main.dart                  # App entry point, Firebase init, Crashlytics
  core/
    theme.dart               # Light + dark Material themes
    constants.dart           # App-wide constants
    analytics.dart           # Firebase Analytics helpers
    utils.dart               # Date/formatting utilities
  models/
    person.dart              # Person, PastGift, Party, SocialLink
    enums.dart               # Relationship, KnownFrom, NotificationTiming
    notification_settings.dart
    user_preferences.dart
    gift_suggestion.dart
  providers/                 # Riverpod state providers
    auth_provider.dart       # Auth state (StreamProvider)
    people_provider.dart     # People list state
    settings_provider.dart   # Notification + preference settings
    gift_provider.dart       # AI gift suggestion state
  repositories/              # Data access layer
    auth_repository.dart     # Firebase Auth operations
    people_repository.dart   # Firestore CRUD for people
    settings_repository.dart # Firestore settings read/write
    gift_repository.dart     # Cloud Function calls for gifts
    contacts_repository.dart # Platform channel for device contacts
    export_repository.dart   # CSV/share export
  router/
    app_router.dart          # GoRouter config with auth redirects
  screens/                   # UI screens (dashboard, people, gifts, calendar, settings)
  widgets/                   # Shared widgets (scaffold, avatar, chips, spinner)
```

**Key patterns:**
- **State management:** Riverpod providers wrap repositories for reactive UI updates.
- **Navigation:** GoRouter with `ShellRoute` for bottom navigation and auth-based redirects.
- **Offline:** Firestore persistence enabled; the app works offline and syncs when reconnected.
- **Contacts import:** Platform channels access native device contacts.

## Next.js Architecture

```
src/
  app/                       # App Router pages
    page.tsx                 # Dashboard (upcoming birthdays)
    login/page.tsx           # Auth page
    people/page.tsx          # People list
    people/new/page.tsx      # Add person
    people/import/page.tsx   # CSV import
    people/export/page.tsx   # CSV export
    people/[id]/page.tsx     # Person detail
    people/[id]/edit/page.tsx
    people/[id]/gifts/page.tsx  # AI gift suggestions
    calendar/page.tsx        # Calendar view
    settings/page.tsx        # Settings (notifications, country)
    privacy/page.tsx         # Privacy policy
    layout.tsx               # Root layout with AuthProvider, Navbar
  components/
    AuthProvider.tsx          # React context for Firebase Auth state
    Navbar.tsx                # Top navigation bar
  hooks/
    usePeople.ts             # People CRUD hook (Firestore or localStorage)
  lib/
    firebase.ts              # Firebase app/auth/firestore initialisation
    auth.ts                  # Sign-in/sign-up/sign-out helpers
    db.ts                    # Firestore CRUD operations
    gifts.ts                 # Cloud Function call for gift suggestions
    fcm.ts                   # FCM token registration
    localStorage.ts          # Offline/anonymous storage fallback
    contacts.ts              # Contact Picker API integration
    csv.ts                   # CSV import/export
    utils.ts                 # Date/formatting utilities
  types/
    index.ts                 # Shared TypeScript interfaces
```

**Key patterns:**
- **Dual storage:** Authenticated users use Firestore; anonymous users use localStorage.
- **Client SDK:** All Firebase calls use the client-side Firebase JS SDK.
- **Hooks:** `usePeople` abstracts storage layer; `useAuth` provides auth context.

## Environment Variables

See `.env.example` for the full list:

| Variable | Description |
|----------|-------------|
| `NEXT_PUBLIC_FIREBASE_API_KEY` | Firebase Web API key |
| `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN` | Firebase Auth domain |
| `NEXT_PUBLIC_FIREBASE_PROJECT_ID` | Firebase project ID |
| `NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET` | Firebase Storage bucket |
| `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID` | FCM sender ID |
| `NEXT_PUBLIC_FIREBASE_APP_ID` | Firebase App ID |
| `NEXT_PUBLIC_FIREBASE_VAPID_KEY` | FCM VAPID key (optional, for web push) |
| `ANTHROPIC_API_KEY` | Anthropic API key (Cloud Functions secret) |

In production, `FIREBASE_WEBAPP_CONFIG` is auto-provided by Firebase App Hosting.

## Deployment

### Web App (Next.js)
- Deployed via **Firebase App Hosting** (backend: `big-birthdays-web`, region: `europe-west4`).
- Config in `apphosting.yaml`: 0-4 instances, 512 MiB memory, 1 CPU, 80 concurrency.
- Auto-deploys from the GitHub repo on push to `main`.

### Cloud Functions
- Deployed with `cd functions && npm run deploy` (or `firebase deploy --only functions`).
- Region: `europe-west2`.
- Secrets managed via Firebase Functions secrets (`ANTHROPIC_API_KEY`).

### Mobile App (Flutter)
- Distributed via **Firebase App Distribution** for testing.
- Production releases via App Store (iOS) and Google Play (Android).
- Firebase config generated by FlutterFire CLI (`firebase_options.dart`).

### Firestore Rules
- Deployed with `firebase deploy --only firestore:rules`.
- Users can only read/write their own `people` and `settings` subcollections.
