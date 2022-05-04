// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/response_struct.dart';
import '../services/database_handler.dart';

Future<void> saveUserToDB(Map<String, dynamic> userData) async {
  print(userData);
  try {
    var userObject = User(
        userName: userData['user'],
        userPassword: userData['password'],
        userId: userData['userID'],
        loginStatus: userData['login_status'],
        isOnline: userData['isOnline'],
        dbname: 'doednhdd');

    await DBProvider.db.insertUser(userObject);
  } catch (e) {
    log(e.toString());
  }
}

Future<dynamic> isLoggedIn() async {
  String query = "SELECT * FROM users WHERE loginstatus=1 OR loginstatus='1'";
  var params = [];

  var result = await DBProvider.db.dynamicRead(query, params);

  if (kDebugMode) {
    print('isLoggedIn()');
    print(result.toString());
  }
  if (result.isEmpty) {
    return 0;
  } else {
    return '1';
  }
}

Future<String?> getUserName() async {
  try {
    var resultQ = await DBProvider.db.readUserName();

    var resultL = resultQ.toList();

    if (resultL.isNotEmpty) {
      var val = resultL[0]['userName'];

      if (kDebugMode) {
        print(val);
      }

      if (val != null) {
        return val.toString();
      } else {
        return '';
      }
    } else {
      return '';
    }
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
  return null;
}

// check if attendance record exists for selected date(format YYYY-MM-DD)

Future<dynamic> editOrCreateNewAttendance(
    String selectedDate, String className) async {
  var canNotEdit = {"edit": "no"};

  if (kDebugMode) {
    print('$selectedDate, $className');
  }

  try {
    var r0 = await DBProvider.db.allEditableAttendance();
    if (kDebugMode) {
      print('r0');
      // print(r0.toString());
    }

    var resQ =
        await DBProvider.db.isEditableAttendanceDate(selectedDate, className);

    if (kDebugMode) {
      // print(resQ.toString());
    }

    if (resQ.isNotEmpty) {
      var resL = resQ.toList();

      if (resL.isNotEmpty) {
        var record = resL[0];

        var editable = record['editable'];
        var synced = record['synced'];

        if (editable == "true" && synced == "false") {
          return record;
        } else {
          return canNotEdit;
        }
      }
    } else {
      return canNotEdit;
    }
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
    return canNotEdit;
  }
}
// check if attendance record exists for selected date(format YYYY-MM-DD) end

// check if numeric record exists for selected date(format YYYY-MM-DD)
Future<dynamic> editOrCreateNewNumeric(
    String selectedDate, String className) async {
  var canNotEdit = {"edit": "no"};

  try {
    var resQ =
        await DBProvider.db.isEditableNumericeDate(selectedDate, className);

    if (resQ.isNotEmpty) {
      var resL = resQ.toList();

      if (resL.isNotEmpty) {
        var record = resL[0];

        var editable = record['editable'];
        var synced = record['synced'];

        if (editable == "true" && synced == "false") {
          return record;
        } else {
          return canNotEdit;
        }
      }
    } else {
      return canNotEdit;
    }
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
    return canNotEdit;
  }
}
// check if numeric record exists for selected date(format YYYY-MM-DD) end

// check if basic record exists for selected date(format YYYY-MM-DD)
Future<dynamic> editOrCreateNewBasic(
    String selectedDate, String className, String language) async {
  var canNotEdit = {"edit": "no"};

  try {
    var resQ = await DBProvider.db
        .isEditableBasicDate(selectedDate, className, language);

    if (resQ.isNotEmpty) {
      var resL = resQ.toList();

      if (resL.isNotEmpty) {
        var record = resL[0];

        var editable = record['editable'];
        var synced = record['synced'];

        if (editable == "true" && synced == "false") {
          return record;
        } else {
          return canNotEdit;
        }
      }
    } else {
      return canNotEdit;
    }
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
    return canNotEdit;
  }
}
// check if basic record exists for selected date(format YYYY-MM-DD) end

// check if pace record exists for selected date(format YYYY-MM-DD)
Future<dynamic> editOrCreateNewPace(
    String selectedDate, String assessmentName, String className) async {
  var canNotEdit = {"edit": "no"};

  try {
    var resQ = await DBProvider.db
        .isEditablePaceDate(selectedDate, assessmentName, className);

    if (resQ.isNotEmpty) {
      var resL = resQ.toList();

      if (resL.isNotEmpty) {
        var record = resL[0];

        var editable = record['editable'];
        var synced = record['synced'];

        if (editable == "true" && synced == "false") {
          return record;
        } else {
          return canNotEdit;
        }
      }
    } else {
      return canNotEdit;
    }
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
    return canNotEdit;
  }
}
// check if pace record exists for selected date(format YYYY-MM-DD) end

Future<dynamic> readAllAttendanceActive(
    startDateUnformat, endDateUnformat) async {
  try {
    String startDate = DateFormat('yyyy-MM-dd').format(startDateUnformat),
        endDate = DateFormat('yyyy-MM-dd').format(endDateUnformat);

    var res =
        await DBProvider.db.readAllAttendanceDateRange(startDate, endDate);

    if (kDebugMode) {
      log(res.toString());
    }

    return res;
  } catch (e) {
    // log('konm');
    log(e.toString());
  }
}

Future<dynamic> saveLeaveRequestToDB(
    fromDate, toDate, days, leaveType, reason) async {
  try {
    // get teacher Id and use it as leaveTeacherId
    // get leave type id using sql query to match the selected leave type
    // save to db using dynamic insert

  } catch (e) {
    if (kDebugMode) {
      log(e.toString());
    }
  }
}
