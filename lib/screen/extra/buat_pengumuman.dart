import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sku_pramuka/screen/home_screen.dart';
import 'package:uuid/uuid.dart';

var tag = "foto";
File? file;

class BuatPengumuman extends StatefulWidget {
  final String? uid;
  final String? judul;
  final String? detil;
  final String? foto;
  const BuatPengumuman(
      {super.key, this.uid, this.judul, this.detil, this.foto});

  @override
  State<BuatPengumuman> createState() => _BuatPengumumanState();
}

class _BuatPengumumanState extends State<BuatPengumuman> {
  TextEditingController judulCon = TextEditingController();
  TextEditingController detilCon = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String nama = "";
  String? selectedSekolah;
  String? selectedUrgensi;
  String urgensi = "";
  Map<String, String> mapSekolah = {};
  List<String> listSekolah = [];
  List<String> listUrgensi = ["Bahaya", "Peringatan", "Informasi"];
  bool _isLoading = false;
  bool edit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.uid != null) {
      edit = true;
      judulCon.text = widget.judul!;
      detilCon.text = widget.detil!;
    }
    file = null;
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 78, 108, 80),
          title: Text(edit ? "Edit Pengumuman" : "Buat Pengumuman",
              style: const TextStyle(color: Colors.white, fontSize: 24)),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 240, 235, 206),
                Color.fromARGB(255, 250, 245, 216),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text("Judul Pengumuman"),
                  const SizedBox(
                    height: 10.0,
                  ),
                  input("Judul Pengumuman", judulCon, false),
                  const SizedBox(
                    height: 20.0,
                  ),
                  text("Gambar Pendukung"),
                  const SizedBox(
                    height: 10.0,
                  ),
                  foto(),
                  const SizedBox(
                    height: 20.0,
                  ),
                  text("Detil Pengumuman"),
                  const SizedBox(
                    height: 10.0,
                  ),
                  input("Detil Pengumuman", detilCon, true),
                  const SizedBox(
                    height: 20.0,
                  ),
                  text("Sekolah"),
                  const SizedBox(
                    height: 10.0,
                  ),
                  fieldDropDownSekolah(),
                  const SizedBox(
                    height: 20.0,
                  ),
                  text("Urgensi Pengumuman"),
                  const SizedBox(
                    height: 10.0,
                  ),
                  fieldDropDownUrgensi(),
                  const SizedBox(
                    height: 40.0,
                  ),
                  button(),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> init() async {
    await _firestore
        .collection("pembina")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) async {
      nama = value["name"];
      for (var dis in value["sekolah"]) {
        await _firestore
            .collection("sekolah")
            .doc(dis.toString())
            .get()
            .then((value) {
          mapSekolah[value["uid"]] = value["nama"];
          listSekolah.add(value["nama"]);
        });
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget text(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget input(String hint, TextEditingController dis, bool banyak) {
    return Container(
      height: banyak ? 150 : 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 17,
        ),
        controller: dis,
        maxLines: banyak ? null : 1,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 17,
          ),
          contentPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
        ),
      ),
    );
  }

  Widget foto() {
    return file != null || edit
        ? InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (_) => ViewImage(
                    imageUrl: edit ? widget.foto : null,
                    proses: edit,
                  ),
                ),
              )
                  .then((value) {
                setState(() {});
              });
            },
            child: Center(
              child: edit && file == null
                  ? Image.network(
                      widget.foto!,
                      width: 200,
                      height: 250,
                      fit: BoxFit.contain,
                    )
                  : Image.file(
                      file!,
                      width: 200,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
            ),
          )
        : Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                final source = await showImageSource(context);

                if (source == null) return;
                pickImage(source);
              },
              child: const Text('Ambil Gambar'),
            ),
          );
  }

  Widget fieldDropDownSekolah() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: DropdownButtonFormField<String>(
        value: selectedSekolah,
        items: listSekolah.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSekolah = value;
          });
        },
        validator: (value) =>
            value == null ? "Mohon isikan sekolah tujuan" : null,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
            prefixIcon: const Icon(
              Icons.location_city,
              color: Colors.grey,
            ),
            labelText: "Sekolah",
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.deepOrange,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15))),
      ),
    );
  }

  Widget fieldDropDownUrgensi() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: DropdownButtonFormField<String>(
        value: selectedUrgensi,
        items: listUrgensi.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedUrgensi = value;
          });
        },
        validator: (value) =>
            value == null ? "Mohon isikan urgensi pengumuman ini" : null,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
            prefixIcon: const Icon(
              Icons.location_on,
              color: Colors.grey,
            ),
            labelText: "Urgensi",
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.deepOrange,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15))),
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

  Future<bool> pickImage(ImageSource source) async {
    try {
      await ImagePicker().pickImage(source: source).then((value) async {
        if (value != null) {
          setState(() {
            file = File(value.path);
          });
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

  Widget button() {
    return InkWell(
      onTap: () async {
        EasyLoading.show(
            status: "Loading...",
            dismissOnTap: false,
            maskType: EasyLoadingMaskType.black);
        String uidSekolah =
            mapSekolah.keys.firstWhere((e) => mapSekolah[e] == selectedSekolah);
        String foto = "";
        try {
          switch (selectedUrgensi) {
            case "Bahaya":
              urgensi = "1";
              break;
            case "Peringatan":
              urgensi = "2";
              break;
            case "Informasi":
              urgensi = "3";
              break;
            default:
          }
          if (file != null) {
            String fileName = const Uuid().v1();
            var ref = FirebaseStorage.instance
                .ref()
                .child('pengumuman')
                .child("$fileName.jpg");
            var uploadTask = await ref.putFile(file!);
            foto = await ref.getDownloadURL();
          }
          if (edit) {
            await _firestore.collection("pengumuman").doc(widget.uid).update({
              "judul": judulCon.text,
              "detil": detilCon.text,
              "pembuat": nama,
              "tanggal": FieldValue.serverTimestamp(),
              "sekolah": uidSekolah,
              "tipe": urgensi,
              "foto": foto
            }).then((value) {
              EasyLoading.dismiss();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Pengumuman berhasil diupdate"),
                ),
              );
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => const HomePage(
                            i: 1,
                          )),
                  ModalRoute.withName('/'));
            });
          } else {
            await _firestore.collection("pengumuman").doc().set({
              "judul": judulCon.text,
              "detil": detilCon.text,
              "pembuat": nama,
              "tanggal": FieldValue.serverTimestamp(),
              "sekolah": uidSekolah,
              "tipe": urgensi,
              "foto": foto
            }).then((value) {
              EasyLoading.dismiss();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Pengumuman berhasil diubah"),
                ),
              );
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => const HomePage(
                            i: 1,
                          )),
                  ModalRoute.withName('/'));
            });
          }
        } catch (e) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Mohon isikan semua data dengan benar $e"),
            ),
          );
        }
      },
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xff8a32f1),
              Color(0xffad32f9),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            "Submit",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class ViewImage extends StatelessWidget {
  String? imageUrl;
  final bool proses;

  ViewImage({required this.proses, this.imageUrl, Key? key}) : super(key: key);

  File? imageFile;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    print(file);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color.fromARGB(255, 78, 108, 80),
        centerTitle: true,
        title: const Text(
          "Gambar Pengumuman",
          style: TextStyle(
            fontSize: 20,
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
              if (await pickImage(source, context)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Gambar berhasil diubah"),
                  ),
                );
                Navigator.pop(context);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Gambar berhasil diubah"),
                ),
              );
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Hero(
        tag: tag,
        child: Container(
          height: size.height,
          width: size.width,
          color: Colors.black,
          child: proses && file == null
              ? Image.network(imageUrl!)
              : Image.file(file!),
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
      await ImagePicker().pickImage(source: source).then((value) async {
        if (value != null) {
          file = File(value.path);
          return true;
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
}
