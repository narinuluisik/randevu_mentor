import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String userRole;

  const ProfileScreen({
    Key? key,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(widget.userRole == 'mentor' ? 'mentors' : 'students')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    } catch (e) {
      print('Kullanıcı bilgileri yüklenirken hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen(userId: '', userRole: '',)),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${userData!['ad']} ${userData!['soyad']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.userRole == 'mentor' ? 'Mentor' : 'Öğrenci',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard('E-posta', userData!['email']),
                  _buildInfoCard('Telefon', userData!['telefon'] ?? 'Belirtilmemiş'),
                  if (widget.userRole == 'mentor') ...[
                    _buildInfoCard('Uzmanlık', userData!['uzmanlik'] ?? 'Belirtilmemiş'),
                    _buildInfoCard('Deneyim', userData!['deneyim'] ?? 'Belirtilmemiş'),
                  ],
                  if (widget.userRole == 'student') ...[
                    _buildInfoCard('Eğitim', userData!['egitim'] ?? 'Belirtilmemiş'),
                    _buildInfoCard('İlgi Alanları', userData!['ilgiAlanlari']?.join(', ') ?? 'Belirtilmemiş'),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 