import 'package:flutter/material.dart';
import 'package:sku_pramuka/screen/admin/profile_sekolah.dart';
import 'package:sku_pramuka/screen/extra/tugas_siswa.dart';
import 'package:sku_pramuka/screen/extra/user_profile.dart';

class CardSekolah extends StatelessWidget {
  final String uid;
  final String nama;
  final String gudepPutra;
  final String gudepPutri;

  CardSekolah({
    super.key,
    required this.uid,
    required this.nama,
    required this.gudepPutra,
    required this.gudepPutri,
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
                    builder: (context) => ProfileSekolah(uid: uid)),
              ),
              child: SizedBox(
                height: 85,
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
                          vertical: 10.0, horizontal: 30.0),
                      child: Row(
                        children: [
                          Flexible(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nama,
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
                                  "Putra: $gudepPutra\t\t\tPutri: $gudepPutri",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                              // Flexible(
                              //   child: Text(
                              //     "",
                              //     style: const TextStyle(
                              //         color: Colors.black, fontSize: 14),
                              //   ),
                              // ),
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
