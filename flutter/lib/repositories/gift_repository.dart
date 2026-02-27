import 'package:cloud_functions/cloud_functions.dart';
import '../models/gift_suggestion.dart';
import '../models/person.dart';
import '../core/utils.dart';

/// Repository for AI-powered gift suggestions via Firebase Cloud Functions.
///
/// Calls the `getGiftSuggestions` Cloud Function (europe-west2) which uses
/// the Anthropic Claude API to generate personalised gift ideas.
class GiftRepository {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west2');

  /// Fetches AI-generated gift suggestions for a [person].
  ///
  /// Sends the person's name, age, relationship, interests, past gifts,
  /// notes, and existing gift ideas to the Cloud Function for context.
  ///
  /// The [country] parameter (ISO 3166-1 alpha-2 code, e.g. `'AU'`, `'GB'`,
  /// `'US'`) localises suggestions with region-appropriate retailers and
  /// currency. Defaults to `'AU'`.
  Future<List<GiftSuggestion>> getGiftSuggestions(Person person, {String country = 'AU'}) async {
    final age = getCurrentAge(person.dateOfBirth);

    final data = <String, dynamic>{
      'name': person.name,
      'age': age,
      'relationship': person.relationship.displayLabel,
      'interests': person.interests ?? [],
      'pastGifts': (person.pastGifts ?? [])
          .map((g) => {
                'year': g.year,
                'description': g.description,
                'rating': g.rating,
              })
          .toList(),
      'notes': person.notes,
      'giftIdeas': person.giftIdeas ?? [],
      'country': country,
    };

    final callable = _functions.httpsCallable('getGiftSuggestions');
    final result = await callable.call(data);

    final suggestions = (result.data['suggestions'] as List<dynamic>)
        .map((s) => GiftSuggestion.fromMap(Map<String, dynamic>.from(s)))
        .toList();

    return suggestions;
  }
}
