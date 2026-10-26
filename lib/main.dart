import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'admission_form_screen.dart';
import 'attendance_register_screen.dart';
import 'ai_assistant_screen.dart';
import 'marks_entry_screen.dart';
import 'timetable_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartSchoolApp());
}

class SmartSchoolApp extends StatelessWidget {
  const SmartSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart School Management System',
      debugShowCheckedModeBanner: false,
      
      // اردو اور رائٹ ٹو لیفٹ (RTL) سپورٹ کے لیے لوکلائزیشن سیٹ اب
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // انگلش بائی ڈیفالٹ
        Locale('ur', 'PK'), // دیسی اردو لوکلائزیشن
      ],
      
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: 'JameelNoori',
      ),
      home: const HomeScreen(),
    );
  }
}

/// **ایپ کی مین ہوم اسکرین (Dashboard)**
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اسمارٹ اسکول مینجمنٹ سسٹم',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // اسکول لاگو یا خوش آمدید کارڈ (Welcome Card)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.green,
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.school, size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'گورنمنٹ پرائمری اسکول ڈیش بورڈ',
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'پنجاب کریکولم اینڈ ٹیکسٹ بک بورڈ (PCTB) فریم ورک',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            
            const Text(
              'انتظامی موڈیولز (Administrative Menus):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            // 1. داخلہ فارم بٹن
            _buildDashboardButton(
              context: context,
              title: 'نیا داخلہ فارم (Student Admission)',
              subtitle: 'نئے بچوں کا اندراج اور پروفائل ریکارڈ محفوظ کریں',
              icon: Icons.person_add_alt_1,
              color: Colors.green,
              targetScreen: const AdmissionFormScreen(),
            ),
            const SizedBox(height: 15),

            // 2. حاضری رجسٹر بٹن
            _buildDashboardButton(
              context: context,
              title: 'ڈیجیٹل حاضری رجسٹر (Daily Attendance)',
              subtitle: 'روزانہ کی بنیاد پر بچوں کی آف لائن حاضری لگائیں',
              icon: Icons.assignment_turned_in,
              color: Colors.blueAccent,
              targetScreen: const AttendanceRegisterScreen(),
            ),
            const SizedBox(height: 15),

            // 3. اے آئی اسسٹنٹ بٹن (یہاں کالم کے اندر درست جگہ پر ایڈ ہوا ہے)
            _buildDashboardButton(
              context: context,
              title: 'سمارٹ اے آئی ٹیچر اسسٹنٹ (AI Paper Maker)',
              subtitle: 'کتاب کی تصویر یا ٹیکسٹ سے خودکار امتحانی پیپر بنائیں',
              icon: Icons.psychology,
              color: Colors.purple,
              targetScreen: const AIAssistantScreen(),
            ),
          ],
        ),
      ),
    );
  }

  // مینو بٹنز بنانے کے لیے ایک خوبصورت ہیلپر فنکشن
  Widget _buildDashboardButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget targetScreen,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 25,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
// main.dart کے کالم میں نیچے یہ کوڈ ایڈ کریں:
const SizedBox(height: 15),

_buildDashboardButton(
  context: context,
  title: 'امتحانی رزلٹ کارڈ (Exams & Report Cards)',
  subtitle: 'بچوں کے نمبر درج کریں اور پرنٹ ایبل رزلٹ پی ڈی ایف بنائیں',
  icon: Icons.analytics,
  color: Colors.orangeDeep,
  targetScreen: const MarksEntryScreen(), // مارکس اسکرین کھولے گا
),
// main.dart کے کالم میں نیچے یہ کوڈ ایڈ کریں:
const SizedBox(height: 15),

_buildDashboardButton(
  context: context,
  title: 'کلاس ٹائم ٹیبل شیڈولر (Timetable)',
  subtitle: 'اسکول پیریڈز مینیج کریں اور اساتذہ کا ٹکراؤ روکیں',
  icon: Icons.calendar_view_week,
  color: Colors.teal,
  targetScreen: const TimetableScreen(), // ٹائم ٹیبل اسکرین کھولے گا
),