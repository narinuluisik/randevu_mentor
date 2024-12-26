import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MatchesScreen extends StatelessWidget {
  final String studentId;

  MatchesScreen({required this.studentId});

  Future<Map<String, dynamic>?> matchStudentWithMentor(String studentId) async {
    try {
      final studentDoc = await FirebaseFirestore.instance.collection('students').doc(studentId).get();

      if (!studentDoc.exists) {
        print("Öğrenci bulunamadı.");
        return null;
      }

      var studentData = studentDoc.data();
      if (studentData == null) {
        print("Öğrenci verisi boş.");
        return null;
      }

      var studentFields = studentData['ilgiliAlan'] is List
          ? List<String>.from(studentData['ilgiliAlan'])
          : [studentData['ilgiliAlan'].toString()];

      final mentorsSnapshot = await FirebaseFirestore.instance.collection('mentors').get();

      for (var mentorDoc in mentorsSnapshot.docs) {
        var mentorData = mentorDoc.data();

        var mentorFields = mentorData['uzmanlikAlani'] is List
            ? List<String>.from(mentorData['uzmanlikAlani'])
            : [mentorData['uzmanlikAlani'].toString()];

        var commonFields = studentFields.toSet().intersection(mentorFields.toSet());

        if (commonFields.isNotEmpty) {
          await FirebaseFirestore.instance.collection('matches').add({
            'studentId': studentId,
            'mentorId': mentorDoc.id,
            'commonFields': commonFields.toList(),
            'mentor': mentorData,
            'student': studentData,
            'timestamp': FieldValue.serverTimestamp(),
          });

          return {
            'mentor': mentorData,
            'commonFields': commonFields.toList(),
          };
        }
      }

      print("Uygun mentör bulunamadı.");
      return null;
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Eşleşmeler',
        style: TextStyle(color:Colors.white)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: matchStudentWithMentor(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final match = snapshot.data;
          if (match == null) {
            return Center(
              child: Text(
                'Eşleşen bir mentör bulunamadı.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final mentor = match['mentor'];
          final commonFields = match['commonFields'];

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık: Eşleşen Mentör
                Text(
                  'Eşleşen Mentör',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 20),
                // Mentör Bilgileri Kartı
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple[400]!, Colors.grey[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            mentor['profileImageUrl'] ?? 'https://via.placeholder.com/150',
                          ),
                          backgroundColor: Colors.grey[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          '${mentor['ad']} ${mentor['soyad']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          mentor['email'] ?? 'E-posta bilgisi yok',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Divider(color: Colors.white70),
                        SizedBox(height: 10),
                        Text(
                          'Uzmanlık Alanları:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          mentor['uzmanlikAlani'] is List
                              ? (mentor['uzmanlikAlani'] as List).join(', ')
                              : mentor['uzmanlikAlani'] ?? 'Bilinmiyor',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Ortak İlgi Alanları:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          commonFields.join(', '),
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
