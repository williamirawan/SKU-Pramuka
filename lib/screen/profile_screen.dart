import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sku_pramuka/screen/home_screen.dart';
import 'package:sku_pramuka/screen/list_tugas.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:sku_pramuka/service/auth.dart';
import 'package:uuid/uuid.dart';

// int index = 0;
var tag = "dis";

// final List<Widget> _children = [
//   HomePage(i: index),
//   ListTugas(i: index),
//   ProfilePage(i: index)
// ];

class ProfilePage extends StatefulWidget {
  final int i;
  const ProfilePage({super.key, required this.i});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? userMap;
  AuthClass authClass = AuthClass();
  String db = "siswa";
  String kota = "";
  String kecamatan = "";
  String sekolah = "";
  String gudep = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tag = "dis";
    switch (widget.i) {
      case 0:
        init();
        break;
      case 1:
        db = "pembina";
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              authClass.signOutGoogle(context: context);
              authClass.signOut(context);
            },
            color: Colors.redAccent,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingPage()
          : StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection(db)
                  .doc(_auth.currentUser!.uid)
                  .snapshots(),
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
                                    collection: db,
                                    doc: _auth.currentUser!.uid,
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
                          widget.i == 0
                              ? siswaWidget(snapshot)
                              : lainWidget(snapshot),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const LoadingPage();
                }
              }),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        onTap: onTap,
        currentIndex: 2,
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

  Column siswaWidget(AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
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

  Column lainWidget(AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
    return Column(
      children: [
        widget.i == 1
            ? tile(const Icon(Icons.school), "Sekolah", sekolah)
            : Container(),
        widget.i == 1 ? const SizedBox(height: 20) : Container(),
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

  void init() async {
    setState(() {
      _isLoading = true;
    });

    await _firestore
        .collection("siswa")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
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
    List<String> tmp = [];

    _firestore
        .collection("pembina")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) async {
      tmp = (value.data()!["sekolah"] as List)
          .map((item) => item as String)
          .toList();
      sekolah = "";
      for (var s in tmp) {
        await _firestore.collection("sekolah").doc(s).get().then(
            (value) => sekolah = "$sekolah•   ${value.data()!['nama']}\n");
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  void save(String dis) async {
    await _firestore
        .collection(db)
        .doc(_auth.currentUser!.uid)
        .update({dis.toLowerCase(): textEditingController.text});

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$dis updated successfully')));
  }

  Widget tile(Icon dis, String title, String subs) {
    return ListTile(
      leading: dis,
      title: Text(title,
          style: const TextStyle(color: Colors.black, fontSize: 15)),
      subtitle: Text(subs,
          style: const TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
      trailing: widget.i > 0 && title == "Name"
          ? IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.grey,
              ),
              onPressed: () {
                textEditingController.text = subs;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Edit $title anda"),
                    content: TextFormField(
                      controller: textEditingController,
                      decoration: InputDecoration(hintText: "$title Anda"),
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
                                textEditingController.text != "") save(title);
                          },
                          child: const Text("SIMPAN"))
                    ],
                  ),
                );
              },
            )
          : const SizedBox(),
    );
  }

  Widget daftarSekolah(List<String> texts) {
    var widgetList = <Widget>[];
    widgetList.add(
      const Text("Daftar Sekolah",
          style: TextStyle(color: Colors.black, fontSize: 15)),
    );
    widgetList.add(const SizedBox(height: 10));
    for (var text in texts) {
      widgetList.add(unorderedListItem(text));
      widgetList.add(const SizedBox(
        height: 5,
      ));
    }

    return Column(children: widgetList);
  }

  Widget unorderedListItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("• "),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
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

  // Future<bool> pickImage(BuildContext context) async {
  //   try {
  //     await ImagePicker()
  //         .pickImage(source: ImageSource.gallery, imageQuality: 80)
  //         .then((value) async {
  //       if (value != null) {
  //         imageFile = File(value.path);
  //         return uploadImage();
  //       }
  //     });
  //   } on PlatformException catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Gagal mengambil gambar dari galeri: $e"),
  //       ),
  //     );
  //   }
  //   return false;
  // }

  // Future<bool> takeImage(BuildContext context) async {
  //   try {
  //     await ImagePicker()
  //         .pickImage(source: ImageSource.camera, imageQuality: 80)
  //         .then((value) async {
  //       if (value != null) {
  //         imageFile = File(value.path);
  //         return uploadImage();
  //       }
  //     });
  //   } on PlatformException catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Gagal mengambil gambar dari kamera: $e"),
  //       ),
  //     );
  //   }
  //   return false;
  // }

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
