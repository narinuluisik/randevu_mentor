import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_appointment_screen.dart';
import 'package:intl/intl.dart';

class RandevularimPage extends StatelessWidget {
  final String ogrenciId;

  RandevularimPage({required this.ogrenciId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Randevularım"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Aktif Randevular"),
              Tab(text: "Geçmiş Randevular"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Aktif randevular
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Randevular')
                  .where('studentId', isEqualTo: ogrenciId)
                  .where('status', isEqualTo: 'Aktif')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var randevular = snapshot.data!.docs;

                if (randevular.isEmpty) {
                  return Center(child: Text("Aktif randevunuz yok"));
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
            // Geçmiş randevular
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Randevular')
                  .where('studentId', isEqualTo: ogrenciId)
                  .where('status', isEqualTo: 'Geçmiş')
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAppointmentScreen(),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
