import 'package:flutter/material.dart';
import 'matches_screen.dart';

class MatchingPage extends StatelessWidget {
  final String studentId; // Öğrenci ID'si main.dart'tan geliyor

  MatchingPage({required this.studentId});

  // Mentör eşleştirme ekranına geçiş
  void navigateToMatchesScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchesScreen(studentId: studentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentörünü Bul'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => navigateToMatchesScreen(context),
          child: Text('Mentörünü Bul'),
        ),
      ),
    );
  }
}
