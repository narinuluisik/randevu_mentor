import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('Girilen email: ${_emailController.text.trim()}');
        print('Girilen şifre: ${_passwordController.text}');

        // Students koleksiyonunda ara
        final studentSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .get();

        // Tüm öğrenciler arasında doğru e-posta ve şifreyi ara
        for (var doc in studentSnapshot.docs) {
          final studentData = doc.data();
          print('Veritabanı öğrenci email: ${studentData['eposta']}');
          print('Veritabanı öğrenci şifre: ${studentData['sifre']}');

          if (studentData['eposta'] == _emailController.text.trim() &&
              studentData['sifre'] == _passwordController.text) {
            print('Öğrenci bulundu: ${studentData['ad']}');
            
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  userId: studentData['studentId'],
                  userRole: 'student',
                ),
              ),
              (Route<dynamic> route) => false,
            );
            return;
          }
        }

        // Mentors koleksiyonunda ara
        final mentorSnapshot = await FirebaseFirestore.instance
            .collection('mentors')
            .get();

        // Tüm mentörler arasında doğru e-posta ve şifreyi ara
        for (var doc in mentorSnapshot.docs) {
          final mentorData = doc.data();
          print('Veritabanı mentor email: ${mentorData['email']}');
          print('Veritabanı mentor şifre: ${mentorData['sifre']}');

          if (mentorData['email'] == _emailController.text.trim() &&
              mentorData['sifre'] == _passwordController.text) {
            print('Mentor bulundu: ${mentorData['ad']}');
            
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  userId: mentorData['mentorId'],
                  userRole: 'mentor',
                ),
              ),
              (Route<dynamic> route) => false,
            );
            return;
          }
        }

        // Kullanıcı bulunamadı veya şifre yanlış
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-posta veya şifre hatalı'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        print('Login error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş yapılırken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _checkUserRole(String uid) async {
    // Önce mentors koleksiyonunda ara
    final mentorDoc = await FirebaseFirestore.instance
        .collection('mentors')
        .doc(uid)
        .get();

    if (mentorDoc.exists) {
      return 'mentor';
    }

    // Sonra students koleksiyonunda ara
    final studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(uid)
        .get();

    if (studentDoc.exists) {
      return 'student';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 50),
                // Logo veya uygulama adı
                Text(
                  'Mentorluk\nUygulaması',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
                // E-posta alanı
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email, color: Colors.purple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen e-posta adresinizi girin';
                    }
                    if (!value.contains('@')) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Şifre alanı
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock, color: Colors.purple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi girin';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                // Giriş yap butonu
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Giriş Yap',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                SizedBox(height: 16),
                // Kayıt ol butonu
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Hesabınız yok mu? Kayıt olun',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}