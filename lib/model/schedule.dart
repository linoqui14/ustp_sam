
class Schedule{
  String id,room,inTimeStr,outTimeStr;

  int day,inTime,outTime;
  Schedule(
      {
        required this.id,
        required this.room,
        required this.inTime,
        required this.outTime,
        required this.inTimeStr,
        required this.outTimeStr,
        required this.day
      }
      );

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'room':room,
      'inTime':inTime,
      'outTime':outTime,
      'inTimeStr':inTimeStr,
      'outTimeStr':outTimeStr,
      'day':day,
    };
  }
  static Schedule toObject(document){
    return Schedule(
      id:document['id'],
      room:document['room'],
      inTime:document['inTime'],
      outTime:document['outTime'],
      inTimeStr:document['inTimeStr'],
      outTimeStr:document['outTimeStr'],
      day:document['day'],
    );
  }



}
