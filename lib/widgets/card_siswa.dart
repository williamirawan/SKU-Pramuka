import 'package:flutter/material.dart';
import 'package:sku_pramuka/screen/extra/tugas_siswa.dart';
import 'package:sku_pramuka/screen/extra/user_profile.dart';

class CardSiswa extends StatelessWidget {
  final bool isAdmin;
  final String uid;
  final String nama;
  final String profile;
  final String sekolah;
  final String tingkat;
  final String kecakapan;

  CardSiswa({
    super.key,
    required this.uid,
    required this.isAdmin,
    required this.nama,
    required this.tingkat,
    required this.kecakapan,
    required this.sekolah,
    required this.profile,
  });
  Color checkColor = const Color.fromARGB(255, 170, 139, 86);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TugasSiswa(
                    uid: uid,
                    nama: nama,
                  ),
                ),
              ),
              child: SizedBox(
                height: 100,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  //color: Color.fromARGB(255, 247, 211, 132),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 247, 211, 132),
                          Color.fromARGB(255, 255, 225, 156)
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfile(
                                  uid: uid,
                                  db: "siswa",
                                  edit: true,
                                  admin: isAdmin,
                                ),
                              ),
                            ),
                            child: ClipOval(
                              child: SizedBox.fromSize(
                                size: const Size.fromRadius(28),
                                child: Image.network(
                                  profile,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$nama",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.fade)),
                              const SizedBox(
                                height: 5,
                              ),
                              Flexible(
                                child: Text(
                                  "$sekolah",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Flexible(
                                child: Text(
                                  "$tingkat - $kecakapan",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
