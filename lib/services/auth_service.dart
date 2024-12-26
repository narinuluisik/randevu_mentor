import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı girişi
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      // Önce Firebase Auth ile giriş yap
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Önce mentors koleksiyonunda ara
      var mentorDoc = await _firestore
          .collection('mentors')
          .doc(userCredential.user!.uid)
          .get();

      if (mentorDoc.exists) {
        return {
          'user': userCredential.user,
          'role': 'mentor',
          'userData': mentorDoc.data()
        };
      }

      // Mentor değilse students koleksiyonunda ara
      var studentDoc = await _firestore
          .collection('students')
          .doc(userCredential.user!.uid)
          .get();

      if (studentDoc.exists) {
        return {
          'user': userCredential.user,
          'role': 'student',
          'userData': studentDoc.data()
        };
      }

      throw Exception('Kullanıcı bilgileri bulunamadı');
    } catch (e) {
      throw Exception('Giriş başarısız: $e');
    }
  }

  // Yeni kullanıcı kaydı
  Future<UserCredential> register({
    required String email,
    required String password,
    required String ad,
    required String soyad,
    required String role,
    required String uzmanlikAlani,
    required String sektor,
    required String bio,
  }) async {
    try {
      // Firebase Auth'da kullanıcı oluştur
      final UserCredential userCredential = 
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı bilgilerini hazırla
      final userData = {
        'email': email,
        'ad': ad,
        'soyad': soyad,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Role göre ek bilgileri ekle ve doğru koleksiyona kaydet
      if (role == 'mentor') {
        userData.addAll({
          'uzmanlikAlani': uzmanlikAlani,
          'sektor': sektor,
          'bio': bio,
        });
        await _firestore
            .collection('mentors')
            .doc(userCredential.user!.uid)
            .set(userData);
      } else {
        await _firestore
            .collection('students')
            .doc(userCredential.user!.uid)
            .set(userData);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Kayıt başarısız: $e');
    }
  }

  // Kullanıcı rolünü ve bilgilerini getir
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Önce mentors'da ara
      var mentorDoc = await _firestore.collection('mentors').doc(user.uid).get();
      if (mentorDoc.exists) {
        return {'role': 'mentor', 'data': mentorDoc.data()};
      }

      // Sonra students'da ara
      var studentDoc = await _firestore.collection('students').doc(user.uid).get();
      if (studentDoc.exists) {
        return {'role': 'student', 'data': studentDoc.data()};
      }
    }
    return null;
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }
}