import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MentorFormPage extends StatefulWidget {
  final String mentorId;

  MentorFormPage({required this.mentorId});

  @override
  _MentorFormPageState createState() => _MentorFormPageState();
}

class _MentorFormPageState extends State<MentorFormPage> {
  final TextEditingController adController = TextEditingController();
  final TextEditingController soyadController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sifreController = TextEditingController();
  final TextEditingController telefonController = TextEditingController();
  final TextEditingController adresController = TextEditingController();
  final TextEditingController dogumTarihiController = TextEditingController();
  final TextEditingController profileImageUrlController = TextEditingController();

  String? selectedBolum = 'Belirtilmedi';
  String? selectedSektor = 'Belirtilmedi';
  String? selectedUniversite = 'Belirtilmedi';
  String? selectedDeneyim = 'Belirtilmedi';
  String? selectedUzmanlikAlani = 'Belirtilmedi';

  final firestoreRef = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    firestoreRef.collection("mentors").doc(widget.mentorId).get().then((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        adController.text = data['ad'] ?? '';
        soyadController.text = data['soyad'] ?? '';
        emailController.text = data['email'] ?? '';
        sifreController.text = data['sifre'] ?? '';
        telefonController.text = data['telefon'] ?? '';
        adresController.text = data['adres'] ?? '';
        dogumTarihiController.text = data['dogum_tarihi'] ?? '';
        profileImageUrlController.text = data['profileImageUrl'] ?? '';

        setState(() {
          selectedBolum = data['bolum'] ?? 'Belirtilmedi';
          selectedSektor = data['sektor'] ?? 'Belirtilmedi';
          selectedUniversite = data['universite'] ?? 'Belirtilmedi';
          selectedDeneyim = data['deneyim'] ?? 'Belirtilmedi';
          selectedUzmanlikAlani = data['uzmanlikAlani'] ?? 'Belirtilmedi';


        });
      }
    });
  }

  void saveData() {
    if (adController.text.isNotEmpty && soyadController.text.isNotEmpty) {
      firestoreRef.collection("mentors").doc(widget.mentorId).get().then((snapshot) {
        final mentorData = {
          'ad': adController.text,
          'soyad': soyadController.text,
          'email': emailController.text,
          'sifre': sifreController.text,
          'telefon': telefonController.text,
          'adres': adresController.text,
          'dogum_tarihi': dogumTarihiController.text,
          'bolum': selectedBolum,
          'sektor': selectedSektor,
          'universite': selectedUniversite,
          'deneyim': selectedDeneyim,
          'uzmanlikAlani': selectedUzmanlikAlani,
          'profileImageUrl': profileImageUrlController.text,
        };

        if (snapshot.exists) {
          firestoreRef.collection("mentors").doc(widget.mentorId).update(mentorData).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veri başarıyla güncellendi.')));
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $error')));
          });
        } else {
          firestoreRef.collection("mentors").doc(widget.mentorId).set(mentorData).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veri başarıyla kaydedildi.')));
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $error')));
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ad ve Soyad alanları zorunludur!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentör Bilgilerini Düzenle'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mentör Bilgilerini Düzenleyiniz', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            _buildTextField(adController, 'Ad'),
            _buildTextField(soyadController, 'Soyad'),
            _buildTextField(emailController, 'E-posta', TextInputType.emailAddress),
            _buildTextField(sifreController, 'Şifre'),
            _buildTextField(telefonController, 'Telefon', TextInputType.phone),
            _buildTextField(adresController, 'Adres'),
            _buildTextField(dogumTarihiController, 'Doğum Tarihi (DD/AA/YYYY)', TextInputType.datetime),
            _buildTextField(profileImageUrlController, 'Profil Fotoğrafı URL\'si'),
              _buildDropdown(
              selectedBolum,
              'Bölüm',
              ['Belirtilmedi', 'Bilgisayar Mühendisliği', 'Elektrik-Elektronik', 'Makine Mühendisliği'],
                  (value) => setState(() => selectedBolum = value),
            ),
            _buildDropdown(
              selectedSektor,
              'Sektör',
              ['Belirtilmedi', 'Web', 'Mobil', 'Veri', 'Oyun'],
                  (value) => setState(() => selectedSektor = value),
            ),
            _buildDropdown(
              selectedUniversite,
              'Üniversite',
              ['Belirtilmedi', 'Üniversite A', 'Üniversite B', 'Üniversite C'],
                  (value) => setState(() => selectedUniversite = value),
            ),
            _buildDropdown(
              selectedDeneyim,
              'Deneyim',
              ['Belirtilmedi', 'Yeni Mezun', 'Orta Seviye', 'Uzman'],
                  (value) => setState(() => selectedDeneyim = value),
            ),
            _buildDropdown(
              selectedUzmanlikAlani,
              'UzmanlikAlani',
              ['Belirtilmedi', 'web', 'mobil', 'oyun'],
                  (value) => setState(() => selectedUzmanlikAlani = value),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: saveData,
                child: Text('Kaydet ve Güncelle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType keyboardType = TextInputType.text, bool obscureText = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildDropdown(String? selectedValue, String label, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        value: selectedValue,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
