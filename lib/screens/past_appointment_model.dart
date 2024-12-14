import 'package:flutter/material.dart';
import 'package:randevu_1/services/randevu_service.dart';
import 'package:randevu_1/model/appointment_model.dart';

class GecmisRandevularPage extends StatelessWidget {
  final String ogrenciId;

  GecmisRandevularPage({required this.ogrenciId});

  @override
  Widget build(BuildContext context) {
    final randevuService = RandevuService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Geçmiş Randevularım"),
      ),
      body: StreamBuilder<List<Randevu>>(
        stream: randevuService.getGecmisRandevular(ogrenciId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Hiç geçmiş randevu bulunamadı.'));
          }

          final randevular = snapshot.data!;
          return ListView.builder(
            itemCount: randevular.length,
            itemBuilder: (context, index) {
              final randevu = randevular[index];
              return ListTile(
                title: Text('Durum: ${randevu.randevuDurum}'),
                subtitle: Text('Tarih: ${randevu.tarih.toString()}'),
              );
            },
          );
        },
      ),
    );
  }
}
