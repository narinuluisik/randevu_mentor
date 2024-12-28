import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfileEditScreen extends StatefulWidget {
  final String studentId;

  const StudentProfileEditScreen({required this.studentId, Key? key}) : super(key: key);

  @override
  _StudentProfileEditScreenState createState() => _StudentProfileEditScreenState();
}

class _StudentProfileEditScreenState extends State<StudentProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _epostaController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _dogumTarihiController = TextEditingController();
  final TextEditingController _adresController = TextEditingController();
  final TextEditingController _bolumController = TextEditingController();
  final TextEditingController _universiteController = TextEditingController();
  final TextEditingController _sinifController = TextEditingController();
  String _selectedIlgiliAlan = 'Seçiniz';

  final List<String> _ilgiliAlanlar = ['Seçiniz', 'Web', 'Mobil', 'Veri', 'Oyun'];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(widget.studentId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _adController.text = data['ad'] ?? '';
        _soyadController.text = data['soyad'] ?? '';
        _epostaController.text = data['eposta'] ?? '';
        _telefonController.text = data['telefon'] ?? '';
        _dogumTarihiController.text = data['dogum_tarihi'] ?? '';
        _adresController.text = data['adres'] ?? '';
        _bolumController.text = data['bolum'] ?? '';
        _universiteController.text = data['universite'] ?? '';
        _sinifController.text = data['sinif'] ?? '';
        _selectedIlgiliAlan = data['ilgiliAlan'] ?? 'Seçiniz';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dogumTarihiController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(widget.studentId)
            .update({
          'ad': _adController.text,
          'soyad': _soyadController.text,
          'eposta': _epostaController.text,
          'telefon': _telefonController.text,
          'dogum_tarihi': _dogumTarihiController.text,
          'adres': _adresController.text,
          'bolum': _bolumController.text,
          'universite': _universiteController.text,
          'sinif': _sinifController.text,
          'ilgiliAlan': _selectedIlgiliAlan,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bilgiler başarıyla güncellendi')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        backgroundColor: Colors.purple.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_adController, 'Ad'),
              const SizedBox(height: 16),
              _buildTextField(_soyadController, 'Soyad'),
              const SizedBox(height: 16),
              _buildTextField(_epostaController, 'E-posta', TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(_telefonController, 'Telefon', TextInputType.phone),
              const SizedBox(height: 16),
              // Doğum Tarihi Seçici
              TextFormField(
                controller: _dogumTarihiController,
                decoration: InputDecoration(
                  labelText: 'Doğum Tarihi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Doğum tarihi zorunludur';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(_adresController, 'Adres', TextInputType.multiline, 3),
              const SizedBox(height: 16),
              _buildTextField(_bolumController, 'Bölüm'),
              const SizedBox(height: 16),
              _buildTextField(_universiteController, 'Üniversite'),
              const SizedBox(height: 16),
              _buildTextField(_sinifController, 'Sınıf'),
              const SizedBox(height: 16),
              // İlgili Alan Dropdown
              DropdownButtonFormField<String>(
                value: _selectedIlgiliAlan,
                decoration: InputDecoration(
                  labelText: 'İlgili Alan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _ilgiliAlanlar.map((String alan) {
                  return DropdownMenuItem<String>(
                    value: alan,
                    child: Text(alan),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedIlgiliAlan = newValue!;
                  });
                },
                validator: (value) {
                  if (value == 'Seçiniz') {
                    return 'Lütfen bir alan seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.purple.shade700),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label alanı zorunludur';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _epostaController.dispose();
    _telefonController.dispose();
    _dogumTarihiController.dispose();
    _adresController.dispose();
    _bolumController.dispose();
    _universiteController.dispose();
    _sinifController.dispose();
    super.dispose();
  }
} 