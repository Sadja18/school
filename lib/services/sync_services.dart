// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';

import '../services/request_handler.dart';

import './database_handler.dart';
import 'package:intl/intl.dart';

final DateFormat format = DateFormat('yyyy-MM-dd');

void syncAttendance() {
  try {
    final todayDate = DateTime.now();
    final lastMonthDate =
        DateTime(todayDate.year, todayDate.month - 1, todayDate.day);
    DBProvider.db
        .readAllAttendance(todayDate, lastMonthDate)
        .then((attendanceEntries) {
      if (attendanceEntries.isNotEmpty) {
        // print(attendanceEntries.toString());
        var attendanceList = attendanceEntries.toList();
        if (attendanceList.isNotEmpty) {
          attendanceSyncHandler(attendanceList);
        }
      } else {
        print('no entries attendance');
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
}

void syncNumeric() {
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
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
}

void syncBasic() {
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
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
}

void syncPace() {
  try {
    final todayDate = DateTime.now();
    final lastMonthDate =
        DateTime(todayDate.year, todayDate.month - 1, todayDate.day);
    DBProvider.db
        .readAllPace(todayDate, lastMonthDate)
        .then((assessmentRecords) {
      // print(assessmentRecords.toString());
      var assessmentRecordsList = assessmentRecords.toList();
      if (assessmentRecordsList.isNotEmpty) {
        paceSyncHandler(assessmentRecordsList);
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
}

void wrapper() {
  if(kDebugMode){
    print('Fetch Persistent place here');
  }
  fetchPersistent();

  // syncAttendance();
  // syncBasic();
  // syncNumeric();
  // syncPace();
}
