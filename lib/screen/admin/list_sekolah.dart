import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sku_pramuka/screen/admin/tambah_sekolah.dart';
import 'package:sku_pramuka/widgets/card_sekolah.dart';

class ListSekolah extends StatefulWidget {
  final String kecamatan;
  final String kota;
  const ListSekolah({super.key, required this.kecamatan, required this.kota});

  @override
  State<ListSekolah> createState() => _ListSekolahState();
}

class _ListSekolahState extends State<ListSekolah> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.kecamatan);
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
          "Daftar Sekolah",
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
                        builder: (context) => TambahSekolah(
                            kecamatan: widget.kecamatan, kota: widget.kota)),
                  ),
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('sekolah')
            .where("kecamatan", isEqualTo: widget.kecamatan)
            .orderBy("nama")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              reverse: false,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> map =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return CardSekolah(
                  uid: map["uid"],
                  nama: map["nama"],
                  gudepPutra: map["gudep putra"],
                  gudepPutri: map["gudep putri"],
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
}
