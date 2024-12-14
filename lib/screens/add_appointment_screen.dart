import 'package:flutter/material.dart';
import 'package:randevu_1/services/randevu_service.dart';
import 'package:randevu_1/model/appointment_model.dart';

class RandevuEklePage extends StatefulWidget {
  final String ogrenciId;

  RandevuEklePage({required this.ogrenciId});

  @override
  _RandevuEklePageState createState() => _RandevuEklePageState();
}

class _RandevuEklePageState extends State<RandevuEklePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? mentorId;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addRandevu() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lütfen tarih seçin')),
        );
        return;
      }

      Randevu randevu = Randevu(
        ogrenciId: widget.ogrenciId,
        mentorId: mentorId!,
        tarih: _selectedDate!,
        randevuDurum: 'Aktif',
      );

      await RandevuService().addRandevu(randevu);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Randevu Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Mentör ID'),
                onChanged: (value) {
                  mentorId = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen mentör ID girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Tarih'),
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? '${_selectedDate!.toLocal()}'.split(' ')[0]
                      : '',
                ),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addRandevu,
                child: Text("Randevu Ekle"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
