import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/app/app.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'local_signed_in': true,
    });
    setupDependencies();
  });

  testWidgets('Health app starts', (tester) async {
    final settingsController = await AppSettingsController.load();

    await tester.pumpWidget(HealthApp(settingsController: settingsController));
    await tester.pumpAndSettle();

    expect(find.text('Welcome 👋'), findsOneWidget);
  });
}
