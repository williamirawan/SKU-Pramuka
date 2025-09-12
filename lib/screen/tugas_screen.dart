import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sku_pramuka/screen/list_tugas.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:uuid/uuid.dart';

var tag = "foto";
File? file;

class TugasPage extends StatefulWidget {
  final int i;
  final String uid;
  final String title;
  final String progress;
  final List<String> kategori;
  final Map<String, String> pembina;
  final int no;
  String? kec;
  String? uidPending;
  String? uidSiswa;
  String? namaSiswa;
  String? sekolah;
  TugasPage(
      {super.key,
      required this.no,
      required this.i,
      required this.uid,
      required this.title,
      required this.progress,
      required this.kategori,
      required this.pembina,
      this.kec,
      this.uidPending,
      this.uidSiswa,
      this.namaSiswa,
      this.sekolah});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  String inet = "";
  String? pembina;
  List<String>? listPembina;
  bool isFoto = false;
  bool proses = false;
  bool selesai = false;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController isiText = TextEditingController();
  String? pengerjaan;
  String? oleh;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.kategori.contains("outdoor") ? isFoto = true : null;
    widget.uidPending == null
        ? init(widget.progress, widget.pembina)
        : initReview(widget.progress);
    file = null;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingPage()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 78, 108, 80),
              title: Text("Tugas ${widget.no}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  )),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          label("Status"),
                          const SizedBox(height: 12),
                          chipData(
                            widget.progress.toUpperCase(),
                            check(widget.progress),
                          ),
                          const SizedBox(height: 25),
                          widget.i == 0 ? siswaWidget1() : pembinaWidget1(),
                          label("Kategori"),
                          const SizedBox(height: 12),
                          Wrap(
                            runSpacing: 10,
                            children: [
                              chipData("Menyanyi", 0xffff6d6e),
                              const SizedBox(width: 20),
                              chipData("Gotong Royong", 0xfff29732),
                              const SizedBox(width: 20),
                              chipData("Menulis", 0xff6557ff),
                              const SizedBox(width: 20),
                              chipData("Outdoor", 0xff234ebd),
                              const SizedBox(width: 20),
                              chipData("Entah", 0xff2bc8d9),
                            ],
                          ),
                          const SizedBox(height: 25),
                          widget.kec != "Tamu" ? notTamu() : Container()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget notTamu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isFoto ? label("Foto Pengerjaan") : label("Text Jawaban"),
        const SizedBox(height: 15),
        isFoto ? foto() : text(),
        widget.i == 0 ? siswaWidget2() : pembinaWidget2(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget siswaWidget1() {
    if (proses) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label("Dikerjakan pada"),
          const SizedBox(height: 12),
          dilaksanakan(),
          const SizedBox(height: 25),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget siswaWidget2() {
    if (!proses) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          label("Pembina"),
          const SizedBox(height: 12),
          cariPembina(),
          const SizedBox(height: 40),
          button()
        ],
      );
    } else {
      return Container();
    }
  }

  Widget pembinaWidget1() {
    if (proses) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label("Dikerjakan oleh"),
          const SizedBox(height: 12),
          Text(
            "$oleh\npada $pengerjaan",
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 25,
          )
        ],
      );
    } else
      return Column();
  }

  Widget pembinaWidget2() {
    if (proses && !selesai) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          buttonPembina(true),
          const SizedBox(height: 20),
          buttonPembina(false),
        ],
      );
    } else
      return Column();
  }

  Widget label(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: 16.5,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget title() {
    return Container(
      height: 60,
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
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Nama Tugas",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 17,
          ),
          contentPadding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
        ),
      ),
    );
  }

  Widget text() {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        enabled: widget.i == 0,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 17,
        ),
        controller: isiText,
        maxLines: null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Deskripsi Tugas",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 17,
          ),
          contentPadding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
        ),
      ),
    );
  }

  Widget cariPembina() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: DropdownButtonFormField<String>(
        value: pembina,
        items: listPembina!.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) {
          setState(() {
            pembina = value;
          });
        },
        validator: (value) => value == null ? "Mohon isikan pembina" : null,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 1,
              ),
            ),
            prefixIcon: const Icon(
              Icons.hiking,
              color: Colors.grey,
            ),
            labelText: "Pembina",
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1,
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

  Widget foto() {
    return file != null || proses
        ? InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ViewImage(
                    imageUrl: proses ? inet : null,
                    proses: proses,
                  ),
                ),
              );
            },
            child: Center(
              child: proses
                  ? Image.network(
                      inet,
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
        : widget.i == 0
            ? Center(
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
              )
            : const Center(
                child: Text(
                  "Tidak ada gambar....",
                  style: TextStyle(fontSize: 18),
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

  Widget chipData(String label, int color) {
    return Chip(
      backgroundColor: Color(color),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 3.8),
    );
  }

  Widget button() {
    return InkWell(
      onTap: () async {
        EasyLoading.show(
            status: "Loading...",
            dismissOnTap: false,
            maskType: EasyLoadingMaskType.black);
        try {
          String fileName = const Uuid().v1();
          String key = "";
          String value = "";

          String uid = widget.pembina.keys
              .firstWhere((k) => widget.pembina[k] == pembina);

          if (isFoto) {
            var ref = FirebaseStorage.instance
                .ref()
                .child('tugas')
                .child("$fileName.jpg");
            var uploadTask = await ref.putFile(file!);
            key = "gambar";
            value = await ref.getDownloadURL();
          } else if (isiText.text.isNotEmpty) {
            key = "teks";
            value = isiText.text;
          } else {
            return;
          }

          await _firestore
              .collection("pembina")
              .doc(uid)
              .collection("pending")
              .doc()
              .set({
            "siswa": _auth.currentUser!.uid,
            "tanggal": FieldValue.serverTimestamp(),
            "tugas": widget.uid,
            key: value
          });

          await _firestore
              .collection("siswa")
              .doc(_auth.currentUser!.uid)
              .collection("progress")
              .doc()
              .set({
            "pembina": uid,
            "progress": "proses",
            "tanggal": FieldValue.serverTimestamp(),
            "tugas": widget.uid,
            key: value
          }).then((value) {
            EasyLoading.dismiss();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Tunggu keputusan pembina $pembina yaa"),
              ),
            );
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => ListTugas(
                          i: widget.i,
                        )),
                ModalRoute.withName('/'));
          });
        } catch (e) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Kerjakan tugasnya dengan benar ya"),
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

  Widget buttonPembina(bool acc) {
    String progress = acc ? "diterima" : "ditolak";
    return InkWell(
      onTap: () async {
        await _firestore
            .collection("siswa")
            .doc(widget.uidSiswa)
            .collection("progress")
            .where("tugas", isEqualTo: widget.uid)
            .get()
            .then((value) =>
                value.docs[0].reference.update({"progress": progress}));

        await _firestore
            .collection("pembina")
            .doc(_auth.currentUser!.uid)
            .collection("pending")
            .doc(widget.uidPending)
            .delete()
            .then((value) => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => const ListTugas(
                          i: 1,
                        )),
                ModalRoute.withName('/')));
      },
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: acc
                ? [const Color(0xFF1A2980), const Color(0xFF26D0CE)]
                : [const Color(0xffeb3941), const Color(0xffe2373f)],
          ),
        ),
        child: Center(
          child: Text(
            acc ? "Terima" : "Tolak",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget dilaksanakan() {
    return Text(
      "$pengerjaan - $pembina",
      style: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  void init(String progress, Map<String, String> pembina) async {
    if (progress == "proses" || progress == "diterima") {
      setState(() {
        _isLoading = true;
        oleh = "${widget.namaSiswa} - ${widget.sekolah}";
      });
      proses = true;
      if (progress == "diterima") selesai = true;
      await _firestore
          .collection("siswa")
          .doc(widget.uidSiswa ?? _auth.currentUser!.uid)
          .collection("progress")
          .where("tugas", isEqualTo: widget.uid)
          .get()
          .then((value) async {
        if (isFoto) {
          inet = value.docs[0].data()["gambar"];
        } else {
          isiText.text = value.docs[0].data()["teks"].toString();
        }

        pengerjaan = DateFormat("EEEE, d MMMM yyyy", "id_ID")
            .format(value.docs[0].data()['tanggal'].toDate());

        await _firestore
            .collection("pembina")
            .doc(value.docs[0].data()["pembina"])
            .get()
            .then((value2) => this.pembina = value2.data()!["nama"]);
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      listPembina = [];
      pembina.forEach((key, value) {
        listPembina!.add(value);
      });
      proses = false;
    }
  }

  void initReview(String progress) async {
    setState(() {
      _isLoading = true;
    });
    if (progress == "proses") proses = true;
    await _firestore
        .collection("pembina")
        .doc(_auth.currentUser!.uid)
        .collection("pending")
        .where("tugas", isEqualTo: widget.uid)
        .get()
        .then((value) async {
      if (isFoto) {
        inet = value.docs[0].data()["gambar"];
      } else {
        isiText.text = value.docs[0].data()["teks"].toString();
      }

      pengerjaan = DateFormat("EEEE, d MMMM yyyy", "id_ID")
          .format(value.docs[0].data()['tanggal'].toDate());

      oleh = "${widget.namaSiswa} - ${widget.sekolah}";
    });
    setState(() {
      _isLoading = false;
    });
  }

  int check(String progress) {
    switch (progress) {
      case "belum":
        return 0xff2bc8d9;
      case "proses":
        return 0xff2664fa;
      case "ditolak":
        return 0xFFFF6464;
      case "diterima":
        return 0xff3C6255;
      default:
        return 0xFF000000;
    }
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

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color.fromARGB(255, 78, 108, 80),
        centerTitle: true,
        title: const Text(
          "Gambar Tugas",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          file != null
              ? IconButton(
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
                  },
                )
              : Container(),
        ],
      ),
      body: Hero(
        tag: tag,
        child: Container(
          height: size.height,
          width: size.width,
          color: Colors.black,
          child: proses ? Image.network(imageUrl!) : Image.file(file!),
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
