import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _textController = TextEditingController();
  final _aiService = AIService();
  final _imagePicker = ImagePicker();
  
  File? _selectedImage;
  String _aiResult = "";
  bool _isLoading = false;

  // کیمرے یا گیلری سے تصویر لینا
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // پیپر جنریٹ کرنے کا مین فنکشن
  Future<void> _startGeneration() async {
    if (_textController.text.isEmpty && _selectedImage == null) {
      _showSnackBar("براہ کرم کوئی ٹاپک لکھیں یا کتاب کے صفحے کی تصویر سلیکٹ کریں!");
      return;
    }

    setState(() {
      _isLoading = true;
      _aiResult = "اے آئی آپ کا پیپر تیار کر رہا ہے، براہ کرم چند سیکنڈ انتظار کریں...";
    });

    String result = "";
    if (_selectedImage != null) {
      // اگر تصویر سلیکٹڈ ہے
      result = await _aiService.generatePaperFromImage(_selectedImage!, _textController.text);
    } else {
      // اگر صرف ٹیکسٹ لکھا ہے
      result = await _aiService.generatePaperFromText(_textController.text);
    }

    setState(() {
      _aiResult = result;
      _isLoading = false;
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اسمارٹ اے آئی ٹیچر اسسٹنٹ', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // اے آئی تعارفی کارڈ
            Card(
              color: Colors.purple.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.psychology, size: 40, color: Colors.purple),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'یہ اے آئی ٹول کتاب کی تصویر سے یا آپ کے لکھے گئے ٹاپک سے پنجاب بورڈ (PCTB) کے مطابق خودکار پیپر تیار کر سکتا ہے۔',
                        style: TextStyle(fontSize: 13, color: Colors.purple, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ٹیکسٹ ان پٹ
            TextFormField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ٹاپک کا نام یا اے آئی کے لیے خصوصی ہدایات لکھیں',
                hintText: 'مثال: جماعت چہارم ریاضی چیپٹر 2 کا 20 نمبر کا ٹیسٹ بنائیں...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // تصویر سلیکٹ کرنے کا مینو
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('کیمرے سے تصویر لیں'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text('گیلری سے اٹھائیں'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
                ),
              ],
            ),

            // اگر تصویر سلیکٹ ہو تو اس کا پری ویو دکھانا
            if (_selectedImage != null) ...[
              const SizedBox(height: 10),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 20),

            // بٹن رن کرنا
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _isLoading ? null : _startGeneration,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('اے آئی پیپر جنریٹ کریں (Generate Paper)', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 20),

            // رزلٹ دکھانے کا ایریا (AI Result Display Area)
            const Text('تیار شدہ پیپر (Generated Output):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _aiResult.isEmpty ? "آپ کا تیار کردہ پیپر یہاں ظاہر ہوگا..." : _aiResult,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
