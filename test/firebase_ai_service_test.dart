import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/services/health_assistant_service.dart';

void main() {
  test(
    'Firebase assistant uses minimal question context and returns text',
    () async {
      String? prompt;
      final assistant = FirebaseHealthAssistantService(
        generate: (value) async {
          prompt = value;
          return 'Drink water regularly.';
        },
      );
      expect(
        await assistant.reply('How should I track water?'),
        'Drink water regularly.',
      );
      expect(prompt, contains('How should I track water?'));
      expect(prompt, isNot(contains('Firebase UID')));
    },
  );

  test('Firebase assistant handles empty and failed responses', () async {
    final empty = FirebaseHealthAssistantService(generate: (_) async => null);
    expect(await empty.reply('hello'), contains('try again'));
    final error = FirebaseHealthAssistantService(
      generate: (_) async => throw StateError('quota'),
    );
    expect(await error.reply('hello'), contains('temporarily unavailable'));
  });
}
