import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final List<Map<String, dynamic>> leaderboard = const [
    {"name": "Albert", "score": 999999},
    {"name": "Lucky", "score": 999999},
    {"name": "Lucky", "score": 999999},
    {"name": "Lucky", "score": 999999},
    {"name": "Lucky", "score": 999999},
    {"name": "Lucky", "score": 999999},
    {"name": "Lucky", "score": 999999},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  double getItemHeight(int index) {
    if (index == 0) return 90;
    if (index == 1) return 75;
    if (index == 2) return 60;
    return 50;
  }

  double getWidthFactor(int index) {
    if (index == 0) return 1.0;
    if (index == 1) return 0.87;
    if (index == 2) return 0.78;
    return 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final entry = leaderboard[index];
          final isFirst = index == 0;
          final height = getItemHeight(index);
          final widthFactor = getWidthFactor(index);

          return Align(
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width * widthFactor,
              height: height,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  isFirst
                      ? Image.asset('assets/logo/crown1.png', width: 32, height: 32)
                      : Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    entry['score'].toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
