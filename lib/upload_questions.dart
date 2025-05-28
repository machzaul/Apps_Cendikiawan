import 'package:cloud_firestore/cloud_firestore.dart';

void uploadQuestions() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Matematika Questions
  await firestore.collection('matematika_questions').doc('math_1').set({"id": "math_1", "question": "Berapakah hasil dari 71 + 93?", "options": ["164", "166", "163", "165"], "correctAnswer": "164", "category": "Matematika"});
  await firestore.collection('matematika_questions').doc('math_2').set({"id": "math_2", "question": "Berapakah hasil dari 65 + 39?", "options": ["104", "106", "102", "101"], "correctAnswer": "104", "category": "Matematika"});
  await firestore.collection('matematika_questions').doc('math_3').set({"id": "math_3", "question": "Berapakah hasil dari 13 + 29?", "options": ["44", "42", "45", "43"], "correctAnswer": "42", "category": "Matematika"});
  await firestore.collection('matematika_questions').doc('math_4').set({"id": "math_4", "question": "Berapakah hasil dari 90 + 65?", "options": ["155", "156", "152", "153"], "correctAnswer": "155", "category": "Matematika"});
  await firestore.collection('matematika_questions').doc('math_5').set({"id": "math_5", "question": "Berapakah hasil dari 15 + 57?", "options": ["72", "75", "71", "74"], "correctAnswer": "72", "category": "Matematika"});

  // Sains Questions
  await firestore.collection('sains_questions').doc('science_1').set({"id": "science_1", "question": "Apa planet terbesar di tata surya kita?", "options": ["Venus", "Saturnus", "Jupiter", "Mars"], "correctAnswer": "Jupiter", "category": "Sains"});
  await firestore.collection('sains_questions').doc('science_2').set({"id": "science_2", "question": "Apa unsur kimia untuk air?", "options": ["CO2", "O2", "H2O", "NaCl"], "correctAnswer": "H2O", "category": "Sains"});
  await firestore.collection('sains_questions').doc('science_3').set({"id": "science_3", "question": "Hewan apa yang bisa hidup di air dan darat?", "options": ["Amfibi", "Ikan", "Mamalia", "Burung"], "correctAnswer": "Amfibi", "category": "Sains"});
  await firestore.collection('sains_questions').doc('science_4').set({"id": "science_4", "question": "Proses tanaman membuat makanan disebut?", "options": ["Transpirasi", "Respirasi", "Klorofil", "Fotosintesis"], "correctAnswer": "Fotosintesis", "category": "Sains"});
  await firestore.collection('sains_questions').doc('science_5').set({"id": "science_5", "question": "Apa nama alat untuk mengukur suhu?", "options": ["Barometer", "Anemometer", "Termometer", "Higrometer"], "correctAnswer": "Termometer", "category": "Sains"});

  // Sejarah Questions
  await firestore.collection('sejarah_questions').doc('history_1').set({"id": "history_1", "question": "Siapa proklamator kemerdekaan Indonesia?", "options": ["Hatta", "Soekarno", "Jenderal Sudirman", "Soekarno-Hatta"], "correctAnswer": "Soekarno-Hatta", "category": "Sejarah"});
  await firestore.collection('sejarah_questions').doc('history_2').set({"id": "history_2", "question": "Kapan Indonesia merdeka?", "options": ["20 Mei 1945", "17 Agustus 1945", "1 Juni 1945", "18 Agustus 1945"], "correctAnswer": "17 Agustus 1945", "category": "Sejarah"});
  await firestore.collection('sejarah_questions').doc('history_3').set({"id": "history_3", "question": "Kerajaan Hindu pertama di Indonesia?", "options": ["Majapahit", "Sriwijaya", "Kutai", "Mataram"], "correctAnswer": "Kutai", "category": "Sejarah"});
  await firestore.collection('sejarah_questions').doc('history_4').set({"id": "history_4", "question": "Apa nama naskah kuno bersejarah di Indonesia?", "options": ["Prasasti", "Surat", "Maklumat", "Piagam"], "correctAnswer": "Prasasti", "category": "Sejarah"});
  await firestore.collection('sejarah_questions').doc('history_5').set({"id": "history_5", "question": "Siapa tokoh G30S/PKI yang terkenal?", "options": ["DN Aidit", "Soeharto", "Soekarno", "Nasution"], "correctAnswer": "DN Aidit", "category": "Sejarah"});

  // English Questions
  await firestore.collection('english_questions').doc('english_1').set({"id": "english_1", "question": "Translate 'Apple' to Indonesian.", "options": ["Pisang", "Apel", "Jeruk", "Mangga"], "correctAnswer": "Apel", "category": "English"});
  await firestore.collection('english_questions').doc('english_2').set({"id": "english_2", "question": "Past tense of 'Go'?", "options": ["Goes", "Goed", "Went", "Gone"], "correctAnswer": "Went", "category": "English"});
  await firestore.collection('english_questions').doc('english_3').set({"id": "english_3", "question": "Plural of 'Child'?", "options": ["Children", "Childs", "Childer", "Childes"], "correctAnswer": "Children", "category": "English"});
  await firestore.collection('english_questions').doc('english_4').set({"id": "english_4", "question": "Synonym of 'Happy'?", "options": ["Sad", "Angry", "Glad", "Scared"], "correctAnswer": "Glad", "category": "English"});
  await firestore.collection('english_questions').doc('english_5').set({"id": "english_5", "question": "Antonym of 'Hot'?", "options": ["Cold", "Cool", "Boiling", "Warm"], "correctAnswer": "Cold", "category": "English"});
}