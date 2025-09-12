import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sku_pramuka/screen/home_screen.dart';
import 'package:sku_pramuka/screen/signin_screen.dart';
import 'package:sku_pramuka/screen/signup_screen.dart';
import 'package:sku_pramuka/screen/tugas_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sku_pramuka/service/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('id_ID', null).then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthClass authClass = AuthClass();
  Widget currentPage = SignIn();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pramuka',
      home: currentPage,
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
    );
  }

  void checkLogin() async {
    String? token = await authClass.getToken();
    if (token != null) {
      String? name = await authClass.getName();
      int i = int.parse((await authClass.getI())!);
      setState(() {
        currentPage = HomePage(i: i);
      });
    }
  }
}
