import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'PvPGamePage.dart';

class RoomSelectionPage extends StatefulWidget {
  const RoomSelectionPage({super.key});

  @override
  State<RoomSelectionPage> createState() => _RoomSelectionPageState();
}

class _RoomSelectionPageState extends State<RoomSelectionPage> {
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isCreatingRoom = false;
  bool _isJoiningRoom = false;

  // Generate random room code
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Load questions from firestore
  Future<List<Map<String, dynamic>>> _loadQuestions(String category) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(category)
          .limit(10) // Ambil 10 soal untuk PvP
          .get();

      List<Map<String, dynamic>> questions = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Convert to match room structure
        questions.add({
          'question': data['question'],
          'options': List<String>.from(data['options']),
          'answerIndex': data['options'].indexOf(data['correctAnswer']),
        });
      }

      // Shuffle questions
      questions.shuffle();
      return questions;
    } catch (e) {
      print('Error loading questions: $e');
      return [];
    }
  }

  // Create new room
  Future<void> _createRoom() async {
    if (_isCreatingRoom) return;

    setState(() {
      _isCreatingRoom = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get user data
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String userName = 'Player';
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userName = userData['displayName'] ?? userData['name'] ?? 'Player';
      }

      String roomCode = _generateRoomCode();

      // Load questions (default to matematika for now)
      List<Map<String, dynamic>> questions = await _loadQuestions('matematika_questions');

      if (questions.isEmpty) {
        throw Exception('Failed to load questions');
      }

      // Create room data
      Map<String, dynamic> roomData = {
        'roomCode': roomCode,
        'player1': {
          'uid': user.uid,
          'name': userName,
          'score': 0,
          'answered': false,
        },
        'player2': null,
        'status': 'waiting',
        'questions': questions,
        'currentQuestionIndex': 0,
        'category': 'matematika_questions',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to firestore
      await FirebaseFirestore.instance
          .collection('pvp_rooms')
          .doc(roomCode)
          .set(roomData);

      // Navigate to game page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PvPGamePage(roomCode: roomCode),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating room: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingRoom = false;
        });
      }
    }
  }

  // Join existing room
  Future<void> _joinRoom() async {
    if (_isJoiningRoom || _roomCodeController.text.trim().isEmpty) return;

    setState(() {
      _isJoiningRoom = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      String roomCode = _roomCodeController.text.trim().toUpperCase();

      // Check if room exists
      DocumentSnapshot roomDoc = await FirebaseFirestore.instance
          .collection('pvp_rooms')
          .doc(roomCode)
          .get();

      if (!roomDoc.exists) {
        throw Exception('Room not found');
      }

      Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;

      // Check room status
      if (roomData['status'] != 'waiting') {
        throw Exception('Room is not available');
      }

      // Check if room is full
      if (roomData['player2'] != null) {
        throw Exception('Room is full');
      }

      // Check if same user trying to join own room
      if (roomData['player1']['uid'] == user.uid) {
        throw Exception('Cannot join your own room');
      }

      // Get user data
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String userName = 'Player';
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userName = userData['displayName'] ?? userData['name'] ?? 'Player';
      }

      // Join room
      await FirebaseFirestore.instance
          .collection('pvp_rooms')
          .doc(roomCode)
          .update({
        'player2': {
          'uid': user.uid,
          'name': userName,
          'score': 0,
          'answered': false,
        },
        'status': 'full',
      });

      // Navigate to game page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PvPGamePage(roomCode: roomCode),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining room: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoiningRoom = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('PvP Room'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              const Icon(
                Icons.sports_esports,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Player vs Player',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a room or join with room code',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Create Room Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isCreatingRoom ? null : _createRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCreatingRoom
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Create Room',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ],
              ),
              const SizedBox(height: 32),

              // Join Room Section
              const Text(
                'Join with Room Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Room Code Input
              TextField(
                controller: _roomCodeController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'ENTER CODE',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    letterSpacing: 2,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return null; // Hide counter
                },
              ),
              const SizedBox(height: 16),

              // Join Room Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isJoiningRoom ? null : _joinRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isJoiningRoom
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Join Room',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }
}