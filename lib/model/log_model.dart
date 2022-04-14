class LogModel{
  int date;
  String log,id;

  LogModel({required this.id,required this.date, required this.log});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'log':log,
      'date':date,
    };
  }
  static LogModel toObject(document){
    return LogModel(
      id:document['id'],
      log:document['log'],
      date:document['date'],
    );
  }
}