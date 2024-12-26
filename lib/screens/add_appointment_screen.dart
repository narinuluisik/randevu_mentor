import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({
    Key? key,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  final String userId;
  final String userRole;

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  Map<String, dynamic>? matchedMentor;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    fetchMatchedMentor();
  }

  Future<void> fetchMatchedMentor() async {
    try {
      final matchSnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('student.studentId', isEqualTo: widget.userId)
          .get();

      if (matchSnapshot.docs.isNotEmpty) {
        final matchData = matchSnapshot.docs.first.data();
        final mentorData = matchData['mentor'] as Map<String, dynamic>;
        setState(() {
          matchedMentor = {
            'mentorId': mentorData['mentorId'],
            'ad': mentorData['ad'],
            'soyad': mentorData['soyad'],
            'profileImageUrl': mentorData['profileImageUrl'],
            'uzmanlikAlani': mentorData['uzmanlikAlani'],
          };
        });
      }
    } catch (e) {
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mentör bilgileri alınırken bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Ekle'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (matchedMentor != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          matchedMentor!['profileImageUrl'] ?? 
                          'https://via.placeholder.com/150',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${matchedMentor!['ad']} ${matchedMentor!['soyad']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uzmanlık Alanı: ${matchedMentor!['uzmanlikAlani']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Randevu Tarihi Seçin',
                suffixIcon: Icon(Icons.calendar_today, color: Colors.purple),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              controller: TextEditingController(
                text: selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                    : '',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Randevu Saati Seçin',
                suffixIcon: Icon(Icons.access_time, color: Colors.purple),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
              controller: TextEditingController(
                text: selectedTime?.format(context) ?? '',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (selectedDate != null && selectedTime != null && matchedMentor != null) {
                  final appointmentDate = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  await FirebaseFirestore.instance.collection('Randevular').add({
                    'mentorId': matchedMentor!['mentorId'],
                    'studentId': widget.userId,
                    'appointmentDate': appointmentDate,
                    'status': 'Aktif',
                    'createdAt': DateTime.now().toIso8601String(),
                  });

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen tüm alanları doldurun'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Randevu Oluştur',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}