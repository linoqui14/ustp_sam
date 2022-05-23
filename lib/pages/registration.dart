import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ustp_sam/controller/controller.dart';
import 'package:ustp_sam/custom_widgets/custom_texfield.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ustp_sam/custom_widgets/custom_textbutton.dart';
import 'package:ustp_sam/pages/login.dart';
import 'package:ustp_sam/tools/my_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../model/user_model.dart';
import '../model/valid_users.dart';
import '../tools/authentication.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'home.dart';
class Registration extends StatefulWidget{
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();


}

class _RegistrationState extends State<Registration>{
  TextEditingController lname = TextEditingController();
  TextEditingController fname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController passwordConfirm = TextEditingController();
  TextEditingController school = TextEditingController();
  TextEditingController course = TextEditingController();
  TextEditingController section = TextEditingController();
  bool isStudent = true;
  final ImagePicker _picker = ImagePicker();
  XFile? image;
  Future uploadFile(String studentID) async {
    if (image == null) return;
    final destination = 'files/profiles';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child(studentID);
      await ref.putFile(File(image!.path));
    } catch (e) {
      print('error occured');
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle:true,

      ),
      body: Container(
        width:MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        padding: EdgeInsets.only(right: 10,left: 10,top: 10,bottom: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Profile Picture",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: MyColors.deadBlue),),
                    CustomTextButton(
                      color: MyColors.deadBlue,
                      text: "Upload",
                      onPressed: (){
                        _picker.pickImage(source: ImageSource.gallery).then((value) {
                          setState(() {
                            image = value;
                          });
                        });
                      },
                    ),
                    if(image!=null)
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: FileImage(File(image!.path)),
                      )

                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Basic Information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: MyColors.deadBlue),),
                  Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            onChange: (value){
                              ValidUserController.getUserFuture(id: value).then((value) {
                                if(!value.exists)setState(() {
                                  isStudent = true;
                                });
                                ValidUser validUser = ValidUser.toObject(value.data());
                                if(validUser.userType==UserType.instructor){
                                  setState(() {
                                    isStudent = false;
                                  });
                                }
                                else{
                                  setState(() {
                                    isStudent = true;
                                  });
                                }
                              });
                            },
                            controller: school,
                            color: MyColors.deadBlue,
                            rTopLeft:0 ,
                            hint: "School ID",
                            padding: EdgeInsets.symmetric(vertical: 5),
                          ),
                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                        if(isStudent)
                          Flexible(
                            child: CustomTextField(
                              controller: section,
                              color: MyColors.deadBlue,
                              hint: "Section",
                              padding: EdgeInsets.symmetric(horizontal: 0),
                            ),
                          ),

                      ]
                  ),
                  Text("Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: MyColors.deadBlue),),
                  Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            controller: fname,
                            color: MyColors.deadBlue,
                            rTopLeft:0 ,
                            hint: "First Name",
                            padding: EdgeInsets.symmetric(vertical: 5),
                          ),
                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                        Flexible(
                          child: CustomTextField(
                            controller: lname,
                            color: MyColors.deadBlue,
                            hint: "Last Name",
                            padding: EdgeInsets.symmetric(horizontal: 0),
                          ),
                        ),

                      ]
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                  Text("Contact Information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color:MyColors.deadBlue),),
                  Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            controller: email,
                            color: MyColors.deadBlue,
                            rTopLeft:0 ,
                            hint: "Email address",
                            padding: EdgeInsets.symmetric(vertical: 5),
                          ),
                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                        Flexible(
                          child: CustomTextField(
                            controller: mobile,
                            color: MyColors.deadBlue,
                            hint: "Mobile Number",
                            padding: EdgeInsets.symmetric(horizontal: 0),
                          ),
                        ),

                      ]
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                  Text("Password",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color:MyColors.deadBlue),),
                  Column(
                      children: [
                        CustomTextField(
                          controller: password,
                          obscureText: true,
                          color: MyColors.deadBlue,
                          rTopLeft:0 ,
                          hint: "Password",
                          padding: EdgeInsets.symmetric(vertical: 5),

                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                        CustomTextField(
                          controller:passwordConfirm ,
                          obscureText: true,
                          color: MyColors.deadBlue,
                          hint: "Confirm Password",
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),

                      ]
                  ),

                ],
              ),
              TextButton(
                  onPressed: (){
                    if(school.text.isNotEmpty){//if this ID is in the valid user database
                      ValidUserController.getUserFuture(id: school.text).then((value) {
                        if(value.exists){
                          if((value.data() as Map<String,dynamic>)["email"]==email.text){
                            UserController.getUserWhereSchoolID(schoolID: school.text).then((value){
                              try {
                                value.docs.first.exists;
                                Fluttertoast.showToast(
                                    msg: "Student ID is already in-used",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              }catch(e){
                                if(passwordConfirm.text!=password.text){
                                  Fluttertoast.showToast(
                                      msg: "Password confirmation is incorrect",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                }

                                if(passwordConfirm.text.isNotEmpty&&
                                    password.text.isNotEmpty&&
                                    lname.text.isNotEmpty&&
                                    fname.text.isNotEmpty&&
                                    email.text.isNotEmpty&&
                                    mobile.text.isNotEmpty
                                ){

                                  UserModel userModel = UserModel(courseID:course.text,section:section.text,fname: fname.text, lname: lname.text, email: email.text, mobileNumber: mobile.text, schoolID: school.text,profilePicLink: '');
                                  uploadFile(userModel.schoolID);
                                  Fluttertoast.showToast(
                                      msg: "Please wait!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                  Authentication().registerUsingEmailPassword(
                                    userModel: userModel,
                                    onError: (status) {
                                      if("weak-password"==status){
                                        Fluttertoast.showToast(
                                            msg: "Password is too weak!",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0
                                        );
                                      }
                                      else{
                                        Fluttertoast.showToast(
                                            msg: "Email is already in used",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0
                                        );
                                      }


                                    },
                                    onAdded: (){
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => Home(userModel: userModel,)),
                                            (Route<dynamic> route) => false,
                                      );
                                    },
                                    password: password.text,
                                  );
                                }
                                else{
                                  print(passwordConfirm.text);

                                  Fluttertoast.showToast(
                                      msg: "Please fill up all fields",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                }
                              }

                            });
                          }
                          else{
                            Fluttertoast.showToast(
                                msg: "Email address is not related to school ID",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }

                        }
                        else{
                          Fluttertoast.showToast(
                              msg: "ID is invalid",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }



                      });

                    }

                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: const Text("Submit",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(MyColors.deadBlue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),

                          )
                      )
                  )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Divider(
                  height: 5,
                  thickness: 1,
                  color: MyColors.red.withAlpha(50),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              Text("Already have an account?",style: TextStyle(color: Colors.black87.withAlpha(100)),),
              TextButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: const Text("Login",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(MyColors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),

                          )
                      )
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

}