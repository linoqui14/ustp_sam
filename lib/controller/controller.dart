import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ustp_sam/model/RFID.dart';
import 'package:ustp_sam/model/schedule.dart';
import 'package:ustp_sam/model/subject.dart';
import 'package:ustp_sam/model/valid_users.dart';

import '../model/user_model.dart';

class UserController{
  static CollectionReference users = FirebaseFirestore.instance.collection('users');
  static Future<DocumentSnapshot> getUserDoc({required String id}){
    return users.doc(id).get();
  }
  static Future<QuerySnapshot> getUserWhereEmailDoc({required String email}){
    return users.where("email",isEqualTo: email).get();
  }
  static Future<QuerySnapshot> getUserWhereSchoolID({required String schoolID}){
    return users.where("schoolID",isEqualTo: schoolID).get();
  }
  static Stream<DocumentSnapshot> getUser({required String id}){
    return users.doc(id).snapshots();
  }

  static void upSert({required UserModel user}){
    users.doc(user.schoolID).set(user.toMap());
  }
}

class AdminController{
  static CollectionReference admin = FirebaseFirestore.instance.collection('admin');
  static Future<DocumentSnapshot> getUserDoc({required String id}){
    return admin.doc(id).get();
  }

  static void upSert({required UserModel user}){
    admin.doc(user.schoolID).set(user.toMap());
  }
}

class ValidUserController{
  static CollectionReference validUser = FirebaseFirestore.instance.collection('valid_user');

  static void upSert({required ValidUser validUserModel}){
    validUser.doc(validUserModel.id).set(validUserModel.toMap());
  }
  static Stream<DocumentSnapshot> getUser({required String id}){
    return validUser.doc(id).snapshots();
  }
  static Future<DocumentSnapshot> getUserFuture({required String id}){
    return validUser.doc(id).get();
  }
  static Future<QuerySnapshot> getValidUserWhereEmail({required String email}){
    return validUser.where("email",isEqualTo: email).get();
  }

  static Future<void> delete(String jobId)async{
    validUser.doc(jobId).delete();
  }

}
class SubjectController{
  static CollectionReference subjects = FirebaseFirestore.instance.collection('subject');

  static void upSert({required Subject subject}){
    subjects.doc(subject.id).set(subject.toMap());
  }
  static Stream<DocumentSnapshot> getSubject({required String id}){
    return subjects.doc(id).snapshots();
  }
  static Future<DocumentSnapshot> getSubjectDoc({required String id}){
    return subjects.doc(id).get();
  }
  static Future<QuerySnapshot> getSubjectWhereSubjectCode({required String subjectCode}){
    return subjects.where("subjectCode",isEqualTo: subjectCode).get();
  }
  static Future<void> delete(String jobId)async{
    subjects.doc(jobId).delete();
  }

}
class ScheduleController{
  static CollectionReference schedules = FirebaseFirestore.instance.collection('schedule');

  static void upSert({required Schedule schedule}){
    schedules.doc(schedule.id).set(schedule.toMap());
  }
  static Stream<DocumentSnapshot> getSchedule({required String id}){
    return schedules.doc(id).snapshots();
  }
  static Future<DocumentSnapshot> getScheduleFuture({required String id}){
    return schedules.doc(id).get();
  }
  static Future<void> delete(String jobId)async{
    schedules.doc(jobId).delete();
  }

}
class AttendanceController{
  static CollectionReference attendance = FirebaseFirestore.instance.collection('attendance');

  static void upSert({required Schedule schedule}){
    attendance.doc(schedule.id).set(schedule.toMap());
  }
  static Stream<DocumentSnapshot> getAttendance({required String id}){
    return attendance.doc(id).snapshots();
  }
  static Future<DocumentSnapshot> getAttendanceFuture({required String id}){
    return attendance.doc(id).get();
  }
  // static Future<void> delete(String jobId)async{
  //   attendance.doc(jobId).delete();
  // }

}
class RFIDController{
  static CollectionReference rfid = FirebaseFirestore.instance.collection('rfid');

  static void upSert({required RFID rfidm}){
    rfid.doc(rfidm.id).set(rfidm.toMap());
  }
  static Stream<DocumentSnapshot> getRFID({required String id}){
    return rfid.doc(id).snapshots();
  }
  static Future<DocumentSnapshot> getRFIDFuture({required String id}){
    return rfid.doc(id).get();
  }

}
class SenSorAttendanceController{
  static CollectionReference attendance = FirebaseFirestore.instance.collection('attendance_sensor');

  static Stream<DocumentSnapshot> getSenSorAttendance({required String id}){
    return attendance.doc(id).snapshots();
  }
  static Future<DocumentSnapshot> getSenSorAttendanceFuture({required String id}){
    return attendance.doc(id).get();
  }
  static Future<QuerySnapshot> getSenSorAttendanceWhereStudentID({required String studentID}){
    return attendance.where("userid",isEqualTo: studentID).get();
  }
  static Stream<QuerySnapshot> getSenSorAttendanceWhereStudentIDStream({required String studentID}){
    Stream<QuerySnapshot> at = attendance.where("userid",isEqualTo: studentID).snapshots();
    return at;
  }
}