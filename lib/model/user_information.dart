
class UserInformationModel{
  String id,lname,fname;
  int birthday,age;
  UserInformationModel({required this.id,required this.lname,required this.fname,required this.birthday,required this.age});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'lname':lname,
      'fname':fname,
      'birthday':birthday,
      'age':age
    };
  }
  UserInformationModel toObject(document){
    return UserInformationModel(
      id:document['id'],
      lname:document['lname'],
      fname:document['fname'],
      birthday:document['birthday'],
      age:document['birthday'],
    );
  }



}
