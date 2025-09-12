import 'package:flutter/material.dart';
import 'package:sku_pramuka/screen/tugas_screen.dart';
import 'package:sku_pramuka/widgets/custom_checkbox.dart';

class CardTugas extends StatelessWidget {
  final int i;
  final int no;
  final String uid;
  String? uidSiswa;
  String? namaSiswa;
  String? sekolah;
  String? uidPending;
  final String title;
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final String check;
  final String kec;
  final List<String> kategori;
  Map<String, String> pembina;

  CardTugas(
      {super.key,
      required this.no,
      required this.i,
      required this.uid,
      this.uidSiswa,
      this.uidPending,
      this.namaSiswa,
      this.sekolah,
      required this.title,
      required this.iconData,
      required this.iconColor,
      required this.iconBgColor,
      required this.check,
      required this.kategori,
      required this.kec,
      required this.pembina});

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
                  builder: (context) => TugasPage(
                      no: no,
                      i: i,
                      uid: uid,
                      title: title,
                      progress: check,
                      kategori: kategori,
                      uidPending: uidPending,
                      uidSiswa: uidSiswa,
                      namaSiswa: namaSiswa,
                      sekolah: sekolah,
                      kec: kec,
                      pembina: check == "belum" || check == "ditolak"
                          ? pembina
                          : {}),
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: ambilWarna(check),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 12.0),
                      child: Row(
                        children: [
                          Container(
                              height: 30,
                              width: 33,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                  child: Text(
                                no.toString(),
                                style: const TextStyle(
                                    fontSize: 18,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ))),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                            child: Text(
                              title,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                            ),
                          ),
                          Container(
                            height: 33,
                            width: 36,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              iconData,
                              color: iconColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Custom_Checkbox(
              isChecked: check != "belum",
              backgroundColor: checkColor,
              borderColor: checkColor,
              icon: icon(),
              iconColor: Colors.white,
            ),
          ),
          // Theme(
          //   data: ThemeData(
          //       primarySwatch: Colors.green,
          //       unselectedWidgetColor: Color(0xff5e616a),
          //       checkboxTheme: CheckboxThemeData(
          //         fillColor: MaterialStateProperty.all(
          //             Color.fromARGB(255, 170, 139, 86)),
          //       )),
          //   child: Transform.scale(
          //     scale: 1.5,
          //     child: Checkbox(
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(5),
          //       ),
          //       checkColor: Colors.white,
          //       value: check,
          //       onChanged: null,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  IconData icon() {
    if (check == "proses") {
      return Icons.circle_outlined;
    } else if (check == "ditolak") {
      return Icons.close;
    } else {
      return Icons.check;
    }
  }

  List<Color> ambilWarna(String progress) {
    switch (progress) {
      case "belum":
        checkColor = const Color.fromARGB(255, 170, 139, 86);
        return [
          const Color.fromARGB(255, 247, 211, 132),
          const Color.fromARGB(255, 255, 225, 156),
        ];
      case "proses":
        checkColor = const Color(0xff2664fa);
        return [
          const Color.fromARGB(255, 127, 164, 250),
          const Color.fromARGB(255, 147, 184, 250),
        ];
      case "ditolak":
        checkColor = const Color(0xFFFF6464);
        return [
          const Color.fromARGB(255, 253, 125, 125),
          const Color.fromARGB(255, 255, 145, 145),
        ];
      case "diterima":
        checkColor = const Color(0xff00CBA9);
        return [
          const Color.fromARGB(255, 147, 255, 139),
          const Color.fromARGB(255, 167, 255, 159),
        ];
      default:
        return [
          const Color.fromARGB(255, 247, 211, 132),
          const Color.fromARGB(255, 255, 225, 156),
        ];
    }
  }
}
