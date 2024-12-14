import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:randevu_1/model/appointment_model.dart';

class RandevuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Randevu>> getAktifRandevular(String ogrenciId) {
    return _db
        .collection('Randevular')
        .where('ogrenciId', isEqualTo: ogrenciId)
        .where('randevuDurum', isEqualTo: 'Aktif')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Randevu.fromFirestore(doc.data()))
        .toList());
  }

  Stream<List<Randevu>> getGecmisRandevular(String ogrenciId) {
    return _db
        .collection('Randevular')
        .where('ogrenciId', isEqualTo: ogrenciId)
        .where('randevuDurum', isEqualTo: 'Tamamlandı')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Randevu.fromFirestore(doc.data()))
        .toList());
  }

  Future<void> addRandevu(Randevu randevu) async {
    try {
      await _db.collection('Randevular').add(randevu.toMap());
    } catch (e) {
      throw Exception("Randevu eklenirken hata oluştu: $e");
    }
  }
}
