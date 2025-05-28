import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String about = '';
  int quizCount = 0;
  int friendCount = 0;
  int rank = 0;
  bool isLoading = true;
  bool isEditing = false;
  final TextEditingController _aboutController = TextEditingController();

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final allUsers = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('skor', descending: true)
        .get();

    final userData = userDoc.data();
    if (userData != null) {
      name = userData['name'] ?? '';
      about = userData['about'] ?? '';
      quizCount = userData['quiz'] ?? 0;
      friendCount = userData['friend'] ?? 0;

      final index = allUsers.docs.indexWhere((doc) => doc.id == user.uid);
      if (index != -1) {
        rank = index + 1;
      }

      _aboutController.text = about;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveAbout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'about': _aboutController.text.trim(),
    });

    setState(() {
      about = _aboutController.text.trim();
      isEditing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'SETTING',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                saveAbout();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO PROFIL BESAR
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage('assets/logo/avatar.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileStat(value: '$rank', label: 'Rank'),
                      const SizedBox(height: 16),
                      ProfileStat(value: '$quizCount', label: 'Quiz'),
                      const SizedBox(height: 16),
                      ProfileStat(value: '$friendCount', label: 'Friend'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              "Tentang Saya",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            isEditing
                ? TextField(
              controller: _aboutController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Tulis deskripsi tentang dirimu...",
              ),
            )
                : Text(
              about.isNotEmpty
                  ? about
                  : "Halo, saya $name. Saya pengguna setia Cendikiawan Quiz dan selalu berusaha meningkatkan skor saya!",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const ProfileStat({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
