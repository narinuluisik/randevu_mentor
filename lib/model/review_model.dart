class Review {
  final String id;
  final String studentId;
  final String studentName;
  final String comment;
  final double rating;
  final DateTime createdAt;
  final String? studentImageUrl;

  Review({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.comment,
    required this.rating,
    required this.createdAt,
    this.studentImageUrl,
  });

  factory Review.fromFirestore(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as DateTime?) ?? DateTime.now(),
      studentImageUrl: data['studentImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt,
      'studentImageUrl': studentImageUrl,
    };
  }
} 