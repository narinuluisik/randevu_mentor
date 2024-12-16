import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_appointment_screen.dart';
import 'package:intl/intl.dart';

class RandevularimPage extends StatefulWidget {
  final String ogrenciId;

  RandevularimPage({required this.ogrenciId});

  @override
  _RandevularimPageState createState() => _RandevularimPageState();
}

class _RandevularimPageState extends State<RandevularimPage> {

  @override
  void initState() {
    super.initState();
    // Sayfa yüklendiğinde randevuları güncelle
    updateAppointmentsStatus(widget.ogrenciId);
  }

  Future<void> updateAppointmentsStatus(String ogrenciId) async {
    try {
      final now = DateTime.now();

      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('Randevular')
          .where('studentId', isEqualTo: ogrenciId)
          .where('status', isEqualTo: 'Aktif')  // Sadece aktif olanları güncelle
          .get();

      for (var doc in appointmentsSnapshot.docs) {
        final appointmentData = doc.data();
        final appointmentDate = (appointmentData['appointmentDate'] as Timestamp).toDate();

        // Eğer tarih geçmişse, durumu 'Geçmiş' olarak güncelle
        if (appointmentDate.isBefore(now)) {
          await doc.reference.update({'status': 'Geçmiş'});
        }
      }
    } catch (e) {
      print('Randevu durumu güncellenirken bir hata oluştu: $e');
    }
  }

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
                  .where('studentId', isEqualTo: widget.ogrenciId)
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
                  .where('studentId', isEqualTo: widget.ogrenciId)
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
