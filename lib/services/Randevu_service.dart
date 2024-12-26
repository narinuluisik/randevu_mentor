import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:randevu_1/model/appointment_model.dart';
import 'package:randevu_1/model/eslesme_model.dart';
import 'package:randevu_1/model/mentor_model.dart';

class RandevuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Randevu>> getAktifRandevular(String ogrenciId) {
    try {
      return _firestore
          .collection('Randevular')
          .where('ogrenciId', isEqualTo: ogrenciId)
          .where('randevuDurum', whereIn: ['Beklemede', 'Onaylandı'])
          .orderBy('tarih', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Randevu.fromFirestore(doc.data()))
                .toList();
          });
    } catch (e) {
      print('Hata: $e'); // Hata ayıklama için
      return Stream.value([]);
    }
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
          .where('ogrenciId', isEqualTo: randevu.studentId)
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
        'ogrenciId': randevu.studentId,
        'mentorId': mentorId,
        'tarih': randevu.appointmentDate,
        'randevuDurum': randevu. status,
      });

      print("Randevu başarıyla eklendi.");
    } catch (e) {
      print("Randevu eklenirken hata oluştu: $e");
      throw e; // Hata durumunda exception fırlatıyoruz
    }
  }
}

