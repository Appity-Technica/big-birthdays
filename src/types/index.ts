export type Relationship = 'family' | 'friend' | 'colleague' | 'other';

export type KnownFrom = 'school' | 'dance' | 'sports' | 'scouts' | 'neighbourhood' | 'work' | 'church' | 'family-friend' | 'other';

export interface SocialLink {
  platform: string;
  url: string;
}

export interface PastGift {
  year: number;
  description: string;
}

export interface Party {
  year: number;
  date?: string;
  invitedNames?: string[];
  notes?: string;
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
  createdAt: string;
  updatedAt: string;
}
