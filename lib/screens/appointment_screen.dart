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
    final DateTime appointmentDate = (data['appointmentDate'] as Timestamp).toDate();
    final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(appointmentDate);
    final String displayName = widget.userRole == 'student'
        ? '${_mentorData?['ad'] ?? 'Mentör'} ${_mentorData?['soyad'] ?? ''}'
        : data['studentName'] ?? 'Öğrenci';
    final String status = data['status'] ?? 'Belirsiz';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.purple.shade50.withOpacity(0.3),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.purple.shade100,
            child: Text(
              (displayName.isNotEmpty ? displayName[0] : '?').toUpperCase(),
              style: TextStyle(
                color: Colors.purple.shade700,
                fontWeight: FontWeight.bold,
              ),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, 
                       size: 16, 
                       color: Colors.purple.shade300),
                  const SizedBox(width: 8),
                  Text(formattedDate),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.info_outline, 
                       size: 16, 
                       color: Colors.purple.shade300),
                  const SizedBox(width: 8),
                  Text(
                    'Durum: $status',
                    style: TextStyle(
                      color: status == 'Aktif' 
                          ? Colors.green.shade700 
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: status == 'Aktif'
              ? IconButton(
                  icon: Icon(Icons.cancel, 
                           color: Colors.red.shade400),
                  onPressed: () => _cancelAppointment(doc.id),
                )
              : null,
        ),
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

  Widget _buildAppointmentList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getAppointmentsStream(status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Bir hata oluştu: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: Colors.purple.shade200,
                ),
                const SizedBox(height: 16),
                Text(
                  status == 'Aktif' 
                      ? 'Aktif randevunuz bulunmamaktadır'
                      : 'Geçmiş randevunuz bulunmamaktadır',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            widget.userRole == 'mentor' ? "Mentorluk Randevularım" : "Randevularım",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.purple.shade700,
          bottom: TabBar(
            tabs: const [
              Tab(text: "Aktif Randevular"),
              Tab(text: "Geçmiş Randevular"),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade50,
                Colors.white,
              ],
            ),
          ),
          child: TabBarView(
            children: [
              _buildAppointmentList('Aktif'),
              _buildAppointmentList('Geçmiş'),
            ],
          ),
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
                backgroundColor: Colors.purple.shade700,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }
}