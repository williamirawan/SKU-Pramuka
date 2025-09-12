import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:uuid/uuid.dart';

class TambahSekolah extends StatefulWidget {
  final String kecamatan;
  final String kota;
  const TambahSekolah({super.key, required this.kecamatan, required this.kota});

  @override
  State<TambahSekolah> createState() => _TambahSekolahState();
}

class _TambahSekolahState extends State<TambahSekolah> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nama = TextEditingController();
  TextEditingController gudepPutra = TextEditingController();
  TextEditingController gudepPutri = TextEditingController();
  TextEditingController jumlahPutra = TextEditingController();
  TextEditingController jumlahPutri = TextEditingController();

  bool _isLoading = false;
  bool coba = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    coba = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingPage();
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 78, 108, 80),
          title: const Text("Data Sekolah",
              style: TextStyle(color: Colors.white, fontSize: 24)),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: coba
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  textFormBiasa(const Icon(Icons.school, color: Colors.grey),
                      "Nama Sekolah", "Isikan nama sekolah", false, nama),
                  const SizedBox(
                    height: 20,
                  ),
                  textFormBiasa(const Icon(Icons.man, color: Colors.grey),
                      "Gudep Putra", "Isikan gudep putra", true, gudepPutra),
                  const SizedBox(
                    height: 20,
                  ),
                  textFormBiasa(const Icon(Icons.woman, color: Colors.grey),
                      "Gudep Putri", "Isikan gudep putri", true, gudepPutri),
                  const SizedBox(
                    height: 20,
                  ),
                  textFormAngka(const Icon(Icons.male, color: Colors.grey),
                      "Jumlah Putra", "Isikan jumlah putra", jumlahPutra),
                  const SizedBox(
                    height: 20,
                  ),
                  textFormAngka(const Icon(Icons.female, color: Colors.grey),
                      "Jumlah Putri", "Isikan jumlah putri", jumlahPutri),
                  const SizedBox(
                    height: 20,
                  ),
                  colorButton(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<dynamic> konfirmasi() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Simpan Data?"),
        content: Text("Data yang sudah disimpan tidak dapat diubah!"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              simpanSekolah();
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> simpanSekolah() async {
    setState(() {
      _isLoading = true;
    });
    await _firestore
        .collection("sekolah")
        .where("nama", isEqualTo: nama.text)
        .where("kecamatan", isEqualTo: widget.kecamatan)
        .get()
        .then((value) async {
      if (value.size == 0) {
        String uid = Uuid().v1();
        await _firestore.collection('sekolah').doc(uid).set({
          "uid": uid,
          "nama": nama.text,
          "gudep putra": gudepPutra.text,
          "gudep putri": gudepPutri.text,
          "jumlah putra": int.parse(jumlahPutra.text),
          "jumlah putri": int.parse(jumlahPutri.text),
          "kecamatan": widget.kecamatan,
          "kota": widget.kota,
        }).then((value) {
          setState(() {
            _isLoading = false;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Data sekolah ${nama.text} berhasil disimpan!"),
              ),
            );
          });
        });
      } else {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Sekolah ${nama.text} sudah ada di database!"),
            ),
          );
        });
      }
    });
  }

  Widget textFormBiasa(Icon icon, String label, String empty, bool gudep,
      TextEditingController controller) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: TextFormField(
        cursorColor: Colors.blue,
        onChanged: (value) => setState(() {}),
        style: const TextStyle(color: Colors.black, fontSize: 17),
        keyboardType: gudep ? TextInputType.number : TextInputType.name,
        inputFormatters: [
          gudep
              ? FilteringTextInputFormatter.allow(RegExp("[0-9- ]+"))
              : FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9- ]+"))
        ],
        decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            prefixIcon: icon,
            suffixIcon: (controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear))),
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.deepOrange,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15))),
        controller: controller,
        validator: (value) {
          if (value!.isEmpty) {
            return empty;
          }
          return null;
        },
      ),
    );
  }

  Widget textFormAngka(
      Icon icon, String label, String empty, TextEditingController controller) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: TextFormField(
        cursorColor: Colors.blue,
        onChanged: (value) => setState(() {}),
        style: const TextStyle(color: Colors.black, fontSize: 17),
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]+"))],
        decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            prefixIcon: icon,
            suffixIcon: (controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear))),
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.deepOrange,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15))),
        controller: controller,
        validator: (value) {
          if (value!.isEmpty) {
            return empty;
          }
          return null;
        },
      ),
    );
  }

  Widget colorButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          konfirmasi();
        } else {
          coba = true;
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [
            Color(0xfffd746c),
            Color(0xffff9068),
            Color(0xfffd746c)
          ]),
        ),
        child: const Center(
          child: Text(
            "Simpan Sekolah",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
