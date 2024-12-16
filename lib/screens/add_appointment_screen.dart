import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddAppointmentScreen extends StatefulWidget {
  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  List<Map<String, dynamic>> matchedMentors = [];
  String? selectedMentorId;
  String? selectedMentorName;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    fetchMatchedMentors();
  }

  // Mentörleri al
  Future<void> fetchMatchedMentors() async {
    try {
      final matchesSnapshot = await FirebaseFirestore.instance.collection('matches').get();
      setState(() {
        matchedMentors = matchesSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'mentorId': data['mentor']?['mentorId'],
            'mentorName': data['mentor']?['name'],
          };
        }).where((mentor) => mentor['mentorId'] != null && mentor['mentorName'] != null).toList();
      });
    } catch (e) {
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mentörler alınırken bir hata oluştu: $e')),
      );
    }
  }

  // Randevu ekle
  Future<void> addAppointment() async {
    if (selectedMentorId == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    try {
      // Tarih ve saati birleştiriyoruz
      DateTime appointmentDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('Randevular').add({
        'mentorId': selectedMentorId,
        'mentorName': selectedMentorName,
        'appointmentDate': appointmentDateTime,
        'createdAt': DateTime.now().toIso8601String(),
        'studentId': 'ogrenciId', // Öğrenci ID'si
        'status': 'Aktif', // Randevu durumu
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Randevu başarıyla eklendi')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Randevu ekleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Randevu eklenirken bir hata oluştu: $e')),
      );
    }
  }

  // Saat seçici
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Randevu Ekle'),
        centerTitle: true,
      ),
      body: matchedMentors.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Mentör seçimi
            DropdownButton<String>(
              isExpanded: true,
              hint: Text('Mentör Seçin'),
              value: selectedMentorId,
              items: matchedMentors.map((mentor) {
                return DropdownMenuItem<String>(
                  value: mentor['mentorId'],
                  child: Text(mentor['mentorName']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMentorId = value;
                  selectedMentorName = matchedMentors
                      .firstWhere((mentor) => mentor['mentorId'] == value)['mentorName'];
                });
              },
            ),
            SizedBox(height: 16),

            // Tarih seçimi
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Randevu Tarihi Seçin',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
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
            SizedBox(height: 16),

            // Saat seçimi
            Row(
              children: [
                Text(
                  selectedTime == null
                      ? 'Saat Seçin'
                      : selectedTime!.format(context),
                ),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _selectTime(context),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Randevu ekle butonu
            ElevatedButton(
              onPressed: addAppointment,
              child: Text('Randevu Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
