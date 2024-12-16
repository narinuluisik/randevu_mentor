import 'package:cloud_firestore/cloud_firestore.dart';

class Eslesme {
  final String mentorId;
  final String ogrenciId;


  Eslesme({
    required this.mentorId,
    required this.ogrenciId,


  });

  // Firestore'dan veriyi almak için Factory Constructor
  factory Eslesme.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Eslesme(
      mentorId: data['mentorId'] ?? '',
      ogrenciId: data['ogrenciId'] ?? '',

    );
  }

  // Firestore'a veri yazmak için map metodu
  Map<String, dynamic> toMap() {
    return {
      'mentorId': mentorId,
      'ogrenciId': ogrenciId,

    };
  }
}
