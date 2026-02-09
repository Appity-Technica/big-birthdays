import { httpsCallable } from 'firebase/functions';
import { functions } from './firebase';
import { Person, GiftSuggestion, CountryCode } from '@/types';
import { getCurrentAge } from './utils';

export async function getGiftSuggestions(
  person: Person,
  country: CountryCode
): Promise<GiftSuggestion[]> {
  const callable = httpsCallable<
    Record<string, unknown>,
    { suggestions: GiftSuggestion[] }
  >(functions, 'getGiftSuggestions');

  const age = getCurrentAge(person.dateOfBirth);

  const result = await callable({
    name: person.name,
    age,
    relationship: person.relationship,
    interests: person.interests ?? [],
    pastGifts: (person.pastGifts ?? []).map((g) => g.description),
    notes: person.notes ?? '',
    giftIdeas: person.giftIdeas ?? [],
    country,
  });

  return result.data.suggestions;
}
