import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProfilePage.dart';
import 'LoginPage.dart';
import 'utils/audio_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _currentVolume = AudioManager().volume;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));

    // Jalankan musik jika belum jalan
    AudioManager().playBackgroundMusic();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'SETTING',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Profile Card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage('assets/logo/avatar.jpg'),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Cendikiawan Quiz',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Edit Profile Details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),

            // Pengaturan Volume Musik
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Music Volume",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: _currentVolume,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    label: (_currentVolume * 100).toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _currentVolume = value;
                        AudioManager().setVolume(value);
                      });
                    },
                  ),
                ],
              ),
            ),

            // // Dummy Boxes
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 32),
            //   child: Column(
            //     children: List.generate(3, (index) {
            //       return Container(
            //         height: 60,
            //         margin: const EdgeInsets.only(bottom: 16),
            //         decoration: BoxDecoration(
            //           color: Colors.grey[300],
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //       );
            //     }),
            //   ),
            // ),

            const Spacer(),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: logout,
                  child: const Text(
                    'LOG OUT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
