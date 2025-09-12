import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sku_pramuka/screen/extra/buat_pengumuman.dart';
import 'package:sku_pramuka/screen/home_screen.dart';

class PengumumanPage extends StatelessWidget {
  final String uid;
  final String judul;
  final String detil;
  final String foto;
  final String pembuat;
  final String tanggal;
  final bool isPembina;
  PengumumanPage(
      {super.key,
      required this.uid,
      required this.judul,
      required this.detil,
      required this.foto,
      required this.pembuat,
      required this.tanggal,
      required this.isPembina});

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 78, 108, 80),
          title: const Text("Pengumuman",
              style: TextStyle(color: Colors.white, fontSize: 24)),
          centerTitle: true,
          actions: [
            isPembina
                ? PopupMenuButton<String>(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: const Text("Edit"),
                          onTap: () => WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) =>
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (builder) => BuatPengumuman(
                                                uid: uid,
                                                judul: judul,
                                                detil: detil,
                                                foto: foto,
                                              )))),
                        ),
                        PopupMenuItem(
                          child: const Text("Hapus"),
                          onTap: () => WidgetsBinding.instance
                              .addPostFrameCallback(
                                  (timeStamp) => delete(context)),
                        )
                      ];
                    },
                  )
                : Container()
          ],
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
                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    "$pembuat - $tanggal",
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  foto == ""
                      ? Container()
                      : Hero(
                          tag: "${judul}",
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: Image.network(foto),
                          ),
                        ),
                  foto == ""
                      ? Container()
                      : const SizedBox(
                          height: 20.0,
                        ),
                  Text(detil)
                ],
              ),
            ),
          ),
        ));
  }

  void delete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Pengumuman?"),
        content: const Text("Seluruh data akan dihapus"),
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
                EasyLoading.show(
                    status: "Loading...",
                    dismissOnTap: false,
                    maskType: EasyLoadingMaskType.black);
                delete2(context);
              },
              child: const Text(
                "HAPUS",
                style: TextStyle(color: Colors.red),
              ))
        ],
      ),
    );
  }

  Future delete2(BuildContext context) async {
    await _firestore.collection("pengumuman").doc(uid).delete().then((value) {
      EasyLoading.dismiss();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => HomePage(
                    i: isPembina ? 1 : 0,
                  )),
          (route) => false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengumuman telah dihapus'),
      ),
    );
  }
}
