import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';

class ProfileSekolah extends StatefulWidget {
  final String uid;

  const ProfileSekolah({
    super.key,
    required this.uid,
  });

  @override
  State<ProfileSekolah> createState() => _ProfileSekolahState();
}

class _ProfileSekolahState extends State<ProfileSekolah> {
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = false;
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
          "Profile Sekolah",
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
                  _firestore.collection("sekolah").doc(widget.uid).snapshots(),
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
                          tile(const Icon(Icons.school), "Nama",
                              snapshot.data!['nama']),
                          const SizedBox(
                            height: 20,
                          ),
                          tile(const Icon(Icons.man), "Gudep Putra",
                              snapshot.data!['gudep putra']),
                          const SizedBox(
                            height: 20,
                          ),
                          tile(const Icon(Icons.woman), "Gudep Putri",
                              snapshot.data!['gudep putri']),
                          const SizedBox(
                            height: 20,
                          ),
                          tileAngka(const Icon(Icons.male), "Putra",
                              snapshot.data!['jumlah putra']),
                          const SizedBox(
                            height: 20,
                          ),
                          tileAngka(const Icon(Icons.female), "Putri",
                              snapshot.data!['jumlah putri']),
                          const SizedBox(
                            height: 20,
                          ),
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

  Widget tile(Icon dis, String title, String subs) {
    return ListTile(
      leading: dis,
      title: Text(title,
          style: const TextStyle(color: Colors.black, fontSize: 15)),
      subtitle: Text(subs,
          style: const TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
    );
  }

  Widget tileAngka(Icon dis, String gender, int jumlah) {
    textEditingController.text = jumlah.toString();
    return ListTile(
      leading: dis,
      title: Text("Jumlah $gender",
          style: const TextStyle(color: Colors.black, fontSize: 15)),
      subtitle: Text(jumlah.toString(),
          style: const TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
      trailing: IconButton(
          icon: const Icon(
            Icons.edit,
            color: Colors.grey,
          ),
          onPressed: () {
            ubahJumlah(gender, jumlah);
          }),
    );
  }

  Future<dynamic> ubahJumlah(String gender, int subs) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Jumlah $gender"),
        content: TextFormField(
          controller: textEditingController,
          decoration: InputDecoration(hintText: "Jumlah $gender"),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9]+"))
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("BATAL"),
          ),
          TextButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                int tmp = int.tryParse(textEditingController.text) ?? 0;
                if (tmp != subs) {
                  save(gender, tmp);
                  setState(() {
                    _isLoading = false;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("SIMPAN"))
        ],
      ),
    );
  }

  Future<void> save(String gender, int jumlah) async {
    await _firestore
        .collection("sekolah")
        .doc(widget.uid)
        .update({"jumlah ${gender.toLowerCase()}": jumlah})
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Jumlah $gender berhasil diubah'))))
        .onError((error, stackTrace) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Terjadi Kesalahan'))));
  }
}
