// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/foundation.dart';

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
  await fetchLeaveTypeAndRequests();

  // await syncAttendance();
  // await syncBasic();
  // await syncNumeric();
  // await syncPace();
  // syncLeaveRequest();
}
