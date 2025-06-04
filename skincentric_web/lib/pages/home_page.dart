import 'package:flutter/material.dart';
import 'quiz_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Skincentric',
                textAlign: TextAlign.center,
                style: t.displaySmall!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Skincare for all',
                textAlign: TextAlign.center, style: t.titleMedium),
            const SizedBox(height: 32),
            Text(
              'We invite you to take the SPM-6 Quiz.\n'
              'Unlike current skin-typing systems, the SPM-6 Quiz is based on the latest research and provides a more accurate understanding of your skin type. '
              'Knowing your skin type is crucial for effective skincare, as it helps you choose the right products and routines tailored to your unique needs.',
              textAlign: TextAlign.center,
              style: t.titleMedium,
            ),
            const SizedBox(height: 48),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondary, // button fill
                  foregroundColor:
                      Theme.of(context).colorScheme.surface, // text / icon
                ),
                onPressed: () => Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const QuizPage(),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                  ),
                ),
                child: const Text('Take the SPM-6 Quiz',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
