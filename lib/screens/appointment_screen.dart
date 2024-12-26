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
          title: Text("Randevularım", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.purple,
          bottom: TabBar(
            tabs: [
              Tab(text: "Aktif Randevular"),
              Tab(text: "Geçmiş Randevular"),
            ],
            indicatorColor: Colors.white, // Sekme altı renk
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
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
                  return Center(child: Text("Aktif randevunuz yok", style: TextStyle(fontSize: 18)));
                }

                return ListView.builder(
                  itemCount: randevular.length,
                  itemBuilder: (context, index) {
                    var randevu = randevular[index].data() as Map<String, dynamic>;
                    var tarih = (randevu['appointmentDate'] as Timestamp).toDate();
                    var ad = randevu['ad'];

                    return Card(
                      margin: EdgeInsets.all(8),
                      elevation: 5,
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text("Mentör: $ad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text("Tarih: ${DateFormat('dd/MM/yyyy').format(tarih)}", style: TextStyle(fontSize: 14)),
                        trailing: Text("Saat: ${DateFormat('HH:mm').format(tarih)}", style: TextStyle(fontSize: 14)),
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
                  return Center(child: Text("Geçmiş randevunuz yok", style: TextStyle(fontSize: 18)));
                }

                return ListView.builder(
                  itemCount: randevular.length,
                  itemBuilder: (context, index) {
                    var randevu = randevular[index].data() as Map<String, dynamic>;
                    var tarih = (randevu['appointmentDate'] as Timestamp).toDate();
                    var ad = randevu['ad'];

                    return Card(
                      margin: EdgeInsets.all(8),
                      elevation: 5,
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text("Mentör: $ad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text("Tarih: ${DateFormat('dd/MM/yyyy').format(tarih)}", style: TextStyle(fontSize: 14)),
                        trailing: Text("Saat: ${DateFormat('HH:mm').format(tarih)}", style: TextStyle(fontSize: 14)),
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
          backgroundColor: Colors.purple, // Buton rengi
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
