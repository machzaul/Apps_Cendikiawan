import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'upload_questions.dart'; // pastikan path-nya benar

import 'QuizPage.dart';
import 'LeaderboardPage.dart';
import 'SettingsPage.dart';
import 'LoginPage.dart'; // ✅ tambahkan halaman login
import 'utils/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar color
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
  AudioManager().playBackgroundMusic();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cendikiawan Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          elevation: 10,
        ),
      ),
      // ⬇️ Gunakan StreamBuilder untuk cek login
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            return const RootPage(); // ✅ user sudah login
          } else {
            return const LoginPage(); // ❌ belum login
          }
        },
      ),
    );
  }
}

class RootPage extends StatefulWidget {
  final int startIndex;
  const RootPage({super.key, this.startIndex = 0});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.startIndex;
  }

  final List<Widget> _pages = const [
    QuizPage(),
    LeaderboardPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('assets/logo/checklist.png', width: 30, height: 30),
              activeIcon: Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(width: 2, color: Colors.black)),
                ),
                child: Image.asset('assets/logo/checklist.png', width: 30, height: 30),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/logo/podium.png', width: 30, height: 30),
              activeIcon: Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(width: 2, color: Colors.black)),
                ),
                child: Image.asset('assets/logo/podium.png', width: 30, height: 30),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/logo/settings1.png', width: 30, height: 30),
              activeIcon: Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(width: 2, color: Colors.black)),
                ),
                child: Image.asset('assets/logo/settings1.png', width: 30, height: 30),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
