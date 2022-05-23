


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:ustp_sam/controller/controller.dart';
import 'package:ustp_sam/model/schedule.dart';
import 'package:ustp_sam/model/sensor_attendance.dart';
import 'package:ustp_sam/model/subject.dart';
import 'package:ustp_sam/model/user_model.dart';
import 'package:ustp_sam/pages/home.dart';
import 'package:uuid/uuid.dart';
import 'package:date_utils/date_utils.dart' as utilDate;
class Attendance extends StatefulWidget{
  const Attendance({Key? key,required this.subject,required this.userModel,required this.sensorAttendances}) : super(key: key);
  final UserModel userModel;
  final Subject subject;
  final List<SensorAttendance> sensorAttendances;

  @override
  State<Attendance> createState() =>_AttendanceState();
}

class _AttendanceState extends State<Attendance>{
  List<Schedule> schedules = [];
  int late = 0 ,present = 0 ,absent = 0;
  int lmonth = 0,pmonth = 0,amonth = 0;
  int lsem = 0,psem = 0,asem = 0;
  GlobalKey<FormState> gkey = GlobalKey<FormState>();
  late DateTime end;
  @override
  void initState() {
    widget.sensorAttendances.forEach((element) {
      if(element.subjectID == widget.subject.id){
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

    widget.subject.schedulesID.forEach((schedID) {
      ScheduleController.getScheduleFuture(id: schedID).then((value) {
        setState(() {
          Schedule schedule = Schedule.toObject(value.data());
          schedules.add(schedule);
        });

      });
    });
    DateTime start = DateTime.fromMillisecondsSinceEpoch(widget.subject.subjectStartDate);
    end = DateTime(start.year,start.month+5,start.day);
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subject.name.toTitleCase(),style: TextStyle(color: Colors.white)),
            Text(widget.subject.subjectCode.toTitleCase(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w100,fontSize: 12)),
          ],
        ),
      ),
      body: Container(
        color: Colors.black87,
        child: Column(
          children: [

            SizedBox(

              height: MediaQuery.of(context).size.height*0.5,
              child: SfCalendar(
                key: gkey,
                timeSlotViewSettings: TimeSlotViewSettings(
                    timeTextStyle: TextStyle(color: Colors.white.withAlpha(100),fontWeight: FontWeight.w300)
                ),
                firstDayOfWeek: 1,
                viewHeaderStyle: ViewHeaderStyle(dayTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.white.withAlpha(100)),dateTextStyle: TextStyle(color: Colors.white)),
                headerStyle: CalendarHeaderStyle(textStyle: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w100)),
                weekNumberStyle: const WeekNumberStyle(textStyle: TextStyle(color: Colors.white)),
                cellBorderColor: Colors.white.withAlpha(20),
                todayHighlightColor: Colors.white.withAlpha(100),
                todayTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                minDate: DateTime.fromMillisecondsSinceEpoch(widget.subject.subjectStartDate),
                maxDate: end,
                view: CalendarView.week,
                dataSource: MeetingDataSource( getAppointment()),
                onViewChanged: (view){
                  int monthCountP = 0,monthCountA = 0,monthCountL = 0;

                  widget.sensorAttendances.forEach((sensorAtt) {
                    DateTime date = DateTime.now();
                    try{
                      date = DateTime.parse(sensorAtt.date);
                    }catch(e){
                      List<String >tempdate = sensorAtt.date.split("-");
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
                    if( view.visibleDates.first.month == date.month&&sensorAtt.subjectID==widget.subject.id){
                      switch(sensorAtt.status){
                        case 1:
                          monthCountP++;
                          break;
                        case 2:
                          monthCountL++;
                          break;
                        case 3:
                          monthCountA++;
                          break;
                      }

                    }
                  });
                  try{
                    setState(() {
                      lmonth = monthCountL;
                      amonth = monthCountA;
                      pmonth = monthCountP;
                    });
                  }
                  catch(e){

                  }



                },


              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Monthly",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w100,fontSize: 20),),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text("Late",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.white.withAlpha(100))),
                            Text(lmonth.toString(),style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.amber)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Present",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.white.withAlpha(100))),
                            Text(pmonth.toString(),style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.green)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Absent",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.white.withAlpha(100))),
                            Text(amonth.toString(),style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.redAccent)),
                          ],
                        ),
                      ],
                    ),),
                  Divider(color: Colors.white.withAlpha(50),),
                  Text("Whole Sem",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w100,fontSize: 20),),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text("Late",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.white.withAlpha(100))),
                            Text(late.toString(),style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.amber)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Present",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.white.withAlpha(100))),
                            Text(present.toString(),style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.green)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Absent",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100,color: Colors.white.withAlpha(100))),
                            Text(absent.toString(),style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.redAccent)),
                          ],
                        ),
                      ],
                    ),)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  List<Appointment> getAppointment(){
    List<Appointment> schedulesApt  = [];

    schedules.forEach((sched) {
      SensorAttendance? sensorAttendance;

      DateTime now = DateTime.now();
      int hr1 = (sched.inTime/60).toInt();
      int min1 = (sched.inTime%30).toInt();

      int hr2 = (sched.outTime/60).toInt();
      int min2 = (sched.outTime%30).toInt();


      DateTime startTime = DateTime(now.year,now.month,dayToDate(sched.day+1,DateTime.fromMillisecondsSinceEpoch(widget.subject.subjectStartDate)),hr1,min1,0);
      DateTime endTime = DateTime(now.year,now.month,dayToDate(sched.day+1,DateTime.fromMillisecondsSinceEpoch(widget.subject.subjectStartDate)),hr2,min2,0);

      if(widget.sensorAttendances.where((element){
        DateTime date = DateTime.now();
        try{
          date = DateTime.parse(element.date);
        }catch(e){
          List<String >tempdate = element.date.split("-");
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
        //absent if adlaw karon is mas dako sa adlaw sa
        bool isTrue = date.year==startTime.year&&date.month==startTime.month&&date.day==startTime.day;
        return isTrue;

      }).isEmpty){
        if(startTime.day<DateTime.now().day){
          var uuid = Uuid();
          int start = (startTime.hour*60)+startTime.minute;
          int nowStart = (DateTime.now().hour*60)+DateTime.now().minute;
          if((nowStart-start)>30){
            SenSorAttendanceController.upSert(sensorAttendance:
            SensorAttendance(
                status: 3,
                id: uuid.v1(),
                timeIn: 0,
                subjectID: widget.subject.id,
                timeOut: 0,
                date: startTime.year.toString()+"-"+startTime.month.toString()+"-"+startTime.day.toString(),
                scheduleID:sched.id,
                userid: widget.userModel.schoolID,
                isTexted: false
            )
            );
          }
        }

      }

      widget.sensorAttendances.forEach((element) {
        DateTime date = DateTime.now();
        try{
          date = DateTime.parse(element.date);
        }catch(e){
          List<String >tempdate = element.date.split("-");
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
        if(element.scheduleID==sched.id){
          Color color = Colors.blue;
          switch(element.status){
            case 1:
              color = Colors.green;
              break;
            case 2:
              color = Colors.amber;
              break;
            case 3:
              color = Colors.red;
              break;
          }
          schedulesApt.add(
              Appointment(
                  startTime:date.add(Duration(hours: startTime.hour,minutes: startTime.minute)),
                  endTime: endTime,
                  subject: sched.room+"\n"+sched.inTimeStr+"\n"+sched.outTimeStr,
                  color: color
              )
          );
          sensorAttendance = element;
          return;
        }
      });


      String day = "";
      switch (sched.day){
        case 0:
          day = "MO";
          break;
        case 1:
          day = "TU";
          break;
        case 2:
          day = "WE";
          break;
        case 3:
          day = "TH";
          break;
        case 4:
          day = "FR";
          break;
        case 5:
          day = "SA";
          break;
        case 6:
          day = "SU";
          break;
      }

      if(sensorAttendance==null){
        schedulesApt.add(
            Appointment(
                startTime:startTime,
                endTime: endTime,
                subject: sched.room+"\n"+sched.inTimeStr+"\n"+sched.outTimeStr,
                recurrenceRule: "FREQ=WEEKLY;INTERVAL=1;BYDAY="+day+";COUNT=23",
                color: Colors.white.withAlpha(50)
            )
        );
      }
      else{
        schedulesApt.add(
            Appointment(
                startTime:startTime.add(Duration(days: 7)),
                endTime: endTime.add(Duration(days: 7)),
                subject: sched.room+"\n"+sched.inTimeStr+"\n"+sched.outTimeStr,
                recurrenceRule: "FREQ=WEEKLY;INTERVAL=1;BYDAY="+day+";COUNT=22",
                color: Colors.white.withAlpha(50)
            )
        );
      }









    });

    return schedulesApt;

  }
  int dayToDate(int weekDay,DateTime dateStart){//this will give you the date of the weekday
    DateTime date = dateStart;//get the current date
    int days  = DateUtils.getDaysInMonth(DateTime.now().year, DateTime.now().month);//number of days in this month
    var listOfDates = new List<int>.generate(days, (i) => i + 1);//put in in an array
    for(int x in listOfDates){
      if(x>=date.day){//day start must be start at the current day
        if(weekDay == DateTime(date.year,date.month,x).weekday){//check if that date weekday is equal to the weekday you passed
          return x;//return the date of that day
        }
      }
    }
    //this can help you get the specific date of your schedules and use it on a DateTime as a day.
    return 0;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source){
    appointments = source;
  }

}
