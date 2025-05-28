import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CategoryPage.dart';
import 'SinglePlayerPage.dart';
import 'MultiPlayerPage.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool isTestTab = true;
  List<Map<String, dynamic>> gameHistory = [];
  bool isLoadingHistory = true;
  String? currentUserId;

  // Data kategori dengan mapping image
  final Map<String, Map<String, String>> categoryData = {
    'matematika_questions': {
      'title': 'Matematika',
      'image': 'assets/images/math.jpg',
    },
    'sains_questions': {
      'title': 'Sains',
      'image': 'assets/images/science.jpg',
    },
    'sejarah_questions': {
      'title': 'Sejarah',
      'image': 'assets/images/history.jpg',
    },
    'english_questions': {
      'title': 'Bahasa Inggris',
      'image': 'assets/images/english.jpg',
    },
  };

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadGameHistory();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<void> _loadGameHistory() async {
    if (currentUserId == null) {
      setState(() {
        isLoadingHistory = false;
      });
      return;
    }

    try {
      QuerySnapshot historySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId!)
          .collection('history')
          .orderBy('gameEndTime', descending: true) // Urutkan berdasarkan waktu terbaru
          .limit(10) // Batasi 10 history terbaru
          .get();

      List<Map<String, dynamic>> loadedHistory = [];

      for (var doc in historySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Ambil data kategori berdasarkan collectionName
        String collectionName = data['collectionName'] ?? '';
        Map<String, String>? categoryInfo = categoryData[collectionName];

        // Jika ada info kategori, gunakan image dari mapping, jika tidak gunakan yang tersimpan
        if (categoryInfo != null) {
          data['categoryImage'] = categoryInfo['image']!;
          data['categoryTitle'] = categoryInfo['title']!;
        }

        loadedHistory.add(data);
      }

      setState(() {
        gameHistory = loadedHistory;
        isLoadingHistory = false;
      });
    } catch (e) {
      print('Error loading game history: $e');
      setState(() {
        isLoadingHistory = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                'QUIZ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Tab Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isTestTab = true),
                    child: Column(
                      children: [
                        Text(
                          "Test your skills",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isTestTab ? Colors.black : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 2,
                          width: 60,
                          color: isTestTab ? Colors.black : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => setState(() => isTestTab = false),
                    child: Column(
                      children: [
                        Text(
                          "PVP",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !isTestTab ? Colors.black : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 2,
                          width: 40,
                          color: !isTestTab ? Colors.black : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tampilkan konten berdasarkan tab
              if (isTestTab)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryPage(),
                          ),
                        ).then((_) {
                          // Refresh history ketika kembali dari quiz
                          _loadGameHistory();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Start Quiz"),
                    ),
                    const SizedBox(height: 24),

                    // History Section
                    Row(
                      children: [
                        const Text(
                          'Recent Games',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (gameHistory.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/history');
                            },
                            child: const Text('View All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // History Cards
                    if (isLoadingHistory)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (gameHistory.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No game history yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Start a quiz to see your progress!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...gameHistory.map((history) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Category Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    history['categoryImage'] ?? 'assets/images/default.jpg',
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.quiz,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Game Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        history['categoryTitle'] ?? 'Unknown Category',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.score,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Score: ${history['score'] ?? 0}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.percent,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${history['percentage'] ?? 0}%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDuration(history['timeSpent'] ?? 0),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            _formatTimestamp(history['gameEndTime']),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Performance Indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (history['percentage'] ?? 0) >= 80
                                        ? Colors.green[100]
                                        : (history['percentage'] ?? 0) >= 60
                                        ? Colors.orange[100]
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (history['percentage'] ?? 0) >= 80
                                        ? 'Excellent'
                                        : (history['percentage'] ?? 0) >= 60
                                        ? 'Good'
                                        : 'Need Practice',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: (history['percentage'] ?? 0) >= 80
                                          ? Colors.green[800]
                                          : (history['percentage'] ?? 0) >= 60
                                          ? Colors.orange[800]
                                          : Colors.red[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                )
              else
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SinglePlayerPage(),
                          ),
                        );
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Single Player",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SinglePlayerPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                )
              ,
            ],
          ),
        ),
      ),
    );
  }
}