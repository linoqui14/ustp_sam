
class ValidUser{
  String id,email,userType;

  ValidUser({required this.id, required this.email,required this.userType});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'email':email,
      'userType':userType
    };
  }
  static ValidUser toObject(document){
    return ValidUser(id: document['id'], email: document['email'],userType: document['userType']);
  }
}