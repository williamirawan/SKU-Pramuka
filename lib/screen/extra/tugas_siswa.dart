import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sku_pramuka/screen/extra/user_profile.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:sku_pramuka/widgets/card_tugas.dart';

class TugasSiswa extends StatefulWidget {
  final String uid;
  final String nama;
  const TugasSiswa({super.key, required this.uid, required this.nama});

  @override
  State<TugasSiswa> createState() => _TugasSiswaState();
}

class _TugasSiswaState extends State<TugasSiswa> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  List<String> kategori = [];
  Map<String, String> pending = {};
  Map<String, String> userMap = {"Kecakapan": "Dis"};
  Map<String, dynamic> progress = {};
  Map<String, dynamic>? tugasMap = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
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
        title: Text(
          "SKU ${widget.nama}",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          StreamBuilder(
            stream: _firestore.collection("siswa").doc(widget.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfile(
                            uid: widget.uid,
                            db: "siswa",
                            edit: true,
                            admin: false,
                          ),
                        ),
                      ),
                      child: ClipOval(
                        child: SizedBox.fromSize(
                          size: const Size.fromRadius(28),
                          child: Image.network(
                            snapshot.data!["profile"],
                            fit: BoxFit.fill,
                          ),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tugas')
            .orderBy("no")
            .where("kecakapan",
                isEqualTo: userMap["kecakapan"].toString().toLowerCase())
            .where("tingkat",
                isEqualTo: userMap["tingkat"].toString().toLowerCase())
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData && !_isLoading) {
            return ListView.builder(
              reverse: false,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> map =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                if (map["no"] != 1 ||
                    map["kategori"].contains(userMap["agama"]!.toLowerCase())) {
                  kategori = (map["kategori"] as List)
                      .map((item) => item as String)
                      .toList();
                  return CardTugas(
                    i: 1,
                    no: map["no"],
                    uid: map["uid"],
                    title: map["nama"],
                    iconData: map['kategori'].contains("outdoor")
                        ? Icons.hiking
                        : Icons.edit,
                    iconColor: map['kategori'].contains("outdoor")
                        ? Colors.white
                        : const Color(0xFF395144),
                    iconBgColor: map['kategori'].contains("outdoor")
                        ? const Color(0xff00B8A9)
                        : Colors.white,
                    check: check(map["uid"]),
                    kategori: kategori,
                    pembina: const {},
                    uidSiswa: widget.uid,
                    kec: userMap["kecakapan"].toString(),
                    namaSiswa: userMap["nama"],
                    uidPending: pending[map["uid"]],
                    sekolah: userMap["sekolah"],
                  );
                } else {
                  return Container();
                }
              },
            );
          } else {
            return const LoadingPage();
          }
        },
      ),
    );
  }

  Future<void> init() async {
    setState(() {
      _isLoading = true;
    });
    await _firestore
        .collection("siswa")
        .doc(widget.uid)
        .get()
        .then((value) async {
      await _firestore
          .collection("sekolah")
          .doc(value.data()!["sekolah"])
          .get()
          .then((value) => userMap["sekolah"] = value.data()!["nama"]);
      userMap["nama"] = value.data()!["name"];
      userMap["kecakapan"] = value.data()!["kecakapan"];
      userMap["tingkat"] = value.data()!["tingkat"];
      userMap["agama"] = value.data()!["agama"];
    });
    init2().then((value) => setState((() {
          _isLoading = false;
          print(pending);
        })));
  }

  Future<void> init2() async {
    await _firestore
        .collection("siswa")
        .doc(widget.uid)
        .collection("progress")
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        progress[doc.data()["tugas"].toString()] = doc.data();
        if (doc.data()["progress"] == "proses" &&
            doc.data()["pembina"] == _auth.currentUser!.uid) {
          await _firestore
              .collection("pembina")
              .doc(_auth.currentUser!.uid)
              .collection("pending")
              .where("tugas", isEqualTo: doc.data()["tugas"].toString())
              .where("siswa", isEqualTo: widget.uid)
              .get()
              .then((value) =>
                  pending[doc.data()["tugas"].toString()] = value.docs[0].id);
        }
      }
    });
  }

  String check(String uid) {
    if (progress[uid] != null) {
      return progress[uid]["progress"];
    } else {
      return "belum";
    }
  }
}
