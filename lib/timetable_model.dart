import 'dart:convert';

/// **ٹائم ٹیبل کا ڈیٹا بیس ماڈل (Timetable Model)**
class TimetableModel {
  final String classLevel; // جیسے: Class 1, Class 5
  final String sectionName; // جیسے: A, B
  final String dayOfWeek; // Monday, Tuesday وغیرہ
  final int periodNumber; // 1st Period, 2nd Period (1 سے 8 تک)
  
  final String subjectName; // مضمون کا نام
  final String teacherName; // ٹیچر کا نام

  TimetableModel({
    required this.classLevel,
    required this.sectionName,
    required this.dayOfWeek,
    required this.periodNumber,
    required this.subjectName,
    required this.teacherName,
  });

  Map<String, dynamic> toMap() {
    return {
      'classLevel': classLevel,
      'sectionName': sectionName,
      'dayOfWeek': dayOfWeek,
      'periodNumber': periodNumber,
      'subjectName': subjectName,
      'teacherName': teacherName,
    };
  }

  factory TimetableModel.fromMap(Map<String, dynamic> map) {
    return TimetableModel(
      classLevel: map['classLevel'] ?? '',
      sectionName: map['sectionName'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      periodNumber: map['periodNumber']?.toInt() ?? 1,
      subjectName: map['subjectName'] ?? '',
      teacherName: map['teacherName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TimetableModel.fromJson(String source) => TimetableModel.fromMap(json.decode(source));
}
