import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:randevu_1/screens/appointment_screen.dart';
import 'package:randevu_1/screens/matches_screen.dart';
import 'package:randevu_1/screens/matching_page.dart';
import 'package:randevu_1/screens/mentor_screen.dart';
import 'package:randevu_1/screens/ogrenci_screen.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:randevu_1/screens/matches_screen.dart'; // Eşleşme ekranını içe aktarın.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:randevu_1/screens/matching_page.dart'; // Mentörünü Bul sayfasını içe aktarın

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentör Eşleştirme Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MatchingPage(), // Ana sayfa olarak MatchingPage kullanılıyor
    );
  }
}






/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase'i başlatıyoruz.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mentör Bilgi Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MentorFormPage(mentorId: 'TE7HDj3cKnOAhHASLTHM',), // Burayı MentorFormPage olarak değiştiriyoruz.
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mentör Bilgi Sistemi',
      home: StudentFormPage(studentId: 'RfpdBmrILPKgeEpBNA1Q',),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Randevu Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(ogrenciId: 'ogrenci123'),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug bannerını kaldırır.
      title: 'Mentör Öğrenci Randevu Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RandevularimPage(ogrenciId: 'ogrenciId',),
    );
  }
}
*/