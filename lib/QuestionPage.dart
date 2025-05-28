import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuestionPage extends StatefulWidget {
  final String categoryTitle;
  final String collectionName;
  final String categoryImage; // Tambahkan parameter image

  const QuestionPage({
    super.key,
    required this.categoryTitle,
    required this.collectionName,
    required this.categoryImage, // Tambahkan required image
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool isLoading = true;
  Timer? timer;
  int timeLeft = 300; // 5 minutes in seconds
  bool quizCompleted = false;
  String? currentUserName;
  String? currentUserId;
  DateTime? gameStartTime; // Tambahkan untuk tracking waktu mulai

  @override
  void initState() {
    super.initState();
    gameStartTime = DateTime.now(); // Set waktu mulai game
    _getCurrentUser();
    _loadQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;

      // Ambil nama user dari Firestore
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            currentUserName = userDoc.get('name') ?? user.displayName ?? 'Anonymous';
          });
        } else {
          setState(() {
            currentUserName = user.displayName ?? 'Anonymous';
          });
        }
      } catch (e) {
        setState(() {
          currentUserName = user.displayName ?? 'Anonymous';
        });
      }
    }
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        _completeQuiz();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadQuestions() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .get();

      setState(() {
        questions = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _nextQuestion() {
    if (selectedAnswer != null) {
      // Check if answer is correct
      if (selectedAnswer == questions[currentQuestionIndex]['correctAnswer']) {
        score += 20; // Add 20 points per correct answer
      }

      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
        });
      } else {
        _completeQuiz();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer')),
      );
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        selectedAnswer = null;
      });
    }
  }

  Future<void> _saveScoreToFirestore() async {
    if (currentUserId == null || currentUserName == null) return;

    try {
      // Ambil skor saat ini dari Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId!)
          .get();

      int currentFirestoreScore = 0;
      if (userDoc.exists) {
        currentFirestoreScore = userDoc.get('skor') ?? 0;
      }

      // Update skor dengan menambahkan skor quiz saat ini
      int newTotalScore = currentFirestoreScore + score;

      // Simpan atau update data user di Firestore (tanpa category)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId!)
          .set({
        'name': currentUserName!,
        'skor': newTotalScore,
        'lastPlayed': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Score saved successfully: $newTotalScore');
    } catch (e) {
      print('Error saving score: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving score: $e')),
      );
    }
  }

  Future<void> _saveGameHistory() async {
    if (currentUserId == null || currentUserName == null) return;

    try {
      DateTime gameEndTime = DateTime.now();
      int gameDuration = gameEndTime.difference(gameStartTime!).inSeconds;
      int correctAnswers = score ~/ 20;
      double percentage = (correctAnswers / questions.length) * 100;

      // Simpan history game ke subcollection history di dalam document user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId!)
          .collection('history')
          .add({
        'categoryTitle': widget.categoryTitle,
        'categoryImage': widget.categoryImage,
        'collectionName': widget.collectionName,
        'score': score,
        'totalQuestions': questions.length,
        'correctAnswers': correctAnswers,
        'percentage': percentage.round(),
        'timeSpent': gameDuration, // waktu dalam detik
        'timeLeft': timeLeft, // sisa waktu ketika selesai
        'gameStartTime': Timestamp.fromDate(gameStartTime!),
        'gameEndTime': Timestamp.fromDate(gameEndTime),
        'completed': quizCompleted, // true jika selesai semua soal, false jika habis waktu
        'playerName': currentUserName!,
      });

      print('Game history saved successfully');
    } catch (e) {
      print('Error saving game history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving game history: $e')),
      );
    }
  }

  void _completeQuiz() async {
    timer?.cancel();
    setState(() {
      quizCompleted = true;
    });

    // Simpan skor ke Firestore
    await _saveScoreToFirestore();

    // Simpan history game
    await _saveGameHistory();

    _showResultDialog();
  }

  void _showResultDialog() {
    int correctAnswers = score ~/ 20;
    double percentage = (correctAnswers / questions.length) * 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Completed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tampilkan image kategori di dialog
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  widget.categoryImage,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.categoryTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Your Score: $score'),
              Text('Total Questions: ${questions.length}'),
              Text('Correct Answers: $correctAnswers'),
              Text('Percentage: ${percentage.round()}%'),
              const SizedBox(height: 10),
              const Text(
                'Your score has been added to the leaderboard!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to category page
              },
              child: const Text('Back to Categories'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to category page
                // Navigate to leaderboard page
                Navigator.pushNamed(context, '/leaderboard');
              },
              child: const Text('View Leaderboard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to category page
                // Navigate to history page
                Navigator.pushNamed(context, '/history');
              },
              child: const Text('View History'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  widget.categoryImage,
                  height: 24,
                  width: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.quiz,
                        color: Colors.grey,
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.categoryTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading questions...'),
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  widget.categoryImage,
                  height: 24,
                  width: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.quiz,
                        color: Colors.grey,
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.categoryTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('No questions available'),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                widget.categoryImage,
                height: 24,
                width: 24,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.quiz,
                      color: Colors.grey,
                      size: 16,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.categoryTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User info and Score & Time Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Player: ${currentUserName ?? 'Loading...'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Score: $score',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Time left: ${_formatTime(timeLeft)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: timeLeft < 60 ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question number indicator
              Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Question Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  currentQuestion['question'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Answer choices
              ...List.generate(
                currentQuestion['options'].length,
                    (index) {
                  final option = currentQuestion['options'][index];
                  final isSelected = selectedAnswer == option;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _selectAnswer(option),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue[800] : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Back and Next Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: currentQuestionIndex > 0 ? _previousQuestion : null,
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedAnswer != null ? Colors.blue : Colors.grey[300],
                      foregroundColor: selectedAnswer != null ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: selectedAnswer != null ? _nextQuestion : null,
                    child: Text(
                        currentQuestionIndex == questions.length - 1 ? "Finish" : "Next"
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}