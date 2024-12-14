class Mentor {
  final String mentorId;
  final String mentorAd;
  final String mentorSoyad;
  final String mentorResimUrl;
  final String sector; // Yeni alan: Sector
  final String universite; // Yeni alan: Universite
  final String deneyim; // Yeni alan: Deneyim

  Mentor({
    required this.mentorId,
    required this.mentorAd,
    required this.mentorSoyad,
    required this.mentorResimUrl,
    required this.sector,
    required this.universite,
    required this.deneyim,
  });

  // Firestore'dan veri alırken bu fonksiyon kullanılabilir
  factory Mentor.fromFirestore(Map<String, dynamic> data) {
    return Mentor(
      mentorId: data['mentorId'],
      mentorAd: data['mentorAd'],
      mentorSoyad: data['mentorSoyad'],
      mentorResimUrl: data['mentorResimUrl'] ?? '',
      sector: data['sector'] ?? '', // Yeni alan
      universite: data['universite'] ?? '', // Yeni alan
      deneyim: data['deneyim'] ?? '', // Yeni alan
    );
  }

  // Firestore'a veri yazarken bu fonksiyon kullanılabilir
  Map<String, dynamic> toMap() {
    return {
      'mentorId': mentorId,
      'mentorAd': mentorAd,
      'mentorSoyad': mentorSoyad,
      'mentorResimUrl': mentorResimUrl,
      'sector': sector, // Yeni alan
      'universite': universite, // Yeni alan
      'deneyim': deneyim, // Yeni alan
    };
  }
}
