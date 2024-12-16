import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:randevu_1/model/appointment_model.dart';
import 'package:randevu_1/model/eslesme_model.dart';
import 'package:randevu_1/model/mentor_model.dart';

class RandevuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  get _firestore => null;


  // Aktif randevuları getirme
  Stream<List<Randevu>> getAktifRandevular(String ogrenciId) {
    return _firestore
        .collection('Randevular')
        .where('studentId', isEqualTo: ogrenciId)
        .where('status', isEqualTo: 'Aktif')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Randevu.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Geçmiş randevuları getirme
  Stream<List<Randevu>> getGecmisRandevular(String ogrenciId) {
    return _firestore
        .collection('Randevular')
        .where('studentId', isEqualTo: ogrenciId)
        .where('status', isEqualTo: 'Geçmiş')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Randevu.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  // Eşleşen mentor ile randevu ekleme fonksiyonu
  Future<void> addRandevu(Randevu randevu) async {
    try {
      // Öğrenci ile eşleşen mentörün olup olmadığını kontrol ediyoruz
      final QuerySnapshot eslesmeQuery = await _firestore
          .collection('Eslesmeler')
          .where('ogrenciId', isEqualTo: randevu.ogrenciId)
          .get();

      if (eslesmeQuery.docs.isEmpty) {
        // Eşleşme bulunamadıysa
        print("Öğrenci için eşleşen mentör bulunamadı.");
        throw Exception("Öğrenci için eşleşen mentör bulunamadı.");
      }

      // Eşleşen mentör bulunmuşsa, mentörId'yi alıyoruz
      String mentorId = eslesmeQuery.docs.first['mentorId'];

      // Mentör ile randevu ekliyoruz
      await _firestore.collection('Randevular').add({
        'ogrenciId': randevu.ogrenciId,
        'mentorId': mentorId,
        'tarih': randevu.tarih,
        'randevuDurum': randevu.randevuDurum,
      });

      print("Randevu başarıyla eklendi.");
    } catch (e) {
      print("Randevu eklenirken hata oluştu: $e");
      throw e; // Hata durumunda exception fırlatıyoruz
    }
  }
}