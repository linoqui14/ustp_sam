
class Subject{
  String id,instructorID,name,subjectCode;
  int subjectStartDate;
  List<dynamic> schedulesID;
  Subject({required this.id,required this.instructorID,required this.name,required this.subjectCode,required this.schedulesID,required this.subjectStartDate});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'instructorID':instructorID,
      'name':name,
      'subjectCode':subjectCode,
      'schedulesID':schedulesID,
      'subjectStartDate':subjectStartDate,
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
    );
  }



}
