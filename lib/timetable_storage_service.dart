import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'timetable_model.dart';

class TimetableStorageService {
  
  Future<File> _getTimetableFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/smart_school_timetable.json');
  }

  /// **نیا پیریڈ محفوظ کرنا اور ٹائم ٹیبل کلیش چیک کرنا (Conflict Detection)**
  Future<void> savePeriodSchedule(TimetableModel newSchedule) async {
    try {
      final file = await _getTimetableFile();
      List<TimetableModel> allSchedules = await loadAllSchedules();

      // کلیش نمبر 1: کیا یہ ٹیچر اس دن، اس پیریڈ میں پہلے ہی کسی اور کلاس میں مصروف تو نہیں؟
      bool isTeacherBusy = allSchedules.any((s) => 
        s.dayOfWeek == newSchedule.dayOfWeek && 
        s.periodNumber == newSchedule.periodNumber && 
        s.teacherName == newSchedule.teacherName &&
        !(s.classLevel == newSchedule.classLevel && s.sectionName == newSchedule.sectionName)
      );

      if (isTeacherBusy) {
        throw Exception("ٹائم ٹیبل کلیش! یہ ٹیچر اس پیریڈ میں پہلے ہی دوسری کلاس میں پڑھا رہے ہیں۔");
      }

      // اگر اسی کلاس کا یہ پیریڈ پہلے سے سیٹ تھا، تو اسے اپڈیٹ (Overwrite) کر دیں
      allSchedules.removeWhere((s) => 
        s.classLevel == newSchedule.classLevel && 
        s.sectionName == newSchedule.sectionName && 
        s.dayOfWeek == newSchedule.dayOfWeek && 
        s.periodNumber == newSchedule.periodNumber
      );

      allSchedules.add(newSchedule);

      // فائل میں رائٹ کرنا
      List<Map<String, dynamic>> mappedList = allSchedules.map((s) => s.toMap()).toList();
      await file.writeAsString(json.encode(mappedList));
    } catch (e) {
      rethrow;
    }
  }

  /// **تمام شیڈول لوڈ کرنا**
  Future<List<TimetableModel>> loadAllSchedules() async {
    try {
      final file = await _getTimetableFile();
      if (!await file.exists()) return [];

      String jsonString = await file.readAsString();
      if (jsonString.isEmpty) return [];

      List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => TimetableModel.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// **کسی خاص کلاس کا پورے ہفتے کا ٹائم ٹیبل حاصل کرنا**
  Future<List<TimetableModel>> getClassTimetable(String classLevel, String section) async {
    List<TimetableModel> all = await loadAllSchedules();
    return all.where((s) => s.classLevel == classLevel && s.sectionName == section).toList();
  }
}
