import 'package:flutter/material.dart';
import 'matches_screen.dart'; // Eşleşme ekranını içe aktarın

class MatchingPage extends StatefulWidget {
  @override
  _MatchingPageState createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  // Mentör bul butonuna basıldığında eşleşme ekranına geçiş yapılacak
  void navigateToMatchesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MatchesScreen()), // MatchesScreen'e geçiş yapılıyor
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
          onPressed: navigateToMatchesScreen,
          child: Text('Mentörünü Bul'),
        ),
      ),
    );
  }
}
