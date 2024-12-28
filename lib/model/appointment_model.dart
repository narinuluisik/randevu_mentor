import 'package:cloud_firestore/cloud_firestore.dart';

class Randevu {
  final String id;
  final String studentId;
  final String mentorId;
  final DateTime appointmentDate;
  final String status;

  Randevu({
    required this.id,
    required this.studentId,
    required this.mentorId,
    required this.appointmentDate,
    required this.status,
  });

  factory Randevu.fromFirestore(Map<String, dynamic> data) {
    return Randevu(
      id: data['id'] ?? '',
      studentId: data['studentId'] ?? '',
      mentorId: data['mentorId'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'mentorId': mentorId,
      'appointmentDate': appointmentDate,
      'status': status,
    };
  }
}
