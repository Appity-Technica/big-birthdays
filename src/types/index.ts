export type Relationship = 'family' | 'friend' | 'colleague' | 'other';

export type KnownFrom = 'school' | 'dance' | 'sports' | 'scouts' | 'neighbourhood' | 'work' | 'church' | 'family-friend' | 'other';

export interface SocialLink {
  platform: string;
  url: string;
}

export interface PastGift {
  year: number;
  description: string;
  url?: string;
  rating?: number; // 1-5 stars, how well received
}

export interface Party {
  year: number;
  date?: string;
  invitedNames?: string[];
  notes?: string;
}

export type NotificationTiming = 'on-the-day' | '1-day' | '3-days' | '1-week' | '2-weeks';

export interface NotificationSettings {
  enabled: boolean;
  defaultTimings: NotificationTiming[];
  fcmToken?: string;
}

export interface Person {
  id: string;
  name: string;
  dateOfBirth: string; // ISO date string (YYYY-MM-DD)
  photo?: string;
  relationship: Relationship;
  connectedThrough?: string;
  knownFrom?: KnownFrom;
  knownFromCustom?: string;
  notes?: string;
  giftIdeas?: string[];
  interests?: string[];
  pastGifts?: PastGift[];
  parties?: Party[];
  socialLinks?: SocialLink[];
  notificationTimings?: NotificationTiming[]; // per-person override; absent = use defaults
  createdAt: string;
  updatedAt: string;
}
