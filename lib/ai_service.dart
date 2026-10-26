import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // گوگل جیمنائی کی مفت API Key (آپ کو گوگل اے آئی اسٹوڈیو سے مفت مل جائے گی)
  final String _apiKey = "YOUR_GEMINI_API_KEY_HERE"; 

  /// **1. صرف مضمون یا ٹاپک کا نام لکھ کر پیپر بنانا**
  Future<String> generatePaperFromText(String promptText) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      
      final systemInstruction = """
      آپ ایک پاکستانی اسکول کے سینئر استاد ہیں۔ پنجاب کریکولم اینڈ ٹیکسٹ بک بورڈ (PCTB) کے سلیبس کے مطابق ایک پروفیشنل سوالیہ پیپر تیار کریں۔ 
      پیپر میں اسکول کا نام، کلاس، کل نمبر، اور وقت کی جگہ چھوڑیں۔ 
      پیپر میں کثیر الانتخابی سوالات (MCQs)، خالی جگہیں پُر کریں، اور مختصر سوالات شامل کریں۔ 
      زبان کا خاص خیال رکھیں، اگر اردو کا ٹاپک ہے تو پیپر مکمل اردو میں ہونا چاہیے اور فارمیٹ پرنٹنگ کے لیے پرفیکٹ ہو۔
      """;

      final response = await model.generateContent([
        Content.text("$systemInstruction\n\nٹاپک یہ ہے: $promptText")
      ]);
      
      return response.text ?? "اے آئی جواب جنریٹ نہیں کر سکا۔ دوبارہ کوشش کریں۔";
    } catch (e) {
      return "اے آئی سروس میں خرابی: ${e.toString()}";
    }
  }

  /// **2. کتاب کے صفحے کی تصویر سے پیپر بنانا (Image to Paper)**
  Future<String> generatePaperFromImage(File imageFile, String instructions) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      
      // تصویر کو بائٹس (Bytes) میں تبدیل کرنا
      final imageBytes = await imageFile.readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);

      final prompt = TextPart("""
      اس تصویر کو غور سے دیکھیں۔ یہ پاکستان کی اسکول کی کتاب کا ایک صفحہ ہے۔ 
      اس صفحے کے اندر موجود معلومات، اسباق یا مشق کو استعمال کرتے ہوئے ایک امتحانی پیپر تیار کریں۔
      اضافی ہدایات یہ ہیں: $instructions
      پیپر کا فارمیٹ خوبصورت اور پرنٹنگ کے قابل ہونا چاہیے جس میں نمبرز کی تقسیم واضح ہو۔
      """);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      return response.text ?? "تصویر سے پیپر جنریٹ نہیں ہو سکا۔";
    } catch (e) {
      return "تصویر پروسیس کرنے میں خرابی: ${e.toString()}";
    }
  }
}
