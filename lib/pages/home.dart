import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ustp_sam/controller/controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ustp_sam/custom_widgets/custom_texfield.dart';
import 'package:ustp_sam/custom_widgets/day_picker.dart';
import 'package:ustp_sam/model/sensor_attendance.dart';
import 'package:ustp_sam/model/subject.dart';
import 'package:ustp_sam/model/valid_users.dart';
import 'package:ustp_sam/pages/attendance.dart';
import 'package:ustp_sam/pages/subject_student.dart';
import 'package:ustp_sam/tools/my_colors.dart';
import 'package:ustp_sam/tools/my_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_widgets/custom_textbutton.dart';
import '../model/schedule.dart';
import '../model/student_log.dart';
import '../model/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'login.dart';
import 'package:telephony/telephony.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
class Home extends StatefulWidget{
  const Home({Key? key,this.email,this.userModel}) : super(key: key);

  final String? email;
  final UserModel? userModel;


  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home>{
  Telephony telephony = Telephony.instance;
  UserModel userModel = UserModel(fname: '', lname: '', schoolID: '', courseID: '', mobileNumber: '', section: '', email: '',profilePicLink: '');
  FirebaseAuth auth = FirebaseAuth.instance;
  List<SensorAttendance> sensorAttendances = [];
  TextEditingController lname = TextEditingController();
  TextEditingController fname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController school = TextEditingController();
  TextEditingController course = TextEditingController();
  TextEditingController section = TextEditingController();
  String usertype = UserType.student;
  String imageURL = "";
  XFile? image;
  final ImagePicker _picker = ImagePicker();
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
  void initState() {
    print(widget.email);
    if(widget.email != null){
      UserController.getUserWhereEmailDoc(email: widget.email!).then((value) {

        if(value.size>0){
          if(value.docs.first.exists){
            setState(() {
              userModel = UserModel.toObject(value.docs.first.data());
              print(userModel.fname);
              lname.text=userModel.lname;
              fname.text=userModel.fname;
              email.text=userModel.email;
              school.text=userModel.schoolID;
              course.text=userModel.courseID;
              section.text=userModel.section;
              mobile.text=userModel.mobileNumber;
              final ref = firebase_storage.FirebaseStorage.instance.ref().child('files/profiles/'+userModel.schoolID);
              ref.getDownloadURL().then((value){
                setState(() {
                  imageURL = value;
                });
              });
              ValidUserController.getUserFuture(id: userModel.schoolID).then((value){
                if(value.exists){
                  setState(() {
                    ValidUser validUser = ValidUser.toObject(value.data());
                    usertype = validUser.userType;
                  });

                }
              });
            });
          }
        }

      });
    }
    if(widget.userModel!=null){
      userModel = widget.userModel!;
      lname.text=userModel.lname;
      fname.text=userModel.fname;
      email.text=userModel.email;
      school.text=userModel.schoolID;
      course.text=userModel.courseID;
      section.text=userModel.section;
      mobile.text=userModel.mobileNumber;
      final ref = firebase_storage.FirebaseStorage.instance.ref().child('files/profiles/'+userModel.schoolID);
      ref.getDownloadURL().then((value){
        setState(() {
          imageURL = value;
        });
      });

      ValidUserController.getUserFuture(id: userModel.schoolID).then((value){
        if(value.exists){
          ValidUser validUser = ValidUser.toObject(value.data());
          usertype = validUser.userType;
        }
      });
    }


    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return DefaultTabController(
      length:  usertype!=UserType.instructor?3:2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: usertype!=UserType.instructor?Colors.orange:Color(0xff009688),
          elevation: 0,
          toolbarHeight: 60,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: CircleAvatar(
                backgroundImage: imageURL!=""?NetworkImage(imageURL):NetworkImage("https://firebasestorage.googleapis.com/v0/b/ustp-sam.appspot.com/o/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg?alt=media&token=467e3a72-190c-4320-bd3f-2948c481d5f3")

            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width:  MediaQuery. of(context). size. width*.55,
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(userModel.fname.toTitleCase()+" "+userModel.lname.toTitleCase(),style: TextStyle(color: Colors.white),),
                    ),
                  ),

                  Row(
                    children: [
                      Text(userModel.schoolID.toTitleCase(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w100,fontSize: 15),),
                      Text(" - "+usertype,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                    ],
                  ),
                ],
              ),
              IconButton(onPressed: (){setState(() {
              });}, icon: Icon(Icons.refresh))
            ],
          ),
          actions: [
            IconButton(
                onPressed: (){
                  auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                        (Route<dynamic> route) => false,
                  );
                },
                icon: Icon(Icons.exit_to_app,color: Colors.white,)
            )
          ],
        ),
        body: TabBarView(

          children: [
            if(usertype==UserType.student)
              Container(
                child: Scaffold(
                  body: Stack(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                          stream: SenSorAttendanceController.getSenSorAttendanceWhereStudentIDStream(studentID: userModel.schoolID),
                          builder: (context,snapshot){
                            if(!snapshot.hasData)return Center();
                            if(snapshot.data!.size<0)return Center();
                            snapshot.data!.docs.forEach((element) {
                              SensorAttendance sensorAttendance = SensorAttendance.toObject(element);
                              if(sensorAttendances.where((element) => sensorAttendance.id==element.id).isEmpty){
                                sensorAttendances.add(sensorAttendance);
                              }
                            });
                            return Center();
                          }
                      ),
                      Container(
                        color:Color(0xffF4F6F6),
                        child: StreamBuilder<DocumentSnapshot>(
                            stream: UserController.getUser(id: userModel.schoolID),
                            builder: (context, snapshot) {
                              if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                              UserModel userModel = UserModel.toObject(snapshot.data);
                              this.userModel = userModel;
                              return ListView(
                                children: userModel.subjectIDs.map((subject)  {
                                  return StreamBuilder(
                                    stream: SubjectController.getSubject(id: subject),
                                    builder: (context, snapshot) {
                                      if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                      Subject subject = Subject.toObject(snapshot.data);
                                      int late = 0 , present = 0,absent = 0;
                                      sensorAttendances.forEach((element) {
                                        if(subject.id == element.subjectID&&element.userid==userModel.schoolID){
                                          switch(element.status){
                                            case 1:
                                              present++;
                                              break;
                                            case 2:
                                              late++;
                                              break;
                                            case 3:
                                              absent++;
                                              break;
                                          }
                                        }
                                      });
                                      String strColor = subject.color;
                                      Color color = Color(int.parse("0x$strColor"));
                                      if(subject.isDeleted)return Center();
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 30),
                                            child: Row(
                                              children: [
                                                Text("ID - ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                Text(subject.id,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black87),),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 10,right: 10),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: color.withAlpha(100),
                                                border: Border.all(
                                                  color: color,
                                                ),
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomLeft: Radius.circular(20))
                                            ),
                                            child: GestureDetector(
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Attendance(userModel: userModel,subject:subject,sensorAttendances: sensorAttendances,)),
                                                );
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      FutureBuilder<DocumentSnapshot>(
                                                          future: UserController.getUserDoc(id: subject.instructorID),
                                                          builder: (context, snapshot) {
                                                            if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                            if(!snapshot.data!.exists)return Text("No instructor assigned yet",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),);
                                                            UserModel userModel = UserModel.toObject(snapshot.data);
                                                            // return Text(userModel.fname.toTitleCase()+" "+userModel.lname.toTitleCase(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),);
                                                            return FutureBuilder<String>(
                                                              future: firebase_storage.FirebaseStorage.instance.ref().child('files/profiles/'+userModel.schoolID).getDownloadURL(),
                                                              builder: (context,snapshot){
                                                                if(!snapshot.hasData)return ClipRRect(
                                                                    borderRadius:BorderRadius.horizontal(left: Radius.circular(25)) ,
                                                                    child: Image.network("https://firebasestorage.googleapis.com/v0/b/ustp-sam.appspot.com/o/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg?alt=media&token=467e3a72-190c-4320-bd3f-2948c481d5f3",width: 100,height: 99,fit: BoxFit.fitWidth,)
                                                                );
                                                                return ClipRRect(
                                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(50),topRight:Radius.circular(100),bottomRight:Radius.circular(100),bottomLeft: Radius.circular(100) ) ,
                                                                    child: Image.network(snapshot.data!,width: 100,height: 99,fit: BoxFit.fitWidth,)
                                                                );
                                                              },
                                                            );
                                                          }
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          margin: EdgeInsets.only(left: 5),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [

                                                                  FutureBuilder<DocumentSnapshot>(
                                                                      future: UserController.getUserDoc(id: subject.instructorID),
                                                                      builder: (context, snapshot) {
                                                                        if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                                        if(!snapshot.data!.exists)return Text("No instructor assigned yet",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),);
                                                                        UserModel userModel = UserModel.toObject(snapshot.data);
                                                                        return Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(userModel.fname.toTitleCase()+" "+userModel.lname.toTitleCase(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                                                                            Text(userModel.mobileNumber,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color: Colors.white),)
                                                                          ],
                                                                        );

                                                                      }
                                                                  ),
                                                                ],

                                                              ),

                                                            ],
                                                          ),
                                                        ),
                                                      ),


                                                    ],
                                                  ),

                                                  Divider(color: Colors.black87.withAlpha(50),),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("Code",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                      Text(subject.subjectCode,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),

                                                    ],
                                                  ),
                                                  Text("Subject Name",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                  SizedBox(
                                                    width:  MediaQuery. of(context). size. width*.60,
                                                    child: FittedBox(
                                                      fit: BoxFit.fitWidth,
                                                      child: Text(subject.name+" ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
                                                    ),
                                                  ),
                                                  Divider(color: Colors.black87.withAlpha(50),),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: const [
                                                          Text("Day",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                          Text("    Time-in",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                          Text("Time-out",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 50,
                                                        child: ListView(
                                                          children: subject.schedulesID.map((schedule) {
                                                            SenSorAttendanceController.getSenSorAttendanceWhereScheduleIDFuture(scheduleID: schedule).then((value) {
                                                              if(value.size<0)return;
                                                              value.docs.forEach((element) {
                                                                SensorAttendance sensorAttendance = SensorAttendance.toObject(element);
                                                                String status = "";
                                                                switch(sensorAttendance.status){
                                                                  case 1:
                                                                    status = "PRESENT";
                                                                    break;
                                                                  case 2:
                                                                    status = "LATE";
                                                                    break;
                                                                  case 3:
                                                                    status = "ABSENT";
                                                                    break;
                                                                }
                                                                if(!sensorAttendance.isTexted){
                                                                  DateTime date = DateTime.now();
                                                                  try{
                                                                    date = DateTime.parse(sensorAttendance.date);
                                                                  }catch(e){
                                                                    List<String >tempdate = sensorAttendance.date.split("-");
                                                                    String dateStr = "";
                                                                    if( tempdate[1].length==1){
                                                                      tempdate[1] = "0"+tempdate[1];
                                                                    }
                                                                    if( tempdate[2].length==1){
                                                                      tempdate[2] = "0"+tempdate[2];
                                                                    }

                                                                    dateStr+=tempdate[0]+"-"+tempdate[1]+"-"+tempdate[2];
                                                                    date = DateTime.parse(dateStr);
                                                                  }
                                                                  DateTime timeIn = date.add(Duration(hours: sensorAttendance.timeIn));
                                                                  String message = subject.name+" "+status+" "+DateFormat().add_jms().format(DateTime.fromMillisecondsSinceEpoch(timeIn.millisecondsSinceEpoch));
                                                                  telephony.sendSms(
                                                                      to:userModel.mobileNumber,
                                                                      message: message
                                                                  );
                                                                  var uuid = Uuid();
                                                                  StudentLog studentLog = StudentLog(id: uuid.v1(),message: message,time: timeIn.millisecondsSinceEpoch, studentID: userModel.schoolID);
                                                                  StudentLogController.upSert(log: studentLog);
                                                                  sensorAttendance.isTexted = true;
                                                                  SenSorAttendanceController.upSert(sensorAttendance: sensorAttendance);
                                                                }
                                                              });

                                                            });
                                                            return FutureBuilder<DocumentSnapshot>(
                                                                future: ScheduleController.getScheduleFuture(id:schedule),
                                                                builder: (context,snapshot){
                                                                  if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                                  if(!snapshot.data!.exists)return Center(child: CircularProgressIndicator(),);
                                                                  Schedule schedule = Schedule.toObject(snapshot.data);
                                                                  return Padding(
                                                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Text(CustomDayPicker.intToDay(schedule.day),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87),),
                                                                        Text("    "+schedule.inTimeStr,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87)),
                                                                        Text(schedule.outTimeStr,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87)),
                                                                      ],
                                                                    ),
                                                                  );
                                                                }
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Divider(color: Colors.black87.withAlpha(50),),
                                                  StreamBuilder<QuerySnapshot>(
                                                    stream: SenSorAttendanceController.getSenSorAttendanceWhereSubjectIDStream(subjectID: subject.id),
                                                    builder: (context, snapshot) {
                                                      if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                      if(snapshot.data!.size<0)return Center(child: CircularProgressIndicator(),);
                                                      List<SensorAttendance> sensorAttendance =[];
                                                      int late = 0 , present = 0,absent = 0;
                                                      snapshot.data!.docs.forEach((element) {
                                                        SensorAttendance att = SensorAttendance.toObject(element.data());
                                                        sensorAttendance.add(att);
                                                      });
                                                      sensorAttendance.forEach((element) {
                                                        if(element.userid==userModel.schoolID){
                                                          switch(element.status){
                                                            case 1:
                                                              present++;
                                                              break;
                                                            case 2:
                                                              late++;
                                                              break;
                                                            case 3:
                                                              absent++;
                                                              break;
                                                          }
                                                        }
                                                      });
                                                      this.sensorAttendances = sensorAttendance;
                                                      return Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text("Late",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87)),
                                                              Text(late.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.amber)),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text("Present",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87)),
                                                              Text(present.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green)),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text("Absent",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87)),
                                                              Text(absent.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.redAccent)),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 10,right: 10,bottom: 10),
                                            width: 150,
                                            child: CustomTextButton(
                                              rTR: 0,
                                              rTl: 0,
                                              rBL: 100,
                                              rBR: 50,
                                              width: 100,
                                              text: "Unenroll",
                                              color: MyColors.red,
                                              onPressed: (){
                                                TextEditingController confirmText = TextEditingController();
                                                MyDialog().show(context: context,
                                                    statefulBuilder: StatefulBuilder(builder: (context, setState){
                                                      return AlertDialog(
                                                        content: SizedBox(
                                                          height: 150,
                                                          child: Center(child:Column(
                                                            children: [
                                                              Text("Unenroll Subject ",style: TextStyle(fontWeight: FontWeight.w100),),
                                                              Text(subject.name,style: TextStyle(fontWeight: FontWeight.bold),),
                                                              CustomTextField(
                                                                  hint: "Subject Code",
                                                                  padding: EdgeInsets.zero,
                                                                  controller: confirmText),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  CustomTextButton(
                                                                      text: "Confirm",
                                                                      color: MyColors.red,
                                                                      onPressed: (){
                                                                        if(confirmText.text==subject.subjectCode){
                                                                          userModel.subjectIDs.remove(subject.id);
                                                                          UserController.upSert(user: userModel);
                                                                          Navigator.of(context).pop();
                                                                        }
                                                                      }
                                                                  ),
                                                                  CustomTextButton(
                                                                      text: "Cancel",
                                                                      color: MyColors.deadBlue,
                                                                      onPressed: (){
                                                                        Navigator.of(context).pop();

                                                                      }
                                                                  )
                                                                ],
                                                              ),

                                                            ],
                                                          )),
                                                        ),
                                                      );
                                                    })
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                }).toList(),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(

                    backgroundColor: Colors.orange,
                    elevation: 10,
                    child: Icon(Icons.library_add),
                    onPressed: () {
                      TextEditingController subjectCode = TextEditingController();
                      List<Subject> subjects = [];
                      MyDialog().show(
                          context: context,
                          statefulBuilder: StatefulBuilder(
                              builder: (context,setState){
                                UserModel tempUser = userModel;
                                List<dynamic> temp = [];
                                return AlertDialog(
                                  title: Text("Add Subject"),
                                  content: Container(
                                    height: 500,
                                    width: 500,
                                    child: Column(
                                      children: [
                                        CustomTextField(
                                          color: MyColors.deadBlue,
                                          hint: "Subject Code",
                                          padding: EdgeInsets.zero,
                                          controller: subjectCode,
                                          onChange: (text){
                                            SubjectController.getSubjectWhereSubjectCode(subjectCode: text).then((value) {
                                              if(value.docs.isNotEmpty){
                                                List<Subject> tempSubs = [];
                                                value.docs.forEach((element) {
                                                  Subject tempSub = Subject.toObject(element.data());
                                                  tempSubs.add(tempSub);
                                                });
                                                setState((){
                                                  subjects = tempSubs;
                                                });
                                              }

                                            });
                                          },

                                        ),
                                        Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                                        SizedBox(
                                          height: 200,
                                          child: ListView(
                                            children: subjects.map((subject){
                                              return GestureDetector(
                                                onTap: (){
                                                  if(!userModel.subjectIDs.contains(subject.id)){
                                                    userModel.subjectIDs.add(subject.id);
                                                    UserController.upSert(user: userModel);
                                                    Navigator.of(context).pop();
                                                    setState((){});
                                                  }
                                                  else{
                                                    Fluttertoast.showToast(
                                                        msg: 'Already have that subject',
                                                        toastLength: Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor: Colors.red,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  }

                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: MyColors.skyBlueDead,
                                                        ),
                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                    ),
                                                    padding: EdgeInsets.all(10),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(subject.name,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                                        FutureBuilder<QuerySnapshot>(
                                                            future: UserController.getUserWhereSchoolID(schoolID: subject.instructorID),
                                                            builder: (context,snapshot) {
                                                              if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                              try{
                                                                UserModel instructor = UserModel.toObject(snapshot.data!.docs.first.data());
                                                                return Text(instructor.fname.toTitleCase()+" "+instructor.lname.toTitleCase(),style: TextStyle(fontSize: 10,fontWeight: FontWeight.w100),);
                                                              }catch(e){
                                                                return Text("No instructor yet",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w100),);
                                                              }

                                                            }
                                                        ),
                                                        SizedBox(
                                                          height: 100,
                                                          child: ListView(
                                                            children: subject.schedulesID.map((e) {
                                                              return StreamBuilder(
                                                                  stream: ScheduleController.getSchedule(id: e),
                                                                  builder: (context,snapshot){
                                                                    if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                                    Schedule schedule = Schedule.toObject(snapshot.data);

                                                                    return Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(CustomDayPicker.intToDay(schedule.day)+" "+schedule.room,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text("Time in"+schedule.inTimeStr,style: TextStyle(fontWeight: FontWeight.w100,fontSize: 15),),
                                                                            Text("Time out"+schedule.outTimeStr,style: TextStyle(fontWeight: FontWeight.w100,fontSize: 15),)
                                                                          ],
                                                                        )
                                                                      ],
                                                                    );
                                                                  }
                                                              );
                                                            }).toList(),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                ),
                                              );
                                            }).toList(),
                                          ),

                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                          )
                      );
                    },

                  ),

                ),
              ),
            if(usertype==UserType.student)
              Scaffold(
                body: Container(
                  width:MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Color(0xffF4F6F6),
                  padding: EdgeInsets.only(right: 10,left: 10,top: 10,bottom: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Profile Picture",style: TextStyle(color: Colors.black87),),
                                  CustomTextButton(
                                    color: Colors.orange,
                                    text: "Upload",
                                    onPressed: (){
                                      _picker.pickImage(source: ImageSource.gallery).then((value) {
                                        setState(() {
                                          image = value;
                                        });
                                      });
                                    },

                                  ),
                                  if(image!=null&&imageURL.isNotEmpty)
                                    CircleAvatar(
                                      radius: 200,
                                      backgroundImage: FileImage(File(image!.path)),
                                    ),

                                  if(imageURL.isNotEmpty&&image==null)
                                    FutureBuilder<String>(
                                      future: firebase_storage.FirebaseStorage.instance.ref().child('files/profiles/'+userModel.schoolID).getDownloadURL(),
                                      builder: (context,snapshot){
                                        if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                        return CircleAvatar(
                                            radius: 200,
                                            backgroundImage:NetworkImage(snapshot.data!)
                                        );
                                      },
                                    )
                                ],
                              ),
                            ),
                            Text("Student Information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.black87),),
                            // Image.network(,width: 100,),
                            Row(
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      enable: false,
                                      controller: school,
                                      color: Colors.black87,
                                      rTopLeft:0 ,
                                      hint: "School ID",
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                                  Flexible(
                                    child: CustomTextField(
                                      controller: section,
                                      color: Colors.black87,
                                      hint: "Section",
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                    ),
                                  ),
                                ]
                            ),
                            Text("Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.black87),),
                            Row(
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      controller: fname,
                                      color: Colors.black87,
                                      rTopLeft:0 ,
                                      hint: "First Name",
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                                  Flexible(
                                    child: CustomTextField(
                                      controller: lname,
                                      color: Colors.black87,
                                      hint: "Last Name",
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                    ),
                                  ),

                                ]
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                            Text("Contact Information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color:Colors.black87),),
                            Row(
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      enable: false,
                                      controller: email,
                                      color: Colors.black87,
                                      rTopLeft:0 ,
                                      hint: "Email address",
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                                  Flexible(
                                    child: CustomTextField(
                                      controller: mobile,
                                      color: Colors.black87,
                                      hint: "Mobile Number",
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                    ),
                                  ),

                                ]
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                          ],
                        ),
                        CustomTextButton(
                            text: "Update",
                            color: Colors.orange,
                            onPressed: (){
                              if(school.text.isNotEmpty){//if this ID is in the valid user database
                                if(
                                lname.text.isNotEmpty&&
                                    fname.text.isNotEmpty&&
                                    email.text.isNotEmpty&&
                                    mobile.text.isNotEmpty
                                ){
                                  UserModel userModelt = UserModel(
                                      courseID:course.text,
                                      section:section.text,
                                      fname: fname.text,
                                      lname: lname.text,
                                      email: email.text,
                                      mobileNumber: mobile.text,
                                      schoolID: school.text,
                                      profilePicLink:"",
                                      subjectIDs: userModel.subjectIDs
                                  );
                                  UserController.upSert(user: userModelt);
                                  uploadFile(userModel.schoolID);
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const Login()),
                                        (Route<dynamic> route) => false,
                                  );
                                }
                                else{
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
                            }),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 150),
                          child: Divider(
                            height: 5,
                            thickness: 1,
                            color: MyColors.red.withAlpha(50),
                          ),
                        ),
                        Padding(padding: EdgeInsets.symmetric(vertical: 10)),

                      ],
                    ),
                  ),
                ),
              ),
            if(usertype==UserType.student)
              Scaffold(
                body: Container(
                  color: Color(0xffF4F6F6),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: StudentLogController.getStLogWithStudentIDStream(studentID:userModel.schoolID),
                    builder: (context,snapshots){
                      if(!snapshots.hasData)return Center(child: CircularProgressIndicator(),);
                      List<StudentLog> logs = [];
                      snapshots.data!.docs.forEach((element) {
                        logs.add(StudentLog.toObject(element.data()));
                      });
                      logs.sort((a,b)=>b.time.compareTo(a.time));
                      return ListView(
                        children: logs.map((e){
                          return Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.deepOrange.withAlpha(50),
                                border: Border.all(
                                    color:Colors.deepOrange.withAlpha(255)
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat.yMMMd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(e.time)),style: TextStyle(fontSize: 10,fontWeight: FontWeight.w100,color: Colors.black87),),
                                Text(e.message,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black87))
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

              ),
            if(usertype==UserType.instructor)
              Container(
                child: Scaffold(
                  body: Container(
                    color: Color(0xffF4F6F6),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: SubjectController.getSubjectWhereInstructorID(instructorID: userModel.schoolID),
                        builder: (context, snapshot) {
                          if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                          if(snapshot.data!.size<0)return Center(child: CircularProgressIndicator(),);

                          List<Subject> subjects = [];
                          snapshot.data!.docs.forEach((sub) {
                            Subject subject = Subject.toObject(sub.data());
                            subjects.add(subject);
                          });

                          return ListView(
                            children:subjects.map((subject)  {

                              String strColor = subject.color;
                              Color color = Color(int.parse("0x$strColor"));
                              if(subject.isDeleted)return Center();
                              return StreamBuilder<QuerySnapshot>(
                                stream: SenSorAttendanceController.getSenSorAttendanceWhereSubjectIDStream(subjectID: subject.id),
                                builder: (context, snapshot) {
                                  if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                  if(snapshot.data!.size<0)return Center(child: CircularProgressIndicator(),);
                                  int late = 0 , present = 0,absent = 0;
                                  snapshot.data!.docs.forEach((element) {
                                    SensorAttendance senor = SensorAttendance.toObject(element.data());
                                      switch(senor.status){
                                        case 1:
                                          present++;
                                          break;
                                        case 2:
                                          late++;
                                          break;
                                        case 3:
                                          absent++;
                                          break;
                                      }

                                  });
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text("ID - ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                Text(subject.id,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black87),),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 25.0),
                                              child: Row(
                                                children: [
                                                  Text("Enrolled Students - ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                  StreamBuilder<QuerySnapshot>(
                                                      stream:UserController.getValidUserWhereSubjectID(subjectID: subject.id),
                                                      builder: (context,snapshot){
                                                        if(!snapshot.hasData)return Text("0",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black87),);

                                                        return Text(snapshot.data!.size.toString(),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black87),);
                                                      }
                                                  )

                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10,right: 10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: color.withAlpha(100),
                                            border: Border.all(
                                              color: color,
                                            ),
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomLeft: Radius.circular(20))
                                        ),
                                        child: GestureDetector(
                                          onTap: (){
                                            UserController.getValidUserWhereSubjectIDFuture(subjectID: subject.id).then((value){
                                              if(value.size<0)return;
                                              List<UserModel> users = [];
                                              value.docs.forEach((element) {
                                                UserModel user = UserModel.toObject(element.data());
                                                users.add(user);
                                              });
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => SubjectStudent(students: users,subject:subject,user: userModel, )),
                                              );
                                            });

                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  FutureBuilder<DocumentSnapshot>(
                                                      future: UserController.getUserDoc(id: subject.instructorID),
                                                      builder: (context, snapshot) {
                                                        if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                        if(!snapshot.data!.exists)return Text("No instructor assigned yet",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),);
                                                        UserModel userModel = UserModel.toObject(snapshot.data);
                                                        // return Text(userModel.fname.toTitleCase()+" "+userModel.lname.toTitleCase(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),);
                                                        return FutureBuilder<String>(
                                                          future: firebase_storage.FirebaseStorage.instance.ref().child('files/profiles/'+userModel.schoolID).getDownloadURL(),
                                                          builder: (context,snapshot){
                                                            if(!snapshot.hasData)return ClipRRect(
                                                                borderRadius:BorderRadius.horizontal(left: Radius.circular(25)) ,
                                                                child: Image.network("https://firebasestorage.googleapis.com/v0/b/ustp-sam.appspot.com/o/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg?alt=media&token=467e3a72-190c-4320-bd3f-2948c481d5f3",width: 100,height: 99,fit: BoxFit.fitWidth,)
                                                            );
                                                            return ClipRRect(
                                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(50),topRight:Radius.circular(100),bottomRight:Radius.circular(100),bottomLeft: Radius.circular(100) ) ,
                                                                child: Image.network(snapshot.data!,width: 100,height: 99,fit: BoxFit.fitWidth,)
                                                            );
                                                          },
                                                        );
                                                      }
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      margin: EdgeInsets.only(left: 5),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [

                                                              FutureBuilder<DocumentSnapshot>(
                                                                  future: UserController.getUserDoc(id: subject.instructorID),
                                                                  builder: (context, snapshot) {
                                                                    if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                                    if(!snapshot.data!.exists)return Text("No instructor assigned yet",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),);
                                                                    UserModel userModel = UserModel.toObject(snapshot.data);
                                                                    return Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(userModel.fname.toTitleCase()+" "+userModel.lname.toTitleCase(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                                                                        Text(userModel.mobileNumber,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color: Colors.white),)
                                                                      ],
                                                                    );

                                                                  }
                                                              ),
                                                            ],

                                                          ),

                                                        ],
                                                      ),
                                                    ),
                                                  ),


                                                ],
                                              ),

                                              Divider(color: Colors.black87.withAlpha(50),),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Code",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                  Text(subject.subjectCode,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),

                                                ],
                                              ),
                                              Text("Subject Name",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                              SizedBox(
                                                width:  MediaQuery. of(context). size. width*.60,
                                                child: FittedBox(
                                                  fit: BoxFit.fitWidth,
                                                  child: Text(subject.name+" ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
                                                ),
                                              ),
                                              Divider(color: Colors.black87.withAlpha(50),),
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: const [
                                                      Text("Day",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                      Text("    Time-in",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                      Text("Time-out",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 50,
                                                    child: ListView(
                                                      children: subject.schedulesID.map((schedule) {
                                                        SenSorAttendanceController.getSenSorAttendanceWhereScheduleIDFuture(scheduleID: schedule).then((value) {
                                                          if(value.size<0)return;
                                                          value.docs.forEach((element) {
                                                            SensorAttendance sensorAttendance = SensorAttendance.toObject(element);
                                                            String status = "";
                                                            switch(sensorAttendance.status){
                                                              case 1:
                                                                status = "PRESENT";
                                                                break;
                                                              case 2:
                                                                status = "LATE";
                                                                break;
                                                              case 3:
                                                                status = "ABSENT";
                                                                break;
                                                            }
                                                            if(!sensorAttendance.isTexted){
                                                              DateTime date = DateTime.now();
                                                              try{
                                                                date = DateTime.parse(sensorAttendance.date);
                                                              }catch(e){
                                                                List<String >tempdate = sensorAttendance.date.split("-");
                                                                String dateStr = "";
                                                                if( tempdate[1].length==1){
                                                                  tempdate[1] = "0"+tempdate[1];
                                                                }
                                                                if( tempdate[2].length==1){
                                                                  tempdate[2] = "0"+tempdate[2];
                                                                }

                                                                dateStr+=tempdate[0]+"-"+tempdate[1]+"-"+tempdate[2];
                                                                date = DateTime.parse(dateStr);
                                                              }
                                                              DateTime timeIn = date.add(Duration(hours: sensorAttendance.timeIn));
                                                              String message = subject.name+" "+status+" "+DateFormat().add_jms().format(DateTime.fromMillisecondsSinceEpoch(timeIn.millisecondsSinceEpoch));
                                                              telephony.sendSms(
                                                                  to:userModel.mobileNumber,
                                                                  message: message
                                                              );
                                                              var uuid = Uuid();
                                                              StudentLog studentLog = StudentLog(id: uuid.v1(),message: message,time: timeIn.millisecondsSinceEpoch, studentID: userModel.schoolID);
                                                              StudentLogController.upSert(log: studentLog);
                                                              sensorAttendance.isTexted = true;
                                                              SenSorAttendanceController.upSert(sensorAttendance: sensorAttendance);
                                                            }
                                                          });

                                                        });
                                                        return FutureBuilder<DocumentSnapshot>(
                                                            future: ScheduleController.getScheduleFuture(id:schedule),
                                                            builder: (context,snapshot){
                                                              if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                              if(!snapshot.data!.exists)return Center(child: CircularProgressIndicator(),);
                                                              Schedule schedule = Schedule.toObject(snapshot.data);
                                                              return Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text(CustomDayPicker.intToDay(schedule.day),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87),),
                                                                    Text("    "+schedule.inTimeStr,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87)),
                                                                    Text(schedule.outTimeStr,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87)),
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(color: Colors.black87.withAlpha(50),),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text("Late",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87)),
                                                      Text(late.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.amber)),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text("Present",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87)),
                                                      Text(present.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green)),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text("Absent",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87)),
                                                      Text(absent.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.redAccent)),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                    ],
                                  );
                                }
                              );
                            }).toList(),
                          );
                        }
                    ),
                  ),
                ),
              ),
            if(usertype==UserType.instructor)
              Scaffold(
                body: Container(
                  width:MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color:  Color(0xffF4F6F6),
                  padding: EdgeInsets.only(right: 10,left: 10,top: 10,bottom: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Profile Picture",style: TextStyle(color: Colors.black87),),
                                  CustomTextButton(
                                    color: Color(0xff009688),
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
                                      radius: 200,
                                      backgroundImage: FileImage(File(image!.path)),
                                    ),

                                  if(imageURL.isNotEmpty&&image==null)
                                    FutureBuilder<String>(
                                      future: firebase_storage.FirebaseStorage.instance.ref().child('files/profiles/'+userModel.schoolID).getDownloadURL(),
                                      builder: (context,snapshot){
                                        if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                        return CircleAvatar(
                                            radius: 200,
                                            backgroundImage:NetworkImage(snapshot.data!)
                                        );
                                      },
                                    )
                                ],
                              ),
                            ),
                            Text("Basic Information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.black87),),
                            Row(
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      enable: false,
                                      controller: school,
                                      color: Colors.black87,
                                      rTopLeft:0 ,
                                      hint: "School ID",
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                                  Flexible(
                                    child: CustomTextField(
                                      controller: section,
                                      color: Colors.black87,
                                      hint: "Section",
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                    ),
                                  ),

                                ]
                            ),
                            Text("Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.black87),),
                            Row(
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      controller: fname,
                                      color: Colors.black87,
                                      rTopLeft:0 ,
                                      hint: "First Name",
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                                  Flexible(
                                    child: CustomTextField(
                                      controller: lname,
                                      color: Colors.black87,
                                      hint: "Last Name",
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                    ),
                                  ),

                                ]
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                            Text("Contact Information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color:Colors.black87),),
                            Row(
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      enable: false,
                                      controller: email,
                                      color: Colors.black87,
                                      rTopLeft:0 ,
                                      hint: "Email address",
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.symmetric(horizontal:10 )),
                                  Flexible(
                                    child: CustomTextField(
                                      controller: mobile,
                                      color: Colors.black87,
                                      hint: "Mobile Number",
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                    ),
                                  ),

                                ]
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                          ],
                        ),
                        CustomTextButton(
                          text: "Update",
                          color: Color(0xff009688),
                          onPressed: (){
                            if(school.text.isNotEmpty){//if this ID is in the valid user database
                              if(
                              lname.text.isNotEmpty&&
                                  fname.text.isNotEmpty&&
                                  email.text.isNotEmpty&&
                                  mobile.text.isNotEmpty
                              ){

                                UserModel userModelt = UserModel(
                                    courseID:course.text,
                                    section:section.text,
                                    fname: fname.text,
                                    lname: lname.text,
                                    email: email.text,
                                    mobileNumber: mobile.text,
                                    schoolID: school.text,
                                    profilePicLink:"",
                                    subjectIDs: userModel.subjectIDs
                                );
                                UserController.upSert(user: userModelt);
                                uploadFile(userModel.schoolID);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                      (Route<dynamic> route) => false,
                                );
                              }
                              else{
                                Fluttertoast.showToast(
                                    msg: "Please fill up all fields",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.black87,
                                    fontSize: 16.0
                                );
                              }

                            }
                          },
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

                      ],
                    ),
                  ),
                ),
              ),

          ],
        ),
        bottomNavigationBar: Container(
          color: usertype!=UserType.instructor?Colors.orange:Color(0xff009688),
          child: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.event_note,color: Colors.white,)),
              if(usertype!=UserType.instructor)
                Tab(icon: Icon(Icons.manage_accounts,color:  Colors.white)),
              Tab(icon: Icon(usertype!=UserType.instructor?Icons.segment:Icons.manage_accounts,color:  Colors.white)),

            ],
          ),
        ),
      ),
    );

  }

}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}