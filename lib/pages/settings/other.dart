import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../l10n/app_localizations.dart';

class EggPage extends StatefulWidget {
  const EggPage({super.key});

  @override
  State<EggPage> createState() => _EggPageState();
}

class _EggPageState extends State<EggPage> {
  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOff();
  }

  final List<Map<String, dynamic>> _messages = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _insertMessage({'text': text, 'isUser': true});

    if (text == 'samuioto') {
      final t = AppLocalizations.of(context);
      _insertMessage({'text': t.secretMessageReceived, 'isUser': false});
    }

    _controller.clear();
  }

  void _insertMessage(Map<String, dynamic> message) {
    final index = _messages.length;
    _messages.add(message);
    _listKey.currentState?.insertItem(
      index,
      duration: const Duration(milliseconds: 300),
    );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    ScreenProtector.preventScreenshotOn();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.easterEggTitle),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              padding: const EdgeInsets.only(top: 16),
              key: _listKey,
              initialItemCount: _messages.length,
              itemBuilder: (context, index, animation) {
                final message = _messages[index];
                final isUser = message['isUser'];
                final text = message['text'];

                return FadeTransition(
                  opacity: animation,
                  child: Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.grey[300] : Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isUser ? Colors.black : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: t.typeMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: t.send,
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.send, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
