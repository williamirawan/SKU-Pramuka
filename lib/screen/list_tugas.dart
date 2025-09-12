import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sku_pramuka/screen/home_screen.dart';
import 'package:sku_pramuka/screen/profile_screen.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:sku_pramuka/service/auth.dart';
import 'package:sku_pramuka/widgets/card_cek.dart';
import 'package:sku_pramuka/widgets/card_tugas.dart';

// int index = 0;

// final List<Widget> _children = [
//   HomePage(i: index),
//   ListTugas(i: index),
//   ProfilePage(i: index)
// ];

class ListTugas extends StatefulWidget {
  final int i;
  const ListTugas({super.key, required this.i});

  @override
  State<ListTugas> createState() => _ListTugasState();
}

class _ListTugasState extends State<ListTugas> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthClass authClass = AuthClass();
  bool _isLoading = false;

  List<String> kategori = [];
  Map<String, String> userMap = {"Kecakapan": "Dis"};
  Map<String, String> pembina = {};
  Map<String, dynamic> progress = {};
  Map<String, dynamic>? siswaMap = {};
  Map<String, dynamic>? tugasMap = {};
  String sekolah = "";

  String db = "siswa";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    //index = widget.i;
    switch (widget.i) {
      case 0:
        db = "siswa";
        init();
        break;
      case 1:
        db = "pembina";
        initPembina();
        break;
      default:
    }
    print(widget.i);
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
          "SKU",
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
      body: widget.i == 0 ? SiswaWidget() : PembinaWidget(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        onTap: onTap,
        currentIndex: 1,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color.fromARGB(255, 78, 108, 80),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 32,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.indigoAccent,
                    Colors.purple,
                  ],
                ),
              ),
              child: const Icon(
                Icons.task,
                size: 32,
                color: Colors.white,
              ),
            ),
            label: "Tugas",
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_rounded,
              size: 32,
            ),
            label: "Settings",
          ),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> SiswaWidget() {
    String tmpKec = userMap["kecakapan"].toString();
    if (userMap["kecakapan"] == "Tamu") {
      switch (userMap["tingkat"]) {
        case "Penggalang":
          tmpKec = "Ramu";
          break;
        case "Penegak":
          tmpKec = "Bantara";
          break;
        default:
      }
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('tugas')
          .orderBy("no")
          .where("kecakapan", isEqualTo: tmpKec.toLowerCase())
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
                  i: widget.i,
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
                  kec: userMap["kecakapan"]!.toString(),
                  pembina: pembina,
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
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> PembinaWidget() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('pembina')
          .doc(_auth.currentUser!.uid)
          .collection("pending")
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
              return CardCek(
                  no: tugasMap!["no"],
                  i: widget.i,
                  uid: snapshot.data!.docs[index].id,
                  siswa: siswaMap!,
                  tugas: tugasMap!,
                  sekolah: sekolah,
                  iconData: tugasMap!['kategori'].contains("outdoor")
                      ? Icons.hiking
                      : Icons.edit,
                  iconColor: tugasMap!['kategori'].contains("outdoor")
                      ? Colors.white
                      : const Color(0xFF395144),
                  iconBgColor: tugasMap!['kategori'].contains("outdoor")
                      ? const Color(0xff00B8A9)
                      : Colors.white,
                  kategori: kategori);
            },
          );
        } else {
          return const LoadingPage();
        }
      },
    );
  }

  Future<void> init() async {
    await _firestore
        .collection("siswa")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
      userMap["kecakapan"] = value.data()!["kecakapan"];
      userMap["tingkat"] = value.data()!["tingkat"];
      userMap["agama"] = value.data()!["agama"];
    });
    init2().then((value) => setState((() {
          _isLoading = false;
        })));
  }

  Future<void> init2() async {
    await _firestore
        .collection("siswa")
        .doc(_auth.currentUser!.uid)
        .collection("progress")
        .get()
        .then((value) {
      for (var doc in value.docs) {
        progress[doc.data()["tugas"].toString()] = doc.data();
      }
    });
    init3();
  }

  Future<void> init3() async {
    await _firestore
        .collection("pembina")
        .where("siswa", arrayContains: _auth.currentUser!.uid)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        pembina[doc.data()["uid"].toString()] = doc.data()["nama"].toString();
      }
    });
  }

  Future<void> initPembina() async {
    await _firestore
        .collection("pembina")
        .doc(_auth.currentUser!.uid)
        .collection("pending")
        .get()
        .then((value) {
      if (value.size == 0) {
        setState(() {
          _isLoading = false;
        });
      }
      for (var doc in value.docs) {
        initPembina2(doc).then((value) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  Future<void> initPembina2(
      QueryDocumentSnapshot<Map<String, dynamic>> map) async {
    await _firestore.collection("siswa").doc(map["siswa"]).get().then((value) {
      siswaMap = value.data()!;
      _firestore
          .collection("sekolah")
          .doc(siswaMap!["sekolah"])
          .get()
          .then((value) => sekolah = value.data()!["nama"]);
    });

    await _firestore.collection("tugas").doc(map["tugas"]).get().then((value) {
      tugasMap = value.data()!;
      kategori = (tugasMap!["kategori"] as List)
          .map((item) => item as String)
          .toList();
    });
  }

  void onTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(i: widget.i),
        ));
        break;
      case 1:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ListTugas(i: widget.i),
        ));
        break;
      case 2:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ProfilePage(i: widget.i),
        ));
        break;
      default:
    }
    // Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (context) => _children[index]));
  }

  String check(String uid) {
    if (progress[uid] != null) {
      return progress[uid]["progress"];
    } else {
      return "belum";
    }
  }
}
