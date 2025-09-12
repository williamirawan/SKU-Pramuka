import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:sku_pramuka/service/auth.dart';
import 'package:uuid/uuid.dart';

var tag = "dis";

class UserProfile extends StatefulWidget {
  final String db;
  final String uid;
  final bool edit;
  final bool admin;
  String? kecamatan;
  UserProfile(
      {super.key,
      required this.db,
      required this.uid,
      required this.edit,
      required this.admin,
      this.kecamatan});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _isLoading = true;
  Map<String, dynamic>? userMap;
  AuthClass authClass = AuthClass();
  String? selectedSekolah;
  String? formattedDate;
  String? selectedKota;
  String? selectedKecamatan;
  String? selectedAgama;
  String kota = "";
  String kecamatan = "";
  String sekolah = "";
  String gudep = "";
  DateTime? tl;
  String kecakapan = "None";
  int umur = -1;
  Map<String, dynamic> mapKota = {};
  List<String> listKec = [];
  List<String> listKota = [];
  List<String> listKecamatan = [];
  late List<Map<String, dynamic>> listSekolah;
  late List<String> uidSekolah;
  List<String> listAgama = [
    "Islam",
    "Katolik",
    "Prostestan",
    "Hindu",
    "Buddha"
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tag = "dis";
    switch (widget.db) {
      case "siswa":
        initSiswa();
        break;
      case "pembina":
        initPembina();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color.fromARGB(255, 78, 108, 80),
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingPage()
          : StreamBuilder<DocumentSnapshot>(
              stream:
                  _firestore.collection(widget.db).doc(widget.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    height: MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        kBottomNavigationBarHeight,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              tag = snapshot.data!["profile"];
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SaveImage(
                                    imageUrl: snapshot.data!['profile'],
                                    tag: tag,
                                    collection: widget.db,
                                    doc: widget.uid,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: snapshot.data!['profile'],
                              child: ClipOval(
                                child: SizedBox.fromSize(
                                  size: const Size.fromRadius(120),
                                  child: Image.network(
                                      snapshot.data!['profile'],
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          tile(
                            const Icon(Icons.person),
                            "Name",
                            snapshot.data!['name'],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          tile(
                            const Icon(Icons.email),
                            "Email",
                            snapshot.data!['email'],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          widget.db == "siswa"
                              ? siswaWidget(snapshot)
                              : widget.db == "pembina"
                                  ? pembinaWidget(snapshot)
                                  : adminWidget(snapshot),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const LoadingPage();
                }
              }),
    );
  }

  Column siswaWidget(AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
    widget.edit
        ? getList(snapshot.data!['tingkat'], snapshot.data!['kecakapan'])
        : null;
    return Column(
      children: [
        tile(
          const Icon(Icons.event),
          "Tanggal Lahir",
          DateFormat("d MMMM yyyy", "id_ID")
              .format((snapshot.data!['tl'] as Timestamp).toDate()),
        ),
        const SizedBox(
          height: 20,
        ),
        tile(
          const Icon(Icons.elderly),
          "Tingkat",
          snapshot.data!['tingkat'],
        ),
        const SizedBox(
          height: 20,
        ),
        tile(
          const Icon(Icons.info),
          "Kecakapan",
          snapshot.data!['kecakapan'],
        ),
        const SizedBox(
          height: 20,
        ),
        tile(
          const Icon(Icons.school),
          "Sekolah",
          sekolah,
        ),
        const SizedBox(
          height: 20,
        ),
        tile(
          const Icon(Icons.numbers),
          "Nomor Gudep",
          gudep,
        ),
        const SizedBox(
          height: 20,
        ),
        tile(
          const Icon(Icons.location_on),
          "Kecamatan",
          kecamatan,
        ),
        const SizedBox(
          height: 20,
        ),
        tile(
          const Icon(Icons.location_city),
          "Kota",
          kota,
        ),
      ],
    );
  }

  Column pembinaWidget(AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
    return Column(
      children: [
        tile(const Icon(Icons.school), "Sekolah", sekolah),
        const SizedBox(height: 20),
        tile(
          const Icon(Icons.location_on),
          "Kecamatan",
          snapshot.data!["kecamatan"],
        ),
        const SizedBox(
          height: 20,
        ),
        tile(
          const Icon(Icons.location_city),
          "Kota",
          snapshot.data!["kota"],
        ),
      ],
    );
  }

  Column adminWidget(AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
    return Column();
  }

  void initSiswa() async {
    setState(() {
      _isLoading = true;
    });

    await _firestore.collection("siswa").doc(widget.uid).get().then((value) {
      userMap = value.data();
      tag = userMap!['profile'];
    });

    await _firestore
        .collection("sekolah")
        .doc(userMap!["sekolah"])
        .get()
        .then((value) {
      kota = value.data()!["kota"];
      kecamatan = value.data()!["kecamatan"];
      sekolah = value.data()!["nama"];

      if (userMap!["gender"] == "Laki-laki") {
        gudep = value.data()!["gudep putra"];
      } else {
        gudep = value.data()!["gudep putri"];
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  void initPembina() async {
    setState(() {
      _isLoading = true;
    });

    _firestore.collection("pembina").doc(widget.uid).get().then((value) async {
      uidSekolah = (value.data()!["sekolah"] as List)
          .map((item) => item as String)
          .toList();
      sekolah = "";
      for (var s in uidSekolah) {
        await _firestore.collection("sekolah").doc(s).get().then(
            (value) => sekolah = "$sekolah•   ${value.data()!['nama']}\n");
      }

      setState(() {
        _isLoading = false;
      });
    });
  }

  void getList(String tingkat, String kec) async {
    kecakapan = kec;
    switch (tingkat) {
      case "Siaga":
        listKec = <String>["Muda", "Bantu", "Tata"];
        break;
      case "Penggalang":
        listKec = <String>["Ramu", "Rakit", "Terap", "Garuda"];
        break;
      case "Penegak":
        listKec = <String>["Tamu", "Bantara", "Laksana"];
        break;
      default:
    }
  }

  void save(String a, String b) async {
    await _firestore
        .collection(widget.db)
        .doc(widget.uid)
        .update({a.toLowerCase(): b});

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$a berhasil diubah')));
  }

  Widget tile(Icon dis, String title, String subs) {
    List<String> nono = [
      "Email",
      "Tanggal Lahir",
      "Nomor Gudep",
      "Kecamatan",
      "Kota"
    ];
    !widget.admin
        ? nono = [
            "Sekolah",
            "Kecamatan",
            "Kota",
            "Email",
            "Tanggal Lahir",
            "Tingkat",
            "Nomor Gudep"
          ]
        : null;
    return ListTile(
      leading: dis,
      title: Text(title,
          style: const TextStyle(color: Colors.black, fontSize: 15)),
      subtitle: Text(subs,
          style: const TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
      trailing: widget.edit && !nono.contains(title)
          ? IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.grey,
              ),
              onPressed: () {
                textEditingController.text = subs;
                switch (title) {
                  case "Name":
                    ubahNama(title, subs);
                    break;
                  case "Kecakapan":
                    ubahKec();
                    break;
                  case "Sekolah":
                    ubahSekolah();
                    break;

                  default:
                }
              },
            )
          : const SizedBox(),
    );
  }

  Future<dynamic> ubahNama(String title, String subs) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextFormField(
          controller: textEditingController,
          decoration: InputDecoration(hintText: title),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("BATAL"),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (textEditingController.text != subs &&
                    textEditingController.text != "")
                  save(title, textEditingController.text);
              },
              child: const Text("SIMPAN"))
        ],
      ),
    );
  }

  Future<dynamic> ubahKec() {
    String tmpKec = kecakapan;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Kecakapan"),
        content: DropdownButtonFormField<String>(
          value: tmpKec,
          items: listKec.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) => setState(() {
            tmpKec = value!;
          }),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("BATAL"),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (kecakapan != tmpKec) {
                  kecakapan = tmpKec;
                  save("Kecakapan", kecakapan);
                }
              },
              child: const Text("SIMPAN"))
        ],
      ),
    );
  }

  Future<dynamic> ubahSekolah() async {
    listSekolah = await _firestore
        .collection("sekolah")
        .where("kecamatan", isEqualTo: widget.kecamatan)
        .get()
        .then((value) =>
            listSekolah = value.docs.map((doc) => doc.data()).toList());
    print(widget.kecamatan);
    print(listSekolah);
    return showDialog(
      context: context,
      builder: (context) {
        // List<String> tmp =
        //     listSekolah.map((map) => map["nama"].toString()).toList();
        return AlertDialog(
          title: const Text('Edit Sekolah'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: listSekolah
                      .map(
                        (sekolah) => CheckboxListTile(
                          title: Text(sekolah["nama"]),
                          value: uidSekolah.contains(sekolah["uid"]),
                          onChanged: (value) {
                            setState(() {
                              if (value != null && value) {
                                uidSekolah.add(sekolah["uid"]);
                              } else {
                                uidSekolah.remove(sekolah["uid"]);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("BATAL"),
            ),
            TextButton(
                onPressed: () {
                  simpanSekolah();
                  Navigator.of(context).pop();
                },
                child: const Text("SIMPAN"))
          ],
        );
      },
    );
  }

  Future<void> simpanSekolah() async {
    await _firestore
        .collection("pembina")
        .doc(widget.uid)
        .update({"sekolah": uidSekolah});
    initPembina();
  }

  // Widget daftarSekolah(List<String> texts) {
  //   var widgetList = <Widget>[];
  //   widgetList.add(
  //     const Text("Daftar Sekolah",
  //         style: TextStyle(color: Colors.black, fontSize: 15)),
  //   );
  //   widgetList.add(const SizedBox(height: 10));
  //   for (var text in texts) {
  //     widgetList.add(unorderedListItem(text));
  //     widgetList.add(const SizedBox(
  //       height: 5,
  //     ));
  //   }

  //   return Column(children: widgetList);
  // }

  // Widget unorderedListItem(String text) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       const Text("• "),
  //       Expanded(
  //         child: Text(
  //           text,
  //           style: const TextStyle(
  //               color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

class SaveImage extends StatelessWidget {
  final String imageUrl, collection, doc;
  final tag;

  SaveImage(
      {required this.imageUrl,
      required this.tag,
      Key? key,
      required this.collection,
      required this.doc})
      : super(key: key);

  File? imageFile;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color.fromARGB(255, 78, 108, 80),
        centerTitle: true,
        title: const Text(
          "Gambar Profile",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () async {
              final source = await showImageSource(context);
              if (source == null) return;
              await pickImage(source, context).then((value) {
                // if (value) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text("Gambar profile berhasil diubah"),
                //     ),
                //   );
                //   Navigator.pop(context);
                // }
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
      body: Hero(
        tag: tag,
        child: Container(
          height: size.height,
          width: size.width,
          color: Colors.black,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  Future<ImageSource?> showImageSource(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: ((context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          )),
    );
  }

  Future<bool> pickImage(ImageSource source, BuildContext context) async {
    try {
      await ImagePicker()
          .pickImage(source: source, imageQuality: 80)
          .then((value) async {
        if (value != null) {
          imageFile = File(value.path);
          return await uploadImage();
        } else {
          return false;
        }
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengambil gambar: $e"),
        ),
      );
    }
    return false;
  }

  Future<bool> uploadImage() async {
    String fileName = const Uuid().v1();

    var ref =
        FirebaseStorage.instance.ref().child('profiles').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!).then((p0) async {
      String imageUrl = await ref.getDownloadURL();
      await _firestore
          .collection(collection)
          .doc(doc)
          .update({"profile": imageUrl}).then((value) {
        print("True 3");
        return true;
      });
    });
    return false;
  }
}
