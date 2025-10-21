import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ChatScreen());
  }
}
