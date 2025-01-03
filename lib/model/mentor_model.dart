class Mentor {
  final String mentorId;
  final String ad;
  final String email;
  final String expertise;
  final String university;
  final String sector;
  final String profileImage;

  Mentor({
    required this.mentorId,
    required this.ad,
    required this.email,
    required this.expertise,
    required this.university,
    required this.sector,
    required this.profileImage,
  });

  factory Mentor.fromFirestore(Map<String, dynamic> firestoreData) {
    return Mentor(
      mentorId: firestoreData['mentorId'],
      ad: firestoreData['name'],
      email: firestoreData['email'],
      expertise: firestoreData['expertise'],
      university: firestoreData['university'],
      sector: firestoreData['sector'],
      profileImage: firestoreData['profileImage'] ?? 'https://www.w3schools.com/w3images/avatar2.png', // Varsayılan resim
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mentorId': mentorId,
      'ad': ad,
      'email': email,
      'expertise': expertise,
      'university': university,
      'sector': sector,
      'profileImage': profileImage,
    };
  }
}