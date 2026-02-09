import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gift_suggestion.dart';
import '../models/person.dart';
import '../repositories/gift_repository.dart';

final giftRepositoryProvider = Provider<GiftRepository>((ref) {
  return GiftRepository();
});

final giftSuggestionsProvider = NotifierProvider<GiftSuggestionsNotifier,
    AsyncValue<List<GiftSuggestion>>>(GiftSuggestionsNotifier.new);

class GiftSuggestionsNotifier
    extends Notifier<AsyncValue<List<GiftSuggestion>>> {
  @override
  AsyncValue<List<GiftSuggestion>> build() => const AsyncValue.data([]);

  Future<void> fetchSuggestions(Person person, {String country = 'AU'}) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(giftRepositoryProvider);
      final suggestions = await repository.getGiftSuggestions(person, country: country);
      state = AsyncValue.data(suggestions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data([]);
  }
}
