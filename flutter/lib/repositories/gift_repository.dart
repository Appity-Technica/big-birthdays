import 'package:cloud_functions/cloud_functions.dart';
import '../models/gift_suggestion.dart';
import '../models/person.dart';
import '../core/utils.dart';

class GiftRepository {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west2');

  Future<List<GiftSuggestion>> getGiftSuggestions(Person person) async {
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
    };

    final callable = _functions.httpsCallable('getGiftSuggestions');
    final result = await callable.call(data);

    final suggestions = (result.data['suggestions'] as List<dynamic>)
        .map((s) => GiftSuggestion.fromMap(Map<String, dynamic>.from(s)))
        .toList();

    return suggestions;
  }
}
