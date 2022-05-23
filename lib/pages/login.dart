import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ustp_sam/controller/controller.dart';
import 'package:ustp_sam/custom_widgets/custom_textbutton.dart';
import 'package:ustp_sam/pages/registration.dart';
import 'package:ustp_sam/tools/my_colors.dart';
import '../custom_widgets/custom_texfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';
import 'admin.dart';
import 'home.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController schoolID = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.network(
                "https://firebasestorage.googleapis.com/v0/b/ustp-sam.appspot.com/o/16.webp?alt=media&token=82c61c7b-473e-4df6-80fb-774f76310ce3",
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fitHeight,
            ),
            Container(
              height:MediaQuery.of(context).size.height ,
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          Text("SAM",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 150,height: 0.4),),
                          Text("STUDENT ATTENDANCE MANAGEMENT",style: TextStyle(color: Colors.white.withAlpha(100),fontWeight: FontWeight.w100,fontSize: 12),),
                        ],
                      ),
                    ),
                    CustomTextField(
                      color: Colors.orange,
                      controller: schoolID,
                      padding: EdgeInsets.all(10),
                      hint: 'School ID',

                    ),
                    CustomTextField(
                      obscureText: true,
                      color: Colors.orange,
                      controller: password,
                      padding: EdgeInsets.all(10),
                      hint: 'Password',

                    ),
                    CustomTextButton(
                      color: Colors.orange,
                      text: "Login",
                      onPressed: ()async {
                        if(schoolID.text.isNotEmpty&&password.text.isNotEmpty){
                          UserController.getUserDoc(id: schoolID.text).then((value) async{
                            print(value.exists);
                            if(value.exists){

                              try {
                                print((value.data() as Map<String,dynamic>)['email']);
                                UserCredential userCredential = await FirebaseAuth
                                    .instance
                                    .signInWithEmailAndPassword(
                                    email: (value.data() as Map<String,dynamic>)['email'],
                                    password: password.text);
                                UserModel userModel = UserModel.toObject(value.data());
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => Home(userModel: userModel,)),
                                      (Route<dynamic> route) => false,
                                );

                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  Fluttertoast.showToast(
                                      msg: 'No user found for that email.',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else if (e.code == 'wrong-password') {
                                  Fluttertoast.showToast(
                                      msg: 'Wrong password provided for that user.',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              }
                            }

                          });

                        }
                        else{
                          Fluttertoast.showToast(
                              msg: 'It is empty',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                        try{
                          AdminController.getUserDoc(id: schoolID.text).then((value){
                            if(value.exists){
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => Admin()),
                                    (Route<dynamic> route) => false,
                              );
                            }

                            // if(password.text.isNotEmpty){
                            //   if(password.text==passwordX){
                            //     Navigator.pushAndRemoveUntil(
                            //       context,
                            //       MaterialPageRoute(builder: (context) => Admin()),
                            //           (Route<dynamic> route) => false,
                            //     );
                            //   }
                            // }
                          });
                        }catch(e){

                        }

                      },
                    ),
                    Padding(padding: EdgeInsets.only(top: 50)),
                    Text("Doesn't have an account yet?",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w100),),
                    CustomTextButton(
                      width: 150,
                      color: Colors.deepOrange,
                      text: "Create Account",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Registration()),
                        );

                      },
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
