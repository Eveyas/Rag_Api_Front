import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/theme_controller.dart';
import 'features/chat/chat_controller.dart';
import 'features/chat/chat_screen.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeController(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatController(
            apiClient: context.read<ApiClient>(),
          ),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            title: 'RAG Chatbot',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              useMaterial3: true,
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                secondary: Colors.blueAccent,
                background: Colors.grey[50]!,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              scaffoldBackgroundColor: Colors.grey[50],
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.zero,
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
              useMaterial3: true,
              colorScheme: ColorScheme.dark(
                primary: Colors.blue[300]!,
                secondary: Colors.blueAccent[200]!,
                background: Colors.grey[900]!,
                surface: Colors.grey[800]!,
                onSurface: Colors.white70,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              scaffoldBackgroundColor: Colors.grey[900],
              cardTheme: CardThemeData(
                color: Colors.grey[800],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.zero,
              ),
            ),
            themeMode: themeController.themeMode,
            home: const ChatScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
