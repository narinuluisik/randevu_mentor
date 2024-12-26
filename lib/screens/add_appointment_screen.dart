import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddAppointmentScreen extends StatefulWidget {
  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  Map<String, dynamic>? matchedMentor;  // Eşleşen mentör bilgileri
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    fetchMatchedMentor();
  }

  // Eşleşen mentörü al
  Future<void> fetchMatchedMentor() async {
    try {
      // Burada eşleşen mentörün bilgilerini alıyoruz (örneğin, ilk eşleşeni alabiliriz)
      final matchesSnapshot = await FirebaseFirestore.instance.collection('matches').limit(1).get();
      if (matchesSnapshot.docs.isNotEmpty) {
        final mentorData = matchesSnapshot.docs.first.data();
        setState(() {
          matchedMentor = {
            'mentorId': mentorData['mentor']?['mentorId'],
            'ad': mentorData['mentor']?['ad'],
            'soyad': mentorData['mentor']?['soyad'],
            'mentorBio': mentorData['mentor']?['bio'],  // Mentör biyografisi
            'uzmanlikAlani': mentorData['mentor']?['uzmanlikAlani'],  // Mentör uzmanlık alanı
            'sektor': mentorData['mentor']?['sektor'],  // Mentör sektör
            'profileImageUrl': mentorData['mentor']?['profileImageUrl'],  // Mentör fotoğrafı
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

  // Randevu ekle
  Future<void> addAppointment() async {
    if (matchedMentor == null || selectedDate == null || selectedTime == null) {
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
        'mentorId': matchedMentor!['mentorId'],
        'ad': matchedMentor!['ad'],
        'soyad': matchedMentor!['soyad'],
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
        title: Text('Randevu Ekle', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.purple, // Mor tonları
      ),
      body: matchedMentor == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Mentör bilgileri Card içinde
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.grey[100], // Gri tonları
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mentör fotoğrafı
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: matchedMentor!['profileImageUrl'] != null
                          ? NetworkImage(matchedMentor!['profileImageUrl'])
                          : AssetImage('assets/default_avatar.png') as ImageProvider,
                    ),
                    SizedBox(height: 16),
                    // Mentörün adı
                  Text(
                    '${matchedMentor!['ad']} ${matchedMentor!['soyad']}',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purple),
                  ),


                    SizedBox(height: 8),

                    // Sektör ve Uzmanlık Alanı Yan Yana
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Sektör
                        Column(
                          children: [
                            Text(
                              'Sektör:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                            Text(
                              matchedMentor!['sektor'] ?? 'Mentörün sektörü bulunmamaktadır.',
                              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        SizedBox(width: 30),  // Aralarındaki boşluk
                        // Uzmanlık Alanı
                        Column(
                          children: [
                            Text(
                              'Uzmanlık Alanı:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                            Text(
                              matchedMentor!['uzmanlikAlani'] ?? 'Mentörün uzmanlık alanı bulunmamaktadır.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Tarih seçimi
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Randevu Tarihi Seçin',
                suffixIcon: Icon(Icons.calendar_today, color: Colors.purple),
                border: OutlineInputBorder(),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTime == null
                      ? 'Saat Seçin'
                      : selectedTime!.format(context),
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.access_time, color: Colors.purple),
                  onPressed: () => _selectTime(context),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Randevu ekle butonu
            ElevatedButton(
              onPressed: addAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, // Button color
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
              child: Text(
                'Randevu Ekle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
