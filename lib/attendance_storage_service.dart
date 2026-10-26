import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'attendance_model.dart';

/// **آف لائن حاضری اسٹوریج سروس (Offline Attendance Storage)**
class AttendanceStorageService {

  /// موبائل میموری میں اٹینڈنس فائل کا راستہ تلاش کرنا
  Future<File> _getAttendanceFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/smart_school_attendance.json');
  }

  /// **پوری کلاس کی حاضری ایک ساتھ آف لائن محفوظ کرنا (Save Bulk Attendance)**
  Future<void> saveClassAttendance(List<AttendanceModel> newRecords) async {
    try {
      final file = await _getAttendanceFile();
      List<AttendanceModel> allRecords = await loadAllAttendanceRecords();

      for (var newRecord in newRecords) {
        // سخت چیکنگ: اگر اس بچے کی اس تاریخ کی حاضری پہلے سے موجود ہو تو پرانی انٹری ہٹا دیں (Overwrite/Update Check)
        allRecords.removeWhere((rec) => 
          rec.studentUuid == newRecord.studentUuid && rec.date == newRecord.date
        );
        // نیا ریکارڈ شامل کریں
        allRecords.add(newRecord);
      }

      // فائل میں ڈیٹا رائٹ (Write) کرنا
      List<Map<String, dynamic>> mappedList = allRecords.map((r) => r.toMap()).toList();
      await file.writeAsString(json.encode(mappedList));
    } catch (e) {
      rethrow;
    }
  }

  /// **تمام حاضری کا ریکارڈ لوڈ کرنا**
  Future<List<AttendanceModel>> loadAllAttendanceRecords() async {
    try {
      final file = await _getAttendanceFile();
      if (!await file.exists()) return [];

      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return [];

      List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => AttendanceModel.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// **کسی خاص تاریخ اور اسٹوڈنٹ کی حاضری کا اسٹیٹس معلوم کرنا**
  Future<String?> getStudentStatusForDate(String studentUuid, String date) async {
    List<AttendanceModel> allRecords = await loadAllAttendanceRecords();
    try {
      final record = allRecords.firstWhere((rec) => 
        rec.studentUuid == studentUuid && rec.date == date
      );
      return record.status;
    } catch (e) {
      return null; // اگر حاضری نہ لگی ہو
    }
  }
}
