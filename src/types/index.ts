export type Relationship = 'family' | 'friend' | 'colleague' | 'other';

export interface SocialLink {
  platform: string;
  url: string;
}

export interface PastGift {
  year: number;
  description: string;
}

export interface Person {
  id: string;
  name: string;
  dateOfBirth: string; // ISO date string (YYYY-MM-DD)
  photo?: string;
  relationship: Relationship;
  notes?: string;
  giftIdeas?: string[];
  interests?: string[];
  pastGifts?: PastGift[];
  socialLinks?: SocialLink[];
  createdAt: string;
  updatedAt: string;
}
