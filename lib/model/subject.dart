
class Subject{
  String id,instructorID,name,subjectCode,color;
  int subjectStartDate,late,absent,present;
  bool isDeleted;
  List<dynamic> schedulesID;
  Subject({required this.color,this.isDeleted = false,required this.id,required this.late,required this.absent,required this.present,required this.instructorID,required this.name,required this.subjectCode,required this.schedulesID,required this.subjectStartDate});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'instructorID':instructorID,
      'name':name,
      'subjectCode':subjectCode,
      'schedulesID':schedulesID,
      'subjectStartDate':subjectStartDate,
      'late':late,
      'absent':absent,
      'present':present,
      'isDeleted':isDeleted,
      'color':color,
    };
  }
  static Subject toObject(document){
    return Subject(
      id:document['id'],
      instructorID:document['instructorID'],
      name:document['name'],
      subjectCode:document['subjectCode'],
      schedulesID:document['schedulesID'],
      subjectStartDate:document['subjectStartDate'],
      late:document['late'],
      absent:document['absent'],
      present:document['present'],
      isDeleted:document['isDeleted'],
      color:document['color'],
    );
  }



}
