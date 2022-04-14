import 'package:flutter/material.dart';
import 'package:ustp_sam/controller/controller.dart';
import 'package:ustp_sam/pages/home.dart';
import 'package:ustp_sam/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  FirebaseAuth auth = FirebaseAuth.instance;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  auth.currentUser!=null?Home(email:auth.currentUser!.email):Login(),
    );
  }
}
