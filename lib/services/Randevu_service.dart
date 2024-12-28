import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:randevu_1/model/appointment_model.dart';
import 'package:randevu_1/model/eslesme_model.dart';
import 'package:randevu_1/model/mentor_model.dart';

class RandevuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Aktif randevuları getirme
  Stream<List<Randevu>> getAktifRandevular(String ogrenciId) {
    try {
      return _firestore
          .collection('Randevular')
          .where('studentId', isEqualTo: ogrenciId)
          .where('status', whereIn: ['Beklemede', 'Onaylandı'])
          .orderBy('appointmentDate', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Randevu.fromFirestore(data);
            }).toList();
          });
    } catch (e) {
      print('Hata: $e');
      return Stream.value([]);
    }
  }

  // Geçmiş randevuları getirme
  Stream<List<Randevu>> getGecmisRandevular(String ogrenciId) {
    return _firestore
        .collection('Randevular')
        .where('studentId', isEqualTo: ogrenciId)
        .where('status', isEqualTo: 'Tamamlandı')
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Randevu.fromFirestore(data);
          }).toList();
        });
  }

  // Randevu ekleme fonksiyonu
  Future<void> addRandevu(Randevu randevu) async {
    try {
      // Öğrenci ile eşleşen mentörün olup olmadığını kontrol ediyoruz
      final QuerySnapshot eslesmeQuery = await _firestore
          .collection('Eslesmeler')
          .where('studentId', isEqualTo: randevu.studentId)
          .get();

      if (eslesmeQuery.docs.isEmpty) {
        print("Öğrenci için eşleşen mentör bulunamadı.");
        throw Exception("Öğrenci için eşleşen mentör bulunamadı.");
      }

      // Eşleşen mentör bulunmuşsa, mentörId'yi alıyoruz
      String mentorId = eslesmeQuery.docs.first['mentorId'];

      // Mentör ile randevu ekliyoruz
      await _firestore.collection('Randevular').add({
        'studentId': randevu.studentId,
        'mentorId': mentorId,
        'appointmentDate': randevu.appointmentDate,
        'status': randevu.status,
      });

      print("Randevu başarıyla eklendi.");
    } catch (e) {
      print("Randevu eklenirken hata oluştu: $e");
      throw e;
    }
  }
}

