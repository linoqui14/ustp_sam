
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
import '../model/schedule.dart';
import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';


import '../model/subject.dart';

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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: MyColors.darkBlue,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.event_note)),
              Tab(icon: Icon(Icons.people)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Scaffold(
              body: StreamBuilder<QuerySnapshot>(
                stream: SubjectController.subjects.snapshots(),
                builder: (context,snapshots){
                  if(!snapshots.hasData)return Center(child: CircularProgressIndicator(),);
                  if(snapshots.data!.docs.isEmpty) return Center(child: CircularProgressIndicator(),);
                  List<Subject> subjects = [];
                  snapshots.data!.docs.forEach((element) {
                    subjects.add(Subject.toObject(element.data()));
                  });
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView(
                      children: subjects.map((subject){
                        print(subject.schedulesID);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(subject.name+" ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                Text(subject.id+" ",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 13),),
                                // Text(inTime,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15),)
                              ],
                            ),
                            IconButton(
                                onPressed: (){
                                  TextEditingController subjectCode = TextEditingController(text: subject.subjectCode);
                                  TextEditingController subjectName = TextEditingController(text: subject.name);
                                  List<Schedule> schedules = [];
                                  ValidUser instructor = ValidUser(id: "", email: "", userType: "");
                                  setState(() {

                                  });
                                  MyDialog().show(
                                      context: context,
                                      statefulBuilder: StatefulBuilder(
                                          builder: (contexts,setState){
                                            Subject subTemp = subject;

                                            subTemp.schedulesID.forEach((sched) {
                                              ScheduleController.getScheduleFuture(id: sched).then((value){

                                                if(value.exists) {
                                                  Schedule schedTemp = Schedule.toObject(value.data());
                                                  print(schedules.where((element) => element.id == schedTemp.id).isEmpty);
                                                  if(schedules.where((element) => element.id == schedTemp.id).isEmpty){
                                                    setState(() {
                                                      schedules.add(schedTemp);
                                                    });
                                                  }
                                                }
                                              });
                                            });
                                            // schedules.removeAt(schedules.length-1);
                                            ValidUserController.getUserFuture(id: subject.instructorID).then((value) {
                                              if(value.exists) {
                                                instructor =
                                                    ValidUser.toObject(
                                                        value.data());
                                              }
                                            });
                                            return AlertDialog(
                                              title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text("Add Schedule "),
                                                  CustomTextButton(
                                                    width: 50,
                                                    color: MyColors.red,
                                                    text: "Cancel",
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
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
                                                            instructor = validUsers[0];
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
                                                                            Text(schd.inTime
                                                                              ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100,height: 1),),
                                                                          ],
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text("Time-out",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,height:1),),
                                                                            Text(schd.outTime
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
                                                CustomTextButton(
                                                  width: 150,
                                                  color: MyColors.deadBlue,
                                                  text: "Add",
                                                  onPressed: () {

                                                    if(subjectName.text.isNotEmpty&&schedules.isNotEmpty&&subjectName.text.isNotEmpty){
                                                      subject.schedulesID = [];
                                                      schedules.forEach((element) {
                                                        subject.schedulesID.add(element.id);
                                                      });
                                                      SubjectController.upSert(subject: subject);
                                                      schedules.forEach((element) {
                                                        ScheduleController.upSert(schedule: element);
                                                      });
                                                      Navigator.of(context).pop();
                                                    }
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
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: MyColors.darkBlue,
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
                                  Text("Add Schedule "+schedules.length.toString()),
                                  CustomTextButton(
                                    width: 50,
                                    color: MyColors.red,
                                    text: "Cancel",
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
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
                                            instructor = validUsers[0];
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
                                                            Text(e.inTime
                                                              ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100,height: 1),),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("Time-out",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,height:1),),
                                                            Text(e.outTime
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
                                CustomTextButton(
                                  width: 150,
                                  color: MyColors.deadBlue,
                                  text: "Add",
                                  onPressed: () {
                                    if(subjectName.text.isNotEmpty&&schedules.isNotEmpty&&subjectName.text.isNotEmpty){
                                      var uuid = Uuid();
                                      List<dynamic> schedulesID = [];
                                      schedules.forEach((element) {
                                        ScheduleController.upSert(schedule: element);
                                        schedulesID.add(element.id);
                                      });


                                      SubjectController.upSert(subject: Subject(
                                        id: uuid.v1(),
                                        name: subjectName.text,
                                        instructorID: instructor.id,
                                        subjectCode: subjectCode.text,
                                        schedulesID: schedulesID,
                                        subjectStartDate: selectedDate.millisecondsSinceEpoch
                                      ));

                                      Navigator.of(context).pop();
                                    }
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
              body: StreamBuilder<QuerySnapshot>(
                stream: ValidUserController.validUser.snapshots(),
                builder: (context,snapshots){
                  if(!snapshots.hasData)return Center(child: CircularProgressIndicator(),);

                  List<ValidUser> validUsers = [];
                  snapshots.data!.docs.forEach((element) {
                    validUsers.add(ValidUser.toObject(element.data()));
                  });
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView(
                      children: validUsers.map((e){
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.email,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                SizedBox(
                                  width: 200,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e.id,style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color: Colors.black87.withAlpha(150))),
                                      Text(e.userType,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15),)
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
                                                height: 150,
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
                                                      ValidUserController.upSert(validUserModel: ValidUser(id: id.text, email: email.text, userType: dropdownvalue));
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
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: MyColors.darkBlue,
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
                                              ValidUserController.upSert(validUserModel: ValidUser(id: id.text, email: email.text,userType: dropdownvalue));
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
          ],
        ),
      ),
    );

  }



}