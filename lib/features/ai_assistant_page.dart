import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/services/health_assistant_service.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});
  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final _input = TextEditingController();
  final HealthAssistantService _assistant = getIt<HealthAssistantService>();
  final _messages = <_Message>[
    const _Message(
      'Hi! I can help with healthy habits and app tracking.',
      false,
    ),
  ];
  bool _waiting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.length == 1 && !_messages.first.user) {
      final arabic = AppStrings.of(context).isArabic;
      _messages[0] = _Message(
        arabic
            ? 'مرحبًا! يمكنني مساعدتك في العادات الصحية ومتابعة بيانات التطبيق.'
            : 'Hi! I can help with healthy habits and app tracking.',
        false,
      );
    }
  }

  Future<void> _send() async {
    final question = _input.text.trim();
    if (question.isEmpty || _waiting) return;
    setState(() {
      _messages.add(_Message(question, true));
      _waiting = true;
    });
    _input.clear();
    final answer = await _assistant.reply(question);
    if (!mounted) return;
    setState(() {
      _messages.add(_Message(answer, false));
      _waiting = false;
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        AppStrings.of(context).isArabic ? 'المساعد الصحي' : 'Health Assistant',
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_waiting ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length)
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CircularProgressIndicator(),
                  ),
                );
              final item = _messages[index];
              return Align(
                alignment: item.user
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 310),
                  decoration: BoxDecoration(
                    color: item.user
                        ? Appcolors.Primary
                        : context.appMutedSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item.text,
                    style: TextStyle(
                      color: item.user ? context.appOnPrimary : context.appText,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: AppStrings.of(context).isArabic
                          ? 'اسأل عن الماء أو النوم أو الأدوية…'
                          : 'Ask about water, sleep, medication…',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: Icon(Icons.send, color: Appcolors.Primary),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Message {
  const _Message(this.text, this.user);
  final String text;
  final bool user;
}
