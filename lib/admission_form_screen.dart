import 'package:flutter/material.dart';
import 'student_model.dart';
import 'storage_service.dart';

class AdmissionFormScreen extends StatefulWidget {
  const AdmissionFormScreen({super.key});

  @override
  State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();

  // ان پٹ فیلڈز کے کنٹرولرز
  final _admNumController = TextEditingController();
  final _rollNumController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // ڈیفالٹ سلیکشنز
  String _selectedClass = 'Class 1';
  String _selectedSection = 'A';
  String _selectedGender = 'Male';
  String _academicYear = '2026-2027';

  // ڈیٹا بیس میں محفوظ کرنے کا فنکشن
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    // شناختی کارڈ فارمیٹ چیک کرنا (Length calculation)
    if (_cnicController.text.length < 15) {
      _showSnackBar("براہ کرم والد کا مکمل شناختی کارڈ نمبر ڈیش کے ساتھ درج کریں (15 ہندسے)");
      return;
    }

    // نیا اسٹوڈنٹ آبجیکٹ بنانا
    final newStudent = StudentModel(
      uuid: DateTime.now().microsecondsSinceEpoch.toString(), // موبائل فرینڈلی یونیک آئی ڈی
      admissionNumber: _admNumController.text.trim(),
      rollNumber: int.parse(_rollNumController.text.trim()),
      firstName: _firstNameController.text.trim(),
      lastName: '',
      fatherName: _fatherNameController.text.trim(),
      fatherCnic: _cnicController.text.trim(),
      dateOfBirth: DateTime.now().toString().split(' ')[0], // عارضی ڈیٹ اسائنمنٹ
      gender: _selectedGender,
      address: _addressController.text.trim(),
      emergencyContact: _phoneController.text.trim(),
      currentClass: _selectedClass,
      currentSection: _selectedSection,
      academicYear: _academicYear,
      admissionDate: DateTime.now().toString().split(' ')[0],
    );

    try {
      // آف لائن اسٹوریج میں ڈیٹا محفوظ کرنا
      await _storageService.saveStudentOffline(newStudent);
      _showSnackBar("طالب علم کا ریکارڈ کامیابی سے محفوظ ہو گیا ہے! ✅");
      _clearForm();
    } catch (e) {
      _showSnackBar("خرابی: ${e.toString().replaceAll("Exception:", "")}");
    }
  }

  void _clearForm() {
    _admNumController.clear();
    _rollNumController.clear();
    _firstNameController.clear();
    _fatherNameController.clear();
    _cnicController.clear();
    _phoneController.clear();
    _addressController.clear();
    setState(() {});
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
        title: const Text('نیا داخلہ فارم (New Admission)', style: TextStyle(fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // داخلہ اور رول نمبر (Parallel row structure)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _admNumController,
                      decoration: const InputDecoration(labelText: 'Admission No / داخلہ نمبر', border: OutlineInputBorder()),
                      keyboardType: TextInputType.text,
                      validator: (val) => val!.isEmpty ? 'داخلہ نمبر لازمی ہے' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _rollNumController,
                      decoration: const InputDecoration(labelText: 'Roll No / رول نمبر', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? 'رول نمبر لازمی ہے' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // طالب علم کا نام
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Student Name / طالب علم کا نام', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'نام درج کرنا لازمی ہے' : null,
              ),
              const SizedBox(height: 15),

              // والد کا نام
              TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(labelText: 'Father Name / والد کا نام', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'والد کا نام لازمی ہے' : null,
              ),
              const SizedBox(height: 15),

              // والد کا شناختی کارڈ (CNIC Validator Mask matching)
              TextFormField(
                controller: _cnicController,
                decoration: const InputDecoration(labelText: 'Father CNIC / شناختی کارڈ', hintText: '35202-xxxxxxx-x', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'شناختی کارڈ نمبر لازمی ہے' : null,
              ),
              const SizedBox(height: 15),

              // رابطہ نمبر
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Mobile Number / موبائل نمبر', hintText: '03001234567', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (val) => val!.isEmpty ? 'موبائل نمبر لازمی ہے' : null,
              ),
              const SizedBox(height: 15),

              // کلاس اور سیکشن سلیکشن (Dropdown elements layout)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: const InputDecoration(labelText: 'Class / جماعت', border: OutlineInputBorder()),
                      items: ['Nursery', 'KG', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedClass = val!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSection,
                      decoration: const InputDecoration(labelText: 'Section / سیکشن', border: OutlineInputBorder()),
                      items: ['A', 'B', 'C'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _selectedSection = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // جنڈر سلیکشن
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender / جنس', border: OutlineInputBorder()),
                items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const SizedBox(height: 15),

              // مکمل پتہ
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Home Address / گھر کا پتہ', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'پتہ لکھنا لازمی ہے' : null,
              ),
              const SizedBox(height: 25),

              // بٹن (Submission button execution layout)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _saveForm,
                child: const Text('طالب علم کا اندراج کریں (Save Record)', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
