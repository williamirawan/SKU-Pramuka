import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:sku_pramuka/widgets/card_siswa.dart';

class ListSiswa extends StatefulWidget {
  final bool isAdmin;
  final bool siswaBaru;
  const ListSiswa({super.key, required this.isAdmin, required this.siswaBaru});

  @override
  State<ListSiswa> createState() => _ListSiswaState();
}

class _ListSiswaState extends State<ListSiswa> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<dynamic> listSekolah = [];
  Map<String, String> mapSekolah = {};
  bool _isLoading = false;
  String db = "pembina";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.siswaBaru) {
      db = "admin";
    }
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 78, 108, 80),
        title: const Text(
          "Daftar Siswa",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          StreamBuilder(
            stream: _firestore
                .collection(db)
                .doc(_auth.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Row(
                  children: [
                    ClipOval(
                      child: SizedBox.fromSize(
                        size: const Size.fromRadius(28),
                        child: Image.network(
                          snapshot.data!["profile"],
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                  ],
                );
              } else {
                return Row(
                  children: const [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingPage()
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('siswa')
                  .where("sekolah", whereIn: listSekolah)
                  .orderBy("tingkat")
                  .orderBy("kecakapan")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    reverse: false,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> map = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      return CardSiswa(
                          kecakapan: map["kecakapan"],
                          nama: map["name"],
                          profile: map["profile"],
                          sekolah: mapSekolah[map["sekolah"]]!,
                          tingkat: map["tingkat"],
                          uid: map["uid"],
                          isAdmin: widget.isAdmin);
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
    );
  }

  void init() async {
    setState(() {
      _isLoading = true;
    });
    await _firestore
        .collection("pembina")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
      listSekolah = value["sekolah"];
    });

    for (var sekolah in listSekolah) {
      await _firestore
          .collection("sekolah")
          .doc(sekolah.toString())
          .get()
          .then((value) => mapSekolah[value["uid"]] = value["nama"]);
    }

    setState(() {
      _isLoading = false;
    });

    print(mapSekolah);
  }
}
