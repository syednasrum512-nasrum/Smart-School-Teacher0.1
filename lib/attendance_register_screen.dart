import 'package:flutter/material.dart';
import 'student_model.dart';
import 'storage_service.dart';
import 'attendance_model.dart';
import 'attendance_storage_service.dart';

class AttendanceRegisterScreen extends StatefulWidget {
  const AttendanceRegisterScreen({super.key});

  @override
  State<AttendanceRegisterScreen> createState() => _AttendanceRegisterScreenState();
}

class _AttendanceRegisterScreenState extends State<AttendanceRegisterScreen> {
  final _studentStorage = StorageService();
  final _attendanceStorage = AttendanceStorageService();

  String _selectedClass = 'Class 1';
  String _selectedSection = 'A';
  String _currentDate = '';

  List<StudentModel> _students = [];
  Map<String, String> _attendanceStatus = {}; // {studentUuid: status}
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // آج کی تاریخ سیٹ کرنا (Format tracking)
    final now = DateTime.now();
    _currentDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _loadClassStudents();
  }

  // منتخب کلاس کے بچوں کو میموری سے لوڈ کرنا
  Future<void> _loadClassStudents() async {
    setState(() => _isLoading = true);
    
    // بچوں کی لسٹ لوڈ کریں
    List<StudentModel> classStudents = await _studentStorage.getStudentsByClass(_selectedClass, _selectedSection);
    
    // رول نمبر کے حساب سے ترتیب دیں (Sort roster)
    classStudents.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));

    // حاضری کا ڈیفالٹ اسٹیٹس 'Present' سیٹ کریں
    Map<String, String> initialStatus = {};
    for (var student in classStudents) {
      // اگر پہلے سے حاضری لگی ہوئی ہے تو وہ لوڈ کریں، ورنہ Present رکھیں
      String? existingStatus = await _attendanceStorage.getStudentStatusForDate(student.uuid, _currentDate);
      initialStatus[student.uuid] = existingStatus ?? 'Present';
    }

    setState(() {
      _students = classStudents;
      _attendanceStatus = initialStatus;
      _isLoading = false;
    });
  }

  // پوری کلاس کی حاضری سیو کرنے کا فنکشن
  Future<void> _submitAttendance() async {
    if (_students.isEmpty) {
      _showSnackBar("اس کلاس میں کوئی طالب علم موجود نہیں ہے");
      return;
    }

    List<AttendanceModel> recordsToSave = [];
    _attendanceStatus.forEach((uuid, status) {
      recordsToSave.add(AttendanceModel(
        studentUuid: uuid,
        date: _currentDate,
        status: status,
      ));
    });

    try {
      await _attendanceStorage.saveClassAttendance(recordsToSave);
      _showSnackBar("آج کی حاضری کامیابی سے محفوظ ہو گئی ہے! 📝✅");
    } catch (e) {
      _showSnackBar("حاضری محفوظ کرنے میں خرابی: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontFamily: 'JameelNoori', fontSize: 16)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ڈیجیٹل حاضری رجسٹر (Attendance)', style: TextStyle(fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Column(
        children: [
          // کلاس اور سیکشن سلیکٹر فلٹر (Top bar filter structure)
          Container(
            color: Colors.blueAccent.withOpacity(0.1),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: const InputDecoration(labelText: 'Class / جماعت', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), border: OutlineInputBorder()),
                    items: ['Nursery', 'KG', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      _selectedClass = val!;
                      _loadClassStudents();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSection,
                    decoration: const InputDecoration(labelText: 'Section / سیکشن', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), border: OutlineInputBorder()),
                    items: ['A', 'B', 'C'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      _selectedSection = val!;
                      _loadClassStudents();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // تاریخ کی پٹی (Date indicator band)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("حاضری کی تاریخ: $_currentDate", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),

          // بچوں کی لسٹ (Roster multi-grid view allocation)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text("اس کلاس میں کوئی بچہ نہیں ملا۔ پہلے داخلہ فارم بھریں۔", style: TextStyle(fontSize: 14)))
                    : ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          final currentStatus = _attendanceStatus[student.uuid] ?? 'Present';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // بچے کا نام اور رول نمبر
                                  Text(
                                    "رول نمبر ${student.rollNumber}: ${student.firstName} (ولد: ${student.fatherName})",
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  
                                  // حاضری کے آپشنز (Present, Absent, Leave, Late Radio buttons)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatusRadio(student.uuid, 'Present', 'حاضر', Colors.green),
                                      _buildStatusRadio(student.uuid, 'Absent', 'غیر حاضر', Colors.red),
                                      _buildStatusRadio(student.uuid, 'Leave', 'رخصت', Colors.orange),
                                      _buildStatusRadio(student.uuid, 'Late', 'دیر سے', Colors.amber),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // محفوظ کرنے کا بٹن
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _submitAttendance,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 8),
                  Text('حاضری رجسٹر محفوظ کریں (Save Attendance)', style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ریڈیو بٹن بنانے کا ہیلپر فنکشن
  Widget _buildStatusRadio(String studentUuid, String statusValue, String label, Color color) {
    bool isSelected = _attendanceStatus[studentUuid] == statusValue;
    return InkWell(
      onTap: () {
        setState(() {
          _attendanceStatus[studentUuid] = statusValue;
        });
      },
      child: Row(
        children: [
          Radio<String>(
            value: statusValue,
            groupValue: _attendanceStatus[studentUuid],
            activeColor: color,
            onChanged: (val) {
              setState(() {
                _attendanceStatus[studentUuid] = val!;
              });
            },
          ),
          Text(label, style: TextStyle(fontSize: 13, color: isSelected ? color : Colors.black54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
