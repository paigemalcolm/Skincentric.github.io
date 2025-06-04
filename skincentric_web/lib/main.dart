
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() => runApp(const SkincentricApp());

class SkincentricApp extends StatelessWidget {
  const SkincentricApp({super.key});

  @override
  Widget build(BuildContext context) {
    const nudeBg     = Color.fromARGB(255, 245, 236, 227);
    const nudePri    = Color.fromARGB(255, 99, 81, 67);
    const nudeAccent = Color.fromARGB(255, 58, 43, 28);

    return MaterialApp(
      title: 'Skincentric',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromARGB(255, 245, 236, 227),
          onPrimary: Color.fromARGB(255, 245, 236, 227),
          secondary: Color.fromARGB(255, 255, 145, 77),
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF3B2E25),
          error: Colors.red,
          onError: Colors.white,
          primaryContainer: Color(0xFFEADACF),
          onPrimaryContainer: Color(0xFF3B2E25),
          secondaryContainer: Color(0xFFE7D7D3),
          onSecondaryContainer: Color(0xFF3B2E25),
        ),
        scaffoldBackgroundColor: nudeBg,
      ),
      home: const HomePage(),
    );
  }
}
