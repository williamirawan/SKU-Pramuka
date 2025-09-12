import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sku_pramuka/screen/admin/tambah_pembina.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:sku_pramuka/widgets/card_pembina.dart';

class ListPembina extends StatefulWidget {
  final String kec;
  final String kota;
  const ListPembina({super.key, required this.kec, required this.kota});

  @override
  State<ListPembina> createState() => _ListPembinaState();
}

class _ListPembinaState extends State<ListPembina> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<dynamic> listSekolah = [];
  Map<String, String> mapSekolah = {};
  bool _isLoading = false;
  String db = "pembina";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
          "Daftar Pembina",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TambahPembina(
                          kecamatan: widget.kec, kota: widget.kota),
                    ),
                  ),
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ))
        ],
      ),
      body: _isLoading
          ? const LoadingPage()
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('pembina')
                  .where("kecamatan", isEqualTo: widget.kec)
                  .orderBy("name")
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
                      return CardPembina(
                        nama: map["name"],
                        profile: map["profile"],
                        email: map["email"],
                        uid: map["uid"],
                        kecamatan: widget.kec,
                      );
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
      listSekolah.clear();
      _isLoading = true;
    });
    await _firestore
        .collection("sekolah")
        .where("kecamatan", isEqualTo: widget.kec)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        listSekolah.add(doc["uid"]);
      }
    });

    setState(() {
      _isLoading = false;
    });
  }
}
