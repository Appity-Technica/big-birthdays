import { parseGiftResponse } from '../src/utils';

const validGifts = [
  { name: 'Book', description: 'A great read', estimatedPrice: 'A$20-A$30', purchaseUrl: 'https://example.com' },
  { name: 'Mug', description: 'For coffee', estimatedPrice: 'A$15', purchaseUrl: 'https://example.com/mug' },
];

describe('parseGiftResponse', () => {
  it('parses a clean JSON array', () => {
    const text = JSON.stringify(validGifts);
    const result = parseGiftResponse(text);
    expect(result).toEqual(validGifts);
  });

  it('extracts JSON from markdown code fences', () => {
    const text = `Here are my suggestions:\n\`\`\`json\n${JSON.stringify(validGifts)}\n\`\`\`\nHope you like them!`;
    const result = parseGiftResponse(text);
    expect(result).toEqual(validGifts);
  });

  it('extracts JSON from markdown fences without the json language tag', () => {
    const text = `\`\`\`\n${JSON.stringify(validGifts)}\n\`\`\``;
    const result = parseGiftResponse(text);
    expect(result).toEqual(validGifts);
  });

  it('extracts JSON from bracket match when surrounded by text', () => {
    const text = `Sure! Here are the gifts: ${JSON.stringify(validGifts)} I hope these help.`;
    const result = parseGiftResponse(text);
    expect(result).toEqual(validGifts);
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
