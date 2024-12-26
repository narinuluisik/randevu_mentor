import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'add_appointment_screen.dart';

class RandevularimPage extends StatefulWidget {
  const RandevularimPage({
    Key? key,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  final String userId;
  final String userRole;

  @override
  State<RandevularimPage> createState() => _RandevularimPageState();
}

class _RandevularimPageState extends State<RandevularimPage> {
  String? _matchedMentorId;
  Map<String, dynamic>? _mentorData;

  @override
  void initState() {
    super.initState();
    if (widget.userRole == 'student') {
      _getMatchedMentor();
    }
    updateAppointmentsStatus();
  }

  Future<void> _getMatchedMentor() async {
    try {
      final matchSnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('student.studentId', isEqualTo: widget.userId)
          .get();

      if (matchSnapshot.docs.isNotEmpty) {
        final mentorData = matchSnapshot.docs.first.data()['mentor'] as Map<String, dynamic>;
        setState(() {
          _matchedMentorId = mentorData['mentorId'];
          _mentorData = mentorData;
        });
      }
    } catch (e) {
      print('Eşleşen mentör bilgisi alınamadı: $e');
    }
  }

  Future<void> updateAppointmentsStatus() async {
    try {
      final now = DateTime.now();
      final String fieldToCheck =
          widget.userRole == 'mentor' ? 'mentorId' : 'studentId';

      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('Randevular')
          .where(fieldToCheck, isEqualTo: widget.userId)
          .where('status', isEqualTo: 'Aktif')
          .get();

      for (var doc in appointmentsSnapshot.docs) {
        final appointmentData = doc.data();
        final appointmentDate =
            (appointmentData['appointmentDate'] as Timestamp).toDate();

        if (appointmentDate.isBefore(now)) {
          await doc.reference.update({'status': 'Geçmiş'});
        }
      }
    } catch (e) {
      print('Randevu durumu güncellenirken bir hata oluştu: $e');
    }
  }

  Stream<QuerySnapshot> _getAppointmentsStream(String status) {
    if (widget.userRole == 'student' && _matchedMentorId != null) {
      return FirebaseFirestore.instance
          .collection('Randevular')
          .where('studentId', isEqualTo: widget.userId)
          .where('mentorId', isEqualTo: _matchedMentorId)
          .where('status', isEqualTo: status)
          .snapshots();
    } else if (widget.userRole == 'mentor') {
      return FirebaseFirestore.instance
          .collection('Randevular')
          .where('mentorId', isEqualTo: widget.userId)
          .where('status', isEqualTo: status)
          .snapshots();
    }
    return FirebaseFirestore.instance
        .collection('Randevular')
        .where('studentId', isEqualTo: 'no-match')
        .snapshots();
  }

  Widget _buildAppointmentCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Tarih kontrolü
    final Timestamp? timestamp = data['appointmentDate'] as Timestamp?;
    if (timestamp == null) {
      return const Card(
        child: ListTile(title: Text('Geçersiz randevu tarihi')),
      );
    }

    final DateTime appointmentDate = timestamp.toDate();
    final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(appointmentDate);
    
    // Mentor/Student bilgisi
    final String displayName = widget.userRole == 'student' 
        ? '${_mentorData?['ad'] ?? 'Mentör'} ${_mentorData?['soyad'] ?? ''}'
        : data['studentName'] ?? 'Öğrenci';
    
    final String status = data['status'] ?? 'Belirsiz';

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: Text(
            (displayName.isNotEmpty ? displayName[0] : '?').toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Tarih: $formattedDate'),
            Text(
              'Durum: $status',
              style: TextStyle(
                color: status == 'Aktif' ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        trailing: status == 'Aktif'
            ? IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => _cancelAppointment(doc.id),
              )
            : null,
      ),
    );
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Randevular')
          .doc(appointmentId)
          .update({'status': 'İptal Edildi'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Randevu iptal edildi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.userRole == 'mentor' ? "Mentorluk Randevularım" : "Randevularım",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.purple,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Aktif Randevular"),
              Tab(text: "Geçmiş Randevular"),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // Aktif randevular
            StreamBuilder<QuerySnapshot>(
              stream: _getAppointmentsStream('Aktif'),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Aktif randevunuz bulunmamaktadır.'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(snapshot.data!.docs[index]);
                  },
                );
              },
            ),
            // Geçmiş randevular
            StreamBuilder<QuerySnapshot>(
              stream: _getAppointmentsStream('Geçmiş'),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Geçmiş randevunuz bulunmamaktadır.'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(snapshot.data!.docs[index]);
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: widget.userRole == 'student'
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddAppointmentScreen(
                        userId: widget.userId,
                        userRole: widget.userRole,
                      ),
                    ),
                  );
                },
                backgroundColor: Colors.purple,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }
}