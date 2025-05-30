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
  int timeLeft = 10; // 10 detik per pertanyaan
  bool isWaitingForNextQuestion = false;

  @override
  void initState() {
    super.initState();
    print('SinglePlayerPage initialized with roomId: ${widget.roomId}');
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
      if (!mounted) return;

      if (snapshot.exists) {
        final newRoomData = snapshot.data() as Map<String, dynamic>;
        final oldRoomData = roomData;

        setState(() {
          roomData = newRoomData;
          isLoading = false;
        });

        // Start game jika room sudah full dan belum playing
        if (newRoomData['status'] == 'full' && oldRoomData?['status'] != 'full') {
          _updateRoomStatus('playing');
          setState(() {
            currentQuestionIndex = 0;
          });
          _resetQuestionState();
        }

        // PERBAIKAN: Perbaiki deteksi perubahan question
        int newQuestionIndex = newRoomData['currentQuestionIndex'] ?? 0;
        if (newQuestionIndex != currentQuestionIndex) {
          print('Question changed from $currentQuestionIndex to $newQuestionIndex');
          setState(() {
            currentQuestionIndex = newQuestionIndex;
          });
          _resetQuestionState();
        }

        // Check jika game sudah finished
        if (newRoomData['status'] == 'finished' && oldRoomData?['status'] != 'finished') {
          questionTimer?.cancel();
          _showGameResults();
        }
      } else {
        setState(() {
          error = 'Room not found';
          isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error listening to room: $error');
      if (mounted) {
        setState(() {
          this.error = 'Connection error: $error';
          isLoading = false;
        });
      }
    });
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

  // PERBAIKAN: Method untuk reset state saat question berubah
  void _resetQuestionState() {
    questionTimer?.cancel();
    setState(() {
      hasAnswered = false;
      isWaitingForNextQuestion = false;
      timeLeft = 10;
    });
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    print('Starting question timer for question ${currentQuestionIndex + 1}');
    questionTimer?.cancel();

    if (!mounted) return;

    setState(() {
      timeLeft = 10;
      isWaitingForNextQuestion = false;
    });

    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        timeLeft--;
      });

      if (timeLeft <= 0) {
        timer.cancel();
        print('Timer ended for question ${currentQuestionIndex + 1}');

        // PERBAIKAN: Pastikan auto submit hanya sekali
        if (!hasAnswered && !isWaitingForNextQuestion) {
          print('Auto submitting answer (time up)');
          _answerQuestion(-1);
        }

        // PERBAIKAN: Langsung handle question end tanpa menunggu
        if (!isWaitingForNextQuestion) {
          _handleQuestionEnd();
        }
      }
    });
  }

  void _handleQuestionEnd() {
    if (isWaitingForNextQuestion) return;

    print('Handling question end for question ${currentQuestionIndex + 1}');
    setState(() {
      isWaitingForNextQuestion = true;
    });

    // PERBAIKAN: Kurangi delay dan tambahkan fallback
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        print('Moving to next question after delay');
        _moveToNextQuestion();
      }
    });
  }

  Future<void> _answerQuestion(int selectedIndex) async {
    if (hasAnswered || widget.roomId == null || currentUserId == null) {
      print('Cannot answer: hasAnswered=$hasAnswered');
      return;
    }

    print('Player answering question ${currentQuestionIndex + 1} with option $selectedIndex');

    setState(() {
      hasAnswered = true;
    });

    // PERBAIKAN: Stop timer saat menjawab
    questionTimer?.cancel();

    try {
      List questions = roomData!['questions'] ?? [];
      if (currentQuestionIndex < questions.length && selectedIndex >= -1) {
        int correctAnswer = questions[currentQuestionIndex]['answerIndex'] ?? 0;
        bool isCorrect = selectedIndex == correctAnswer && selectedIndex != -1;

        if (isCorrect) {
          setState(() {
            playerScore += 10;
          });
          print('Correct answer! Score: $playerScore');
        } else {
          print('Wrong answer or time up');
        }

        String playerKey = _getPlayerKey();
        await FirebaseFirestore.instance
            .collection('multiplayer_rooms')
            .doc(widget.roomId!)
            .update({
          '$playerKey.answered': true,
          '$playerKey.score': playerScore,
          '$playerKey.lastAnswerTime': FieldValue.serverTimestamp(),
          '$playerKey.selectedAnswer': selectedIndex,
        });

        print('Answer submitted to Firebase');

        // PERBAIKAN: Auto move jika sudah menjawab
        if (!isWaitingForNextQuestion) {
          _handleQuestionEnd();
        }
      }
    } catch (e) {
      print('Error answering question: $e');
      if (mounted) {
        setState(() {
          hasAnswered = false;
        });
      }
    }
  }

  String _getPlayerKey() {
    if (roomData == null || currentUserId == null) {
      print('Cannot get player key: roomData or userId null');
      return 'player1';
    }

    String? player1Uid = roomData!['player1']?['uid'];
    String? player2Uid = roomData!['player2']?['uid'];

    print('Current user: $currentUserId');
    print('Player1 UID: $player1Uid');
    print('Player2 UID: $player2Uid');

    String playerKey = (player1Uid == currentUserId) ? 'player1' : 'player2';
    print('Determined player key: $playerKey');

    return playerKey;
  }

  Future<void> _moveToNextQuestion() async {
    if (widget.roomId == null || isLoading) {
      print('Cannot move to next question: roomId null or loading');
      return;
    }

    try {
      List questions = roomData!['questions'] ?? [];
      int nextIndex = currentQuestionIndex + 1;

      print('Current question: ${currentQuestionIndex + 1}/${questions.length}');

      if (nextIndex < questions.length) {
        String playerKey = _getPlayerKey();
        print('Player key: $playerKey, moving to question ${nextIndex + 1}');

        // PERBAIKAN: Kedua player bisa update, tapi dengan kondisi
        DocumentReference roomRef = FirebaseFirestore.instance
            .collection('multiplayer_rooms')
            .doc(widget.roomId!);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot roomSnapshot = await transaction.get(roomRef);

          if (roomSnapshot.exists) {
            Map<String, dynamic> currentRoomData = roomSnapshot.data() as Map<String, dynamic>;
            int currentQuestionInDb = currentRoomData['currentQuestionIndex'] ?? 0;

            // Hanya update jika question index masih sama (belum ada yang update)
            if (currentQuestionInDb == currentQuestionIndex) {
              transaction.update(roomRef, {
                'currentQuestionIndex': nextIndex,
                'player1.answered': false,
                'player2.answered': false,
                'questionStartTime': FieldValue.serverTimestamp(),
              });
              print('Successfully updated question index to $nextIndex');
            } else {
              print('Question already updated by other player');
            }
          }
        });
      } else {
        // Game finished
        String playerKey = _getPlayerKey();
        print('Game finished, player key: $playerKey');

        if (playerKey == 'player1') {
          print('Player1 ending game');
          await _endGame();
        }
      }
    } catch (e) {
      print('Error moving to next question: $e');
      if (mounted) {
        setState(() {
          isWaitingForNextQuestion = false;
        });
      }
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
        'timeSpent': totalQuestions * 10, // 10 detik per soal
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
              color: timeLeft <= 3 ? Colors.red :
              timeLeft <= 5 ? Colors.orange : Colors.blue,
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
                  bool isCorrectAnswer = index == (currentQuestion['answerIndex'] ?? 0);
                  bool showCorrectAnswer = hasAnswered || timeLeft <= 0;

                  Color buttonColor;
                  Color textColor;

                  if (showCorrectAnswer) {
                    if (isCorrectAnswer) {
                      buttonColor = Colors.green;
                      textColor = Colors.white;
                    } else {
                      buttonColor = Colors.grey[300]!;
                      textColor = Colors.black;
                    }
                  } else {
                    buttonColor = Colors.blue[50]!;
                    textColor = Colors.black;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: (hasAnswered || timeLeft <= 0) ? null : () => _answerQuestion(index),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: buttonColor,
                        foregroundColor: textColor,
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
                    isWaitingForNextQuestion
                        ? Icons.hourglass_empty
                        : hasAnswered
                        ? Icons.check_circle
                        : Icons.access_time,
                    color: isWaitingForNextQuestion
                        ? Colors.blue
                        : hasAnswered
                        ? Colors.green
                        : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isWaitingForNextQuestion
                        ? 'Moving to next question...'
                        : hasAnswered
                        ? 'Answer submitted! Wait for next question...'
                        : timeLeft <= 0
                        ? 'Time\'s up!'
                        : 'Choose your answer',
                    style: TextStyle(
                      color: isWaitingForNextQuestion
                          ? Colors.blue
                          : hasAnswered
                          ? Colors.green
                          : timeLeft <= 0
                          ? Colors.red
                          : Colors.orange,
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