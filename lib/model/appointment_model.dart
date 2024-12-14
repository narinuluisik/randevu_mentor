import 'package:cloud_firestore/cloud_firestore.dart';

class Randevu {
  final String ogrenciId;
  final String mentorId;
  final DateTime tarih;
  final String randevuDurum;

  Randevu({
    required this.ogrenciId,
    required this.mentorId,
    required this.tarih,
    required this.randevuDurum,
  });

  factory Randevu.fromFirestore(Map<String, dynamic> data) {
    return Randevu(
      ogrenciId: data['ogrenciId'],
      mentorId: data['mentorId'],
      tarih: (data['tarih'] as Timestamp).toDate(),
      randevuDurum: data['randevuDurum'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ogrenciId': ogrenciId,
      'mentorId': mentorId,
      'tarih': tarih,
      'randevuDurum': randevuDurum,
    };
  }
}
