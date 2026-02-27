import { parseGiftResponse, buildSearchUrl } from '../src/utils';

const aiGifts = [
  { name: 'Book', description: 'A great read', estimatedPrice: 'A$20-A$30' },
  { name: 'Mug', description: 'For coffee', estimatedPrice: 'A$15' },
];

describe('parseGiftResponse', () => {
  it('parses a clean JSON array and injects Google search URLs', () => {
    const text = JSON.stringify(aiGifts);
    const result = parseGiftResponse(text);
    expect(result).toHaveLength(2);
    expect(result[0].name).toBe('Book');
    expect(result[0].purchaseUrl).toBe('https://www.google.com/search?q=Book');
    expect(result[1].purchaseUrl).toBe('https://www.google.com/search?q=Mug');
  });

  it('extracts JSON from markdown code fences', () => {
    const text = `Here are my suggestions:\n\`\`\`json\n${JSON.stringify(aiGifts)}\n\`\`\`\nHope you like them!`;
    const result = parseGiftResponse(text);
    expect(result).toHaveLength(2);
    expect(result[0].name).toBe('Book');
  });

  it('extracts JSON from markdown fences without the json language tag', () => {
    const text = `\`\`\`\n${JSON.stringify(aiGifts)}\n\`\`\``;
    const result = parseGiftResponse(text);
    expect(result).toHaveLength(2);
  });

  it('extracts JSON from bracket match when surrounded by text', () => {
    const text = `Sure! Here are the gifts: ${JSON.stringify(aiGifts)} I hope these help.`;
    const result = parseGiftResponse(text);
    expect(result).toHaveLength(2);
  });

  it('overrides any AI-hallucinated purchaseUrl with a Google search URL', () => {
    const giftsWithFakeUrls = [
      { name: 'Headphones', description: 'Great sound', estimatedPrice: '$50', purchaseUrl: 'https://fake-hallucinated-url.com/product/123' },
    ];
    const result = parseGiftResponse(JSON.stringify(giftsWithFakeUrls));
    expect(result[0].purchaseUrl).toBe('https://www.google.com/search?q=Headphones');
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
  it('builds a Google search URL', () => {
    expect(buildSearchUrl('Wireless Headphones')).toBe(
      'https://www.google.com/search?q=Wireless%20Headphones'
    );
  });

  it('encodes special characters in the query', () => {
    expect(buildSearchUrl('Kids\' Book & Puzzle')).toBe(
      "https://www.google.com/search?q=Kids'%20Book%20%26%20Puzzle"
    );
  });

  it('handles a simple single-word query', () => {
    expect(buildSearchUrl('Candle')).toBe(
      'https://www.google.com/search?q=Candle'
    );
  });
});
