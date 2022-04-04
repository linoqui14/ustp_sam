

class AttendanceStatus{
  static const present = 1;
  static const absent = 2;
  static const late = 2;
}

class Attendance {
  String id,subjectID,sceduleID,studentID;
  int status,timeIn,timeOut;

  Attendance(
      {
        required this.id,
        required this.subjectID,
        required this.sceduleID,
        this.status = AttendanceStatus.absent,
        required this.timeIn,
        required this.timeOut,
        required this.studentID
      });
  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'subjectID':subjectID,
      'sceduleID':sceduleID,
      'status':status,
      'timeIn':timeIn,
      'timeOut':timeOut,
      'studentID':studentID,
    };
  }
  static Attendance toObject(document){
    return Attendance(
      id:document['id'],
      subjectID:document['subjectID'],
      sceduleID:document['sceduleID'],
      status:document['status'],
      timeIn:document['timeIn'],
      timeOut:document['timeOut'],
      studentID:document['studentID'],

    );
  }
}