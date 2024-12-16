import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:randevu_1/screens/add_appointment_screen.dart';

Future<List<Map<String, dynamic>>> matchStudentsWithMentors() async {
  List<Map<String, dynamic>> matches = [];
  final studentsSnapshot = await FirebaseFirestore.instance.collection('students').get();
  final mentorsSnapshot = await FirebaseFirestore.instance.collection('mentors').get();

  for (var student in studentsSnapshot.docs) {
    var studentData = student.data();
    var studentFields = studentData['ilgiliAlan'] is List
        ? List<String>.from(studentData['ilgiliAlan'])
        : [studentData['ilgiliAlan'].toString()];

    for (var mentor in mentorsSnapshot.docs) {
      var mentorData = mentor.data();
      var mentorFields = mentorData['uzmanlikAlani'] is List
          ? List<String>.from(mentorData['uzmanlikAlani'])
          : [mentorData['uzmanlikAlani'].toString()];

      var commonFields = studentFields.toSet().intersection(mentorFields.toSet());
      if (commonFields.isNotEmpty) {
        matches.add({
          'student': studentData,
          'mentor': mentorData,
          'commonFields': commonFields.toList(),
        });
      }
    }
  }
  return matches;
}

class MatchesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eşleşmeler'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: matchStudentsWithMentors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final matches = snapshot.data ?? [];
          if (matches.isEmpty) {
            return Center(
              child: Text(
                'Henüz bir eşleşme bulunamadı.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: matches.length,
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final match = matches[index];
              final student = match['student'];
              final mentor = match['mentor'];
              final commonFields = match['commonFields'];

              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mentör Adı: ${mentor['name']} ${mentor['surname']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'E-posta: ${mentor['email']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Uzmanlık Alanları: ${mentor['uzmanlikAlani'] is List ? (mentor['uzmanlikAlani'] as List).join(', ') : mentor['uzmanlikAlani']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Deneyim: ${mentor['deneyim'] ?? 'Bilinmiyor'} yıl',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Divider(color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Ortak İlgi Alanları: ${commonFields.join(', ')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.blueGrey,
                        ),
                      ),

                ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
