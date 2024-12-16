import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PastAppointmentsScreen extends StatefulWidget {
  @override
  _PastAppointmentsScreenState createState() => _PastAppointmentsScreenState();
}

class _PastAppointmentsScreenState extends State<PastAppointmentsScreen> {
  List<Map<String, dynamic>> pastAppointments = [];

  @override
  void initState() {
    super.initState();
    fetchPastAppointments();
  }

  // Geçmiş randevuları al
  Future<void> fetchPastAppointments() async {
    try {
      final now = DateTime.now();
      final pastAppointmentsSnapshot = await FirebaseFirestore.instance
          .collection('Randevular')
          .where('status', isEqualTo: 'Geçmiş')
          .get();

      setState(() {
        pastAppointments = pastAppointmentsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'mentorName': data['mentorName'],
            'appointmentDate': (data['appointmentDate'] as Timestamp).toDate(),
            'status': data['status'],
          };
        }).toList();
      });
    } catch (e) {
      print('Geçmiş randevular alınırken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geçmiş Randevular'),
        centerTitle: true,
      ),
      body: pastAppointments.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: pastAppointments.length,
        itemBuilder: (context, index) {
          final appointment = pastAppointments[index];
          return ListTile(
            title: Text(appointment['mentorName']),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(appointment['appointmentDate'])),
            trailing: Text(appointment['status']),
          );
        },
      ),
    );
  }
}
