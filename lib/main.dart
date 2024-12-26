import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<String?> _getUserRole(String uid) async {
    // Önce öğrenci koleksiyonunda ara
    final studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(uid)
        .get();

    if (studentDoc.exists) {
      return 'student';
    }

    // Öğrenci değilse mentor koleksiyonunda ara
    final mentorDoc = await FirebaseFirestore.instance
        .collection('mentors')
        .doc(uid)
        .get();

    if (mentorDoc.exists) {
      return 'mentor';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentorluk Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            // Kullanıcı giriş yapmışsa, rolünü kontrol et
            return FutureBuilder<String?>(
              future: _getUserRole(snapshot.data!.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Kullanıcı rolü ile birlikte HomeScreen'i döndür
                return HomeScreen(
                  userId: snapshot.data!.uid,
                  userRole: roleSnapshot.data,
                );
              },
            );
          }

          // Kullanıcı giriş yapmamışsa
          return const HomeScreen();
        },
      ),
    );
  }
}