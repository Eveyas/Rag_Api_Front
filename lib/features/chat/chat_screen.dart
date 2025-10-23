import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_controller.dart';
import '../../core/theme_controller.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/input_bar.dart';
import '../../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot RAG'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: Icon(
              themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              themeController.toggleTheme();
            },
            tooltip: themeController.isDarkMode
                ? 'Cambiar a tema claro'
                : 'Cambiar a tema oscuro',
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              context.read<ChatController>().clearChat();
            },
            tooltip: 'Limpiar chat',
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatController>(
                builder: (context, controller, child) {
                  // Scroll al final cuando hay nuevos mensajes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  // Mostrar error
                  if (controller.error != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(controller.error!),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      controller.clearError();
                    });
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.messages.length +
                        (controller.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < controller.messages.length) {
                        final message = controller.messages[index];
                        return MessageBubble(
                          message: message,
                        );
                      } else {
                        return const TypingIndicator();
                      }
                    },
                  );
                },
              ),
            ),
            const InputBar(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
