import 'package:flutter/material.dart';
import 'student_model.dart';
import 'storage_service.dart';
import 'exam_result_model.dart';
import 'exam_storage_service.dart';

class MarksEntryScreen extends StatefulWidget {
  const MarksEntryScreen({super.key});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  final _studentStorage = StorageService();
  final _examStorage = ExamStorageService();

  String _selectedClass = 'Class 1';
  String _selectedSection = 'A';
  String _selectedExam = 'Mid Term';
  String _selectedSubject = 'Mathematics';
  
  final _totalMarksController = TextEditingController(text: '100');
  
  List<StudentModel> _students = [];
  Map<String, TextEditingController> _marksControllers = {}; // {studentUuid: controller}
  Map<String, bool> _absentStatus = {}; // {studentUuid: isAbsent}
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    List<StudentModel> classStudents = await _studentStorage.getStudentsByClass(_selectedClass, _selectedSection);
    classStudents.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));

    Map<String, TextEditingController> controllers = {};
    Map<String, bool> absenties = {};

    // پرانا رزلٹ اگر موجود ہو تو اسے پہلے سے لوڈ کرنا
    List<ExamResultModel> allSavedResults = await _examStorage.loadAllResults();

    for (var student in classStudents) {
      var saved = allSavedResults.firstWhere(
        (r) => r.studentUuid == student.uuid && r.examType == _selectedExam && r.subjectName == _selectedSubject,
        orElse: () => ExamResultModel(studentUuid: student.uuid, examType: _selectedExam, subjectName: _selectedSubject, academicYear: '2026-2027', totalMarks: 100, obtainedMarks: 0),
      );

      controllers[student.uuid] = TextEditingController(text: saved.obtainedMarks > 0 ? saved.obtainedMarks.toString() : '');
      absenties[student.uuid] = saved.isAbsent;
    }

    setState(() {
      _students = classStudents;
      _marksControllers = controllers;
      _absentStatus = absenties;
      _isLoading = false;
    });
  }

  Future<void> _saveResults() async {
    if (_students.isEmpty) return;
    double? totalMarks = double.tryParse(_totalMarksController.text);
    if (totalMarks == null || totalMarks <= 0) {
      _showSnackBar("براہ کرم امتحان کے درست کل نمبر درج کریں");
      return;
    }

    List<ExamResultModel> resultsToSave = [];

    for (var student in _students) {
      bool isAbsent = _absentStatus[student.uuid] ?? false;
      double obtained = 0.0;

      if (!isAbsent) {
        double? enteredMarks = double.tryParse(_marksControllers[student.uuid]!.text);
        if (enteredMarks == null) {
          _showSnackBar("رول نمبر ${student.rollNumber} کے نمبر درج کریں یا غیر حاضر مارک کریں");
          return;
        }
        if (enteredMarks > totalMarks) {
          _showSnackBar("رول نمبر ${student.rollNumber} کے حاصل کردہ نمبر کل نمبر سے زیادہ ہیں!");
          return;
        }
        obtained = enteredMarks;
      }

      resultsToSave.add(ExamResultModel(
        studentUuid: student.uuid,
        examType: _selectedExam,
        subjectName: _selectedSubject,
        academicYear: '2026-2027',
        totalMarks: totalMarks,
        obtainedMarks: obtained,
        isAbsent: isAbsent,
      ));
    }

    try {
      await _examStorage.saveClassResults(resultsToSave);
      _showSnackBar("امتحانی نمبرز کامیابی سے محفوظ ہو گئے ہیں! 📊✅");
    } catch (e) {
      _showSnackBar("خرابی: ${e.toString()}");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'JameelNoori'))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('امتحانی نمبرز کا اندراج (Marks Entry)', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.orangeDeep,
      ),
      body: Column(
        children: [
          // فلٹر پینل (Filters Panel)
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.orange.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedClass,
                        decoration: const InputDecoration(labelText: 'جماعت', border: OutlineInputBorder()),
                        items: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) { _selectedClass = val!; _loadStudents(); },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: const InputDecoration(labelText: 'مضمون', border: OutlineInputBorder()),
                        items: ['Mathematics', 'Urdu', 'English', 'Science', 'Islamiat', 'Social Studies'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) { _selectedSubject = val!; _loadStudents(); },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedExam,
                        decoration: const InputDecoration(labelText: 'امتحان', border: OutlineInputBorder()),
                        items: ['Monthly Test', 'Mid Term', 'Annual Exam'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) { _selectedExam = val!; _loadStudents(); },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _totalMarksController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'کل نمبر (Total)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // طلباء کی لسٹ
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _students.isEmpty 
                ? const Center(child: Text("اس کلاس میں کوئی طالب علم موجود نہیں ہے۔"))
                : ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      bool isAbsent = _absentStatus[student.uuid] ?? false;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text("رول نمبر ${student.rollNumber}\n${student.firstName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _marksControllers[student.uuid],
                                  keyboardType: TextInputType.number,
                                  enabled: !isAbsent,
                                  decoration: InputDecoration(
                                    hintText: isAbsent ? 'غیر حاضر' : 'نمبر لکھیں',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text('غير حاضر', style: TextStyle(fontSize: 12, color: Colors.red)),
                                    Checkbox(
                                      value: isAbsent,
                                      activeColor: Colors.red,
                                      onChanged: (val) {
                                        setState(() {
                                          _absentStatus[student.uuid] = val!;
                                          if (val) _marksControllers[student.uuid]!.clear();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // سیو بٹن
          Padding(
            padding: const EdgeInsets.all(12.0),
