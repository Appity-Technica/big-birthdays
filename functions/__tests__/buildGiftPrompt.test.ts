import { buildGiftPrompt, GiftRequest } from '../src/utils';

function makeRequest(overrides: Partial<GiftRequest> = {}): GiftRequest {
  return {
    name: 'Alice',
    age: 30,
    relationship: 'friend',
    interests: [],
    pastGifts: [],
    notes: null,
    giftIdeas: [],
    ...overrides,
  };
}

describe('buildGiftPrompt', () => {
  it('includes the person name', () => {
    const prompt = buildGiftPrompt(makeRequest({ name: 'Bob' }));
    expect(prompt).toContain('Bob');
  });

  it('includes the age when provided', () => {
    const prompt = buildGiftPrompt(makeRequest({ age: 25 }));
    expect(prompt).toContain('Age: 25');
  });

  it('omits the age line when age is null', () => {
    const prompt = buildGiftPrompt(makeRequest({ age: null }));
    expect(prompt).not.toContain('Age:');
  });

  it('includes interests when provided', () => {
    const prompt = buildGiftPrompt(makeRequest({ interests: ['cooking', 'hiking'] }));
    expect(prompt).toContain('Interests: cooking, hiking');
  });

  it('does not include interests line when empty', () => {
    const prompt = buildGiftPrompt(makeRequest({ interests: [] }));
    expect(prompt).not.toContain('Interests:');
  });

  it('includes past gifts with ratings', () => {
    const prompt = buildGiftPrompt(makeRequest({
      pastGifts: [
        { year: 2024, description: 'Book', rating: 4 },
        { year: 2023, description: 'Scarf', rating: null },
      ],
    }));
    expect(prompt).toContain('Past gifts:');
    expect(prompt).toContain('2024: Book (rated 4/5)');
    expect(prompt).toContain('2023: Scarf');
    expect(prompt).not.toContain('2023: Scarf (rated');
  });

  it('includes notes when provided', () => {
    const prompt = buildGiftPrompt(makeRequest({ notes: 'Loves red' }));
    expect(prompt).toContain('Notes/preferences: Loves red');
  });

  it('does not include notes line when null', () => {
    const prompt = buildGiftPrompt(makeRequest({ notes: null }));
    expect(prompt).not.toContain('Notes/preferences:');
  });

  it('includes gift ideas when provided', () => {
    const prompt = buildGiftPrompt(makeRequest({ giftIdeas: ['Candle', 'Puzzle'] }));
    expect(prompt).toContain('Existing gift ideas to consider: Candle, Puzzle');
  });

  describe('country handling', () => {
    it('defaults to AU when country is undefined', () => {
      const prompt = buildGiftPrompt(makeRequest({ country: undefined }));
      expect(prompt).toContain('Australia');
      expect(prompt).toContain('A$');
    });

    it('uses AU config', () => {
      const prompt = buildGiftPrompt(makeRequest({ country: 'AU' }));
      expect(prompt).toContain('Australia');
      expect(prompt).toContain('A$');
    });

    it('uses GB config', () => {
      const prompt = buildGiftPrompt(makeRequest({ country: 'GB' }));
      expect(prompt).toContain('United Kingdom');
      expect(prompt).toContain('£');
    });

    it('uses US config', () => {
      const prompt = buildGiftPrompt(makeRequest({ country: 'US' }));
      expect(prompt).toContain('United States');
      expect(prompt).toContain('Country: United States');
    });

    it('falls back to AU for unknown country code', () => {
      const prompt = buildGiftPrompt(makeRequest({ country: 'XX' }));
      expect(prompt).toContain('Australia');
      expect(prompt).toContain('A$');
    });
  });
});
