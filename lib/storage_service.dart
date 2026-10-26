import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'student_model.dart';

/// **آف لائن ڈیٹا بیس سروس (Offline Storage Service)**
/// یہ کلاس انٹرنیٹ کے بغیر بچوں کا ڈیٹا موبائل کی میموری میں محفوظ اور لوڈ کرتی ہے۔
class StorageService {
  
  /// **موبائل میموری کے اندر اسکول فائل کا راستہ تلاش کرنا**
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/smart_school_students.json');
  }

  /// **نیا طالب علم آف لائن محفوظ کرنا (Save Student Offline)**
  Future<void> saveStudentOffline(StudentModel newStudent) async {
    try {
      final file = await _getLocalFile();
      List<StudentModel> currentStudents = await loadAllStudents();

      // چیک کرنا کہ کہیں یہ داخلہ نمبر پہلے سے موجود تو نہیں (Duplicate Prevention)
      bool isDuplicate = currentStudents.any((s) => s.admissionNumber == newStudent.admissionNumber);
      if (isDuplicate) {
        throw Exception("یہ داخلہ نمبر پہلے سے موجود ہے (Duplicate Admission Number)");
      }

      // لسٹ میں نیا بچہ شامل کریں
      currentStudents.add(newStudent);

      // پوری لسٹ کو واپس ٹیکسٹ (JSON) میں بدلیں
      List<Map<String, dynamic>> mappedList = currentStudents.map((s) => s.toMap()).toList();
      String jsonString = json.encode(mappedList);

      // موبائل کی میموری میں فائل رائٹ (Write) کریں
      await file.writeAsString(jsonString);
    } catch (e) {
      rethrow;
    }
  }

  /// **تمام بچوں کا ریکارڈ آف لائن لوڈ کرنا (Load All Students)**
  Future<List<StudentModel>> loadAllStudents() async {
    try {
      final file = await _getLocalFile();

      // اگر فائل موجود نہیں ہے تو خالی لسٹ بھیجیں
      if (!await file.exists()) {
        return [];
      }

      // فائل سے ڈیٹا پڑھیں
      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return [];

      List<dynamic> jsonList = json.decode(jsonString);
      
      // ٹیکسٹ کو واپس اسٹوڈنٹ ماڈل کی لسٹ میں تبدیل کریں
      return jsonList.map((jsonItem) => StudentModel.fromMap(jsonItem)).toList();
    } catch (e) {
      return [];
    }
  }

  /// **کلاس اور سیکشن کے حساب سے بچوں کی لسٹ نکالنا (Filter by Class)**
  Future<List<StudentModel>> getStudentsByClass(String className, String section) async {
    List<StudentModel> allStudents = await loadAllStudents();
    
    // صرف وہی بچے نکالیں جو ایک مخصوص کلاس اور سیکشن میں ہیں اور ایکٹو ہیں
    return allStudents.where((student) => 
      student.currentClass == className && 
      student.currentSection == section && 
      student.isActive
    ).toList();
  }
}
