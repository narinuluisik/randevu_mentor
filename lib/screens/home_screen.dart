import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:randevu_1/screens/register_screen.dart';
import 'package:randevu_1/screens/student_profile_screen.dart';
import 'appointment_screen.dart';
import 'matches_screen.dart';
import 'login_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatefulWidget {
  final String? userId;
  final String? userRole;

  const HomeScreen({
    Key? key,
    this.userId,
    this.userRole,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = '';
  Stream<QuerySnapshot>? _mentorsStream;
  final TextEditingController _reviewController = TextEditingController();
  double _userRating = 5.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeMentorsStream();
  }

  void _initializeMentorsStream() {
    _mentorsStream = FirebaseFirestore.instance
        .collection('mentors')
        .snapshots();
  }

  Future<void> _loadUserData() async {
    try {
      final collection = widget.userRole == 'student' ? 'students' : 'mentors';
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .where(widget.userRole == 'student' ? 'studentId' : 'mentorId', isEqualTo: widget.userId)
          .get();

      if (doc.docs.isNotEmpty) {
        final userData = doc.docs.first.data();
        setState(() {
          _userName = '${userData['ad']} ${userData['soyad']}';
        });
      }
    } catch (e) {
      print('Kullanıcı bilgileri yüklenirken hata: $e');
    }
  }

  Widget _buildMentorCard(Map<String, dynamic> mentor) {
    return Container(
      width: 190,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade50.withOpacity(0.9),
            Colors.purple.shade50.withOpacity(0.5),
            Colors.white.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.1, 0.5, 0.9],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade100.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.purple.shade50.withOpacity(0.5),
              child: CircleAvatar(
                radius: 33,
                backgroundImage: NetworkImage(
                  mentor['profileImageUrl'] ?? 'https://via.placeholder.com/150',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${mentor['ad']} ${mentor['soyad']}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade50.withOpacity(0.7),
                    Colors.purple.shade100.withOpacity(0.3),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mentor['uzmanlikAlani'] ?? 'Belirtilmemiş',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple.shade700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              mentor['universite'] ?? '',
              style: TextStyle(
                fontSize: 11,
                color: Colors.purple.shade400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.userId != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Hoş geldin, $_userName',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.purple.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade100.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      color: Colors.purple.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kariyer Yolculuğuna Başla',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Deneyimli mentörlerle eşleş, hedeflerine bir adım daha yaklaş!',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.purple.shade900,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Öne Çıkan Mentörler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _navigateToMentors(),
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Colors.purple.shade700,
                  ),
                  label: Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 220,
            child: StreamBuilder<QuerySnapshot>(
              stream: _mentorsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorWidget('Bir hata oluştu');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingWidget();
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final mentor = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return _buildMentorCard(mentor);
                  },
                );
              },
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade50.withOpacity(0.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.purple.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kullanıcı Yorumları',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildReviewsSection(),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.question_answer_rounded,
                      color: Colors.purple.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sıkça Sorulan Sorular',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFAQSection(),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade50,
                  Colors.purple.shade100.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'İletişim',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                _buildContactItem(
                  Icons.email_rounded,
                  'E-posta',
                  'iletisim@mentorapp.com',
                ),
                const SizedBox(height: 16),
                _buildContactItem(
                  Icons.phone_rounded,
                  'Telefon',
                  '+90 (555) 123 45 67',
                ),
                const SizedBox(height: 16),
                _buildContactItem(
                  Icons.location_on_rounded,
                  'Adres',
                  'Teknokent, Ankara',
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  '© 2024 Mentor App. Tüm hakları saklıdır.',
                  style: TextStyle(
                    color: Colors.purple.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.purple.shade300, size: 48),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(color: Colors.purple.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade700),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.purple.shade50.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: Colors.purple.shade100, width: 1),
          bottom: BorderSide(color: Colors.purple.shade100, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              if (widget.userRole == 'student')
                TextButton.icon(
                  onPressed: _showAddReviewDialog,
                  icon: Icon(Icons.add_comment, color: Colors.purple.shade700),
                  label: Text(
                    'Yorum Ekle',
                    style: TextStyle(color: Colors.purple.shade700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reviews')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final reviews = snapshot.data!.docs;
              return Column(
                children: reviews.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ReviewCard(data: data);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorum Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) => IconButton(
                  icon: Icon(
                    index < _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _userRating = index + 1;
                    });
                  },
                ),
              ),
            ),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                hintText: 'Yorumunuzu yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (_reviewController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance.collection('reviews').add({
                    'studentId': widget.userId,
                    'studentName': _userName,
                    'comment': _reviewController.text,
                    'rating': _userRating,
                    'createdAt': DateTime.now(),
                    'studentImageUrl': 'https://via.placeholder.com/150',
                  });
                  _reviewController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yorumunuz eklendi')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata oluştu: $e')),
                  );
                }
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildExpandableFAQItem(
          'Nasıl mentör bulabilirim?',
          'Alt menüdeki "Mentör Bul" sekmesinden ilgi alanınıza uygun mentörleri keşfedebilirsiniz.',
        ),
        _buildExpandableFAQItem(
          'Randevu nasıl oluşturabilirim?',
          'Mentör profilinden veya alt menüdeki "Randevularım" sekmesinden uygun zamanı seçerek randevu talep edebilirsiniz.',
        ),
        _buildExpandableFAQItem(
          'Randevumu nasıl iptal edebilirim?',
          'Alt menüdeki "Randevularım" sekmesinden ilgili randevuyu seçip iptal edebilirsiniz.',
        ),
      ],
    );
  }

  Widget _buildExpandableFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.shade100),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String content) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple.shade700, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            Text(
              content,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToMentors() {
    if (widget.userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchesScreen(studentId: widget.userId!),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor App', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 2,
        actions: widget.userId == null 
          ? [
              // Giriş yapmamış kullanıcı için butonlar
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Giriş',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text(
                  'Kayıt',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
            ]
          : [
              // Giriş yapmış kullanıcı için profil butonu
              TextButton.icon(
                onPressed: () async {
                  final studentDoc = await FirebaseFirestore.instance
                      .collection('students')
                      .where('studentId', isEqualTo: widget.userId)
                      .get();

                if (studentDoc.docs.isNotEmpty) {
                  final studentDocId = studentDoc.docs.first.id;

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentProfileScreen(
                        studentId: studentDocId,
                      ),
                    ),
                  );
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Öğrenci bilgisi bulunamadı')),
                  );
                }
              },
              icon: const Icon(Icons.account_circle, color: Colors.white),
              label: const Text(
                'Profil',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              border: Border(
                bottom: BorderSide(
                  color: Colors.purple.shade100,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      if (widget.userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchesScreen(studentId: widget.userId!),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      }
                    },
                    icon: Icon(Icons.person_search, color: Colors.purple.shade700),
                    label: Text(
                      'Mentörümü Bul',
                      style: TextStyle(color: Colors.purple.shade700),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      if (widget.userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RandevularimPage(
                              userId: widget.userId!,
                              userRole: widget.userRole!,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      }
                    },
                    icon: Icon(Icons.calendar_today, color: Colors.purple.shade700),
                    label: Text(
                      'Randevularım',
                      style: TextStyle(color: Colors.purple.shade700),
                    ),
                  ),
                ),
                if (widget.userId != null)
                  IconButton(
                    onPressed: () async {
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.purple.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text('Çıkış Yap'),
                              ],
                            ),
                            content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'İptal',
                                  style: TextStyle(color: Colors.purple.shade700),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text(
                                  'Çıkış Yap',
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                              userId: null,
                              userRole: null,
                            ),
                          ),
                              (Route<dynamic> route) => false,
                        );
                      }
                    },
                    icon: Icon(Icons.logout_rounded, color: Colors.purple.shade700),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: _buildHomeBody(),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}

class ReviewCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const ReviewCard({Key? key, required this.data}) : super(key: key);

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _isExpanded = false;
  static const int _maxLines = 2;
  late TextPainter _textPainter;
  bool _hasOverflow = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateTextOverflow();
  }

  void _calculateTextOverflow() {
    final text = widget.data['comment'] ?? '';
    _textPainter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(fontSize: 14)),
      maxLines: _maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 48);

    _hasOverflow = _textPainter.didExceedMaxLines;
    setState(() {}); // UI'ı güncelle
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: Image.network(
                      widget.data['studentImageUrl'] ?? 'https://via.placeholder.com/150',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data['studentName'] ?? 'İsimsiz Öğrenci',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                              (index) => Icon(
                            index < (widget.data['rating'] ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data['comment'] ?? '',
                  maxLines: _isExpanded ? null : _maxLines,
                  overflow: _isExpanded ? null : TextOverflow.ellipsis,
                ),
                if (_hasOverflow)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Daha az göster' : 'Devamını oku',
                      style: TextStyle(
                        color: Colors.purple[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}