
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ustp_sam/controller/controller.dart';
import 'package:ustp_sam/custom_widgets/day_picker.dart';
import 'package:ustp_sam/custom_widgets/schedule_picker.dart';
import 'package:ustp_sam/model/user_model.dart';
import 'package:ustp_sam/model/valid_users.dart';
import 'package:ustp_sam/tools/my_colors.dart';
import 'package:ustp_sam/tools/my_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_widgets/custom_texfield.dart';
import '../custom_widgets/custom_textbutton.dart';
import '../model/log_model.dart';
import '../model/schedule.dart';
import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';


import '../model/subject.dart';
import 'login.dart';

class Admin extends StatefulWidget{
  const Admin({Key? key}) : super(key: key);


  @override
  State<Admin> createState() => _AdminState();

}


class _AdminState extends State<Admin>{


  // List of items in our dropdown menu

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: Colors.black87,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.event_note)),
              Tab(icon: Icon(Icons.people)),
              Tab(icon: Icon(Icons.segment)),
            ],
          ),
        ),
        body: Container(
          color: Colors.black87,
          child: TabBarView(
            children: [
              Scaffold(
                body: Container(
                  color: Colors.black87,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: SubjectController.subjects.snapshots(),
                    builder: (context,snapshots){
                      if(!snapshots.hasData)return Center(child: CircularProgressIndicator(),);
                      if(snapshots.data!.docs.isEmpty) return Center(child: CircularProgressIndicator(),);
                      List<Subject> subjects = [];
                      List<Subject> subjectsDeleted = [];
                      snapshots.data!.docs.forEach((element) {
                        Subject subjectTemp = Subject.toObject(element.data());
                        if(subjectTemp.isDeleted)subjectsDeleted.add(subjectTemp);
                        else subjects.add(subjectTemp);
                      });
                      return DefaultTabController(
                        length: 2,
                        child: Scaffold(
                          appBar: AppBar(
                            elevation: 0,
                            toolbarHeight: 0,
                            backgroundColor: Colors.black87,
                            bottom: const TabBar(
                              tabs: [
                                Tab(icon:Text("Subjects")),
                                Tab(icon:Text("Deleted Subject")),
                              ],
                            ),
                          ),
                          body: TabBarView(
                            children: [
                              Container(
                                color:Colors.black87,
                                padding: const EdgeInsets.all(10),
                                child: ListView(
                                  children: subjects.map((subject){
                                    return Opacity(
                                      opacity: subject.isDeleted?0.2:1,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.blue.withAlpha(10),
                                            border: Border.all(
                                                color:Colors.blue.withAlpha(50)
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(subject.name+" ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
                                                Text(subject.id+" ",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 13,color: Colors.white),),
                                                // Text(inTime,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15),)
                                              ],
                                            ),
                                            IconButton(
                                                onPressed: (){
                                                  TextEditingController subjectCode = TextEditingController(text: subject.subjectCode);
                                                  TextEditingController subjectName = TextEditingController(text: subject.name);
                                                  List<Schedule> schedules = [];
                                                  ValidUser instructor = ValidUser(id: "", email: "", userType: "");
                                                  List<ValidUser> validUsers = [];
                                                  MyDialog().show(
                                                      context: context,
                                                      statefulBuilder: StatefulBuilder(
                                                          builder: (contexts,setState1){
                                                            Subject subTemp = subject;
                                                            subTemp.schedulesID.forEach((sched) {
                                                              ScheduleController.getScheduleFuture(id: sched).then((value){
                                                                if(value.exists) {
                                                                  Schedule schedTemp = Schedule.toObject(value.data());

                                                                  if(schedules.where((element) => element.id == schedTemp.id).isEmpty){
                                                                    print(schedules.where((element) => element.id == schedTemp.id).isEmpty);
                                                                    setState1(() {
                                                                      schedules.add(schedTemp);
                                                                    });
                                                                  }
                                                                }
                                                              });
                                                            });
                                                            ValidUserController.validUser.where("userType",isEqualTo: UserType.instructor).get().then((value){
                                                              List<ValidUser> validUserTemp = [];
                                                              if(value.size<0)return;
                                                              value.docs.forEach((element) {
                                                                ValidUser validUser = ValidUser.toObject(element.data());
                                                                validUserTemp.add(validUser);
                                                              });
                                                              if(validUsers.length!=validUserTemp.length){
                                                                setState1((){
                                                                  validUsers = validUserTemp;
                                                                });
                                                              }

                                                            });
                                                            if(subject.instructorID.isNotEmpty&&instructor.id.isEmpty){
                                                              ValidUserController.getUserFuture(id: subject.instructorID).then((value) {
                                                                if(value.exists) {
                                                                  setState1((){
                                                                    instructor =
                                                                        ValidUser.toObject(
                                                                            value.data());
                                                                  });

                                                                }
                                                              });
                                                            }
                                                            try{
                                                              instructor = validUsers.where((element) => element.id==instructor.id).first;
                                                            }catch(e){
                                                              return Center(child: CircularProgressIndicator(),);
                                                            }

                                                            return AlertDialog(
                                                              title: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text("Edit Schedule "),
                                                                  IconButton(
                                                                      onPressed: (){
                                                                        Navigator.of(context).pop();
                                                                        MyDialog().show(context: context,
                                                                            statefulBuilder: StatefulBuilder(builder: (context, setState){
                                                                              return AlertDialog(
                                                                                content: SizedBox(
                                                                                  height: 100,
                                                                                  child: Center(child:Column(
                                                                                    children: [
                                                                                      Text(subject.isDeleted?"Confirm restoration":"Confirm deletion",style: TextStyle(fontWeight: FontWeight.w100),),
                                                                                      Text(subject.name,style: TextStyle(fontWeight: FontWeight.bold),),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          CustomTextButton(
                                                                                              text: "Confirm",
                                                                                              color: MyColors.red,
                                                                                              onPressed: (){

                                                                                                subject.isDeleted = subject.isDeleted?false:true;
                                                                                                SubjectController.upSert(subject: subject);
                                                                                                var uuid = Uuid();
                                                                                                LogController.upSert(log:LogModel(id: uuid.v1(), log: "Removed Subject: "+subjectName.text, date:DateTime.now().millisecondsSinceEpoch) );
                                                                                                Navigator.of(context).pop();
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
                                                                      icon: Icon(subject.isDeleted?Icons.restore_from_trash:Icons.delete_forever,color:subject.isDeleted?MyColors.darkBlue: MyColors.red,size: 35,))
                                                                ],
                                                              ),
                                                              content: Container(
                                                                height: 600,
                                                                width: 500,
                                                                child: SingleChildScrollView(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      CustomTextField(
                                                                        color: Colors.blue,
                                                                        controller: subjectCode,
                                                                        padding: EdgeInsets.symmetric(vertical: 10),
                                                                        hint: 'Subject Code',
                                                                        onChange: (text){
                                                                          // setState((){
                                                                          //   if(text.isNotEmpty){
                                                                          //
                                                                          //   }
                                                                          //   else{
                                                                          //     schedulePickers.clear();
                                                                          //   }
                                                                          // });
                                                                        },
                                                                      ),
                                                                      CustomTextField(
                                                                        color: Colors.blue,
                                                                        controller: subjectName,
                                                                        padding: EdgeInsets.symmetric(vertical: 10),
                                                                        hint: 'Subject Name',

                                                                      ),
                                                                      Container(
                                                                        width: double.infinity,
                                                                        decoration: BoxDecoration(
                                                                            border: Border.all(
                                                                                color: MyColors.skyBlueDead
                                                                            ),
                                                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                                                        ),
                                                                        padding:  EdgeInsets.all(10),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text("Instructor ID",style: TextStyle(color: MyColors.deadBlue),),
                                                                            DropdownButton(
                                                                              // Initial Value
                                                                              value: instructor,

                                                                              // Down Arrow Icon
                                                                              icon: const Icon(Icons.keyboard_arrow_down),

                                                                              // Array list of items
                                                                              items: validUsers.map((ValidUser items) {
                                                                                return DropdownMenuItem(
                                                                                  value: items,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(items.id),
                                                                                      Text(items.email,style: TextStyle(fontSize: 13,fontWeight: FontWeight.w300),),
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                              // After selecting the desired option,it will
                                                                              // change button value to selected value
                                                                              onChanged: (ValidUser? newValue) {
                                                                                setState1(() {
                                                                                  instructor = newValue!;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(top: 30),
                                                                        child: Row(
                                                                          children: [
                                                                            CustomTextButton(
                                                                              width: 150,
                                                                              color: MyColors.deadBlue,
                                                                              text: "Add room and time",
                                                                              onPressed: () {
                                                                                setState((){
                                                                                  if(subjectCode.text.isNotEmpty){
                                                                                    MyDialog().show(
                                                                                        context: context,
                                                                                        statefulBuilder: StatefulBuilder(
                                                                                          builder: (context,setStated){
                                                                                            var uuid = Uuid();
                                                                                            String widgetID = uuid.v1();
                                                                                            return AlertDialog(
                                                                                              contentPadding: EdgeInsets.all(3),
                                                                                              title: CustomTextButton(

                                                                                                width: double.infinity,
                                                                                                color: MyColors.red,
                                                                                                text: "Cancel",
                                                                                                onPressed: () {
                                                                                                  Navigator.of(context).pop();
                                                                                                },
                                                                                              ),
                                                                                              content: Container(
                                                                                                height: 350,
                                                                                                width: 200,
                                                                                                child: SchedulePicker(
                                                                                                  widgetID: widgetID,
                                                                                                  onSet: (sched,schedPickObj) {
                                                                                                    setState((){
                                                                                                      schedules.add(sched);
                                                                                                      Navigator.of(context).pop();
                                                                                                    });
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                        )
                                                                                    );
                                                                                  }

                                                                                });
                                                                              },
                                                                            ),

                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                          padding: EdgeInsets.all(5),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: schedules.length>0?MyColors.deadBlue:Colors.transparent,width: 2),
                                                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                          ),
                                                                          height: 330,
                                                                          child:ListView(
                                                                            children: schedules.map((schd){

                                                                              return Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  CustomTextButton(
                                                                                    text: "Remove",
                                                                                    color: MyColors.red,
                                                                                    onPressed:subTemp.schedulesID.length>1?(){
                                                                                      setState((){
                                                                                        schedules.remove(schd);
                                                                                        subTemp.schedulesID.removeWhere((element) => element==schd.id);
                                                                                      });
                                                                                    }:(){},
                                                                                  ),
                                                                                  Text(subTemp.id,style: TextStyle(fontWeight: FontWeight.w100,fontSize: 10),),
                                                                                  Padding(padding: EdgeInsets.symmetric(vertical: 3)),

                                                                                  Text(CustomDayPicker.intToDay(schd.day),style: TextStyle(color:Colors.black87,fontSize: 30,fontWeight: FontWeight.bold,height: 0.8),),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text("Time-in",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,height:1),),
                                                                                            Text(TimeOfDay(hour: (schd.inTime/60).toInt(),minute: (schd.inTime%60).toInt()).format(context)
                                                                                              ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100,height: 1),),
                                                                                          ],
                                                                                        ),
                                                                                        Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text("Time-out",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,height:1),),
                                                                                            Text(TimeOfDay(hour: (schd.outTime/60).toInt(),minute: (schd.outTime%60).toInt()).format(context)
                                                                                              ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100,height: 1),),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Divider(
                                                                                    height: 1,
                                                                                  )

                                                                                ],
                                                                              );

                                                                            }).toList(),
                                                                          )
                                                                      ),


                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              actions: [
                                                                Container(
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      CustomTextButton(
                                                                        color: MyColors.red,
                                                                        text: "Cancel",
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                      ),
                                                                      CustomTextButton(
                                                                        color: MyColors.deadBlue,
                                                                        text: "Save",
                                                                        onPressed: () {

                                                                          if(subjectName.text.isNotEmpty&&schedules.isNotEmpty&&subjectName.text.isNotEmpty){
                                                                            subject.schedulesID = [];
                                                                            schedules.forEach((element) {
                                                                              subject.schedulesID.add(element.id);
                                                                            });
                                                                            subject.instructorID = instructor.id;
                                                                            SubjectController.upSert(subject: subject);
                                                                            schedules.forEach((element) {
                                                                              ScheduleController.upSert(schedule: element);
                                                                            });
                                                                            var uuid = Uuid();
                                                                            LogController.upSert(log:LogModel(id: uuid.v1(), log: "Edited Subject: "+subjectName.text, date:DateTime.now().millisecondsSinceEpoch) );

                                                                            Navigator.of(context).pop();
                                                                          }
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                              ],
                                                            );
                                                          }
                                                      )
                                                  );
                                                },
                                                icon: Icon(Icons.edit,color: MyColors.deadBlue,)
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Container(
                                color: Colors.black87,
                                padding: const EdgeInsets.all(10),
                                child: ListView(
                                  children: subjectsDeleted.map((subject){
                                    return Opacity(
                                      opacity: subject.isDeleted?0.2:1,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.blue.withAlpha(10),
                                            border: Border.all(
                                                color:Colors.blue.withAlpha(50)
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(subject.name+" ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
                                                Text(subject.id+" ",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 13,color: Colors.white),),
                                                // Text(inTime,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15),)
                                              ],
                                            ),
                                            IconButton(
                                                onPressed: (){
                                                  TextEditingController subjectCode = TextEditingController(text: subject.subjectCode);
                                                  TextEditingController subjectName = TextEditingController(text: subject.name);
                                                  List<Schedule> schedules = [];
                                                  ValidUser instructor = ValidUser(id: "", email: "", userType: "");
                                                  List<ValidUser> validUsers = [];
                                                  MyDialog().show(
                                                      context: context,
                                                      statefulBuilder: StatefulBuilder(
                                                          builder: (contexts,setState1){
                                                            Subject subTemp = subject;
                                                            subTemp.schedulesID.forEach((sched) {
                                                              ScheduleController.getScheduleFuture(id: sched).then((value){
                                                                if(value.exists) {
                                                                  Schedule schedTemp = Schedule.toObject(value.data());

                                                                  if(schedules.where((element) => element.id == schedTemp.id).isEmpty){
                                                                    print(schedules.where((element) => element.id == schedTemp.id).isEmpty);
                                                                    setState1(() {
                                                                      schedules.add(schedTemp);
                                                                    });
                                                                  }
                                                                }
                                                              });
                                                            });
                                                            ValidUserController.validUser.where("userType",isEqualTo: UserType.instructor).get().then((value){
                                                              List<ValidUser> validUserTemp = [];
                                                              if(value.size<0)return;
                                                              value.docs.forEach((element) {
                                                                ValidUser validUser = ValidUser.toObject(element.data());
                                                                validUserTemp.add(validUser);
                                                              });
                                                              if(validUsers.length!=validUserTemp.length){
                                                                setState1((){
                                                                  validUsers = validUserTemp;
                                                                });
                                                              }

                                                            });
                                                            if(subject.instructorID.isNotEmpty&&instructor.id.isEmpty){
                                                              ValidUserController.getUserFuture(id: subject.instructorID).then((value) {
                                                                if(value.exists) {
                                                                  setState1((){
                                                                    instructor =
                                                                        ValidUser.toObject(
                                                                            value.data());
                                                                  });

                                                                }
                                                              });
                                                            }
                                                            try{
                                                              instructor = validUsers.where((element) => element.id==instructor.id).first;
                                                            }catch(e){
                                                              return Center(child: CircularProgressIndicator(),);
                                                            }

                                                            return AlertDialog(
                                                              title: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text("Edit Schedule "),
                                                                  IconButton(
                                                                      onPressed: (){
                                                                        Navigator.of(context).pop();
                                                                        MyDialog().show(context: context,
                                                                            statefulBuilder: StatefulBuilder(builder: (context, setState){
                                                                              return AlertDialog(
                                                                                content: SizedBox(
                                                                                  height: 100,
                                                                                  child: Center(child:Column(
                                                                                    children: [
                                                                                      Text(subject.isDeleted?"Confirm restoration":"Confirm deletion",style: TextStyle(fontWeight: FontWeight.w100),),
                                                                                      Text(subject.name,style: TextStyle(fontWeight: FontWeight.bold),),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          CustomTextButton(
                                                                                              text: "Confirm",
                                                                                              color: MyColors.red,
                                                                                              onPressed: (){

                                                                                                subject.isDeleted = subject.isDeleted?false:true;
                                                                                                SubjectController.upSert(subject: subject);
                                                                                                var uuid = Uuid();
                                                                                                LogController.upSert(log:LogModel(id: uuid.v1(), log: "Removed Subject: "+subjectName.text, date:DateTime.now().millisecondsSinceEpoch) );
                                                                                                Navigator.of(context).pop();
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
                                                                      icon: Icon(subject.isDeleted?Icons.restore_from_trash:Icons.delete_forever,color:subject.isDeleted?MyColors.darkBlue: MyColors.red,size: 35,))
                                                                ],
                                                              ),
                                                              content: Container(
                                                                height: 600,
                                                                width: 500,
                                                                child: SingleChildScrollView(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      CustomTextField(
                                                                        color: Colors.blue,
                                                                        controller: subjectCode,
                                                                        padding: EdgeInsets.symmetric(vertical: 10),
                                                                        hint: 'Subject Code',
                                                                        onChange: (text){
                                                                          // setState((){
                                                                          //   if(text.isNotEmpty){
                                                                          //
                                                                          //   }
                                                                          //   else{
                                                                          //     schedulePickers.clear();
                                                                          //   }
                                                                          // });
                                                                        },
                                                                      ),
                                                                      CustomTextField(
                                                                        color: Colors.blue,
                                                                        controller: subjectName,
                                                                        padding: EdgeInsets.symmetric(vertical: 10),
                                                                        hint: 'Subject Name',

                                                                      ),
                                                                      Container(
                                                                        width: double.infinity,
                                                                        decoration: BoxDecoration(
                                                                            border: Border.all(
                                                                                color: MyColors.skyBlueDead
                                                                            ),
                                                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                                                        ),
                                                                        padding:  EdgeInsets.all(10),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text("Instructor ID",style: TextStyle(color: MyColors.deadBlue),),
                                                                            DropdownButton(
                                                                              // Initial Value
                                                                              value: instructor,

                                                                              // Down Arrow Icon
                                                                              icon: const Icon(Icons.keyboard_arrow_down),

                                                                              // Array list of items
                                                                              items: validUsers.map((ValidUser items) {
                                                                                return DropdownMenuItem(
                                                                                  value: items,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(items.id),
                                                                                      Text(items.email,style: TextStyle(fontSize: 13,fontWeight: FontWeight.w300),),
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                              // After selecting the desired option,it will
                                                                              // change button value to selected value
                                                                              onChanged: (ValidUser? newValue) {
                                                                                setState1(() {
                                                                                  instructor = newValue!;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(top: 30),
                                                                        child: Row(
                                                                          children: [
                                                                            CustomTextButton(
                                                                              width: 150,
                                                                              color: MyColors.deadBlue,
                                                                              text: "Add room and time",
                                                                              onPressed: () {
                                                                                setState((){
                                                                                  if(subjectCode.text.isNotEmpty){
                                                                                    MyDialog().show(
                                                                                        context: context,
                                                                                        statefulBuilder: StatefulBuilder(
                                                                                          builder: (context,setStated){
                                                                                            var uuid = Uuid();
                                                                                            String widgetID = uuid.v1();
                                                                                            return AlertDialog(
                                                                                              contentPadding: EdgeInsets.all(3),
                                                                                              title: CustomTextButton(

                                                                                                width: double.infinity,
                                                                                                color: MyColors.red,
                                                                                                text: "Cancel",
                                                                                                onPressed: () {
                                                                                                  Navigator.of(context).pop();
                                                                                                },
                                                                                              ),
                                                                                              content: Container(
                                                                                                height: 350,
                                                                                                width: 200,
                                                                                                child: SchedulePicker(
                                                                                                  widgetID: widgetID,
                                                                                                  onSet: (sched,schedPickObj) {
                                                                                                    setState((){
                                                                                                      schedules.add(sched);
                                                                                                      Navigator.of(context).pop();
                                                                                                    });
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                        )
                                                                                    );
                                                                                  }

                                                                                });
                                                                              },
                                                                            ),

                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                          padding: EdgeInsets.all(5),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: schedules.length>0?MyColors.deadBlue:Colors.transparent,width: 2),
                                                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                          ),
                                                                          height: 330,
                                                                          child:ListView(
                                                                            children: schedules.map((schd){

                                                                              return Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  CustomTextButton(
                                                                                    text: "Remove",
                                                                                    color: MyColors.red,
                                                                                    onPressed:subTemp.schedulesID.length>1?(){
                                                                                      setState((){
                                                                                        schedules.remove(schd);
                                                                                        subTemp.schedulesID.removeWhere((element) => element==schd.id);
                                                                                      });
                                                                                    }:(){},
                                                                                  ),
                                                                                  Text(subTemp.id,style: TextStyle(fontWeight: FontWeight.w100,fontSize: 10),),
                                                                                  Padding(padding: EdgeInsets.symmetric(vertical: 3)),

                                                                                  Text(CustomDayPicker.intToDay(schd.day),style: TextStyle(color:Colors.black87,fontSize: 30,fontWeight: FontWeight.bold,height: 0.8),),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text("Time-in",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,height:1),),
                                                                                            Text(TimeOfDay(hour: (schd.inTime/60).toInt(),minute: (schd.inTime%60).toInt()).format(context)
                                                                                              ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100,height: 1),),
                                                                                          ],
                                                                                        ),
                                                                                        Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text("Time-out",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,height:1),),
                                                                                            Text(TimeOfDay(hour: (schd.outTime/60).toInt(),minute: (schd.outTime%60).toInt()).format(context)
                                                                                              ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100,height: 1),),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Divider(
                                                                                    height: 1,
                                                                                  )

                                                                                ],
                                                                              );

                                                                            }).toList(),
                                                                          )
                                                                      ),


                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              actions: [
                                                                Container(
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      CustomTextButton(
                                                                        color: MyColors.red,
                                                                        text: "Cancel",
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                      ),
                                                                      CustomTextButton(
                                                                        color: MyColors.deadBlue,
                                                                        text: "Save",
                                                                        onPressed: () {

                                                                          if(subjectName.text.isNotEmpty&&schedules.isNotEmpty&&subjectName.text.isNotEmpty){
                                                                            subject.schedulesID = [];
                                                                            schedules.forEach((element) {
                                                                              subject.schedulesID.add(element.id);
                                                                            });
                                                                            subject.instructorID = instructor.id;
                                                                            SubjectController.upSert(subject: subject);
                                                                            schedules.forEach((element) {
                                                                              ScheduleController.upSert(schedule: element);
                                                                            });
                                                                            var uuid = Uuid();
                                                                            LogController.upSert(log:LogModel(id: uuid.v1(), log: "Edited Subject: "+subjectName.text, date:DateTime.now().millisecondsSinceEpoch) );

                                                                            Navigator.of(context).pop();
                                                                          }
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                              ],
                                                            );
                                                          }
                                                      )
                                                  );
                                                },
                                                icon: Icon(Icons.edit,color: MyColors.deadBlue,)
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: MyColors.darkBlue.withAlpha(100),
                  onPressed: (){
                    List<Schedule> schedules = [];
                    TextEditingController subjectCode = TextEditingController();
                    TextEditingController subjectName = TextEditingController();
                    ValidUser instructor = ValidUser(id: "", email: "", userType: "");
                    DateTime selectedDate = DateTime.now();
                    MyDialog().show(
                        context: context,
                        statefulBuilder: StatefulBuilder(
                            builder: (contexts,setState){
                              return AlertDialog(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Add Schedule"),
                                  ],
                                ),
                                content: Container(
                                  height: 600,
                                  width: 500,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextField(
                                          color: Colors.blue,
                                          controller: subjectCode,
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          hint: 'Subject Code',
                                          onChange: (text){
                                            // setState((){
                                            //   if(text.isNotEmpty){
                                            //
                                            //   }
                                            //   else{
                                            //     schedulePickers.clear();
                                            //   }
                                            // });
                                          },
                                        ),
                                        CustomTextField(
                                          color: Colors.blue,
                                          controller: subjectName,
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          hint: 'Subject Name',

                                        ),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: ValidUserController.validUser.snapshots(),
                                          builder: (context,snapshots){
                                            if(!snapshots.hasData)return Center(child: CircularProgressIndicator(),);
                                            if(snapshots.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                            if(snapshots.data!.docs.isNotEmpty){
                                              List<ValidUser> validUsers = [];
                                              snapshots.data!.docs.forEach((element) {
                                                ValidUser validUser = ValidUser.toObject(element.data());
                                                if(validUser.userType==UserType.instructor){
                                                  validUsers.add(validUser);
                                                }
                                              });
                                              if(validUsers.isEmpty)return Center(child: CircularProgressIndicator(),);
                                              if(instructor.id.isEmpty){
                                                instructor = validUsers[0];
                                              }
                                              else{
                                                print(instructor.id);
                                                instructor = validUsers.where((element) => element.id==instructor.id).first;
                                              }
                                              return  Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: MyColors.skyBlueDead
                                                    ),
                                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                                ),
                                                padding:  EdgeInsets.all(10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Instructor ID",style: TextStyle(color: MyColors.deadBlue),),
                                                    DropdownButton(
                                                      // Initial Value
                                                      value: instructor,

                                                      // Down Arrow Icon
                                                      icon: const Icon(Icons.keyboard_arrow_down),

                                                      // Array list of items
                                                      items: validUsers.map((ValidUser items) {
                                                        return DropdownMenuItem(
                                                          value: items,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(items.id),
                                                              Text(items.email,style: TextStyle(fontSize: 13,fontWeight: FontWeight.w300),),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                      // After selecting the desired option,it will
                                                      // change button value to selected value
                                                      onChanged: (ValidUser? newValue) {
                                                        setState(() {
                                                          instructor = newValue!;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            return Center(child: CircularProgressIndicator(),);
                                          },
                                        ),
                                        Padding(padding: EdgeInsets.only(top: 10)),
                                        CustomTextButton(
                                          width: 150,
                                          color: MyColors.deadBlue,
                                          text: "Start Date - "+DateFormat.yMMMd().format(selectedDate),
                                          onPressed: ()async{
                                            final DateTime? picked = await showDatePicker(
                                                context: context,
                                                initialDate: selectedDate,
                                                firstDate: DateTime(2022, 1),
                                                lastDate: DateTime(2101));
                                            if (picked != null && picked != selectedDate) {
                                              setState(() {
                                                selectedDate = picked;
                                              });
                                            }
                                          },
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: Row(
                                            children: [
                                              CustomTextButton(
                                                width: 150,
                                                color: MyColors.deadBlue,
                                                text: "Add room and time",
                                                onPressed: () {
                                                  setState((){
                                                    if(subjectCode.text.isNotEmpty){
                                                      MyDialog().show(
                                                          context: context,
                                                          statefulBuilder: StatefulBuilder(
                                                            builder: (context,setStated){
                                                              var uuid = Uuid();
                                                              String widgetID = uuid.v1();
                                                              return AlertDialog(
                                                                contentPadding: EdgeInsets.all(3),
                                                                title: CustomTextButton(
                                                                  width: double.infinity,
                                                                  color: MyColors.red,
                                                                  text: "Cancel",
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                                content: Container(
                                                                  height: 350,
                                                                  width: 200,
                                                                  child: SchedulePicker(
                                                                    widgetID: widgetID,
                                                                    onSet: (sched,schedPickObj) {
                                                                      setState((){
                                                                        schedules.add(sched);
                                                                        Navigator.of(context).pop();
                                                                      });
                                                                    },
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )
                                                      );
                                                    }

                                                  });
                                                },
                                              ),

                                            ],
                                          ),
                                        ),
                                        Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: schedules.length>0?MyColors.deadBlue:Colors.transparent,width: 2),
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            height: 330,
                                            child:ListView(
                                              children: schedules.map((e){
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomTextButton(
                                                      text: "Remove",
                                                      color: MyColors.red,
                                                      onPressed: (){
                                                        setState((){
                                                          schedules.remove(e);
                                                          ScheduleController.schedules.doc(e.id).delete();
                                                        });
                                                      },
                                                    ),
                                                    Text(e.id,style: TextStyle(fontWeight: FontWeight.w100,fontSize: 10),),
                                                    Padding(padding: EdgeInsets.symmetric(vertical: 3)),

                                                    Text(CustomDayPicker.intToDay(e.day),style: TextStyle(color:Colors.black87,fontSize: 30,fontWeight: FontWeight.bold,height: 0.8),),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text("Time-in",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,height:1),),
                                                              Text(TimeOfDay(hour: (e.inTime/60).toInt(),minute: (e.inTime%60).toInt()).format(context)
                                                                ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100,height: 1),),
                                                            ],
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text("Time-out",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,height:1),),
                                                              Text(TimeOfDay(hour: (e.outTime/60).toInt(),minute: (e.outTime%60).toInt()).format(context)
                                                                ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100,height: 1),),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Divider(
                                                      height: 1,
                                                    )

                                                  ],
                                                );
                                              }).toList(),
                                            )
                                        ),


                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextButton(
                                          color: MyColors.red,
                                          text: "Cancel",
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        CustomTextButton(
                                          width: 150,
                                          color: MyColors.deadBlue,
                                          text: "Add",
                                          onPressed: () {
                                            if(subjectName.text.isNotEmpty&&schedules.isNotEmpty&&subjectName.text.isNotEmpty){
                                              List<dynamic> schedulesID = [];
                                              schedules.forEach((element) {
                                                ScheduleController.upSert(schedule: element);
                                                schedulesID.add(element.id);
                                              });
                                              var rng = Random();
                                              Color color = MyColors.colors[rng.nextInt(10)];
                                              SubjectController.subjects.get().then((value) {
                                                SubjectController.upSert(subject: Subject(
                                                  id:value.size.toString()+rng.nextInt(100).toString(),
                                                  name: subjectName.text,
                                                  instructorID: instructor.id,
                                                  subjectCode: subjectCode.text,
                                                  schedulesID: schedulesID,
                                                  subjectStartDate: selectedDate.millisecondsSinceEpoch,
                                                  late:0,
                                                  absent: 0,
                                                  present: 0,
                                                  color: color.value.toRadixString(16)
                                                ));
                                                var uuid = Uuid();
                                                LogController.upSert(log:LogModel(id: uuid.v1(), log: "Added Subject: "+subjectName.text, date:DateTime.now().millisecondsSinceEpoch) );
                                                schedulesID.forEach((element) {
                                                  LogController.upSert(log:LogModel(id: uuid.v1(), log: "Added Schedule: "+element, date:DateTime.now().millisecondsSinceEpoch) );
                                                });
                                                Navigator.of(context).pop();
                                              });

                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),



                                ],
                              );
                            }
                        )
                    );
                  },
                  child: Icon(Icons.add,color:MyColors.skyBlueDead ,),
                ),
              ),
              Scaffold(
                body: Container(
                  color: Colors.black87,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: ValidUserController.validUser.snapshots(),
                    builder: (context,snapshots){
                      if(!snapshots.hasData)return Center(child: CircularProgressIndicator(),);
                      List<ValidUser> instructors = [];
                      List<ValidUser> students = [];
                      snapshots.data!.docs.forEach((element) {
                        ValidUser validUser = ValidUser.toObject(element.data());
                        switch(validUser.userType){
                          case UserType.student:
                            students.add(validUser);
                            break;
                          case UserType.instructor:
                            instructors.add(validUser);
                            break;
                        }


                      });

                      return DefaultTabController(
                        length: 2,
                        child: Scaffold(
                          appBar: AppBar(
                            elevation: 0,
                            toolbarHeight: 0,
                            backgroundColor: Colors.black87,
                            bottom: const TabBar(
                              tabs: [
                                Tab(icon:Text("Students")),
                                Tab(icon:Text("Instructors")),
                              ],
                            ),
                          ),
                          body: TabBarView(
                            children: [
                              Container(
                                color:Colors.black87,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ListView(
                                    children: students.map((e){
                                      return Container(
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.blue.withAlpha(10),
                                            border: Border.all(
                                                color:Colors.blue.withAlpha(50)
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(e.email,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
                                                SizedBox(
                                                  width: 200,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(e.id,style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color: Colors.white.withAlpha(100))),
                                                      Text(e.userType,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15,color: Colors.white.withAlpha(100)),)
                                                    ],
                                                  ),
                                                ),

                                              ],
                                            ),
                                            IconButton(
                                                onPressed: (){
                                                  MyDialog().show(
                                                      context: context,
                                                      statefulBuilder: StatefulBuilder(
                                                          builder: (context,setState){
                                                            String dropdownvalue = e.userType;
                                                            TextEditingController id = TextEditingController(text: e.id);
                                                            TextEditingController email = TextEditingController(text: e.email);

                                                            String oldValue = e.id+" "+e.email;
                                                            return AlertDialog(
                                                              title: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text("Edit Valid User"),
                                                                  IconButton(
                                                                      onPressed: (){
                                                                        ValidUserController.delete(e.id);
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      icon: Icon(Icons.delete_forever,color: MyColors.red,size: 35,))
                                                                ],
                                                              ),
                                                              content: Container(
                                                                height: 200,
                                                                width: 300,
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 10),
                                                                      child: DropdownButton(
                                                                        // Initial Value
                                                                        value: dropdownvalue,

                                                                        // Down Arrow Icon
                                                                        icon: const Icon(Icons.keyboard_arrow_down),

                                                                        // Array list of items
                                                                        items: UserType.userTypes.map((String items) {
                                                                          return DropdownMenuItem(
                                                                            value: items,
                                                                            child: Text(items),
                                                                          );
                                                                        }).toList(),
                                                                        // After selecting the desired option,it will
                                                                        // change button value to selected value
                                                                        onChanged: (String? newValue) {
                                                                          setState(() {
                                                                            dropdownvalue = newValue!;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                    CustomTextField(
                                                                      enable: false,
                                                                      color: Colors.blue,
                                                                      controller: id,
                                                                      padding: EdgeInsets.all(10),
                                                                      hint: 'ID',
                                                                    ),
                                                                    CustomTextField(
                                                                      color: Colors.blue,
                                                                      controller: email,
                                                                      padding: EdgeInsets.all(10),
                                                                      hint: 'Email',

                                                                    ),

                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                CustomTextButton(
                                                                  width: 150,
                                                                  color: MyColors.deadBlue,
                                                                  text: "Save",
                                                                  onPressed: () {
                                                                    if(email.text.isNotEmpty&&id.text.isNotEmpty){
                                                                      var uuid = Uuid();
                                                                      ValidUserController.upSert(validUserModel: ValidUser(id: id.text, email: email.text, userType: dropdownvalue));
                                                                      LogController.upSert(log:LogModel(id: uuid.v1(), log: "Edited Valid User\nFrom: "+oldValue+"\nTo: "+id.text+" "+email.text, date:DateTime.now().millisecondsSinceEpoch) );
                                                                      Navigator.of(context).pop();
                                                                    }
                                                                  },
                                                                ),
                                                                CustomTextButton(
                                                                  width: 150,
                                                                  color: MyColors.red,
                                                                  text: "Cancel",
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                      )
                                                  );
                                                },
                                                icon: Icon(Icons.edit,color: MyColors.deadBlue,)
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.black87,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ListView(
                                    children: instructors.map((e){
                                      return Container(
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.blue.withAlpha(10),
                                            border: Border.all(
                                                color:Colors.blue.withAlpha(50)
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(e.email,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
                                                SizedBox(
                                                  width: 200,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(e.id,style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color: Colors.white.withAlpha(100))),
                                                      Text(e.userType,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15,color: Colors.white.withAlpha(100)),)
                                                    ],
                                                  ),
                                                ),

                                              ],
                                            ),
                                            IconButton(
                                                onPressed: (){
                                                  MyDialog().show(
                                                      context: context,
                                                      statefulBuilder: StatefulBuilder(
                                                          builder: (context,setState){
                                                            String dropdownvalue = e.userType;
                                                            TextEditingController id = TextEditingController(text: e.id);
                                                            TextEditingController email = TextEditingController(text: e.email);

                                                            String oldValue = e.id+" "+e.email;
                                                            return AlertDialog(
                                                              title: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text("Edit Valid User"),
                                                                  IconButton(
                                                                      onPressed: (){
                                                                        ValidUserController.delete(e.id);
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      icon: Icon(Icons.delete_forever,color: MyColors.red,size: 35,))
                                                                ],
                                                              ),
                                                              content: Container(
                                                                height: 200,
                                                                width: 300,
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 10),
                                                                      child: DropdownButton(
                                                                        // Initial Value
                                                                        value: dropdownvalue,

                                                                        // Down Arrow Icon
                                                                        icon: const Icon(Icons.keyboard_arrow_down),

                                                                        // Array list of items
                                                                        items: UserType.userTypes.map((String items) {
                                                                          return DropdownMenuItem(
                                                                            value: items,
                                                                            child: Text(items),
                                                                          );
                                                                        }).toList(),
                                                                        // After selecting the desired option,it will
                                                                        // change button value to selected value
                                                                        onChanged: (String? newValue) {
                                                                          setState(() {
                                                                            dropdownvalue = newValue!;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                    CustomTextField(
                                                                      enable: false,
                                                                      color: Colors.blue,
                                                                      controller: id,
                                                                      padding: EdgeInsets.all(10),
                                                                      hint: 'ID',
                                                                    ),
                                                                    CustomTextField(
                                                                      color: Colors.blue,
                                                                      controller: email,
                                                                      padding: EdgeInsets.all(10),
                                                                      hint: 'Email',

                                                                    ),

                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                CustomTextButton(
                                                                  width: 150,
                                                                  color: MyColors.deadBlue,
                                                                  text: "Save",
                                                                  onPressed: () {
                                                                    if(email.text.isNotEmpty&&id.text.isNotEmpty){
                                                                      var uuid = Uuid();
                                                                      ValidUserController.upSert(validUserModel: ValidUser(id: id.text, email: email.text, userType: dropdownvalue));
                                                                      LogController.upSert(log:LogModel(id: uuid.v1(), log: "Edited Valid User\nFrom: "+oldValue+"\nTo: "+id.text+" "+email.text, date:DateTime.now().millisecondsSinceEpoch) );
                                                                      Navigator.of(context).pop();
                                                                    }
                                                                  },
                                                                ),
                                                                CustomTextButton(
                                                                  width: 150,
                                                                  color: MyColors.red,
                                                                  text: "Cancel",
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                      )
                                                  );
                                                },
                                                icon: Icon(Icons.edit,color: MyColors.deadBlue,)
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: MyColors.darkBlue.withAlpha(100),
                  onPressed: (){
                    String dropdownvalue = UserType.student;
                    MyDialog().show(
                        context: context,
                        statefulBuilder: StatefulBuilder(
                            builder: (context,setState){

                              TextEditingController id = TextEditingController();
                              TextEditingController email = TextEditingController();
                              return AlertDialog(
                                title: Text("Add Valid User"),
                                content: Container(
                                  height: 200,
                                  width: 300,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: DropdownButton(
                                          // Initial Value
                                          value: dropdownvalue,

                                          // Down Arrow Icon
                                          icon: const Icon(Icons.keyboard_arrow_down),

                                          // Array list of items
                                          items: UserType.userTypes.map((String items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          // After selecting the desired option,it will
                                          // change button value to selected value
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              dropdownvalue = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                      CustomTextField(

                                        color: Colors.blue,
                                        controller: id,
                                        padding: EdgeInsets.all(10),
                                        hint: 'ID',

                                      ),
                                      CustomTextField(

                                        color: Colors.blue,
                                        controller: email,
                                        padding: EdgeInsets.all(10),
                                        hint: 'Email',

                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  CustomTextButton(
                                    width: 150,
                                    color: MyColors.deadBlue,
                                    text: "Add",
                                    onPressed: () {
                                      if(email.text.isNotEmpty&&id.text.isNotEmpty){
                                        ValidUserController.getValidUserWhereEmail(email: email.text).then((validUser){
                                          try{
                                            validUser.docs.first.data();
                                            Fluttertoast.showToast(
                                                msg: "Email is already in-used",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0
                                            );
                                          }catch(e){
                                            ValidUserController.getUserFuture(id: id.text).then((validUser2) {
                                              if(validUser2.exists){
                                                Fluttertoast.showToast(
                                                    msg: "ID is already used",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0
                                                );
                                              }
                                              else{
                                                var uuid = Uuid();
                                                ValidUserController.upSert(validUserModel: ValidUser(id: id.text, email: email.text,userType: dropdownvalue));
                                                LogController.upSert(log:LogModel(id: uuid.v1(), log: "Added Valid User: " +email.text, date:DateTime.now().millisecondsSinceEpoch) );

                                                Navigator.of(context).pop();
                                              }

                                            });

                                          }
                                        });

                                      }


                                    },
                                  ),
                                  CustomTextButton(
                                    width: 150,
                                    color: MyColors.red,
                                    text: "Cancel",
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            }
                        )
                    );
                  },
                  child: Icon(Icons.add,color:MyColors.skyBlueDead ,),
                ),
              ),
              Scaffold(
                body: Container(
                  color: Colors.black87,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: LogController.logs.snapshots(),
                    builder: (context,snapshots){
                      if(!snapshots.hasData)return Center(child: CircularProgressIndicator(),);
                      List<LogModel> logs = [];
                      snapshots.data!.docs.forEach((element) {
                        logs.add(LogModel.toObject(element.data()));
                      });
                      logs.sort((a,b)=>b.date.compareTo(a.date));
                      return ListView(
                        children: logs.map((e){
                          return Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(10),
                                border: Border.all(
                                    color:Colors.blue.withAlpha(50)
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat.yMMMd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(e.date)),style: TextStyle(fontSize: 10,fontWeight: FontWeight.w100,color: Colors.white),),
                                Text(e.log,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.white))
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.black87,
          child: IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
                  (Route<dynamic> route) => false,
            );
          }, icon: Icon(Icons.exit_to_app,color: Colors.white,)),
        ),
      ),
    );

  }



}