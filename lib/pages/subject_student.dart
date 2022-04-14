





import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ustp_sam/model/sensor_attendance.dart';
import 'package:ustp_sam/pages/attendance.dart';
import 'package:ustp_sam/pages/attendance_instructor.dart';
import '../controller/controller.dart';
import '../model/subject.dart';
import '../model/user_model.dart';
import 'package:ustp_sam/pages/home.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SubjectStudent extends StatefulWidget{
  const SubjectStudent({Key? key,required this.subject,required this.user,required this.students}) : super(key: key);
  final List<UserModel> students;
  final UserModel user;
  final Subject subject;

  @override
  State<SubjectStudent> createState()=> _SubjectStudentState();
}

class _SubjectStudentState extends State<SubjectStudent>{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.subject.name.toTitleCase(),style: TextStyle(color: Colors.white)),
                Text(widget.subject.subjectCode.toTitleCase(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w100,fontSize: 12)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ID-",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w100,fontSize: 12)),
                Text(widget.subject.id,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12)),
              ],
            ),

          ],
        ),
      ),
      body: Container(
        color: Colors.black87,
        child: ListView(
            children: widget.students.map((student) {

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 13),
                      child: FutureBuilder<String>(
                        future: firebase_storage.FirebaseStorage.instance.ref().child('files/profiles/'+student.schoolID).getDownloadURL(),
                        builder: (context,snapshot){
                          if(!snapshot.hasData)return ClipRRect(
                              borderRadius:BorderRadius.horizontal(left: Radius.circular(25)) ,
                              child: Image.network("https://firebasestorage.googleapis.com/v0/b/ustp-sam.appspot.com/o/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg?alt=media&token=467e3a72-190c-4320-bd3f-2948c481d5f3",width: 100,height: 99,fit: BoxFit.fitWidth,)
                          );
                          return ClipRRect(
                              borderRadius:BorderRadius.horizontal(left: Radius.circular(25)) ,
                              child: Image.network(snapshot.data!,width: 100,height: 118,fit: BoxFit.fitWidth,)
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text("ID-",style: TextStyle(fontSize: 10,color: Colors.white,fontWeight: FontWeight.w100),),
                              Text(student.schoolID,style: TextStyle(fontSize: 10,color: Colors.white,fontWeight: FontWeight.normal),),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white.withAlpha(20),
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(25))
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Text("Name",style: TextStyle(fontSize: 10,color: Colors.white,fontWeight: FontWeight.w100),),
                                  Text(student.fname.toTitleCase()+" "+student.lname.toTitleCase(),style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
                                  Text(student.mobileNumber,style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w100),),
                                  StreamBuilder<QuerySnapshot>(
                                      stream: SenSorAttendanceController.getSenSorAttendanceWhereStudentIDStream(studentID: student.schoolID) ,
                                      builder: (context,snapshot) {
                                        if(!snapshot.hasData)return Center();
                                        List<SensorAttendance> sensorAttendances = [];
                                        int late = 0 , absent = 0, present = 0;
                                        snapshot.data!.docs.forEach((element) {
                                          SensorAttendance sensorAttendance = SensorAttendance.toObject(element);
                                          if(sensorAttendance.subjectID==widget.subject.id){
                                            sensorAttendances.add(sensorAttendance);
                                            switch(sensorAttendance.status){
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

                                        return GestureDetector(
                                          onTap: (){
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>  AttendanceInstructor(userModel: student, sensorAttendances: sensorAttendances, subject: widget.subject,)),
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  Text("Late",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.white)),
                                                  Text(late.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.amber)),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text("Present",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.white)),
                                                  Text(present.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green)),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text("Absent",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.white)),
                                                  Text(absent.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.redAccent)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                  )
                                ]

                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
        ),
      ),
    );

  }

}