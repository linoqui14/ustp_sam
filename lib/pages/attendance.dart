


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:ustp_sam/controller/controller.dart';
import 'package:ustp_sam/model/schedule.dart';
import 'package:ustp_sam/model/subject.dart';
import 'package:ustp_sam/model/user_model.dart';
import 'package:ustp_sam/pages/home.dart';
import 'package:date_utils/date_utils.dart' as utilDate;
class Attendance extends StatefulWidget{
  const Attendance({Key? key,required this.subject,required this.userModel}) : super(key: key);
  final UserModel userModel;
  final Subject subject;

  @override
  State<Attendance> createState() =>_AttendanceState();
}

class _AttendanceState extends State<Attendance>{
  List<Schedule> schedules = [];
  @override
  void initState() {
    widget.subject.schedulesID.forEach((schedID) {
      ScheduleController.getScheduleFuture(id: schedID).then((value) {
        setState(() {
          Schedule schedule = Schedule.toObject(value.data());
          schedules.add(schedule);
        });

      });
    });

    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subject.name.toTitleCase(),style: TextStyle(color: Colors.black87)),
            Text(widget.subject.subjectCode.toTitleCase(),style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w100,fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
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
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.8,
            child: SfCalendar(

              view: CalendarView.week,
              dataSource: MeetingDataSource( getAppointment()),


            ),
          )
        ],
      ),
    );
  }
  List<Appointment> getAppointment(){
    List<Appointment> schedulesApt  = [];

    schedules.forEach((sched) {

      DateTime now = DateTime.now();
      List<String> timeSplit1 = sched.inTime.split(" ");
      List<String> hrmin1 = timeSplit1[0].split(":");
      int hr1 = timeSplit1[1]=="AM"?int.parse(hrmin1[0]):int.parse(hrmin1[0])+12;
      int min1 = int.parse(hrmin1[1]);

      List<String> timeSplit2 = sched.outTime.split(" ");
      List<String> hrmin2 = timeSplit2[0].split(":");

      int hr2 = timeSplit2[1]=="AM"||hrmin2[0]=="12"?int.parse(hrmin2[0]):int.parse(hrmin2[0])+12;
      int min2 = int.parse(hrmin2[1]);
      print(dayToDate(sched.day,DateTime.fromMillisecondsSinceEpoch(widget.subject.subjectStartDate)));
      DateTime startTime = DateTime(now.year,now.month,dayToDate(sched.day+1,DateTime.fromMillisecondsSinceEpoch(widget.subject.subjectStartDate)),hr1,min1,0);
      DateTime endTime = DateTime(now.year,now.month,dayToDate(sched.day+1,DateTime.fromMillisecondsSinceEpoch(widget.subject.subjectStartDate)),hr2,min2,0);
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
      schedulesApt.add(
          Appointment(
            startTime:startTime,
            endTime: endTime,
            subject: sched.room+"\n"+sched.inTime+"\n"+sched.outTime,
            recurrenceRule: "FREQ=WEEKLY;INTERVAL=1;BYDAY="+day+";COUNT=30"
          )
      );




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
