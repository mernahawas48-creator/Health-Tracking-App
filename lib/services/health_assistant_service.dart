abstract class HealthAssistantService {
  Future<String> reply(String message);
}

/// Local development assistant. Swap this with a privacy-approved API provider later.
class LocalHealthAssistantService implements HealthAssistantService {
  @override
  Future<String> reply(String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final text = message.toLowerCase();
    if (text.contains('water')) return 'Small, regular sips are easier to maintain. Check your Water Tracking card to log your next glass.';
    if (text.contains('sleep')) return 'A consistent bedtime and a calm wind-down routine can support healthy sleep. Your sleep tracker can help you keep a routine.';
    if (text.contains('medicine') || text.contains('medication')) return 'Use your medication schedule and follow the instructions from your doctor or pharmacist. I cannot replace medical advice.';
    return 'I can help you understand your app data, build healthy habits, and prepare questions for a healthcare professional. What would you like to work on?';
  }
}
