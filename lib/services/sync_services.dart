// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/database_handler.dart';
import '../models/urlPaths.dart' as uri_paths;
import '../services/request_handler.dart';

import './database_handler.dart';
import 'package:intl/intl.dart';

final DateFormat format = DateFormat('yyyy-MM-dd');

Future<void> syncAttendance() async {
  try {
    final todayDate = DateTime.now();
    final lastMonthDate =
        DateTime(todayDate.year, todayDate.month - 1, todayDate.day);
    var attendanceEntries =
        await DBProvider.db.readAllAttendance(todayDate, lastMonthDate);
    if (attendanceEntries.isNotEmpty) {
      // print(attendanceEntries.toString());
      var attendanceList = attendanceEntries.toList();
      if (attendanceList.isNotEmpty) {
        attendanceSyncHandler(attendanceList);
      }
    } else {
      print('no entries attendance');
    }
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
}

Future<void> syncNumeric() async {
  try {
    final todayDate = DateTime.now();
    final lastMonthDate =
        DateTime(todayDate.year, todayDate.month - 1, todayDate.day);

    DBProvider.db
        .readAllNumeric(todayDate, lastMonthDate)
        .then((assessmentRecords) {
      // print(assessmentRecords.toString());
      var assessmentList = assessmentRecords.toList();
      if (assessmentList.isNotEmpty) {
        numericSyncHandler(assessmentList);
      } else {
        if (kDebugMode) {
          log(DateTime.now().toString());
        }
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
}

Future<void> syncBasic() async {
  try {
    final todayDate = DateTime.now();
    final lastMonthDate =
        DateTime(todayDate.year, todayDate.month - 1, todayDate.day);
    DBProvider.db
        .readAllBasic(todayDate, lastMonthDate)
        .then((assessmentRecords) {
      // print(assessmentRecords.toString());
      var assessmentList = assessmentRecords.toList();
      if (assessmentList.isNotEmpty) {
        basicSyncHandler(assessmentList);
      } else {
        if (kDebugMode) {
          print('no entries basic');
          log(DateTime.now().toString());
        }
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
}

Future<void> syncPace() async {
  try {
    final todayDate = DateTime.now();
    final lastMonthDate =
        DateTime(todayDate.year, todayDate.month - 1, todayDate.day);
    var assessmentRecords =
        await DBProvider.db.readAllPace(todayDate, lastMonthDate);
    var assessmentRecordsList = assessmentRecords.toList();
    if (assessmentRecordsList.isNotEmpty) {
      if (kDebugMode) {
        // log(assessmentRecords.toString());
      }
      paceSyncHandler(assessmentRecordsList);
    } else {
      if (kDebugMode) {
        print("no pace");
        log(DateTime.now().toString());
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
}

Future<void> syncLeaveRequest() async {
  try {
    var query =
        "SELECT * FROM TeacherLeaveRequest WHERE leaveRequestEditable='false';";
    var params = [];
    var leaveRequests = await DBProvider.db.dynamicRead(query, params);

    if (leaveRequests.isNotEmpty) {
      leaveRequestSyncHandler(leaveRequests);
    }
  } catch (e) {
    if (kDebugMode) {
      log(e.toString());
    }
  }
}

Future<void> wrapper() async {
  if (kDebugMode) {
    print('Fetch Persistent place here');
  }
  await fetchPersistent();
  // await fetchLeaveTypeAndRequests();

  await syncAttendance();
  await syncBasic();
  await syncNumeric();
  await syncPace();
  await syncLeaveRequest();
}

Future<void> wrapperHeadMaster() async {
  if (kDebugMode) {
    print('Fetch Persistent place here');
  }
  await fetchPersistentHeadMaster();
  // await fetchLeaveTypeAndRequests();

  // await syncAttendance();
  // await syncBasic();
  // await syncNumeric();
  // await syncPace();
  // await syncLeaveRequest();
}

Future<void> syncTeacherAttendance() async {
  try {
    var value = await DBProvider.db.getCredentials();
    final userName = value[0]['userName'];
    final userPassword = value[0]['userPassword'];
    final dbname = value[0]['dbname'];

    var query = "SELECT * FROM TeacherAttendance "
        "WHERE "
        "isSynced=? "
        "AND "
        "headMasterUserId = "
        "("
        "SELECT userId FROM users WHERE loginstatus=1 AND "
        "isHeadMaster=?"
        ");";
    var params = ['no', 'yes'];

    var teacherAttendanceRecords =
        await DBProvider.db.dynamicRead(query, params);

    if (teacherAttendanceRecords != null &&
        teacherAttendanceRecords.isNotEmpty) {
      log("teacher attendance read");
      // log(teacherAttendanceRecords[0].toString());
    }

    if (teacherAttendanceRecords != null &&
        teacherAttendanceRecords.isNotEmpty) {
      var record = teacherAttendanceRecords[0];
      var date = record['date'];
      var submissionDate = record['uploadDate'];
      var present = record['totalPresent'];
      var absent = record['totalAbsent'];
      var attendanceSheet = jsonDecode(record['attendanceJSONified']);
      var headMasterUserId = record['headMasterUserId'];

      var requestBody = {
        'userName': userName as String,
        'userPassword': userPassword as String,
        'dbname': dbname as String,
        'Persistent': '1',
        'date': date,
        'submissionDate': submissionDate,
        'present': present,
        'absent': absent,
        'attendanceSheet': attendanceSheet,
        'headMasterUserId': headMasterUserId,
      };
      if (kDebugMode) {
        log('teacher attendance data');
        // log(teacherAttendanceRecords[0].toString());
        log(requestBody.toString());
      }

      var response = await http.post(
        Uri.parse('${uri_paths.baseURL}${uri_paths.pushTeacherAttendance}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (kDebugMode) {
          log(response.body);
        }

        if (res['message'].toString().toLowerCase() == 'success') {
          String queryNew = "UPDATE TeacherAttendance SET isSynced=? "
              "WHERE "
              "date=?";
          var paramsNew = ['yes', date];
          await DBProvider.db.dynamicRead(queryNew, paramsNew);
        }
      }
      // for (var record in teacherAttendanceRecords) {
      //   var date = record['date'];
      //   var submissionDate = record['uploadDate'];
      //   var present = record['totalPresent'];
      //   var absent = record['totalAbsent'];
      //   var attendanceSheet = jsonDecode(record['attendanceJSONified']);

      //   var requestBody = {
      //     'userName': userName as String,
      //     'userPassword': userPassword as String,
      //     'dbname': dbname as String,
      //     'Persistent': '1',
      //     'date': date,
      //     'submissionDate': submissionDate,
      //     'present': present,
      //     'absent': absent,
      //     'attendanceSheet': attendanceSheet,
      //   };
      // }
    }
  } catch (e) {
    if (kDebugMode) {
      log(e.toString());
    }
  }
}
