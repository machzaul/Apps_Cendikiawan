import 'package:cloud_firestore/cloud_firestore.dart';

void uploadQuestions() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Matematika Questions
  await firestore.collection('matematika_questions').doc('math_1').set({"id": "math_1", "question": "Dalam sebuah keranjang A yang berisi 10 buah jeruk, 2 buah jeruk diantaranya busuk, sedangkan dalam keranjang B yang berisi 15 buah salak, 3 diantaranya busuk. Ibu menghendaki 5 buah buah jeruk dan 5 buah salak tanpa baik, peluangnya adalah?", "options": ["16/273", "26/273", "42/273", "48/273"], "correctAnswer": "16/273", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_2').set({"id": "math_2", "question": "Sebuah dadu dan sekeping uang logam dilemparkan sekali bersama-sama diatas meja. Peluang munculnya mata dadu lima dan angka pada uang logam adalah?", "options": ["1/24", "1/12", "1/8", "2/3"], "correctAnswer": "1/12", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_3').set({"id": "math_3", "question": "Kotak I berisi 2 bola merah dan 4 bola putih. Kotak II berisi 5 bola merah dan 3 bola putih. Dari masing-masing kotak diambil 1 bola. Peluang bola yang terambil bola merah dari kotak I dan bola putih dari kotak II adalah?", "options": ["1/40", "3/20", "3/8", "2/5"], "correctAnswer": "3/20", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_4').set({"id": "math_4", "question": "Misal kita mempunyai 10 kartu yang bernomor 1 sampai 10. Jika 1 kartu diambil secara acak, maka peluang terambil adalah kartu bernomor bilangan prima adalah?", "options": ["4/5", "3/5", "1/2", "3/10"], "correctAnswer": "1/2", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_5').set({"id": "math_5", "question": "Jika siswa memegang kartu remi yang berjumlah 52 buah dari meminta temannya untuk mengambil sebuah kartu secara acak. Peluang terambilnya kartu hati adalah?", "options": ["1/25", "1/13", "9/25", "1/4"], "correctAnswer": "1/4", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_6').set({"id": "math_6", "question": "Dalam percobaan pelemparan sebuah dadu stimbang. K menyatakan kejadian munculnya mata dadu bilangan genap. Peluang kejadian K adalah?", "options": ["1/6", "1/4", "1/3", "1/2"], "correctAnswer": "1/4", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_7').set({"id": "math_7", "question": "Banyak siswa kelas A adalah 30. Kelas B adalah 20 siswa. Nilai rata-rata ujian matematika kelas A lebih 10 dari kelas B. Jika rata-rata nilai ujian matematika gabungan dari kelas A dan kelas B adalah 66, maka rata-rata nilai ujian matematika kelas B adalah?", "options": ["58", "60", "62", "64"], "correctAnswer": "60", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_8').set({"id": "math_8", "question": "Dalam suatu kelas terdapat siswa sebanyak 21 orang. Nilai rata-ratanya 6, jika siswa yang paling rendah nilainya tidak diikutsertakan, maka nilai rata-ratanya menjadi 6.2. nilai yang terendah tersebut adalah?", "options": ["0", "1", "2", "3"], "correctAnswer": "2", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_9').set({"id": "math_9", "question": "Dari 10 orang siswa akan dipilih 4 siswa untuk mengikuti jambore Pramuka. Banyak cara memilih siswa tersebut adalah?", "options": ["105", "210", "420", "5040"], "correctAnswer": "420", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_10').set({"id": "math_10", "question": "Untuk Trigonometri di Kuadran I, nilai sin 30° setara dengan nilai?", "options": ["*cos 60°*", "sin 60°", "tan 30°", "tan 60°"], "correctAnswer": "cos 60°", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_11').set({"id": "math_11", "question": "Nilai sudut istimewa di Kuadran I untuk tan 45° adalah", "options": ["√3", "√2", "1", "1/3 √3"], "correctAnswer": "1", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_12').set({"id": "math_12", "question": "Nilai sudut istimewa di Kuadran I untuk sin 60° adalah", "options": ["√3", "√2", "1", "1/2 √3"], "correctAnswer": "1/2 √3", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_13').set({"id": "math_13", "question": "Akar-akar dari f(x) = x² - 4x - 12 adalah", "options": ["{x | x = -2 atau x = 6}","{x | x = 2 atau x = 6}","{x | x = -2 atau x = -6}", "{x | x = 2 atau x = -6}"], "correctAnswer": "{x | x = -2 atau x = 6}", "category": "Matematika"});

  await firestore.collection('matematika_questions').doc('math_14').set({"id": "math_14", "question": "Sebuah fungsi f(x) = x² + 2x – 2, berapakah nilai fungsi bila x = 3?", "options": ["11", "12", "13", "5"], "correctAnswer": "12", "category": "Matematika" });

  await firestore.collection('matematika_questions').doc('math_15').set({"id": "math_15", "question": "Jika f(x) = -4 + x dan x = -2, maka tentukanlah nilai dari f(x²) – (f(x))² + 3f(x)!", "options": ["9", "–18", "–27", "–54"], "correctAnswer": "–54", "category": "Matematika" });

  await firestore.collection('matematika_questions').doc('math_16').set({"id": "math_16", "question": "Fungsi f(x) = 2x + 7 dan f(p) = -7. Maka nilai p adalah…", "options": ["-1", "-21", "-14", "-7"], "correctAnswer": "-7", "category": "Matematika" });

  await firestore.collection('matematika_questions').doc('math_17').set({"id": "math_17", "question": "Sebuah fungsi f : R → R dan g : R → R dinyatakan dengan f(x) = x² – 2x -3 dan g(x) = x – 2. Berapakah nilai dari komposisi fungsi (f o g)(x)?", "options": [ "x² – 5x + 5", "x² – 6x + 6", "x² – 6x – 5", "x² – 6x + 5"], "correctAnswer": "x² – 6x + 5", "category": "Matematika" });

  await firestore.collection('matematika_questions').doc('math_18').set({"id": "math_18", "question": "Jika f(x) = x² + 2, maka nilai dari f(x + 1) adalah…", "options": [ "x² + 3x + 3", "x² + 2x + 3", "x² + 2x – 3", "x² + 3", "x² – 2x + 3" ], "correctAnswer": "x² + 2x + 3", "category": "Matematika" });

  await firestore.collection('matematika_questions').doc('math_19').set({"id": "math_19", "question": "Jika f(x) = x³ + 3 dan g(x) = 4x, maka nilai dari (f o g)(x) adalah…", "options": [ "3x³ + 64", "3x³ + 3", "64x³ – 3", "6x³ + 3", "64x³ + 3" ], "correctAnswer": "64x³ + 3", "category": "Matematika" });

  await firestore.collection('matematika_questions').doc('math_20').set({"id": "math_20", "question": "Jika g(x) = 6 – 3x + x². Maka nilai dari 4g(-2) adalah…", "options": ["32", "64", "16", "8"], "correctAnswer": "64", "category": "Matematika" });

  // Sejarah Questions
  await firestore.collection('sejarah_questions').doc('history_1').set({"id": "history_1", "question": "Pengaruh Hindu-Buddha dari India terhadap Indonesia dalam bidang kebudayaan dapat dilihat dari contoh berikut, kecuali?", "options": ["Dibangunnya candi-candi bercorak Hindu-Budha", "Penggunaan kalender Saka", "Bentuk rumah ibadah yang berundak-undak", "Banyak seni patung sebagai perwujudan penghormatan kepada dewa"], "correctAnswer": "Bentuk rumah ibadah yang berundak-undak", "category": "Sejarah"});

  await firestore.collection('sejarah_questions').doc('history_2').set({"id": "history_2", "question": "Manusia purba yang sudah menggunakan alat-alat yang halus dan sudah mengenal cara bercocok tanam merupakan ciri-ciri kehidupan zaman?", "options": ["Paleolitikum", "Megalitikum", "Pleistosen", "Neolitikum"], "correctAnswer": "Pleistosen", "category": "Sejarah"});

  await firestore.collection('sejarah_questions').doc('history_3').set({"id": "history_3", "question": "Kehidupan menetap pada manusia purba mulai dilakukan pada masa?", "options": ["Berburu dan mengumpulkan makanan", "Bercocok tanam", "Perundagian", "Bersawah"], "correctAnswer": "Bercocok tanam", "category": "Sejarah"});

  await firestore.collection('sejarah_questions').doc('history_4').set({"id": "history_4", "question": "Sumber Kerajaan Tarumanegara yang lokasi penemuannya terletak di wilayah Provinsi Banten adalah?", "options": ["Munjul", "Tugu", "Cindanghiang", "Ciaruteun"], "correctAnswer": "Munjul", "category": "Sejarah"});

  await firestore.collection('sejarah_questions').doc('history_5').set({"id": "history_5", "question": "Pada masa pemerintahan Raden Fatah, Kesultanan Demak pernah melakukan serangan ke Malaka yang sudah dikuasai Portugis. Serangan tersebut didasari oleh alasan?", "options": ["Portugis terlebih dahulu mengancam menyerang Demak", "Raden Patah ingin memperluas wilayah kekuasaan di Sumatera", "sebagai bentuk solidaritas terhadap sesama muslim sekaligus membebaskan Malaka", "Demak ingin membantu kesultanan Banten untuk membebaskan dari Portugis"], "correctAnswer": "sebagai bentuk solidaritas terhadap sesama muslim sekaligus membebaskan Malaka", "category": "Sejarah"});

  await firestore.collection('sejarah_questions').doc('history_6').set({"id": "history_6", "question": "Jika dibandingkan Kerajaan Spanyol dan Portugis, Belanda lebih akhir datang ke Indonesia. Faktor utama yang menyebabkan kedatangan Belanda ke Indonesia adalah?", "options": ["adanya kesepakatan Thordesillas yang membagi pelayaran samudera menjadi dua", "adanya kesepakatan Saragosa yang membagi pelayaran samudera menjadi dua", "Pelarangan Belanda membeli rempah-rempah di Pelabuhan Lisabon Portugis", "Belanda tidak memiliki armada perang sekuat Portugis"], "correctAnswer": "Pelarangan Belanda membeli rempah-rempah di Pelabuhan Lisabon Portugis", "category": "Sejarah"});

  await firestore.collection('sejarah_questions').doc('history_7').set({"id": "history_7", "question": "Hal yang menjadi faktor internal pendorong munculnya nasionalisme Indonesia adalah?", "options": ["kebijakan politik etis yang memunculkan kelompok cendikiawan di Indonesia", "perjuangan membangkitkan nasionalisme yang dilakukan oleh Mahatma Gandhi di India", "kemenangan Jepang atas Uni Soviet pada tahun 1905 di Manchuria", "munculnya paham-paham baru di Eropa yang kemudian berkembang di Indonesia"], "correctAnswer": "kebijakan politik etis yang memunculkan kelompok cendikiawan di Indonesia", "category": "Sejarah"});

  await firestore.collection('sejarah_questions').doc('history_8').set({"id": "history_8", "question": "Awal abad ke 20 merupakan tonggak awal kebangkitan nasional Indonesia, hal ini ditandai dengan banyak berdirinya organisasi yang bergerak dalam berbagai bidang seperti pendidikan, budaya, agama, bahkan politik. Berikut organisasi pergerakan nasional Islam yang pertama di Indonesia, yaitu?", "options": ["Sarekat Dagang Islam", "Nahdatul Ulama", "Muhammadiyah", "Masyumi"], "correctAnswer": "Sarekat Dagang Islam", "category": "Sejarah"});

  await firestore.collection('sejarah_questions').doc('history_9').set({"id": "history_9", "question": "Dalam menghadapi tuntutan Gabungan Politik Indonesia (GAPI) pemerintah Kolonial Belanda membentuk?", "options": ["Volksraad", "Komisi Visman", "Komisi Lintas Partai", "Komisi Pertimbangan Pemerintah"], "correctAnswer": "Komisi Visman", "category": "Sejarah"});

  await firestore.collection('sejarah_questions').doc('history_10').set({"id": "history_10", "question": "Bukti bahwa Indonesia sebagai anggota ASEAN telah melaksanakan politik luar negeri yang bebas aktif antara lain turut serta berpartisipasi dalam meredakan pertikaian antarfaksi di Kamboja pada tahun 1988 dengan cara di Kamboja pada tahun 1988 dengan cara", "options": ["memberi bantuan senjata kepada kelompok independen ", "mengirim pasukan Garuda sebagai pasukan Dewan Keamanan PBB", "Memberi bantuan ekonomi dan obat-obatan bagi rakyat Kamboja", "Menyediakan tempat untuk pelaksanaan Jakarta Informal Meeting"], "correctAnswer": "Menyediakan tempat untuk pelaksanaan Jakarta Informal Meeting", "category": "Sejarah"});

  await firestore.collection('sejarah_questions').doc('history_11').set({"id": "history_11", "question": "Pada masa Orde Baru peranan negara terus menguat. Hal tersebut tercermin pada hal-hal berikut, kecuali", "options": [ "Kelompokkan oposisi dikendalikan dan dibatasi ruang geraknya", "Organisasi massa berada di bawah kendali penuh pemerintah", "Adanya keterlibatan secara langsung militer dalam sistem pemerintahan", "Partai politik diberi kekuasaan untuk melaksanakan aktivitas politiknya" ], "correctAnswer": "Partai politik diberi kekuasaan untuk melaksanakan aktivitas politiknya", "category": "Sejarah" });

  await firestore.collection('sejarah_questions').doc('history_12').set({"id": "history_12", "question": "Pada masa pemerintahan Orde Baru, terdapat sekelompok tokoh yang menyerahkan sebuah dokumen yang dikenal dengan Petisi 50. Hal yang menjadi tuntutan utama Petisi 50 adalah...", "options": [ "Pencabutan aturan yang bersifat diskriminasi terhadap kelompok etnis Tionghoa", "Pencabutan aturan tentang pelarangan Partai Komunis Indonesia", "Protes penggunaan ideologi Pancasila untuk kepentingan politik praktis", "Pencabutan ajaran Eka Prasetya Pancakarsa" ], "correctAnswer": "Protes penggunaan ideologi Pancasila untuk kepentingan politik praktis", "category": "Sejarah" });

  await firestore.collection('sejarah_questions').doc('history_13').set({"id": "history_13", "question": "Maksud dari kata “pra” adalah ….", "options": ["Sebelum", "Sesudah", "Ada", "Tidak ada"], "correctAnswer": "Sebelum", "category": "Sejarah" });

  await firestore.collection('sejarah_questions').doc('history_14').set({"id": "history_14", "question": "Yang dimaksud dengan zaman praaksara adalah", "options": [ "Masa ketika kehidupan manusia belum mengenal aksara", "Masa ketika kehidupan manusia belum mengenal tulisan", "Masa ketika kehidupan manusia sudah mengenal tulisan", "Masa ketika kehidupan manusia setelah mengenal aksara"], "correctAnswer": "Masa ketika kehidupan manusia belum mengenal tulisan", "category": "Sejarah" });

  await firestore.collection('sejarah_questions').doc('history_15').set({"id": "history_15", "question": "Alasan manusia purba hidup berpindah-pindah dari satu tempat ke tempat lain adalah …. ", "options": [ "Manusia purba ingin mencari daerah yang subur", "Sering terjadinya bencana alam", "Sering terjadi peperangan antarkelompok", "Hidup manusia purba sangat bergantung pada alam" ], "correctAnswer": "Hidup manusia purba sangat bergantung pada alam", "category": "Sejarah" });

  await firestore.collection('sejarah_questions').doc('history_16').set({"id": "history_16", "question": "Pola hunian manusia purba memperlihatkan dua karakter khas purba yaitu kedekatan dengan sumber air, dan kehidupan alam terbuka. Pola hunian ini dapat diketahui dengan melihat pada", "options": [ "Letak geografis situs dan kondisi lingkungan", "Bekas sampah manusia purba", "Teknologi irigasi", "Pola bercocok tanam dan bentuk rumah"], "correctAnswer": "Bekas sampah manusia purba", "category": "Sejarah" });

  await firestore.collection('sejarah_questions').doc('history_17').set({"id": "history_17", "question": "Tujuan manusia pra-aksara selalu mencari tempat tinggal yang dekat dengan sumber air seperti sungai karena", "options": [ "Terhindar dari bencana alam", "Menghindari dari serangan binatang buas dan kelompok lain", "Lebih mudah hidup berkelompok", "Dekat dengan sumber makanan"], "correctAnswer": "Dekat dengan sumber makanan", "category": "Sejarah" });

  await firestore.collection('sejarah_questions').doc('history_18').set({"id": "history_18", "question": "Raja terbesar di Kutai. Raja yang sangat dermawan. Ia mengadakan kurban emas dan 20.000 ekor lembu kepada Kaum Brahmana. Siapakah raja tersebut", "options": [ "Raja Mulawarman", "Raja Purnawarman", "Raja Aswawarman", "Raja Marwan"], "correctAnswer": "Raja Mulawarman", "category": "Sejarah" });

  await firestore.collection('sejarah_questions').doc('history_19').set({"id": "history_19", "question": "Peristiwa sejarah yang terjadi di Eropa dan menandai terbukanya hubungan dagang antara Eropa dengan Indonesia adalah", "options": [ "Berkembangnya paham merkantilisme", "Revolusi industri di beberapa Negara", "Perang salib", "Jatuhnya konstantinopel" ], "correctAnswer": "Jatuhnya konstantinopel", "category": "Sejarah" });

  await firestore.collection('sejarah_questions').doc('history_20').set({"id": "history_20", "question": "Salah satu penyebab kedatangan bangsa Eropa ke dunia Timur termasuk Indonesia adalah", "options": [ "Keinginan untuk membuktikan bahwa bumi itu tidak datar", "Ingin menguasai daerah-daerah di luar Eropa", "Aktivitas perdagangan bangsa Eropa di laut tengah ditutup", "Bangsa Eropa ingin memperoleh keuntungan besar" ], "correctAnswer": "Aktivitas perdagangan bangsa Eropa di laut tengah ditutup", "category": "Sejarah" });

  // Sains Questions
  await firestore.collection('sains_questions').doc('science_1').set({"id": "science_1", "question": "Menurut Teori asam basa Arrhenius, zat dikatakan asam jika?", "options": ["Dalam air menghasilkan ion H+", "Dalam air menghasilkan atom H", "Donor proton", "Akseptor proton"], "correctAnswer": "Dalam air menghasilkan ion H+", "category": "Sains"});

  await firestore.collection('sains_questions').doc('science_2').set({"id": "science_2", "question": "Di antara larutan-larutan berikut, larutan yang termasuk dalam larutan basa adalah?", "options": ["C2H5OH", "CH3COOH", "HCl", "NaOH"], "correctAnswer": "NaOH", "category": "Sains"});

  await firestore.collection('sains_questions').doc('science_3').set({"id": "science_3", "question": "Di antara spesi berikut, yang tidak berlaku sebagai asam Bronsted-Lowry adalah?", "options": ["NH4+", "H2O", "HCO3-", "*O3^2-"], "correctAnswer": "CO3^2-", "category": "Sains"});

  await firestore.collection('sains_questions').doc('science_4').set({"id": "science_4", "question": "Indikator lakmus merah jika dicelupkan pada larutan basa akan berubah menjadi warna?", "options": ["Merah", "Biru", "Orange", "Tidak berwarna"], "correctAnswer": "Biru", "category": "Sains"});

  await firestore.collection('sains_questions').doc('science_5').set({"id": "science_5", "question": "Zat di bawah ini yang dapat memerahkan kertas lakmus adalah?", "options": ["NaOH", "Ca(OH)2", "CH3COOH", "CO(NH2)2"], "correctAnswer": "CH3COOH", "category": "Sains"});

  await firestore.collection('sains_questions').doc('science_6').set({"id": "science_6", "question": "Sepuluh gram urea CO(NH2)2 dilarutkan dalam 90 mL air. Bila tekanan uap jenuh air pada suhu 25 derajat celcius adalah 62 mmHG, maka tekanan uap larutan urea tersebut adalah", "options": ["2 mmHG", "30 mmHG", "31 mmHG", "60 mmHG"], "correctAnswer": "60 mmHG", "category": "Sains"});

  await firestore.collection('sains_questions').doc('science_7').set({"id": "science_7", "question": "Untuk mengetahui massa molekul relatif suatu senyawa elektrolit biner yang belum diketahui rumus molekulnya, seorang kimiawan melakukan percobaan di laboratorium dengan melarutkan 4 gram senyawa elektrolit tersebut ke 250 gram air. Suhu pada termometer menunjukkan 100,26°C pada tekanan 1 atm. Bila diketahui Kb air=0,52°C/m, maka Mr zat tersebut diperkirakan sejumlah", "options": ["16", "32", "64", "103"], "correctAnswer": "64", "category": "Sains"});

  await firestore.collection('sains_questions').doc('science_8').set({"id": "science_8", "question": "Larutan yang isotonis dengan asam nitrat 0,2 M adalah", "options": ["Aluminum sulfat 0,08 M", "Feri bromida 0,2 M", "Asam klorida 0,3 M", "Magnesium sulfat 0,4 M"], "correctAnswer": "Aluminum sulfat 0,08 M", "category": "Sains"});

  await firestore.collection('sains_questions').doc('science_9').set({"id": "science_9", "question": "Berdasarkan deret volta, reaksi elektrokimia yang dapat berlangsung secara spontan adalah", "options": ["Sn(s) + Fe^2+(aq) → Sn^2+(aq) + Fe(s)", "Sn^2+(aq) + Fe(s) → Sn(s) + Fe^2+(aq)", "Pb(s) + 2Ag^+(aq) → Pb^2+(aq) + 2Ag(s)", "3Mg^2+(aq) + 2Al(s) → 3Mg(s) + 2Al^3+(aq)"], "correctAnswer": "Pb(s) + 2Ag^+(aq) → Pb^2+(aq) + 2Ag(s)", "category": "Sains"});

  await firestore.collection('sains_questions').doc('science_10').set({"id": "science_10", "question": "Pasangan polimer yang terbentuk melalui reaksi kondensasi adalah", "options": ["Poliester dan polimida", "Polistirena dan politena", "Polisakrida dan polistirena", "Polivinil Klorida dan polistirena"], "correctAnswer": "Poliester dan polimida", "category": "Sains" });

  await firestore.collection('sains_questions').doc('science_11').set({"id": "science_11", "question": "Jumlah kuat arus listrik yang masuk titik percabangan sama dengan jumlah kuat arus listrik yang keluar dari titik percabangan adalah pernyataan dari", "options": ["Hukum I Newton", "Hukum II Newton", "Hukum III Newton", "Hukum I Kirchoff"], "correctAnswer": "Hukum I Kirchoff", "category": "Sains" });

  await firestore.collection('sains_questions').doc('science_12').set({"id": "science_12", "question": "Alat untuk mengukur kuat arus listrik dan beda potensial listrik adalah", "options": ["Amperemeter dan Neraca", "Voltmeter dan Jangka Sorong", "Mikrometer Sekrup dan Voltmeter", "Amperemeter dan Voltmeter"], "correctAnswer": "Amperemeter dan Voltmeter", "category": "Sains" });

  await firestore.collection('sains_questions').doc('science_13').set({"id": "science_13", "question": "Banyak garis gaya magnet yang terlingkupi atau terkurung dalam daerah dengan luas tertentu dinamakan", "options": ["Induksi magnet", "Medan magnet", "Garis gaya magnet", "Flux magnet"], "correctAnswer": "Flux magnet", "category": "Sains" });

  await firestore.collection('sains_questions').doc('science_14').set({"id": "science_14", "question": "Yang menemukan disekitar kawat akan ada medan magnet adalah ", "options": ["Ampere", "Biot Savart", "Coulomb", "H C Oersted"], "correctAnswer": "H C Oersted", "category": "Sains" });

  await firestore.collection('sains_questions').doc('science_15').set({"id": "science_15", "question": "Arah medan magnet disekitar kawat berarus listrik ditentukan dengan ", "options": ["Kaidah kepalan tangan kanan", "kaidah tangan kanan", "kaidah tangan kiri", "Hukum Lentz"], "correctAnswer": "Kaidah kepalan tangan kanan", "category": "Sains" });

  await firestore.collection('sains_questions').doc('science_16').set({"id": "science_16", "question": "Besar induksi magnet yang dihasilkan kawat berarus listrik, adalah", "options": ["Sebanding dengan jarak titik ke kawat penghantar", "Sebanding dengan kuat arus listrik", "Berbanding terbalik dengan panjang kawat", "Berbanding terbalik dengan kuat arus listrik"], "correctAnswer": "Sebanding dengan kuat arus listrik", "category": "Sains" });

  await firestore.collection('sains_questions').doc('science_17').set({"id": "science_17", "question": "Sebuah lampu memiliki spesifikasi 20 watt, 150 Volt. Lampu dipasang pada tegangan 150 volt. Kuat arus yang mengalir pada lampu adalah", "options": ["0,11 A", "0,12 A", "0,13 A", "0,14 A"], "correctAnswer": "0,13 A", "category": "Sains" });

  await firestore.collection('sains_questions').doc('science_18').set({"id": "science_18", "question": "Sebuah lampu memiliki spesifikasi 20 watt, 150 Volt. Lampu dipasang pada tegangan 150 volt. Hambatan lampu adalah", "options": ["1125 ohm", "1150 ohm", "1500 ohm", "2000 ohm"], "correctAnswer": "1125 ohm", "category": "Sains" });

  await firestore.collection('sains_questions').doc('science_19').set({"id": "science_19", "question": "Kawat logam yang memiliki hambatan R dipotong menjadi 3 bagian yang sama panjang dan kemudian bersebelahan untuk kabel baru dengan panjang sepertiga panjang semula. Besar hambatan kabel baru tersebut adalah", "options": ["1/9 R", "1/3 R", "R", "3 R"], "correctAnswer": "1/9 R", "category": "Sains" });

  await firestore.collection('sains_questions').doc('science_20').set({"id": "science_20", "question": "Sebuah bola berjari-jari 20 cm memiliki muatan +100 µC. Potensial listrik sebuah titik berjarak 30 cm dari permukaan bola tersebut adalah", "options": ["1,8 V", "1,8 KV", "1,8 MV", "1,8 GV"], "correctAnswer": "1,8 MV", "category": "Sains" });


  // English Questions
  await firestore.collection('english_questions').doc('english_1').set({"id": "english_1", "question": "Sarah: Well, I am actually tired of taking a math course. Ari: Why? Sarah: The formula makes me confused ........ . Ari : You'd better pay more atention", "options": ["What do you advise me to do?", "What is the best answer?", "What do you expect?", "What do you hope?"], "correctAnswer": "What do you advise me to do?", "category": "English"});

  await firestore.collection('english_questions').doc('english_2').set({"id": "english_2", "question": "Alice: I've got a terrible toothache. Ayu: You …….. go to the dentist.", "options": ["Better", "Are better", "Has better", "Can better", "Had better"], "correctAnswer": "Had better", "category": "English"});

  await firestore.collection('english_questions').doc('english_3').set({"id": "english_3", "question": "Ridho: I accidentally broke Dity's glasses I don't know what to do. Marty: If I were you, I ………….. tell her. Even though I know she'd be angry.", "options": ["Can", "Might", "Could", "Would"], "correctAnswer": "Would", "category": "English"});

  await firestore.collection('english_questions').doc('english_4').set({"id": "english_4", "question": "Raka: ….. Rido: I think so. It is important to learn English to expand our knowledge.", "options": ["Do you think English is important?", "What do you think about English?", "Would you study English hard?", "Could you tell me your opinion?"], "correctAnswer": "Do you think English is important?", "category": "English"});

  await firestore.collection('english_questions').doc('english_5').set({"id": "english_5", "question": "Tamam: ..... . Fida: Well, at least the movie has got five Academy Award nominations", "options": ["Do you love the movie?", "Is the movie good for us?", "What do you see from the movie", "Why do you think the movie is good"], "correctAnswer": "Why do you think the movie is good", "category": "English"});

  await firestore.collection('english_questions').doc('english_6').set({"id": "english_6", "question": "He is enthusiastic about his new position as a team leader and eager to … additional responsibilities.", "options": ["Get on", "Take after", "Taking over", "Take on"], "correctAnswer": "Take on", "category": "English"});

  await firestore.collection('english_questions').doc('english_7').set({"id": "english_7", "question": "Amsterdam is a city … below sea level.", "options": ["Built", "Has built", "That built", "Was built"], "correctAnswer": "Built", "category": "English" });

  await firestore.collection('english_questions').doc('english_8').set({"id": "english_8", "question": "Neither breakfast … dinner was available at the hotel.", "options": ["And", "Or", "Nor", "But"], "correctAnswer": "Nor", "category": "English" });

  await firestore.collection('english_questions').doc('english_9').set({"id": "english_9", "question": "I can’t decide whether to choose … in Bali or Jakarta.", "options": ["Living", "To live", "Lives", "Lived"], "correctAnswer": "To live", "category": "English" });

  await firestore.collection('english_questions').doc('english_10').set({"id": "english_10", "question": "After several rounds of interviews, I was informed that I … as the marketing assistant.", "options": ["Is chosen", "Accepted", "Was chosen", "Chose"], "correctAnswer": "Was chosen", "category": "English" });

  await firestore.collection('english_questions').doc('english_11').set({"id": "english_11", "question": "Dani has been working hard. …, his business is now thriving.", "options": ["Nevertheless", "Therefore", "Although", "Despite"], "correctAnswer": "Therefore", "category": "English" });

  await firestore.collection('english_questions').doc('english_12').set({"id": "english_12", "question": "The incorrect word in the following sentence is… The color of her car are brighter than my new one, making it more noticeable on the road.", "options": ["Color", "Are", "Than", "More"], "correctAnswer": "Are", "category": "English" });

  await firestore.collection('english_questions').doc('english_13').set({"id": "english_13", "question": "What do you think ____ by the time we meet again next summer?", "options": [ "he will start his new business", "will he start his new business", "will he have started his new business", "he will have started his new business" ], "correctAnswer": "he will have started his new business", "category": "English" });

  await firestore.collection('english_questions').doc('english_14').set({"id": "english_14", "question": "The chef is now preparing a special dish for the guests. The passive voice of the above sentence is ____________", "options": [ "A special dish is now being prepared for the guests", "The guests are preparing a special dish now", "The guests are now served with a special dish", "A special dish was being prepared by the guests" ], "correctAnswer": "A special dish is now being prepared for the guests", "category": "English" });

  await firestore.collection('english_questions').doc('english_15').set({"id": "english_15", "question": "The police are investigating the case. The passive form of the above sentence is ____________", "options": [ "The case was being investigated", "The case is being investigated", "The case has been investigated", "The police were investigating the case" ], "correctAnswer": "The case is being investigated", "category": "English" });

  await firestore.collection('english_questions').doc('english_16').set({"id": "english_16", "question": "The teacher said, “Submit your homework before the deadline!” This means…", "options": [ "The teacher advised us to submit our homework.", "The teacher ordered us to submit our homework before the deadline.", "The teacher asked us when the homework was due.", "The teacher requested us to do our homework quickly." ], "correctAnswer": "The teacher ordered us to submit our homework before the deadline.", "category": "English" });

  await firestore.collection('english_questions').doc('english_17').set({"id": "english_17", "question": "“Is everyone invited to the reunion dinner?” “Well, the event is reserved only for those _______”", "options": [ "who graduated in 2015", "were graduate in 2015", "they graduated from 2015", "to whom 2015 is meaningful" ], "correctAnswer": "who graduated in 2015", "category": "English" });

  await firestore.collection('english_questions').doc('english_18').set({"id": "english_18", "question": "The athlete won the gold medal. The coach praised him. The sentence can be combined as follows.. The athlete _______ won the gold medal.", "options": [ "whom the coach praised", "which the coach praised", "he is praised by the coach", "is praised by the coach" ], "correctAnswer": "whom the coach praised", "category": "English" });

  await firestore.collection('english_questions').doc('english_19').set({"id": "english_19", "question": "Laughing so loudly, they forgot to hear the announcement. The underlined part means: ______________, they forgot to hear the announcement.", "options": [ "Although they laughed loudly", "Because they were laughing loudly", "When they had laughed loudly", "In order to laugh loudly" ], "correctAnswer": "Because they were laughing loudly", "category": "English" });

  await firestore.collection('english_questions').doc('english_20').set({"id": "english_20", "question": "I saw her running when the fire broke out this morning. This means ___________.", "options": [ "She was running when the fire broke out", "I was running and saw the fire", "The fire saw her running", "She caused the fire by running" ], "correctAnswer": "She was running when the fire broke out", "category": "English" });

  print("All questions uploaded successfully!");
}