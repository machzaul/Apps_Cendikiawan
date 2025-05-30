import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class PvPGamePage extends StatefulWidget {
  final String roomCode;

  const PvPGamePage({super.key, required this.roomCode});

  @override
  State<PvPGamePage> createState() => _PvPGamePageState();
}

class _PvPGamePageState extends State<PvPGamePage> {
  StreamSubscription<DocumentSnapshot>? _roomSubscription;
  Map<String, dynamic>? roomData;
  String? currentUserId;
  bool isPlayer1 = false;
  Timer? _gameTimer;
  int timeLeft = 10; // 10 seconds per question
  bool hasAnswered = false;
  int? selectedAnswer;
  bool isTimerActive = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _listenToRoom();
  }

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  void _listenToRoom() {
    _roomSubscription = FirebaseFirestore.instance
        .collection('pvp_rooms')
        .doc(widget.roomCode)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          roomData = data;
          // Check if current user is player1
          if (currentUserId != null && data['player1'] != null) {
            isPlayer1 = data['player1']['uid'] == currentUserId;
          }
        });

        // Handle game state changes
        _handleGameStateChange();
      } else {
        // Room deleted, go back
        _showErrorAndGoBack('Room has been deleted');
      }
    });
  }

  void _handleGameStateChange() {
    if (roomData == null) return;

    String status = roomData!['status'];

    if (status == 'full' && roomData!['startTime'] == null) {
      // Both players joined, start game after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && isPlayer1) {
          _startGame();
        }
      });
    } else if (status == 'playing') {
      // Game is playing, start timer if not already started
      if (!isTimerActive) {
        _startQuestionTimer();
      }
    } else if (status == 'finished') {
      // Game finished, show results
      _gameTimer?.cancel();
      isTimerActive = false;
      _showGameResults();
    }
  }

  void _startGame() async {
    try {
      await FirebaseFirestore.instance
          .collection('pvp_rooms')
          .doc(widget.roomCode)
          .update({
        'status': 'playing',
        'startTime': FieldValue.serverTimestamp(),
        'currentQuestionIndex': 0,
        'player1.answered': false,
        'player2.answered': false,
      });
    } catch (e) {
      print('Error starting game: $e');
    }
  }

  void _startQuestionTimer() {
    if (isTimerActive) return;

    setState(() {
      timeLeft = 10; // Reset to 10 seconds
      hasAnswered = false;
      selectedAnswer = null;
      isTimerActive = true;
    });

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          timeLeft--;
        });

        if (timeLeft <= 0) {
          timer.cancel();
          isTimerActive = false;

          // Submit answer for current player if not answered
          if (!hasAnswered) {
            _submitTimeoutAnswer();
          }

          // Only player1 handles the next question logic
          if (isPlayer1) {
            _moveToNextQuestion();
          }
        }
      } else {
        timer.cancel();
        isTimerActive = false;
      }
    });
  }

  void _submitTimeoutAnswer() async {
    if (hasAnswered || roomData == null) return;

    setState(() {
      hasAnswered = true;
      selectedAnswer = -1; // No answer selected
    });

    try {
      String playerKey = isPlayer1 ? 'player1' : 'player2';

      // Update player data - mark as answered but no score increase
      Map<String, dynamic> updates = {};
      updates['$playerKey.answered'] = true;

      await FirebaseFirestore.instance
          .collection('pvp_rooms')
          .doc(widget.roomCode)
          .update(updates);

    } catch (e) {
      print('Error submitting timeout answer: $e');
    }
  }

  void _submitAnswer(int answerIndex) async {
    if (hasAnswered || roomData == null) return;

    setState(() {
      hasAnswered = true;
      selectedAnswer = answerIndex;
    });

    try {
      String playerKey = isPlayer1 ? 'player1' : 'player2';
      int currentQuestionIndex = roomData!['currentQuestionIndex'];
      List questions = roomData!['questions'];

      if (currentQuestionIndex < questions.length) {
        int correctAnswerIndex = questions[currentQuestionIndex]['answerIndex'];
        bool isCorrect = answerIndex == correctAnswerIndex;

        // Update player data
        Map<String, dynamic> updates = {};
        updates['$playerKey.answered'] = true;

        if (isCorrect) {
          int currentScore = roomData![playerKey]['score'] ?? 0;
          updates['$playerKey.score'] = currentScore + 10; // 10 points per correct answer
        }

        await FirebaseFirestore.instance
            .collection('pvp_rooms')
            .doc(widget.roomCode)
            .update(updates);
      }
    } catch (e) {
      print('Error submitting answer: $e');
    }
  }

  void _moveToNextQuestion() async {
    if (roomData == null || !isPlayer1) return;

    // Wait a bit to ensure updates are processed
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Get fresh data
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('pvp_rooms')
          .doc(widget.roomCode)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int currentQuestionIndex = data['currentQuestionIndex'];
        List questions = data['questions'];

        if (currentQuestionIndex + 1 < questions.length) {
          // Next question
          await FirebaseFirestore.instance
              .collection('pvp_rooms')
              .doc(widget.roomCode)
              .update({
            'currentQuestionIndex': currentQuestionIndex + 1,
            'player1.answered': false,
            'player2.answered': false,
          });
        } else {
          // Game finished
          await FirebaseFirestore.instance
              .collection('pvp_rooms')
              .doc(widget.roomCode)
              .update({
            'status': 'finished',
          });
        }
      }
    } catch (e) {
      print('Error moving to next question: $e');
    }
  }

  void _updatePlayerScores(int player1Score, int player2Score) async {
    try {
      if (roomData == null) return;

      // Get player UIDs
      String? player1Uid = roomData!['player1']['uid'];
      String? player2Uid = roomData!['player2']?['uid'];

      // Update player1 score
      if (player1Uid != null && player1Score > 0) {
        DocumentSnapshot player1Doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(player1Uid)
            .get();

        if (player1Doc.exists) {
          Map<String, dynamic> player1Data = player1Doc.data() as Map<String, dynamic>;
          int currentScore = player1Data['skor'] ?? 0;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(player1Uid)
              .update({
            'skor': currentScore + player1Score,
          });
        }
      }

      // Update player2 score
      if (player2Uid != null && player2Score > 0) {
        DocumentSnapshot player2Doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(player2Uid)
            .get();

        if (player2Doc.exists) {
          Map<String, dynamic> player2Data = player2Doc.data() as Map<String, dynamic>;
          int currentScore = player2Data['skor'] ?? 0;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(player2Uid)
              .update({
            'skor': currentScore + player2Score,
          });
        }
      }

      print('Skor berhasil diupdate: Player1=$player1Score, Player2=$player2Score');
    } catch (e) {
      print('Error updating player scores: $e');
    }
  }

  void _showGameResults() {
    if (roomData == null) return;

    int player1Score = roomData!['player1']['score'] ?? 0;
    int player2Score = roomData!['player2']['score'] ?? 0;

    String result;
    if (isPlayer1) {
      if (player1Score > player2Score) {
        result = 'You Win!';
      } else if (player1Score < player2Score) {
        result = 'You Lose!';
      } else {
        result = 'Draw!';
      }
    } else {
      if (player2Score > player1Score) {
        result = 'You Win!';
      } else if (player2Score < player1Score) {
        result = 'You Lose!';
      } else {
        result = 'Draw!';
      }
    }

    // Update skor pemain ke akun mereka
    _updatePlayerScores(player1Score, player2Score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(result),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${roomData!['player1']['name']}: $player1Score'),
            Text('${roomData!['player2']['name']}: $player2Score'),
            const SizedBox(height: 10),
            const Text(
              'Skor telah ditambahkan ke akun Anda!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorAndGoBack(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _leaveRoom() async {
    try {
      _gameTimer?.cancel();
      isTimerActive = false;

      if (roomData != null && roomData!['status'] != 'finished') {
        // If game is in progress, end it
        await FirebaseFirestore.instance
            .collection('pvp_rooms')
            .doc(widget.roomCode)
            .update({
          'status': 'finished',
        });
      }
    } catch (e) {
      print('Error leaving room: $e');
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (roomData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    String status = roomData!['status'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Room: ${widget.roomCode}'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _leaveRoom,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Players Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Player 1
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.person,
                            size: 32,
                            color: isPlayer1 ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            roomData!['player1']['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPlayer1 ? Colors.blue : Colors.black,
                            ),
                          ),
                          Text(
                            'Score: ${roomData!['player1']['score']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Player 2
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.person,
                            size: 32,
                            color: !isPlayer1 && roomData!['player2'] != null
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            roomData!['player2']?['name'] ?? 'Waiting...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !isPlayer1 && roomData!['player2'] != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          Text(
                            'Score: ${roomData!['player2']?['score'] ?? 0}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Game Content
              Expanded(
                child: _buildGameContent(status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent(String status) {
    switch (status) {
      case 'waiting':
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Waiting for another player...',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        );

      case 'full':
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                size: 64,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                'Get Ready!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Game starting soon...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );

      case 'playing':
        return _buildQuestionContent();

      case 'finished':
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Game Finished!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );

      default:
        return const Center(child: Text('Unknown game state'));
    }
  }

  Widget _buildQuestionContent() {
    if (roomData == null) return const SizedBox();

    int currentQuestionIndex = roomData!['currentQuestionIndex'];
    List questions = roomData!['questions'];

    if (currentQuestionIndex >= questions.length) {
      return const Center(child: Text('No more questions'));
    }

    Map<String, dynamic> currentQuestion = questions[currentQuestionIndex];

    return Column(
      children: [
        // Timer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: timeLeft <= 3 ? Colors.red[100] : Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: timeLeft <= 3 ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$timeLeft',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: timeLeft <= 3 ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Question
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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

        // Options
        Expanded(
          child: ListView.builder(
            itemCount: currentQuestion['options'].length,
            itemBuilder: (context, index) {
              bool isSelected = selectedAnswer == index;
              bool isCorrect = index == currentQuestion['answerIndex'];
              bool showCorrect = hasAnswered && timeLeft <= 0 && isCorrect;
              bool showWrong = hasAnswered && isSelected && !isCorrect && timeLeft <= 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: hasAnswered || timeLeft <= 0 ? null : () => _submitAnswer(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showCorrect
                        ? Colors.green
                        : showWrong
                        ? Colors.red
                        : isSelected
                        ? Colors.blue[100]
                        : Colors.white,
                    foregroundColor: showCorrect || showWrong
                        ? Colors.white
                        : Colors.black,
                    side: BorderSide(
                      color: showCorrect
                          ? Colors.green
                          : showWrong
                          ? Colors.red
                          : isSelected
                          ? Colors.blue
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    currentQuestion['options'][index],
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }
}