

class RFID{
  String id,rfid,userID;

  RFID({required this.id,required this.rfid, required this.userID});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'rfid':rfid,
      'userID':userID,
    };
  }
  static RFID toObject(document){
    return RFID(
      id:document['id'],
      rfid:document['rfid'],
      userID:document['userID'],
    );
  }
}