



class SensorAttendance{
  String id,userid,date,scheduleID,subjectID;
  int timeIn,timeOut,status;
  bool isTexted = false;
  SensorAttendance({required this.isTexted,required this.status,required this.id,required this.timeIn,required this.subjectID,required this.timeOut,required this.date,required this.scheduleID,required this.userid});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'timeIn':timeIn,
      'subjectID':subjectID,
      'timeOut':timeOut,
      'date':date,
      'scheduleID':scheduleID,
      'userid':userid,
      'status':status,
      'isTexted':isTexted,

    };
  }
  static SensorAttendance toObject(document){
    return SensorAttendance(
      id:document['id'],
      timeIn:document['timeIn'],
      subjectID:document['subjectID'],
      timeOut:document['timeOut'],
      date:document['date'],
      userid:document['userid'],
      scheduleID:document['scheduleID'],
      status:document['status'],
      isTexted:document['isTexted'],

    );
  }
}