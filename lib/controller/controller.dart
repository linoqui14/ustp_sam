import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ustp_sam/model/RFID.dart';
import 'package:ustp_sam/model/log_model.dart';
import 'package:ustp_sam/model/schedule.dart';
import 'package:ustp_sam/model/sensor_attendance.dart';
import 'package:ustp_sam/model/student_log.dart';
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
  static Stream<QuerySnapshot> getValidUserWhereSubjectID({required String subjectID}){
    return users.where("subjectIDs",arrayContains: subjectID).snapshots();
  }
  static Future<QuerySnapshot> getValidUserWhereSubjectIDFuture({required String subjectID}){
    return users.where("subjectIDs",arrayContains: subjectID).get();
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
  static Stream<QuerySnapshot> getSubjectWhereInstructorID({required String instructorID}){
    return subjects.where("instructorID",isEqualTo: instructorID).snapshots();
  }
  static Future<QuerySnapshot> getSubjectWhereInstructorIDFFuture({required String instructorID}){
    return subjects.where("instructorID",isEqualTo: instructorID).get();
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
class LogController{
  static CollectionReference logs = FirebaseFirestore.instance.collection('logs');

  static void upSert({required LogModel log}){
    logs.doc(log.id).set(log.toMap());
  }
  static Stream<DocumentSnapshot> getRFID({required String id}){
    return logs.doc(id).snapshots();
  }
  static Future<DocumentSnapshot> getRFIDFuture({required String id}){
    return logs.doc(id).get();
  }

}
class StudentLogController{
  static CollectionReference studentLog = FirebaseFirestore.instance.collection('student_logs');

  static void upSert({required StudentLog log}){
    studentLog.doc(log.id).set(log.toMap());
  }
  static Stream<DocumentSnapshot> getStLog({required String id}){
    return studentLog.doc(id).snapshots();
  }
  static Stream<QuerySnapshot> getStLogWithStudentIDStream({required String studentID}){
    return studentLog.where("studentID",isEqualTo: studentID).snapshots();
  }
  static Future<DocumentSnapshot> getSTLogFuture({required String id}){
    return studentLog.doc(id).get();
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
  static Stream<QuerySnapshot> getSenSorAttendanceWhereScheduleIDStream({required String scheduleID}){
    Stream<QuerySnapshot> at = attendance.where("scheduleID",isEqualTo: scheduleID).snapshots();
    return at;
  }
  static Stream<QuerySnapshot> getSenSorAttendanceWhereSubjectIDStream({required String subjectID}){
    Stream<QuerySnapshot> at = attendance.where("subjectID",isEqualTo: subjectID).snapshots();
    return at;
  }
  static Future<QuerySnapshot> getSenSorAttendanceWhereSubjectIDFuture({required String subjectID}){
    Future<QuerySnapshot> at = attendance.where("subjectID",isEqualTo: subjectID).get();
    return at;
  }
  static Future<QuerySnapshot> getSenSorAttendanceWhereScheduleIDFuture({required String scheduleID}){
    return attendance.where("scheduleID",isEqualTo: scheduleID).get();
  }
  static Future<QuerySnapshot> getSenSorAttendanceWhereScheduleIDANDStudentIDFuture({required String scheduleID,required String studentID}){
    return attendance.where("userid",isEqualTo: studentID).where("scheduleID",isEqualTo: scheduleID).get();
  }
  static void upSert({required SensorAttendance sensorAttendance}){
    attendance.doc(sensorAttendance.id).set(sensorAttendance.toMap());
  }
}