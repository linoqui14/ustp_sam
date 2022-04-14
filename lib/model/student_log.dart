

class StudentLog{
  int time;
  String id,message,studentID;

  StudentLog({required this.time, required this.id, required this.message, required this.studentID});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'time':time,
      'message':message,
      'studentID':studentID,
    };
  }
  static StudentLog toObject(document){
    return StudentLog(
      id:document['id'],
      time:document['time'],
      message:document['message'],
      studentID:document['studentID'],
    );
  }
}