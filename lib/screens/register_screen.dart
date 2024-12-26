import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _uzmanlikAlaniController = TextEditingController();
  final _sektorController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedRole = 'student';
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Firebase Auth ile kullanıcı oluştur
        UserCredential userCredential = 
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Kullanıcı bilgilerini hazırla
        Map<String, dynamic> userData = {
          'email': _emailController.text.trim(),
          'ad': _adController.text.trim(),
          'soyad': _soyadController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Eğer mentor ise ek bilgileri ekle
        if (_selectedRole == 'mentor') {
          userData.addAll({
            'uzmanlikAlani': _uzmanlikAlaniController.text.trim(),
            'sektor': _sektorController.text.trim(),
            'bio': _bioController.text.trim(),
          });

          // Mentor bilgilerini Firestore'a kaydet
          await FirebaseFirestore.instance
              .collection('mentors')
              .doc(userCredential.user!.uid)
              .set(userData);
        } else {
          // Öğrenci bilgilerini Firestore'a kaydet
          await FirebaseFirestore.instance
              .collection('students')
              .doc(userCredential.user!.uid)
              .set(userData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
        );
        
        Navigator.pop(context); // Giriş ekranına dön
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Bir hata oluştu';
        if (e.code == 'weak-password') {
          errorMessage = 'Şifre çok zayıf';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Bu e-posta adresi zaten kullanımda';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt olurken bir hata oluştu: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Ol'),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rol seçimi
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Öğrenci'),
                        value: 'student',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Mentor'),
                        value: 'mentor',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Temel bilgi alanları
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta gerekli';
                    }
                    if (!value.contains('@')) {
                      return 'Geçerli bir e-posta girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre gerekli';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalı';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _adController,
                  decoration: InputDecoration(
                    labelText: 'Ad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ad gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _soyadController,
                  decoration: InputDecoration(
                    labelText: 'Soyad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Soyad gerekli';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Mentor için ek alanlar
                if (_selectedRole == 'mentor') ...[
                  TextFormField(
                    controller: _uzmanlikAlaniController,
                    decoration: InputDecoration(
                      labelText: 'Uzmanlık Alanı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (_selectedRole == 'mentor' && 
                          (value == null || value.isEmpty)) {
                        return 'Uzmanlık alanı gerekli';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _sektorController,
                    decoration: InputDecoration(
                      labelText: 'Sektör',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (_selectedRole == 'mentor' && 
                          (value == null || value.isEmpty)) {
                        return 'Sektör gerekli';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Biyografi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Kayıt ol butonu
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                          'Kayıt Ol',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
    _adController.dispose();
    _soyadController.dispose();
    _uzmanlikAlaniController.dispose();
    _sektorController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}