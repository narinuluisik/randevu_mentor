import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:randevu_1/screens/appointment_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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

class HomePage extends StatelessWidget {
  final String ogrenciId;

  HomePage({required this.ogrenciId});

  @override
  Widget build(BuildContext context) {
    return RandevularimPage(ogrenciId: ogrenciId);
  }
}
