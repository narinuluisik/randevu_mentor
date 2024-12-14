import 'package:flutter/material.dart';
import 'package:randevu_1/services/randevu_service.dart';
import 'package:randevu_1/model/appointment_model.dart';
import 'add_appointment_screen.dart';

class RandevularimPage extends StatelessWidget {
  final String ogrenciId;

  RandevularimPage({required this.ogrenciId});

  @override
  Widget build(BuildContext context) {
    final randevuService = RandevuService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Randevularım"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Randevularım"),
              Tab(text: "Geçmiş Randevularım"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Aktif randevular
            StreamBuilder<List<Randevu>>(
              stream: randevuService.getAktifRandevular(ogrenciId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var randevular = snapshot.data!;

                if (randevular.isEmpty) {
                  return Center(child: Text("Aktif randevunuz yok"));
                }

                return ListView.builder(
                  itemCount: randevular.length,
                  itemBuilder: (context, index) {
                    var randevu = randevular[index];
                    var tarih = randevu.tarih;
                    var mentorAd = randevu.mentorId; // Mentor adı burada alınabilir

                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text("Mentör: $mentorAd"),
                        subtitle: Text("Tarih: ${tarih.toLocal().toString().split(' ')[0]}"),
                        trailing: Text("Saat: ${tarih.toLocal().toString().split(' ')[1].substring(0, 5)}"),
                      ),
                    );
                  },
                );
              },
            ),
            // Geçmiş randevular
            StreamBuilder<List<Randevu>>(
              stream: randevuService.getGecmisRandevular(ogrenciId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var randevular = snapshot.data!;

                if (randevular.isEmpty) {
                  return Center(child: Text("Geçmiş randevunuz yok"));
                }

                return ListView.builder(
                  itemCount: randevular.length,
                  itemBuilder: (context, index) {
                    var randevu = randevular[index];
                    var tarih = randevu.tarih;
                    var mentorAd = randevu.mentorId; // Mentor adı burada alınabilir

                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text("Mentör: $mentorAd"),
                        subtitle: Text("Tarih: ${tarih.toLocal().toString().split(' ')[0]}"),
                        trailing: Text("Saat: ${tarih.toLocal().toString().split(' ')[1].substring(0, 5)}"),
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
                builder: (context) => RandevuEklePage(ogrenciId: ogrenciId),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
