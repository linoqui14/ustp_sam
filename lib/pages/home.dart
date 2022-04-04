import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ustp_sam/controller/controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ustp_sam/custom_widgets/custom_texfield.dart';
import 'package:ustp_sam/custom_widgets/day_picker.dart';
import 'package:ustp_sam/model/sensor_attendance.dart';
import 'package:ustp_sam/model/subject.dart';
import 'package:ustp_sam/pages/attendance.dart';
import 'package:ustp_sam/tools/my_colors.dart';
import 'package:ustp_sam/tools/my_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/schedule.dart';
import '../model/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'login.dart';
class Home extends StatefulWidget{
  const Home({Key? key,this.email,this.userModel}) : super(key: key);

  final String? email;
  final UserModel? userModel;


  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home>{
  UserModel userModel = UserModel(fname: '', lname: '', schoolID: '', courseID: '', mobileNumber: '', section: '', email: '');
  FirebaseAuth auth = FirebaseAuth.instance;
  List<SensorAttendance> sensorAttendances = [];
  @override
  void initState() {
    if(widget.email != null){
      UserController.getUserWhereEmailDoc(email: widget.email!).then((value) {
        if(value.size>0){
          if(value.docs.first.exists){
            setState(() {
              userModel = UserModel.toObject(value.docs.first.data());
            });
          }
        }

      });
    }
    if(widget.userModel!=null){
      userModel = widget.userModel!;
    }



    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 60,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userModel.fname.toTitleCase()+" "+userModel.lname.toTitleCase(),style: TextStyle(color: Colors.black87),),
              Text(userModel.schoolID.toTitleCase(),style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w100,fontSize: 15),),
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
                icon: Icon(Icons.exit_to_app,color: Colors.black87,)
            )
          ],
        ),
        body: TabBarView(

          children: [
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
                            userModel.subjectIDs.forEach((element) {
                              SubjectController.getSubjectDoc(id: element).then((sub) {
                                Subject subject = Subject.toObject(sub.data());
                                subject.schedulesID.forEach((schedID) {
                                  ScheduleController.getScheduleFuture(id: schedID).then((sched){
                                    Schedule schedule = Schedule.toObject(sched.data());
                                    DateTime sensorTime = DateTime.fromMillisecondsSinceEpoch(int.parse(sensorAttendance.time.toString()+"000"));
                                   
                                    if(schedule.day==sensorTime.weekday){
                                      String time = schedule.inTime.split(" ")[0];
                                      String ampm = schedule.inTime.split(" ")[1];
                                      int hr = ampm=="AM"?int.parse(time.split(":")[0]):(time.split(":")[0]=="12")?int.parse(time.split(":")[0]):int.parse(time.split(":")[0])+12;
                                      int min = int.parse(time.split(":")[1]);

                                      String timeOut = schedule.outTime.split(" ")[0];
                                      String ampmOut = schedule.outTime.split(" ")[1];
                                      int hrOut = ampmOut=="AM"?int.parse(timeOut.split(":")[0]):(timeOut.split(":")[0]=="12")?int.parse(timeOut.split(":")[0]):int.parse(timeOut.split(":")[0])+12;
                                      int minOut = int.parse(timeOut.split(":")[1]);

                                      if(sensorTime.hour )

                                    }
                                  });
                                } );

                              });
                            });

                          });
                          return Center();
                        }
                    ),
                    StreamBuilder<DocumentSnapshot>(
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
                                  return Container(
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.black87.withAlpha(20),
                                        border: Border.all(
                                          color: Colors.white,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => Attendance(userModel: userModel,subject:subject,)),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Name",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                  Text(subject.name.toTitleCase(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.black87),),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Code",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),),
                                                  Text(subject.subjectCode,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.black87),),
                                                ],
                                              ),
                                            ],
                                          ),
                                          FutureBuilder<DocumentSnapshot>(
                                              future: UserController.getUserDoc(id: subject.instructorID),
                                              builder: (context, snapshot) {
                                                if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                if(!snapshot.data!.exists)return Text("No instructor assigned yet",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),);
                                                UserModel userModel = UserModel.toObject(snapshot.data);
                                                return Text(userModel.fname.toTitleCase()+" "+userModel.lname.toTitleCase(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87),);
                                              }
                                          ),
                                          Divider(),
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
                                                                Text(CustomDayPicker.intToDay(schedule.day)),
                                                                Text("    "+schedule.inTime),
                                                                Text(schedule.outTime),
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

                                          Divider(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  Text("Late",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87)),
                                                  Text("0",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black87)),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text("Present",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87)),
                                                  Text("0",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black87)),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text("Absent",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.black87)),
                                                  Text("0",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black87)),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        }
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  elevation: 0,
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
                                                                          Text("Time in"+schedule.inTime,style: TextStyle(fontWeight: FontWeight.w100,fontSize: 15),),
                                                                          Text("Time out"+schedule.outTime,style: TextStyle(fontWeight: FontWeight.w100,fontSize: 15),)
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
            Scaffold(
              body: Center(child: Text(""),),
            ),
            Scaffold(
              body: Center(child: Text(""),),
            )
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.event_note,color: MyColors.deadBlue,)),
            Tab(icon: Icon(Icons.people,color:  MyColors.deadBlue)),
            Tab(icon: Icon(Icons.people,color:  MyColors.deadBlue)),
          ],
        ),
      ),
    );

  }

}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}