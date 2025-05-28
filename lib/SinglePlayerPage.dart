import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class SinglePlayerPage extends StatefulWidget {
  final String? roomId; // Optional untuk backward compatibility

  const SinglePlayerPage({super.key, this.roomId});

  @override
  State<SinglePlayerPage> createState() => _SinglePlayerPageState();
}

class _SinglePlayerPageState extends State<SinglePlayerPage> {
  String? currentUserId;
  Map<String, dynamic>? roomData;
  StreamSubscription<DocumentSnapshot>? roomListener;
  bool isLoading = true;
  String? error;

  // Game state
  int currentQuestionIndex = 0;
  int playerScore = 0;
  bool hasAnswered = false;
  Timer? questionTimer;
  int timeLeft = 30; // 30 detik per pertanyaan

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    if (widget.roomId != null) {
      _listenToRoom();
    } else {
      setState(() {
        error = 'Room ID not provided';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    roomListener?.cancel();
    questionTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  void _listenToRoom() {
    if (widget.roomId == null) return;

    roomListener = FirebaseFirestore.instance
        .collection('multiplayer_rooms')
        .doc(widget.roomId!)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        setState(() {
          roomData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });

        // Start game jika room sudah full dan belum playing
        if (roomData!['status'] == 'full') {
          _updateRoomStatus('playing');
          _startQuestionTimer();
        }

        // Handle game state changes
        _handleGameStateChanges();
      } else if (mounted) {
        setState(() {
          error = 'Room not found';
          isLoading = false;
        });
      }
    });
  }

  void _handleGameStateChanges() {
    if (roomData == null) return;

    // Check if both players have answered
    bool player1Answered = roomData!['player1']?['answered'] ?? false;
    bool player2Answered = roomData!['player2']?['answered'] ?? false;

    if (player1Answered && player2Answered && !hasAnswered) {
      // Move to next question or end game
      _moveToNextQuestion();
    }
  }

  Future<void> _updateRoomStatus(String status) async {
    if (widget.roomId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('multiplayer_rooms')
          .doc(widget.roomId!)
          .update({'status': status});
    } catch (e) {
      print('Error updating room status: $e');
    }
  }

  void _startQuestionTimer() {
    questionTimer?.cancel();
    setState(() {
      timeLeft = 30;
      hasAnswered = false;
    });

    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          timeLeft--;
        });

        if (timeLeft <= 0) {
          timer.cancel();
          if (!hasAnswered) {
            _answerQuestion(-1); // Auto submit dengan jawaban salah
          }
        }
      }
    });
  }

  Future<void> _answerQuestion(int selectedIndex) async {
    if (hasAnswered || widget.roomId == null || currentUserId == null) return;

    setState(() {
      hasAnswered = true;
    });

    questionTimer?.cancel();

    try {
      // Check if answer is correct
      List questions = roomData!['questions'] ?? [];
      if (currentQuestionIndex < questions.length) {
        int correctAnswer = questions[currentQuestionIndex]['answerIndex'] ?? 0;
        bool isCorrect = selectedIndex == correctAnswer;

        if (isCorrect) {
          setState(() {
            playerScore += 10; // 10 poin per jawaban benar
          });
        }

        // Update player answer status and score
        String playerKey = _getPlayerKey();
        await FirebaseFirestore.instance
            .collection('multiplayer_rooms')
            .doc(widget.roomId!)
            .update({
          '$playerKey.answered': true,
          '$playerKey.score': playerScore,
        });
      }
    } catch (e) {
      print('Error answering question: $e');
    }
  }

  String _getPlayerKey() {
    if (roomData == null || currentUserId == null) return 'player1';

    String? player1Uid = roomData!['player1']?['uid'];
    return (player1Uid == currentUserId) ? 'player1' : 'player2';
  }

  Future<void> _moveToNextQuestion() async {
    if (widget.roomId == null) return;

    await Future.delayed(const Duration(seconds: 2)); // Delay untuk melihat hasil

    try {
      List questions = roomData!['questions'] ?? [];
      int nextIndex = currentQuestionIndex + 1;

      if (nextIndex < questions.length) {
        // Move to next question
        await FirebaseFirestore.instance
            .collection('multiplayer_rooms')
            .doc(widget.roomId!)
            .update({
          'currentQuestionIndex': nextIndex,
          'player1.answered': false,
          'player2.answered': false,
        });

        setState(() {
          currentQuestionIndex = nextIndex;
        });

        _startQuestionTimer();
      } else {
        // Game finished
        await _endGame();
      }
    } catch (e) {
      print('Error moving to next question: $e');
    }
  }

  Future<void> _endGame() async {
    if (widget.roomId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('multiplayer_rooms')
          .doc(widget.roomId!)
          .update({
        'status': 'finished',
        'endTime': FieldValue.serverTimestamp(),
      });

      // Save to user history
      await _saveGameHistory();

      // Show results
      _showGameResults();
    } catch (e) {
      print('Error ending game: $e');
    }
  }

  Future<void> _saveGameHistory() async {
    if (currentUserId == null || roomData == null) return;

    try {
      List questions = roomData!['questions'] ?? [];
      int totalQuestions = questions.length;
      double percentage = totalQuestions > 0 ? (playerScore / (totalQuestions * 10)) * 100 : 0;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId!)
          .collection('history')
          .add({
        'score': playerScore,
        'totalQuestions': totalQuestions,
        'percentage': percentage.round(),
        'gameType': 'multiplayer',
        'roomId': widget.roomId,
        'timeSpent': totalQuestions * 30, // Estimasi waktu
        'gameEndTime': FieldValue.serverTimestamp(),
        'collectionName': 'multiplayer_room',
        'categoryTitle': 'Multiplayer Quiz',
        'categoryImage': 'assets/images/multiplayer.jpg',
      });
    } catch (e) {
      print('Error saving game history: $e');
    }
  }

  void _showGameResults() {
    if (roomData == null) return;

    String player1Name = roomData!['player1']?['name'] ?? 'Player 1';
    int player1Score = roomData!['player1']?['score'] ?? 0;
    String player2Name = roomData!['player2']?['name'] ?? 'Player 2';
    int player2Score = roomData!['player2']?['score'] ?? 0;

    String winner = player1Score > player2Score ? player1Name :
    player2Score > player1Score ? player2Name : 'Draw';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Finished!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Winner: $winner'),
            const SizedBox(height: 12),
            Text('$player1Name: $player1Score points'),
            Text('$player2Name: $player2Score points'),
            const SizedBox(height: 12),
            Text('Your Score: $playerScore points'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to quiz page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading game...'),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                error!,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (roomData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('No room data')),
      );
    }

    // Waiting for opponent
    if (roomData!['status'] == 'waiting') {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Waiting for Opponent'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Waiting for another player to join...',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Game finished
    if (roomData!['status'] == 'finished') {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Game Finished'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              const Text(
                'Game has ended!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Your final score: $playerScore points'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Menu'),
              ),
            ],
          ),
        ),
      );
    }

    // Playing state
    List questions = roomData!['questions'] ?? [];
    if (currentQuestionIndex >= questions.length) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('No questions available')),
      );
    }

    Map<String, dynamic> currentQuestion = questions[currentQuestionIndex];
    List<String> options = List<String>.from(currentQuestion['options'] ?? []);

    // Get opponent info
    String playerKey = _getPlayerKey();
    String opponentKey = playerKey == 'player1' ? 'player2' : 'player1';
    String opponentName = roomData![opponentKey]?['name'] ?? 'Opponent';
    int opponentScore = roomData![opponentKey]?['score'] ?? 0;
    bool opponentAnswered = roomData![opponentKey]?['answered'] ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Multiplayer Quiz'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Timer
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: timeLeft <= 10 ? Colors.red : Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$timeLeft',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress and scores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1}/${questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        const Text('You', style: TextStyle(fontSize: 12)),
                        Text(
                          '$playerScore',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text(opponentName, style: const TextStyle(fontSize: 12)),
                        Text(
                          '$opponentScore',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 24),

            // Question
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  currentQuestion['question'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Answer options
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: hasAnswered ? null : () => _answerQuestion(index),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: hasAnswered
                            ? (index == currentQuestion['answerIndex']
                            ? Colors.green
                            : Colors.grey[300])
                            : Colors.blue[50],
                        foregroundColor: hasAnswered
                            ? (index == currentQuestion['answerIndex']
                            ? Colors.white
                            : Colors.black)
                            : Colors.black,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          options[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasAnswered ? Icons.check_circle : Icons.access_time,
                    color: hasAnswered ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasAnswered
                        ? (opponentAnswered
                        ? 'Both answered! Moving to next...'
                        : 'Waiting for opponent...')
                        : 'Choose your answer',
                    style: TextStyle(
                      color: hasAnswered ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  }