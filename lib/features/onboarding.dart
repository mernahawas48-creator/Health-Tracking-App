import 'package:flutter/material.dart';
import 'package:meditrack/features/onboarding_view.dart';
import 'package:meditrack/l10n/app_strings.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/themes/appcolors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final settingsController = AppSettingsScope.of(context);

    return Scaffold(
      backgroundColor: Appcolors.White,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: PopupMenuButton<String>(
                tooltip: strings.text('language'),
                onSelected: (languageCode) => settingsController.update(
                  settingsController.settings.copyWith(
                    languageCode: languageCode,
                  ),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'en',
                    child: Text(strings.text('english')),
                  ),
                  PopupMenuItem(
                    value: 'ar',
                    child: Text(strings.text('arabic')),
                  ),
                ],
                child: Container(
                  margin: const EdgeInsetsDirectional.only(top: 8, end: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffE3F7F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        color: Appcolors.Primary,
                        size: 19,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        strings.isArabic
                            ? strings.text('arabic')
                            : strings.text('english'),
                        style: const TextStyle(
                          color: Appcolors.Primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  OnboardingView(
                    image: 'assets/images/onboarding1.png',
                    title: strings.text('onboarding1Title'),
                    description: strings.text('onboarding1Description'),
                  ),
                  OnboardingView(
                    image: 'assets/images/onboarding2.png',
                    title: strings.text('onboarding2Title'),
                    description: strings.text('onboarding2Description'),
                  ),
                  OnboardingView(
                    image: 'assets/images/onboarding3.png',
                    title: strings.text('onboarding3Title'),
                    description: strings.text('onboarding3Description'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      strings.text('skip'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Appcolors.Primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 25 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Appcolors.Primary
                              : Appcolors.Grey2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolors.Primary,
                      foregroundColor: Appcolors.White,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(
                      _currentPage == 2
                          ? strings.text('getStarted')
                          : strings.text('next'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
