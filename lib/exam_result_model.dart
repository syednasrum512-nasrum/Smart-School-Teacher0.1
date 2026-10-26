import 'dart:convert';

/// **امتحانی رزلٹ کا ڈیٹا بیس ماڈل (Exam Result Model)**
/// یہ ماڈل ہر بچے کے انفرادی مضمون کے امتحانی نمبرز کو سنبھالتا ہے۔
class ExamResultModel {
  final String studentUuid; // طالب علم کی مستقل یونیک آئی ڈی (Cross-Reference Key)
  final String examType; // امتحانی قسم: Monthly Test / Mid Term / Annual Exam
  final String subjectName; // مضمون کا نام: Mathematics, Urdu, English وغیرہ
  final String academicYear; // تعلیمی سال: 2026-2027
  
  final double totalMarks; // مضمون کے کل نمبر
  final double obtainedMarks; // بچے کے حاصل کردہ نمبر
  final String teacherRemarks; // استاد کے تعلیمی ریمارکس
  final bool isAbsent; // کیا بچہ امتحان میں غیر حاضر تھا؟

  ExamResultModel({
    required this.studentUuid,
    required this.examType,
    required this.subjectName,
    required this.academicYear,
    required this.totalMarks,
    required this.obtainedMarks,
    this.teacherRemarks = '',
    this.isAbsent = false,
  });

  /// ڈیٹا کو لوکل اسٹوریج میں ٹیکسٹ (JSON) کی صورت محفوظ کرنے کے لیے میپ بنانا
  Map<String, dynamic> toMap() {
    return {
      'studentUuid': studentUuid,
      'examType': examType,
      'subjectName': subjectName,
      'academicYear': academicYear,
      'totalMarks': totalMarks,
      'obtainedMarks': isAbsent ? 0.0 : obtainedMarks,
      'teacherRemarks': teacherRemarks,
      'isAbsent': isAbsent,
    };
  }

  /// محفوظ شدہ لوکل ڈیٹا کو واپس ایپ میں لوڈ کرنا
  factory ExamResultModel.fromMap(Map<String, dynamic> map) {
    return ExamResultModel(
      studentUuid: map['studentUuid'] ?? '',
      examType: map['examType'] ?? '',
      subjectName: map['subjectName'] ?? '',
      academicYear: map['academicYear'] ?? '',
      totalMarks: (map['totalMarks'] as num?)?.toDouble() ?? 100.0,
      obtainedMarks: (map['obtainedMarks'] as num?)?.toDouble() ?? 0.0,
      teacherRemarks: map['teacherRemarks'] ?? '',
      isAbsent: map['isAbsent'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExamResultModel.fromJson(String source) => ExamResultModel.fromMap(json.decode(source));
}
