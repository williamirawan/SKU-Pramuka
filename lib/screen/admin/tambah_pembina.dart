import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:sku_pramuka/service/auth.dart';

class TambahPembina extends StatefulWidget {
  final String kecamatan;
  final String kota;
  const TambahPembina({super.key, required this.kecamatan, required this.kota});

  @override
  State<TambahPembina> createState() => _TambahPembinaState();
}

class _TambahPembinaState extends State<TambahPembina> {
  final _formKey = GlobalKey<FormState>();
  AuthClass authClass = AuthClass();

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  late TextEditingController emailPass;

  String sekolah = "-";
  bool _isLoading = false;
  bool coba = false;
  late List<Map<String, dynamic>> listSekolah;
  List<String> uidSekolah = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
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
          title: const Text("Data Pembina",
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
                    height: 30,
                  ),
                  textFormBiasa(const Icon(Icons.person, color: Colors.grey),
                      "Nama Pembina", "Isikan nama pembina", true, name),
                  const SizedBox(
                    height: 30,
                  ),
                  textFormEmail(),
                  const SizedBox(
                    height: 30,
                  ),
                  tambahSekolah(),
                  const SizedBox(
                    height: 30,
                  ),
                  colorButton(),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<dynamic> emailPassword() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Email dan Password Akun Pembina Baru"),
        content: TextField(
          readOnly: true,
          controller: emailPass,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: emailPass.text));
              Navigator.of(context).pop();
            },
            child: Text('Salin & Keluar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget textFormBiasa(Icon icon, String label, String empty, bool full,
      TextEditingController controller) {
    return SizedBox(
      width: full
          ? MediaQuery.of(context).size.width - 60
          : MediaQuery.of(context).size.width / 2 - 50,
      height: 60,
      child: TextFormField(
        readOnly: !full,
        cursorColor: Colors.blue,
        onChanged: (value) => setState(() {}),
        style: const TextStyle(color: Colors.black, fontSize: 17),
        keyboardType: TextInputType.name,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]+"))
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
            suffixIcon: full
                ? (controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          controller.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear)))
                : null,
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

  Widget textFormEmail() {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: TextFormField(
        cursorColor: Colors.blue,
        style: const TextStyle(color: Colors.black, fontSize: 17),
        keyboardType: TextInputType.emailAddress,
        //inputFormatters: [FilteringTextInputFormatter.allow(RegExp(pattern))],
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            prefixIcon: const Icon(Icons.email, color: Colors.grey),
            suffixIcon: email.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      email.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear)),
            labelText: "Email",
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
            errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.deepOrange,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15))),
        controller: email,
        validator: (value) {
          if (value!.isEmpty) {
            return "Mohon Isikan Email Anda";
          } else if (!RegExp(pattern).hasMatch(value)) {
            return "Mohon Masukkan Email dengan Benar";
          }
          return null;
        },
      ),
    );
  }

  Widget tambahSekolah() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 30,
        child: ListTile(
          leading: const Icon(Icons.school),
          title: const Text("Sekolah",
              style: TextStyle(color: Colors.black, fontSize: 15)),
          subtitle: Text(sekolah,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          trailing: IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.grey,
            ),
            onPressed: () => ubahSekolah(),
          ),
        ),
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
    return showDialog(
      context: context,
      builder: (context) {
        List<String> tmp = [];
        for (var sekolah in listSekolah) {
          if (uidSekolah.contains(sekolah["uid"])) {
            tmp.add(sekolah["nama"]);
          }
        }
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
                                tmp.add(sekolah['nama']);
                              } else {
                                uidSekolah.remove(sekolah["uid"]);
                                tmp.remove(sekolah['nama']);
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
                  setState(() {
                    sekolah = "";
                    for (var dis in tmp) {
                      sekolah = "$sekolah•   $dis\n";
                    }
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("SIMPAN"))
          ],
        );
      },
    );
  }

  Widget colorButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _isLoading = true;
          });
          await authClass
              .pembinaSignUp(name.text, email.text, widget.kecamatan,
                  widget.kota, uidSekolah)
              .then((value) {
            setState(() {
              emailPass = TextEditingController(text: value);
              emailPassword();
            });
          });
        } else {
          coba = true;
        }
        setState(() {
          _isLoading = false;
        });
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
            "Simpan Pembina",
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
