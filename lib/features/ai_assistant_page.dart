import 'package:flutter/material.dart';
import 'package:meditrack/services/health_assistant_service.dart';
import 'package:meditrack/themes/appcolors.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});
  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final _input = TextEditingController();
  final _assistant = LocalHealthAssistantService();
  final _messages = <_Message>[
    const _Message('Hi! I can help with healthy habits and app tracking.', false),
  ];
  bool _waiting = false;

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
  void dispose() { _input.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Health Assistant')),
    body: Column(children: [
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length + (_waiting ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length) return const Padding(padding: EdgeInsets.all(8), child: Align(alignment: Alignment.centerLeft, child: CircularProgressIndicator()));
          final item = _messages[index];
          return Align(
            alignment: item.user ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxWidth: 310),
              decoration: BoxDecoration(color: item.user ? Appcolors.Primary : const Color(0xffE3F7F8), borderRadius: BorderRadius.circular(16)),
              child: Text(item.text, style: TextStyle(color: item.user ? Colors.white : Appcolors.Black2)),
            ),
          );
        },
      )),
      SafeArea(child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(child: TextField(controller: _input, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Ask about water, sleep, medication…'))),
          IconButton(onPressed: _send, icon: const Icon(Icons.send, color: Appcolors.Primary)),
        ]),
      )),
    ]),
  );
}

class _Message { const _Message(this.text, this.user); final String text; final bool user; }
