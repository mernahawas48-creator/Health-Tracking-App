import 'package:firebase_ai/firebase_ai.dart';

abstract class HealthAssistantService {
  Future<String> reply(String message);
}

class FirebaseHealthAssistantService implements HealthAssistantService {
  FirebaseHealthAssistantService({Future<String?> Function(String)? generate})
    : _generate = generate ?? _generateWithFirebase;

  final Future<String?> Function(String) _generate;

  static Future<String?> _generateWithFirebase(String prompt) async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash',
    );
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text;
  }

  @override
  Future<String> reply(String message) async {
    try {
      final answer = await _generate(
        'You are a concise health and wellness assistant in a tracking app. '
        'Answer in the language of the user message. Provide app and general wellness guidance. '
        'Do not diagnose, prescribe, or claim to replace a clinician. '
        'For urgent symptoms, advise emergency care. Do not ask for sensitive identifiers. '
        'User message: ${message.trim()}',
      );
      if (answer == null || answer.trim().isEmpty) {
        return 'I could not generate a response. Please try again.';
      }
      return answer.trim();
    } catch (_) {
      return 'The assistant is temporarily unavailable. Check your connection and try again.';
    }
  }
}

/// Local development assistant. Swap this with a privacy-approved API provider later.
class LocalHealthAssistantService implements HealthAssistantService {
  @override
  Future<String> reply(String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final text = message.toLowerCase();
    if (text.contains('water'))
      return 'Small, regular sips are easier to maintain. Check your Water Tracking card to log your next glass.';
    if (text.contains('sleep'))
      return 'A consistent bedtime and a calm wind-down routine can support healthy sleep. Your sleep tracker can help you keep a routine.';
    if (text.contains('medicine') || text.contains('medication'))
      return 'Use your medication schedule and follow the instructions from your doctor or pharmacist. I cannot replace medical advice.';
    return 'I can help you understand your app data, build healthy habits, and prepare questions for a healthcare professional. What would you like to work on?';
  }
}
