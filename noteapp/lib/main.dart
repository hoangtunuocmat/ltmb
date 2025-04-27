import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/db/theme_provider.dart';
import 'view/NoteListScreen.dart'; // Adjust import based on your project structure
import 'view/LoginScreen.dart'; // Adjust import based on your project structure

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Note App',
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: LoginScreen(),
          debugShowCheckedModeBanner: false,// Assuming LoginScreen is the entry point
        );
      },
    );
  }
}