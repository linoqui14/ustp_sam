


class SensorAttendance{
  String id,userid;
  int time;
  SensorAttendance({required this.id,required this.time,required this.userid});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'time':time,
      'userid':userid,
    };
  }
  static SensorAttendance toObject(document){
    return SensorAttendance(
      id:document['id'],
      time:document['time'],
      userid:document['userid'],
    );
  }
}