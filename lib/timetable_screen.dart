import 'package:flutter/material.dart';
import 'timetable_model.dart';
import 'timetable_storage_service.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final _storageService = TimetableStorageService();
  
  String _selectedClass = 'Class 1';
  String _selectedSection = 'A';
  String _selectedDay = 'Monday';
  
  // نئے پیریڈ کا ڈیٹا درج کرنے کے فارم فیلڈز
  int _selectedPeriod = 1;
  final _subjectController = TextEditingController();
  final _teacherController = TextEditingController();

  List<TimetableModel> _activeTimetable = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentTimetable();
  }

  Future<void> _loadCurrentTimetable() async {
    setState(() => _isLoading = true);
    List<TimetableModel> classSchedule = await _storageService.getClassTimetable(_selectedClass, _selectedSection);
    
    // صرف منتخب دن کے پیریڈز فلٹر کرنا
    _activeTimetable = classSchedule.where((s) => s.dayOfWeek == _selectedDay).toList();
    _activeTimetable.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
    
    setState(() => _isLoading = false);
  }

  Future<void> _addPeriodDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('نیا پیریڈ شامل کریں (Add Period)', style: TextStyle(fontFamily: 'JameelNoori', fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedPeriod,
                      decoration: const InputDecoration(labelText: 'پیریڈ نمبر (Period)'),
                      items: [1, 2, 3, 4, 5, 6, 7, 8].map((p) => DropdownMenuItem(value: p, child: Text("Period $p"))).toList(),
                      onChanged: (val) => setDialogState(() => _selectedPeriod = val!),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(labelText: 'مضمون کا نام (Subject)'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _teacherController,
                      decoration: const InputDecoration(labelText: 'ٹیچر کا نام (Teacher)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('کینسل')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () async {
                    if (_subjectController.text.isEmpty || _teacherController.text.isEmpty) return;
                    
                    final newPeriod = TimetableModel(
                      classLevel: _selectedClass,
                      sectionName: _selectedSection,
                      dayOfWeek: _selectedDay,
                      periodNumber: _selectedPeriod,
                      subjectName: _subjectController.text.trim(),
                      teacherName: _teacherController.text.trim(),
                    );

                    try {
                      await _storageService.savePeriodSchedule(newPeriod);
                      _subjectController.clear();
                      _teacherController.clear();
                      Navigator.pop(context);
                      _loadCurrentTimetable();
                      _showSnackBar("پیریڈ کامیابی سے سیٹ ہو گیا ہے! 📅");
                    } catch (e) {
                      _showSnackBar("خرابی: ${e.toString().replaceAll("Exception:", "")}");
                    }
                  },
                  child: const Text('محفوظ کریں', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'JameelNoori'))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ٹائم ٹیبل شیڈولر (School Timetable)', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // ٹاپ سلیکٹر فلٹرز (Top Selection Bar)
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.teal.withOpacity(0.05),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedClass,
                        decoration: const InputDecoration(labelText: 'جماعت', contentPadding: EdgeInsets.symmetric(horizontal: 5), border: OutlineInputBorder()),
                        items: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) { _selectedClass = val!; _loadCurrentTimetable(); },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDay,
                        decoration: const InputDecoration(labelText: 'دن (Day)', contentPadding: EdgeInsets.symmetric(horizontal: 5), border: OutlineInputBorder()),
                        items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (val) { _selectedDay = val!; _loadCurrentTimetable(); },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // ٹائم ٹیبل ڈسپلے لسٹ
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _activeTimetable.isEmpty
                ? const Center(child: Text("اس دن کا کوئی پیریڈ سیٹ نہیں ہے۔ نیا پیریڈ شامل کریں۔"))
                : ListView.builder(
                    itemCount: _activeTimetable.length,
                    itemBuilder: (context, index) {
                      final period = _activeTimetable[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Text("${period.periodNumber}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(period.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("استاد: ${period.teacherName}"),
                          trailing: const Icon(Icons.access_time, color: Colors.teal),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _addPeriodDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
