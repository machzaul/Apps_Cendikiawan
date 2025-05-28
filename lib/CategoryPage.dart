import 'dart:ui';
import 'package:flutter/material.dart';
import 'QuestionPage.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int _selectedIndex = 0;

  final List<Map<String, String>> categories = const [
    {
      "title": "Matematika",
      "image": "assets/images/math.jpg",
      "collection": "matematika_questions"
    },
    {
      "title": "Sains",
      "image": "assets/images/science.jpg",
      "collection": "sains_questions"
    },
    {
      "title": "Sejarah",
      "image": "assets/images/history.jpg",
      "collection": "sejarah_questions"
    },
    {
      "title": "Bahasa Inggris",
      "image": "assets/images/english.jpg",
      "collection": "english_questions"
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Tambahkan navigasi sesuai index jika diperlukan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'CATEGORY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 120,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    category['image']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black.withOpacity(0.3),
                      child: ListTile(
                        title: Text(
                          category['title']!,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuestionPage(
                                  categoryTitle: category['title']!,
                                  collectionName: category['collection']!,
                                ),
                              ),
                            );
                          },
                          child: const Text('Start Quiz'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}