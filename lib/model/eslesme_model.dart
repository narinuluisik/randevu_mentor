import 'package:cloud_firestore/cloud_firestore.dart';

class Eslesme {
  final String mentorId;
  final String ogrenciId;
  final Timestamp eslesmeTarihi; // Eşleşme tarihi (Firebase Timestamp)
  final String? durum; // Eşleşme durumu, örneğin "aktif" ya da "tamamlandı"

  Eslesme({
    required this.mentorId,
    required this.ogrenciId,
    required this.eslesmeTarihi,
    this.durum,
  });

  // Firestore'dan veriyi almak için Factory Constructor
  factory Eslesme.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Eslesme(
      mentorId: data['MentorId'] ?? '',
      ogrenciId: data['OgrenciId'] ?? '',
      eslesmeTarihi: data['EslesmeTarihi'] ?? Timestamp.now(),
      durum: data['Durum'], // Durum opsiyonel olduğu için null olabilir
    );
  }

  // Firestore'a veri yazmak için map metodu
  Map<String, dynamic> toMap() {
    return {
      'MentorId': mentorId,
      'OgrenciId': ogrenciId,
      'EslesmeTarihi': eslesmeTarihi,
      'Durum': durum, // Durum boş olabilir
    };
  }
}
