import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PastAppointmentsPage extends StatelessWidget {
  final String ogrenciId;

  PastAppointmentsPage({required this.ogrenciId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geçmiş Randevular"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Randevular')
            .where('studentId', isEqualTo: ogrenciId)
            .where('status', isEqualTo: 'Geçmiş') // Geçmiş randevuları filtreliyoruz
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var randevular = snapshot.data!.docs;

          if (randevular.isEmpty) {
            return Center(child: Text("Geçmiş randevunuz yok"));
          }

          return ListView.builder(
            itemCount: randevular.length,
            itemBuilder: (context, index) {
              var randevu = randevular[index].data() as Map<String, dynamic>;
              var tarih = (randevu['appointmentDate'] as Timestamp).toDate();
              var mentorAd = randevu['mentorName'];

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Mentör: $mentorAd"),
                  subtitle: Text("Tarih: ${DateFormat('dd/MM/yyyy').format(tarih)}"),
                  trailing: Text("Saat: ${DateFormat('HH:mm').format(tarih)}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
