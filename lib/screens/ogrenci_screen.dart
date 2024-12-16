import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentFormPage extends StatefulWidget {
  final String studentId;

  StudentFormPage({required this.studentId});

  @override
  _StudentFormPageState createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final TextEditingController adController = TextEditingController();
  final TextEditingController soyadController = TextEditingController();
  final TextEditingController tcKimlikController = TextEditingController();
  final TextEditingController sifreController = TextEditingController();
  final TextEditingController epostaController = TextEditingController();
  final TextEditingController telefonController = TextEditingController();
  final TextEditingController adresController = TextEditingController();
  final TextEditingController dogumTarihiController = TextEditingController();
  final TextEditingController profileImageUrlController = TextEditingController();

  String? selectedSinif = 'Belirtilmedi';
  String? selectedUniversite = 'Belirtilmedi';
  String? selectedBolum = 'Belirtilmedi';
  String? selectedIlgiliAlan = 'Belirtilmedi';
  bool mezuniyetBilgisi = false;

  final firestoreRef = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    firestoreRef.collection("students").doc(widget.studentId).get().then((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        adController.text = data['ad'] ?? '';
        soyadController.text = data['soyad'] ?? '';
        tcKimlikController.text = data['tc_kimlik'] ?? '';
        sifreController.text = data['sifre'] ?? '';
        epostaController.text = data['eposta'] ?? '';
        telefonController.text = data['telefon'] ?? '';
        adresController.text = data['adres'] ?? '';
        dogumTarihiController.text = data['dogum_tarihi'] ?? '';
        profileImageUrlController.text = data['profileImageUrl'] ?? '';

        setState(() {
          selectedSinif = data['sinif'] ?? 'Belirtilmedi';
          selectedUniversite = data['universite'] ?? 'Belirtilmedi';
          selectedBolum = data['bolum'] ?? 'Belirtilmedi';
          mezuniyetBilgisi = data['mezuniyet_bilgisi'] ?? false;
          selectedIlgiliAlan = data['ilgiliAlan'] ?? 'Belirtilmedi';
        });
      }
    });
  }

  void saveData() {
    if (adController.text.isNotEmpty && soyadController.text.isNotEmpty) {
      firestoreRef.collection("students").doc(widget.studentId).get().then((snapshot) {
        final studentData = {
          'ad': adController.text,
          'soyad': soyadController.text,
          'tc_kimlik': tcKimlikController.text,
          'sifre': sifreController.text,
          'eposta': epostaController.text,
          'telefon': telefonController.text,
          'adres': adresController.text,
          'dogum_tarihi': dogumTarihiController.text,
          'sinif': selectedSinif,
          'universite': selectedUniversite,
          'bolum': selectedBolum,
          'mezuniyet_bilgisi': mezuniyetBilgisi,
          'profileImageUrl': profileImageUrlController.text,
          'ilgiliAlan': selectedIlgiliAlan,
        };

        if (snapshot.exists) {
          firestoreRef.collection("students").doc(widget.studentId).update(studentData).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veri başarıyla güncellendi.')));
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $error')));
          });
        } else {
          firestoreRef.collection("students").doc(widget.studentId).set(studentData).then((_) {
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
        title: Text('Öğrenci Bilgilerini Düzenle'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Öğrenci Bilgilerini Düzenleyiniz', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            _buildTextField(adController, 'Ad'),
            _buildTextField(soyadController, 'Soyad'),
            _buildTextField(tcKimlikController, 'T.C. Kimlik No', TextInputType.number),
            _buildTextField(sifreController, 'Şifre'),
            _buildTextField(epostaController, 'E-posta', TextInputType.emailAddress),
            _buildTextField(telefonController, 'Telefon', TextInputType.phone),
            _buildTextField(adresController, 'Adres'),
            _buildTextField(dogumTarihiController, 'Doğum Tarihi (DD/AA/YYYY)', TextInputType.datetime),
            _buildTextField(profileImageUrlController, 'Profil Fotoğrafı URL\'si'),
            _buildDropdown(
              selectedSinif,
              'Sınıf',
              ['Belirtilmedi', '1. Sınıf', '2. Sınıf', '3. Sınıf', '4. Sınıf'],
                  (value) => setState(() => selectedSinif = value),
            ),
            _buildDropdown(
              selectedUniversite,
              'Üniversite',
              ['Belirtilmedi', 'Üniversite A', 'Üniversite B', 'Üniversite C'],
                  (value) => setState(() => selectedUniversite = value),
            ),
            _buildDropdown(
              selectedBolum,
              'Bölüm',
              ['Belirtilmedi', 'Bilgisayar Mühendisliği', 'Elektrik-Elektronik', 'Makine Mühendisliği'],
                  (value) => setState(() => selectedBolum = value),
            ),
            _buildDropdown(
              selectedIlgiliAlan,
              'İlgili Alan',
              ['Belirtilmedi', 'Web', 'Mobil', 'Veri', 'Oyun'],
                  (value) => setState(() => selectedIlgiliAlan = value),
            ),
            CheckboxListTile(
              title: Text('Mezuniyet Bilgisi'),
              value: mezuniyetBilgisi,
              onChanged: (value) {
                setState(() {
                  mezuniyetBilgisi = value!;
                });
              },
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