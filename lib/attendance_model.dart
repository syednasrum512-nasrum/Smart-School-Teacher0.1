import 'dart:convert';

/// **حاضری کا ڈیٹا بیس ماڈل (Attendance Model)**
/// یہ ماڈل ہر بچے کی روزانہ کی حاضری کا ریکارڈ سنبھالتا ہے۔
class AttendanceModel {
  final String studentUuid; // طالب علم کی مستقل یونیک آئی ڈی (Cross-Reference Key)
  final String date; // حاضری کی تاریخ (فارمیٹ: YYYY-MM-DD)
  final String status; // Present, Absent, Late, Leave
  final String remarks; // اگر کوئی خاص وجہ یا رخصت کی تفصیل ہو

  AttendanceModel({
    required this.studentUuid,
    required this.date,
    required this.status,
    this.remarks = '',
  });

  /// JSON یا لوکل اسٹوریج کے لیے میپ میں تبدیل کرنا
  Map<String, dynamic> toMap() {
    return {
      'studentUuid': studentUuid,
      'date': date,
      'status': status,
      'remarks': remarks,
    };
  }

  /// محفوظ شدہ ڈیٹا کو واپس ایپ میں لوڈ کرنا
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      studentUuid: map['studentUuid'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'Absent',
      remarks: map['remarks'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AttendanceModel.fromJson(String source) => AttendanceModel.fromMap(json.decode(source));
}
