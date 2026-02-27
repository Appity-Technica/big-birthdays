import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:big_birthdays/models/enums.dart';
import 'package:big_birthdays/models/gift_suggestion.dart';
import 'package:big_birthdays/models/person.dart';
import 'package:big_birthdays/providers/gift_provider.dart';
import 'package:big_birthdays/repositories/gift_repository.dart';

/// A fake [GiftRepository] that returns a canned list of suggestions
/// without calling Firebase Cloud Functions.
class FakeGiftRepository extends GiftRepository {
  final List<GiftSuggestion> _suggestions;
  final Duration _delay;
  final Object? _error;

  /// How many times [getGiftSuggestions] has been called.
  int callCount = 0;

  FakeGiftRepository({
    List<GiftSuggestion>? suggestions,
    Duration delay = Duration.zero,
    Object? error,
  })  : _suggestions = suggestions ?? [],
        _delay = delay,
        _error = error;

  @override
  Future<List<GiftSuggestion>> getGiftSuggestions(
    Person person, {
    String country = 'AU',
  }) async {
    callCount++;
    if (_delay > Duration.zero) {
      await Future<void>.delayed(_delay);
    }
    if (_error != null) {
      throw _error;
    }
    return _suggestions;
  }
}

Person _makePerson({
  String id = 'test-id',
  String name = 'Test Person',
  String dateOfBirth = '1990-06-15',
}) {
  return Person(
    id: id,
    name: name,
    dateOfBirth: dateOfBirth,
    relationship: Relationship.friend,
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
  );
}

void main() {
  // Set up Firebase core mocks and a fake handler for the Firebase Analytics
  // pigeon channel so that Analytics.logRequestGiftSuggestions() does not
  // throw during tests.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();

    // Register a no-op handler for the Firebase Analytics pigeon channel.
    // The channel name matches what the pigeon-generated code uses.
    const analyticsChannel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      StandardMessageCodec(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(analyticsChannel.name, (message) async {
      // Return an empty successful response (a list with a single null
      // element indicates success in pigeon).
      return analyticsChannel.codec.encodeMessage(<Object?>[null]);
    });
  });

  group('GiftSuggestionsNotifier', () {
    test('initial state is AsyncValue.data with empty list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(giftSuggestionsProvider);

      expect(state, isA<AsyncData<List<GiftSuggestion>>>());
      expect(state.value, isEmpty);
    });

    test('reset() returns state to empty data', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(giftSuggestionsProvider.notifier);

      // Call reset and verify state returns to empty.
      notifier.reset();

      final state = container.read(giftSuggestionsProvider);
      expect(state, isA<AsyncData<List<GiftSuggestion>>>());
      expect(state.value, isEmpty);
    });

    test('fetchSuggestions transitions to loading then data on success',
        () async {
      final fakeSuggestions = [
        const GiftSuggestion(
          name: 'Book',
          description: 'A great novel',
          estimatedPrice: '\$25',
          purchaseUrl: 'https://example.com/book',
        ),
        const GiftSuggestion(
          name: 'Headphones',
          description: 'Wireless headphones',
          estimatedPrice: '\$80',
          purchaseUrl: 'https://example.com/headphones',
        ),
      ];

      final fakeRepo = FakeGiftRepository(suggestions: fakeSuggestions);

      final container = ProviderContainer(
        overrides: [
          giftRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(giftSuggestionsProvider.notifier);
      final person = _makePerson();

      await notifier.fetchSuggestions(person);

      final state = container.read(giftSuggestionsProvider);
      expect(state, isA<AsyncData<List<GiftSuggestion>>>());
      expect(state.value, hasLength(2));
      expect(state.value![0].name, 'Book');
      expect(state.value![1].name, 'Headphones');
      expect(fakeRepo.callCount, 1);
    });

    test('fetchSuggestions transitions to error state on failure', () async {
      final fakeRepo = FakeGiftRepository(
        error: Exception('Network error'),
      );

      final container = ProviderContainer(
        overrides: [
          giftRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(giftSuggestionsProvider.notifier);
      final person = _makePerson();

      await notifier.fetchSuggestions(person);

      final state = container.read(giftSuggestionsProvider);
      expect(state, isA<AsyncError<List<GiftSuggestion>>>());
      expect(state.error, isA<Exception>());
      expect(fakeRepo.callCount, 1);
    });

    test('reset after fetchSuggestions clears results', () async {
      final fakeSuggestions = [
        const GiftSuggestion(
          name: 'Book',
          description: 'A novel',
          estimatedPrice: '\$20',
          purchaseUrl: 'https://example.com',
        ),
      ];

      final fakeRepo = FakeGiftRepository(suggestions: fakeSuggestions);

      final container = ProviderContainer(
        overrides: [
          giftRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(giftSuggestionsProvider.notifier);
      final person = _makePerson();

      await notifier.fetchSuggestions(person);

      // Verify we have data.
      var state = container.read(giftSuggestionsProvider);
      expect(state.value, hasLength(1));

      // Reset.
      notifier.reset();

      state = container.read(giftSuggestionsProvider);
      expect(state, isA<AsyncData<List<GiftSuggestion>>>());
      expect(state.value, isEmpty);
    });

    test('fetchSuggestions passes country parameter to repository', () async {
      String? capturedCountry;

      final fakeRepo = _CountryCapturingGiftRepository(
        onCall: (country) => capturedCountry = country,
      );

      final container = ProviderContainer(
        overrides: [
          giftRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(giftSuggestionsProvider.notifier);
      final person = _makePerson();

      await notifier.fetchSuggestions(person, country: 'GB');

      expect(capturedCountry, 'GB');
    });
  });
}

/// A fake repository that captures the country parameter.
class _CountryCapturingGiftRepository extends GiftRepository {
  final void Function(String country) onCall;

  _CountryCapturingGiftRepository({required this.onCall});

  @override
  Future<List<GiftSuggestion>> getGiftSuggestions(
    Person person, {
    String country = 'AU',
  }) async {
    onCall(country);
    return [];
  }
}
