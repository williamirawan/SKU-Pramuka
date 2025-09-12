import 'package:flutter/material.dart';

class TeksPage extends StatelessWidget {
  final int index;
  TeksPage({super.key, required this.index});

  final List<Map<String, String>> konten = [
    {
      "judul": "Pancasila",
      "isi":
          "1. Ketuhanan yang Maha Esa\n\n2. Kemanusiaan yang adil dan beradab\n\n3. Persatuan Indonesia\n\n4. Kerakyatan yang dipimpin oleh hikmat kebijaksanaan dalam permusyawaratan/perwakilan, serta\n\n5. Keadilan sosial bagi seluruh rakyat Indonesia",
      "gambar": "Pancasila.png"
    },
    {
      "judul": "Tri Satya",
      "isi":
          "Demi kehormatanku, aku berjanji akan bersungguh-sungguh:\n\n1. Menjalankan kewajibanku terhadap Tuhan, Negara Kesatuan Republik Indonesia dan mengamalkan Pancasila\n\n2. Menolong sesama hidup dan mempersiapkan diri membangun masyarakat\n\n3. Menepati Dasa Dharma",
      "gambar": "Pramuka.png"
    },
    {
      "judul": "Dasa Dharma",
      "isi":
          "1. Takwa kepada Tuhan Yang Maha Esa\n\n2. Cinta alam dan kasih sayang sesama manusia\n\n3. Patriot yang sopan dan ksatria\n\n4. Patuh dan suka bermusyawarah\n\n5. Rela menolong dan tabah\n\n6. Rajin, terampil dan gembira\n\n7. Hemat, cermat dan bersahaja\n\n8. Disiplin, berani dan setia\n\n9. Bertanggung jawab dan dapat dipercaya\n\n10. Suci dalam pikiran, perkataan dan perbuatan",
      "gambar": "Pramuka.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color.fromARGB(255, 78, 108, 80),
        centerTitle: true,
        title: Text(
          konten[index]["judul"]!,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/image/${konten[index]['gambar']}",
              width: 300,
              height: 200,
            ),
            const SizedBox(height: 30),
            Text(
              konten[index]["isi"]!,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            )
          ],
        )),
      ),
    );
  }
}
