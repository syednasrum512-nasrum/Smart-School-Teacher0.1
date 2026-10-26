import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'exam_result_model.dart';

/// **آف لائن امتحانی رزلٹ اسٹوریج سروس (Offline Exam Storage)**
class ExamStorageService {

  /// موبائل میموری میں رزلٹ فائل کا لوکل ایڈریس حاصل کرنا
  Future<File> _getExamFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/smart_school_exams.json');
  }

  /// **پوری کلاس کے نمبرز ایک ساتھ محفوظ کرنا (Bulk Save Results)**
  Future<void> saveClassResults(List<ExamResultModel> newResults) async {
    try {
      final file = await _getExamFile();
      List<ExamResultModel> allResults = await loadAllResults();

      for (var newResult in newResults) {
        // سخت ویلیڈیشن: حاصل کردہ نمبر کبھی بھی کل نمبر سے زیادہ نہیں ہونے چاہئیں
        if (newResult.obtainedMarks > newResult.totalMarks) {
          throw Exception("حاصل کردہ نمبر کل نمبر سے زیادہ نہیں ہو سکتے!");
        }

        // اگر اس بچے کا اس امتحان کے اس مضمون کا رزلٹ پہلے سے موجود ہو تو اسے اپڈیٹ کریں (Overwriting Check)
        allResults.removeWhere((res) => 
          res.studentUuid == newResult.studentUuid && 
          res.examType == newResult.examType && 
          res.subjectName == newResult.subjectName &&
          res.academicYear == newResult.academicYear
        );
        
        allResults.add(newResult);
      }

      // ڈیٹا کو ٹیکسٹ فارمیٹ میں محفوظ کرنا
      List<Map<String, dynamic>> mappedList = allResults.map((r) => r.toMap()).toList();
      await file.writeAsString(json.encode(mappedList));
    } catch (e) {
      rethrow;
    }
  }

  /// **تمام امتحانی ریکارڈز لوڈ کرنا**
  Future<List<ExamResultModel>> loadAllResults() async {
    try {
      final file = await _getExamFile();
      if (!await file.exists()) return [];

      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return [];

      List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => ExamResultModel.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// **کسی مخصوص طالب علم کا مکمل رزلٹ کارڈ ڈیٹا نکالنا**
  Future<List<ExamResultModel>> getStudentResults(String studentUuid, String examType, String academicYear) async {
    List<ExamResultModel> allResults = await loadAllResults();
    return allResults.where((res) => 
      res.studentUuid == studentUuid && 
      res.examType == examType && 
      res.academicYear == academicYear
    ).toList();
  }
}
