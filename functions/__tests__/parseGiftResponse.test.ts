import { parseGiftResponse, buildSearchUrl } from '../src/utils';

const aiGifts = [
  { name: 'Book', description: 'A great read', estimatedPrice: 'A$20-A$30' },
  { name: 'Mug', description: 'For coffee', estimatedPrice: 'A$15' },
];

describe('parseGiftResponse', () => {
  it('parses a clean JSON array and injects search URLs', () => {
    const text = JSON.stringify(aiGifts);
    const result = parseGiftResponse(text, 'AU');
    expect(result).toHaveLength(2);
    expect(result[0].name).toBe('Book');
    expect(result[0].purchaseUrl).toBe('https://www.amazon.com.au/s?k=Book');
    expect(result[1].purchaseUrl).toBe('https://www.amazon.com.au/s?k=Mug');
  });

  it('extracts JSON from markdown code fences', () => {
    const text = `Here are my suggestions:\n\`\`\`json\n${JSON.stringify(aiGifts)}\n\`\`\`\nHope you like them!`;
    const result = parseGiftResponse(text, 'AU');
    expect(result).toHaveLength(2);
    expect(result[0].name).toBe('Book');
  });

  it('extracts JSON from markdown fences without the json language tag', () => {
    const text = `\`\`\`\n${JSON.stringify(aiGifts)}\n\`\`\``;
    const result = parseGiftResponse(text, 'AU');
    expect(result).toHaveLength(2);
  });

  it('extracts JSON from bracket match when surrounded by text', () => {
    const text = `Sure! Here are the gifts: ${JSON.stringify(aiGifts)} I hope these help.`;
    const result = parseGiftResponse(text, 'AU');
    expect(result).toHaveLength(2);
  });

  it('overrides any AI-hallucinated purchaseUrl with a search URL', () => {
    const giftsWithFakeUrls = [
      { name: 'Headphones', description: 'Great sound', estimatedPrice: '$50', purchaseUrl: 'https://fake-hallucinated-url.com/product/123' },
    ];
    const result = parseGiftResponse(JSON.stringify(giftsWithFakeUrls), 'US');
    expect(result[0].purchaseUrl).toBe('https://www.amazon.com/s?k=Headphones');
  });

  it('uses the correct Amazon domain per country', () => {
    const gifts = [{ name: 'Tea Set', description: 'Nice', estimatedPrice: '£25' }];
    const result = parseGiftResponse(JSON.stringify(gifts), 'GB');
    expect(result[0].purchaseUrl).toBe('https://www.amazon.co.uk/s?k=Tea%20Set');
  });

  it('defaults to AU when no country is provided', () => {
    const gifts = [{ name: 'Candle', description: 'Smells good', estimatedPrice: 'A$15' }];
    const result = parseGiftResponse(JSON.stringify(gifts));
    expect(result[0].purchaseUrl).toBe('https://www.amazon.com.au/s?k=Candle');
  });

  it('throws on completely invalid input', () => {
    expect(() => parseGiftResponse('This is just plain text with no JSON')).toThrow(
      'Could not parse gift suggestions from AI response'
    );
  });

  it('throws on empty string', () => {
    expect(() => parseGiftResponse('')).toThrow();
  });

  it('throws on malformed JSON inside brackets', () => {
    expect(() => parseGiftResponse('[not valid json}')).toThrow();
  });
});

describe('buildSearchUrl', () => {
  it('builds an Amazon AU search URL', () => {
    expect(buildSearchUrl('Wireless Headphones', 'AU')).toBe(
      'https://www.amazon.com.au/s?k=Wireless%20Headphones'
    );
  });

  it('builds an Amazon UK search URL', () => {
    expect(buildSearchUrl('Tea Set', 'GB')).toBe(
      'https://www.amazon.co.uk/s?k=Tea%20Set'
    );
  });

  it('builds an Amazon US search URL', () => {
    expect(buildSearchUrl('Board Game', 'US')).toBe(
      'https://www.amazon.com/s?k=Board%20Game'
    );
  });

  it('builds an Amazon India search URL', () => {
    expect(buildSearchUrl('Spice Box', 'IN')).toBe(
      'https://www.amazon.in/s?k=Spice%20Box'
    );
  });

  it('falls back to AU for unknown country', () => {
    expect(buildSearchUrl('Gift', 'XX')).toBe(
      'https://www.amazon.com.au/s?k=Gift'
    );
  });

  it('encodes special characters in the query', () => {
    expect(buildSearchUrl('Kids\' Book & Puzzle', 'US')).toBe(
      "https://www.amazon.com/s?k=Kids'%20Book%20%26%20Puzzle"
    );
  });
});
