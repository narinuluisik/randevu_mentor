class Student {
  final String studentId;
  final String name;
  final String email;
  final String department;
  final String university;

  Student({
    required this.studentId,
    required this.name,
    required this.email,
    required this.department,
    required this.university,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentId: map['studentId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      university: map['university'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'email': email,
      'department': department,
      'university': university,
    };
  }
}
