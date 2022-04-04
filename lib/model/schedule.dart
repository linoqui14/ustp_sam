
class Schedule{
  String id,room,inTime,outTime;
  int day;
  Schedule(
      {
        required this.id,
        required this.room,
        required this.inTime,
        required this.outTime,
        required this.day
      }
      );

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'room':room,
      'inTime':inTime,
      'outTime':outTime,
      'day':day,
    };
  }
  static Schedule toObject(document){
    return Schedule(
      id:document['id'],
      room:document['room'],
      inTime:document['inTime'],
      outTime:document['outTime'],
      day:document['day'],
    );
  }



}
