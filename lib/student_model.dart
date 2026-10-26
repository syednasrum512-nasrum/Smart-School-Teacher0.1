import 'dart:convert';

/// **صارف کی معلومات کا ڈیٹا بیس ماڈل (Student Model)**
/// یہ ماڈل ہر طالب علم کی معلومات کو محفوظ اور ہینڈل کرنے کے لیے استعمال ہوتا ہے۔
class StudentModel {
  // ہر بچے کی ایک مستقل شناختی چابی (Persistent Unique ID)
  final String uuid; 
  
  // اسکول کا داخلہ نمبر اور رول نمبر
  final String admissionNumber;
  final int rollNumber;
  
  // بنیادی معلومات
  final String firstName;
  final String lastName;
  final String fatherName;
  final String fatherCnic; // فارمیٹ: 00000-0000000-0
  final String dateOfBirth; // فارمیٹ: YYYY-MM-DD
  final String gender; // Male / Female
  final String address;
  final String emergencyContact;
  
  // اکیڈمک معلومات
  final String currentClass; // جیسے: Class 1, Class 5
  final String currentSection; // جیسے: A, B
  final String academicYear; // جیسے: 2026-2027
  final String admissionDate;
  final bool isActive; // کیا بچہ اسکول میں پڑھ رہا ہے یا چھوڑ گیا ہے

  // کنسٹرکٹر (Constructor)
  StudentModel({
    required this.uuid,
    required this.admissionNumber,
    required this.rollNumber,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.fatherCnic,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.emergencyContact,
    required this.currentClass,
    required this.currentSection,
    required this.academicYear,
    required this.admissionDate,
    this.isActive = true,
  });

  /// **ڈیٹا کو انٹرنیٹ یا لوکل میموری میں بھیجنے کے لیے JSON میں تبدیل کرنا**
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'admissionNumber': admissionNumber,
      'rollNumber': rollNumber,
      'firstName': firstName,
      'lastName': lastName,
      'fatherName': fatherName,
      'fatherCnic': fatherCnic,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'emergencyContact': emergencyContact,
      'currentClass': currentClass,
      'currentSection': currentSection,
      'academicYear': academicYear,
      'admissionDate': admissionDate,
      'isActive': isActive,
    };
  }

  /// **محفوظ شدہ لوکل ڈیٹا یا انٹرنیٹ سے آنے والے ڈیٹا کو واپس ایپ میں لوڈ کرنا**
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uuid: map['uuid'] ?? '',
      admissionNumber: map['admissionNumber'] ?? '',
      rollNumber: map['rollNumber']?.toInt() ?? 0,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      fatherName: map['fatherName'] ?? '',
      fatherCnic: map['fatherCnic'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      gender: map['gender'] ?? '',
      address: map['address'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '',
      currentClass: map['currentClass'] ?? '',
      currentSection: map['currentSection'] ?? '',
      academicYear: map['academicYear'] ?? '',
      admissionDate: map['admissionDate'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory StudentModel.fromJson(String source) => StudentModel.fromMap(json.decode(source));
}
