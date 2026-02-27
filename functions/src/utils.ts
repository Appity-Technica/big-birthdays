export type NotificationTiming = 'on-the-day' | '1-day' | '3-days' | '1-week' | '2-weeks';

export interface GiftRequest {
  name: string;
  age: number | null;
  relationship: string;
  interests: string[];
  pastGifts: { year: number; description: string; rating: number | null }[];
  notes: string | null;
  giftIdeas: string[];
  country?: string;
}

export interface CountryConfig {
  name: string;
  currency: string;
  retailers: string;
}

export const COUNTRY_CONFIG: Record<string, CountryConfig> = {
  'AU': { name: 'Australia', currency: 'A$', retailers: 'Amazon Australia, Kmart, Big W, The Iconic, Myer' },
  'GB': { name: 'United Kingdom', currency: '£', retailers: 'Amazon UK, Etsy, Not On The High Street, John Lewis' },
  'US': { name: 'United States', currency: '$', retailers: 'Amazon, Etsy, Target, Nordstrom' },
  'CA': { name: 'Canada', currency: 'C$', retailers: 'Amazon Canada, Indigo, Canadian Tire, Hudson\'s Bay' },
  'IE': { name: 'Ireland', currency: '€', retailers: 'Amazon, Etsy, Brown Thomas, Arnotts' },
  'NZ': { name: 'New Zealand', currency: 'NZ$', retailers: 'Amazon, The Warehouse, Mighty Ape, Farmers' },
  'ZA': { name: 'South Africa', currency: 'R', retailers: 'Takealot, Superbalist, Mr Price, Woolworths' },
  'IN': { name: 'India', currency: '₹', retailers: 'Amazon India, Flipkart, Myntra, Nykaa' },
};

export interface GiftSuggestion {
  name: string;
  description: string;
  estimatedPrice: string;
  purchaseUrl: string;
}

export const TIMING_TO_DAYS: Record<NotificationTiming, number> = {
  'on-the-day': 0,
  '1-day': 1,
  '3-days': 3,
  '1-week': 7,
  '2-weeks': 14,
};

export function daysUntilBirthday(dateOfBirth: string): number {
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

export function timingLabel(timing: NotificationTiming): string {
  switch (timing) {
    case 'on-the-day': return 'today';
    case '1-day': return 'tomorrow';
    case '3-days': return 'in 3 days';
    case '1-week': return 'in 1 week';
    case '2-weeks': return 'in 2 weeks';
  }
}

export function buildGiftPrompt(data: GiftRequest): string {
  const countryCode = data.country || 'AU';
  const config = COUNTRY_CONFIG[countryCode] || COUNTRY_CONFIG['AU'];

  let prompt = `You are a gift recommendation expert. Based on the following information about a person, suggest exactly 3 thoughtful, purchasable gift ideas. Return ONLY a JSON array with no other text, no markdown fences, no explanation.

Each gift object must have these exact fields:
- "name": short, specific product name (e.g. "Sony WH-1000XM5 Headphones" not just "Headphones")
- "description": 2-3 sentence description of why this gift suits the person
- "estimatedPrice": price range as a string (e.g. "${config.currency}20-${config.currency}30")

Person details:
- Name: ${data.name}`;

  if (data.age !== null) prompt += `\n- Age: ${data.age}`;
  prompt += `\n- Relationship: ${data.relationship}`;
  prompt += `\n- Country: ${config.name}`;

  if (data.interests.length > 0) {
    prompt += `\n- Interests: ${data.interests.join(', ')}`;
  }

  if (data.pastGifts.length > 0) {
    prompt += `\n- Past gifts:`;
    for (const g of data.pastGifts) {
      prompt += `\n  - ${g.year}: ${g.description}`;
      if (g.rating !== null) prompt += ` (rated ${g.rating}/5)`;
    }
  }

  if (data.notes) prompt += `\n- Notes/preferences: ${data.notes}`;

  if (data.giftIdeas.length > 0) {
    prompt += `\n- Existing gift ideas to consider: ${data.giftIdeas.join(', ')}`;
  }

  prompt += `\n\nIMPORTANT: Suggest gifts that are different from past gifts. If a past gift had a high rating, use it as a signal of what they like. Use prices in ${config.currency}. Do NOT include a "purchaseUrl" field — we will generate search links automatically. Return ONLY valid JSON array - no markdown, no explanation.`;

  return prompt;
}

/** Build a Google search URL for a gift name. */
export function buildSearchUrl(giftName: string): string {
  const query = encodeURIComponent(giftName);
  return `https://www.google.com/search?q=${query}`;
}

export function parseGiftResponse(text: string): GiftSuggestion[] {
  let raw: Array<Record<string, unknown>>;
  // Try direct JSON parse first
  try {
    raw = JSON.parse(text);
  } catch {
    // Try extracting from markdown code fences
    const fenceMatch = text.match(/```(?:json)?\s*([\s\S]*?)```/);
    if (fenceMatch) {
      raw = JSON.parse(fenceMatch[1].trim());
    } else {
      // Try finding array brackets
      const bracketMatch = text.match(/\[[\s\S]*\]/);
      if (bracketMatch) {
        raw = JSON.parse(bracketMatch[0]);
      } else {
        throw new Error('Could not parse gift suggestions from AI response');
      }
    }
  }

  // Inject reliable search URLs, replacing any AI-hallucinated purchaseUrl
  return raw.map((item) => ({
    name: String(item.name ?? ''),
    description: String(item.description ?? ''),
    estimatedPrice: String(item.estimatedPrice ?? ''),
    purchaseUrl: buildSearchUrl(String(item.name ?? '')),
  }));
}
