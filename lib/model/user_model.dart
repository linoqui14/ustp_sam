

class UserType{
  static const String student = "student";
  static const String instructor = "instructor";
  static const List<String> userTypes = [student,instructor];
}

class UserModel{
  String schoolID,email,courseID,section,userType,fname,lname,mobileNumber,profilePicLink;
  List<dynamic> subjectIDs;
  UserModel({this.subjectIDs = const [],required this.fname,required this.lname,required this.mobileNumber,required this.schoolID,required this.email,required this.courseID,required this.section,this.userType = UserType.student,required this.profilePicLink});

  Map<String,dynamic> toMap(){
    return {
      'email':email,
      'courseID':courseID,
      'section':section,
      'fname':fname,
      'lname':lname,
      'schoolID':schoolID,
      'mobileNumber':mobileNumber,
      'subjectIDs':subjectIDs,
      'profilePicLink':profilePicLink,
    };
  }

  static UserModel toObject(document){
    return UserModel(
      email:document['email'],
      courseID:document['courseID'],
      section:document['section'],
      fname:document['fname'],
      lname:document['lname'],
      mobileNumber:document['mobileNumber'],
      schoolID:document['schoolID'],
      subjectIDs:document['subjectIDs'],
      profilePicLink:document['profilePicLink'],
    );
  }



}
