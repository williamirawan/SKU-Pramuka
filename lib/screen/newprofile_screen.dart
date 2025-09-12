import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:sku_pramuka/service/auth.dart';
import 'package:time_machine/time_machine.dart';

enum Pil { Laki, Perempuan }

class NewProfile extends StatefulWidget {
  final String name, email, pass;
  final bool logged;
  const NewProfile(
      {super.key,
      required this.name,
      required this.email,
      required this.pass,
      required this.logged});

  @override
  State<NewProfile> createState() => _NewProfileState();
}

class _NewProfileState extends State<NewProfile> {
  bool coba = false;
  AuthClass authClass = AuthClass();
  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController dateInput = TextEditingController();
  TextEditingController tingkat = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _passwordVisible = false;
  bool _isLoading = false;
  String? selectedSekolah;
  String? formattedDate;
  String? selectedKota;
  String? selectedKecamatan;
  String? selectedAgama;
  String uidSekolah = "";
  DateTime? tl;
  String kecakapan = "None";
  int umur = -1;
  Map<String, dynamic> kota = {};
  List<String> listKota = [];
  List<String> listKecamatan = [];
  List<String> listSekolah = [];
  List<String> listAgama = ["Islam", "Katolik", "Protestan", "Hindu", "Buddha"];

  List<String> list = [];
  final lsiaga = <String>["Muda", "Bantu", "Tata"];
  final lpenggalang = <String>["Ramu", "Rakit", "Terap", "Garuda"];
  final lpenegak = <String>["Tamu", "Bantara", "Laksana"];

  Pil? _pil = Pil.Laki;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    name.text = widget.name;
    email.text = widget.email;
    password.text = widget.pass;
    tingkat.text = kecakapan;
    coba = false;
    init();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingPage();
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 78, 108, 80),
          title: const Text("Data Diri",
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
                  textFormBiasa(const Icon(Icons.person, color: Colors.grey),
                      "Nama", "Isikan nama anda", true, name),
                  const SizedBox(
                    height: 20,
                  ),
                  textFormEmail(),
                  const SizedBox(
                    height: 20,
                  ),
                  textFormPass(),
                  const SizedBox(
                    height: 20,
                  ),
                  fieldDropDownKota(),
                  const SizedBox(
                    height: 20,
                  ),
                  fieldDropDownKecamatan(),
                  const SizedBox(
                    height: 20,
                  ),
                  fieldDropDownSekolah(),
                  const SizedBox(
                    height: 20,
                  ),
                  textFormTanggal(
                      const Icon(
                        Icons.event,
                        color: Colors.grey,
                      ),
                      "Tanggal Lahir",
                      "Mohon inputkan tanggal lahir anda",
                      dateInput),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        textFormBiasa(
                            const Icon(Icons.elderly, color: Colors.grey),
                            "Tingkat",
                            "Isikan kecakapan anda",
                            false,
                            tingkat),
                        const SizedBox(
                          width: 20,
                        ),
                        fieldDropDownTingkat(
                            const Icon(Icons.info, color: Colors.grey),
                            "Kecakapan",
                            "Isikan kecakapan anda")
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  fieldDropDownAgama(),
                  const SizedBox(
                    height: 20,
                  ),
                  radioBtnPil(),
                  const SizedBox(
                    height: 30,
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

  Future<void> init() async {
    await _firestore.collection("kota").get().then((value) {
      for (var doc in value.docs) {
        kota[doc.id] = doc.data()["kecamatan"];
        listKota.add(doc.id);
      }
    });
    setState(() {});
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
        readOnly: widget.logged,
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

  Widget textFormPass() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: TextFormField(
        cursorColor: Colors.blue,
        style: const TextStyle(color: Colors.black, fontSize: 17),
        obscureText: !_passwordVisible,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            prefixIcon: const Icon(Icons.lock, color: Colors.grey),
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => setState(() {
                _passwordVisible = !_passwordVisible;
              }),
            ),
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
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
        controller: password,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Mohon Isikan Password Anda';
          }
          return null;
        },
      ),
    );
  }

  Widget fieldDropDownKota() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: DropdownButtonFormField<String>(
        value: selectedKota,
        items: listKota.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedKota = value;
            if (selectedKota != null) {
              selectedKecamatan = null;
              listKecamatan = (kota[selectedKota] as List)
                  .map((item) => item as String)
                  .toList();
              selectedSekolah = null;
              listSekolah = [];
            }
          });
        },
        validator: (value) => value == null ? "Mohon isikan kota anda" : null,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            prefixIcon: const Icon(
              Icons.location_city,
              color: Colors.grey,
            ),
            labelText: "Kota",
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
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
      ),
    );
  }

  Widget fieldDropDownKecamatan() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: DropdownButtonFormField<String>(
        value: selectedKecamatan,
        items: listKecamatan.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedKecamatan = value;
            if (selectedKecamatan != null) {
              selectedSekolah = null;
              if (selectedKecamatan != null && selectedKota != null) {
                getSekolah(selectedKota!, selectedKecamatan!);
              }
            }
          });
        },
        validator: (value) =>
            value == null ? "Mohon isikan kecamatan anda" : null,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            prefixIcon: const Icon(
              Icons.location_on,
              color: Colors.grey,
            ),
            labelText: "Kecamatan",
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
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
            getSekolahUid(selectedKota!, selectedKecamatan!, selectedSekolah!);
          });
        },
        validator: (value) =>
            value == null ? "Mohon isikan sekolah anda" : null,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            prefixIcon: const Icon(
              Icons.school,
              color: Colors.grey,
            ),
            labelText: "Sekolah",
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
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
      ),
    );
  }

  Widget fieldDropDownTingkat(Icon icon, String label, String empty) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 30,
      height: 60,
      child: DropdownButtonFormField<String>(
        value: kecakapan,
        items: list.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) => setState(() {
          kecakapan = value!;
        }),
        validator: (value) => value == null ? empty : null,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            prefixIcon: icon,
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
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
      ),
    );
  }

  Widget fieldDropDownAgama() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: DropdownButtonFormField<String>(
        value: selectedAgama,
        items: listAgama.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedAgama = value;
          });
        },
        validator: (value) => value == null ? "Mohon isikan agama anda" : null,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            prefixIcon: const Icon(
              Icons.location_on,
              color: Colors.grey,
            ),
            labelText: "Agama",
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
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
      ),
    );
  }

  Widget radioBtnPil() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Radio(
            value: Pil.Laki,
            groupValue: _pil,
            onChanged: (Pil? value) => setState(() {
              _pil = value;
            }),
            fillColor: MaterialStateColor.resolveWith(
              (states) => Colors.teal,
            ),
          ),
          const Text("Laki-laki",
              style: TextStyle(color: Colors.black, fontSize: 17)),
          const SizedBox(
            width: 50,
          ),
          Radio(
            value: Pil.Perempuan,
            groupValue: _pil,
            onChanged: (Pil? value) => setState(() {
              _pil = value;
            }),
            fillColor: MaterialStateColor.resolveWith(
              (states) => Colors.teal,
            ),
          ),
          const Text("Perempuan",
              style: TextStyle(color: Colors.black, fontSize: 17)),
        ],
      ),
    );
  }

  Widget textFormTanggal(
      Icon icon, String label, String empty, TextEditingController controller) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime(2017),
              firstDate: DateTime(2003),
              lastDate: DateTime(2017));
          if (pickedDate != null) {
            tl = pickedDate;
            formattedDate = DateFormat('dd MMMM yyyy').format(pickedDate);
            LocalDate b = LocalDate.dateTime(DateTime.now());
            Period diff = b.periodSince(LocalDate.dateTime(pickedDate));
            setState(() {
              umur = diff.years;
              controller.text = formattedDate!;
              if (umur < 7) {
                list = ["None"];
                tingkat.text = "None";
              } else if (umur < 11) {
                list = lsiaga;
                tingkat.text = "Siaga";
              } else if (umur < 16) {
                list = lpenggalang;
                tingkat.text = "Penggalang";
              } else if (umur < 21) {
                list = lpenegak;
                tingkat.text = "Penegak";
              } else {
                list = ["None"];
              }
              kecakapan = list[0];
            });
          }
        },
        cursorColor: Colors.blue,
        decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            prefixIcon: icon,
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        umur = -1;
                      });
                    },
                    icon: const Icon(Icons.clear)),
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 17),
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
        validator: (value) {
          if (value!.isEmpty) {
            return empty;
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget colorButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _isLoading = true;
          });
          String pil;
          if (_pil.toString() == "Pil.Laki") {
            pil = "Laki-Laki";
          } else {
            pil = "Perempuan";
          }
          authClass
              .emailSignUp(
                  context,
                  widget.logged,
                  name.text,
                  email.text,
                  password.text,
                  pil,
                  uidSekolah,
                  tl!,
                  umur,
                  tingkat.text,
                  kecakapan,
                  selectedAgama!,
                  selectedKecamatan!)
              .then((value) => setState(() {
                    _isLoading = false;
                  }));
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
            "Buat Akun",
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

  Future<void> getSekolah(String kota, String kecamatan) async {
    await _firestore
        .collection("sekolah")
        .where("kota", isEqualTo: kota)
        .where("kecamatan", isEqualTo: kecamatan)
        .get()
        .then((value) {
      listSekolah = [];
      for (var doc in value.docs) {
        if (!listSekolah.contains(doc.data()["nama"])) {
          listSekolah.add(doc.data()["nama"]);
        }
      }
    });
    setState(() {});
  }

  Future<void> getSekolahUid(
      String kota, String kecamatan, String sekolah) async {
    await _firestore
        .collection("sekolah")
        .where("kota", isEqualTo: kota)
        .where("kecamatan", isEqualTo: kecamatan)
        .where("nama", isEqualTo: sekolah)
        .get()
        .then((value) {
      uidSekolah = value.docs[0].data()["uid"];
    });
  }
}
