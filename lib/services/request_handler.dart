// ignore_for_file: avoid_print, unused_local_variable, empty_catches

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/database_handler.dart';
import '../models/urlPaths.dart' as uri_paths;

const resultMap = {
  'noacc': 'Not Achieved',
  'noeval': 'Not Evaluated',
  'acc': 'Achieved'
};
const defaultString =
    "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";

Future<dynamic> sendTestRequest() async {
  try {
    var response = await http.get(
        Uri.parse('${uri_paths.baseURL}${uri_paths.checkIfOnline}?get=1'));

    return response;
  } on Exception catch (e) {
    return e;
  }
}

Future<dynamic> tryLogin(String username, String userpassword) async {
  try {
    var response = await http.post(
      Uri.parse('${uri_paths.baseURL}${uri_paths.onlineLogin}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user': username,
        'password': userpassword,
        'dbname': 'doednhdd'
      }),
    );
    // return response;
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['user'] != null &&
          data['user'].isNotEmpty &&
          data['userID'] != null) {
        Map<String, Object> dbEntry = {
          "userName": data['user'].toString(),
          "userPassword": data['password'].toString(),
          "dbname": data['dbname'].toString(),
          "loginstatus": data['login_status'],
          "userID": data['userID'],
          "isHeadMaster": data['headMaster'].toString(),
          "schoolId": data['schoolId'],
          "isOnline": 1,
        };
        if (kDebugMode) {
          log("dbENtry");
          log(dbEntry.toString());
        }
        await DBProvider.db.dynamicInsert("users", dbEntry);
        return 1;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  } catch (e) {
    if (kDebugMode) {
      log("error in online login");
      log(e.toString());
    }
    return 0;
  }
}

Future<void> fetchPersistent() async {
  try {
    var value = await DBProvider.db.getCredentials();
    final userName = value[0]['userName'];
    final userPassword = value[0]['userPassword'];
    final dbname = value[0]['dbname'];

    Map<String, String> queryParams = {
      'userName': userName as String,
      'userPassword': userPassword as String,
      'dbname': dbname as String,
      'Persistent': '1',
    };
    var requestURL = Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchRelevantData,
        queryParameters: queryParams);
    if (kDebugMode) {
      print('sending persistent');
    }
    var yearResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchYear,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending year');
    }
    var teacherResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchTeacher,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending teacher');
    }
    var schoolResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchSchool,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending school');
    }
    var classResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchClasses,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending class');
    }
    var studentsResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchStudents,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending students');
    }
    var languagesResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchLanguages,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending languages');
    }
    var readingLevelResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchReadingLevels,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending reading');
    }
    var numericLevelResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchNumericLevels,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending numeric');
    }
    var assessmentsResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchAssessments,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending assessment');
    }
    var qPaperResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchQPapers,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending grading');
    }
    var gradingResp = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchGrading,
        queryParameters: queryParams));

    if (gradingResp.statusCode == 200 &&
        qPaperResp.statusCode == 200 &&
        assessmentsResp.statusCode == 200 &&
        numericLevelResp.statusCode == 200 &&
        readingLevelResp.statusCode == 200 &&
        languagesResp.statusCode == 200 &&
        studentsResp.statusCode == 200 &&
        classResp.statusCode == 200 &&
        schoolResp.statusCode == 200 &&
        teacherResp.statusCode == 200 &&
        yearResp.statusCode == 200) {
      var year = jsonDecode(yearResp.body);
      var teacher = jsonDecode(teacherResp.body);
      var school = jsonDecode(schoolResp.body);
      var classes = jsonDecode(classResp.body);
      var students = jsonDecode(studentsResp.body);
      var languages = jsonDecode(languagesResp.body);
      var readingLevels = jsonDecode(readingLevelResp.body);
      var numericLevels = jsonDecode(numericLevelResp.body);
      var assessments = jsonDecode(assessmentsResp.body);
      var qPaper = jsonDecode(qPaperResp.body);
      var grading = jsonDecode(gradingResp.body);
      if (kDebugMode) {
        print('persistent fetched');
        print(classes.toString());
        print(year['academic_year'] != null &&
            classes['classes'] != null &&
            teacher['teacher'] != null &&
            school['school'] != null &&
            students['students'] != null &&
            languages['languages'] != null &&
            readingLevels['reading_levels'] != null &&
            numericLevels['numeric_levels'] != null &&
            qPaper['qpapers'] != null &&
            grading['grading'] != null &&
            assessments['assessments'] != null);
        // assessments can be empty
      }

      if (year['academic_year'] != null &&
          classes['classes'] != null &&
          teacher['teacher'] != null &&
          school['school'] != null &&
          students['students'] != null &&
          languages['languages'] != null &&
          readingLevels['reading_levels'] != null &&
          numericLevels['numeric_levels'] != null &&
          qPaper['qpapers'] != null &&
          grading['grading'] != null &&
          assessments['assessments'] != null) {
        if (kDebugMode) {
          print('persistent fetched');
          // print(grading);
          // assessments can be empty
        }

        await DBProvider.db.saveFetchedData(
            year['academic_year'],
            teacher['teacher'],
            school['school'],
            classes['classes'],
            students['students'],
            assessments['assessments'],
            grading['grading'],
            qPaper['qpapers'],
            readingLevels['reading_levels'],
            numericLevels['numeric_levels'],
            languages['languages']);
      } else {
        if (kDebugMode) {
          print('null body');
          // print("year['academic_year'] != null");
          // print(year['academic_year'] != null);

          // print("classes['classes'] != null");
          // print(classes['classes'] != null);

          // print("teacher['teacher'] != null");
          // print(teacher['teacher'] != null);

          // print("school['school'] != null");
          // print(school['school'] != null);

          // print("students['students'] != null");
          // print(students['students'] != null);

          // print("languages['languages'] != null");
          // print(languages['languages'] != null);

          // print("readingLevels['reading_levels'] != null");
          // print(readingLevels['reading_levels'] != null);

          // print("numericLevels['numeric_levels'] != null");
          // print(numericLevels['numeric_levels'] != null);

          // print("qPaper['qpapers'] != null");
          // print(qPaper['qpapers'] != null);

          // print("grading['grading'] != null");
          // print(grading['grading'] != null);

          // print("assessments['assessments'] != null");
          // print(assessments['assessments'] != null);
        }
      }
    } else {
      if (kDebugMode) {
        print('some not 200 statuscode');
        // print("gradingResp.statusCode == 200");

        // print(gradingResp.statusCode == 200);
        // print("qPaperResp.statusCode == 200");

        // print(qPaperResp.statusCode == 200);
        // print("assessmentsResp.statusCode == 200");

        // print(assessmentsResp.statusCode == 200);
        // print("numericLevelResp.statusCode == 200");

        // print(numericLevelResp.statusCode == 200);
        // print("readingLevelResp.statusCode == 200");

        // print(readingLevelResp.statusCode == 200);
        // print("languagesResp.statusCode == 200");

        // print(languagesResp.statusCode == 200);
        // print("studentsResp.statusCode == 200");

        // print(studentsResp.statusCode == 200);
        // print("classResp.statusCode == 200");

        // print(classResp.statusCode == 200);
        // print("schoolResp.statusCode == 200");

        // print(schoolResp.statusCode == 200);
        // print("teacherResp.statusCode == 200");

        // print(teacherResp.statusCode == 200);
        // print("yearResp.statusCode == 200");

        // print(yearResp.statusCode == 200);
      }
    }
    await fetchLeaveTypeAndRequests();
  } catch (e) {
    // return e;
    if (kDebugMode) {
      log(e.toString());
    }
  }
}

Future<void> fetchLeaveTypeAndRequests() async {
  try {
    var value = await DBProvider.db.getCredentials();
    final userName = value[0]['userName'];
    final userPassword = value[0]['userPassword'];
    final dbname = value[0]['dbname'];

    Map<String, String> queryParams = {
      'userName': userName as String,
      'userPassword': userPassword as String,
      'dbname': dbname as String,
      'Persistent': '1',
    };

    if (kDebugMode) {
      print('sending fetch leave types');
    }
    var leaveTypesResponse = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchLeaveTypes,
        queryParameters: queryParams));

    if (kDebugMode) {
      // log('response leave type ${leaveTypesResponse.statusCode}');
      // log(leaveTypesResponse.body.toString());
    }
    if (leaveTypesResponse.statusCode == 200) {
      var respBody = jsonDecode(leaveTypesResponse.body);
      if (respBody['message'] != null &&
          respBody['message'].toString().toLowerCase() == 'success' &&
          respBody['leaveTypes'] != null &&
          respBody['leaveTypes'].isNotEmpty) {
        var leaveTypes = respBody['leaveTypes'];
        for (var leaveType in leaveTypes) {
          var id = leaveType['id'];
          var name = leaveType['name'];
          Map<String, Object> leaveTypeEntry = {
            "leaveTypeId": id,
            "leaveTypeName": name,
          };

          await DBProvider.db
              .dynamicInsert("TeacherLeaveAllocation", leaveTypeEntry);
        }
      }
    }
    if (kDebugMode) {
      print('sending fetch leave requests');
      log(queryParams.toString());
    }

    var leaveRequestResponse = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchLeaveRequests,
        queryParameters: queryParams));

    if (leaveRequestResponse.statusCode == 200) {
      if (kDebugMode) {
        print('leave');
        log(leaveRequestResponse.body.toString());
      }
      var respBody = jsonDecode(leaveRequestResponse.body);
      if (respBody['message'].toString().toLowerCase() == "success") {
        var leaveRequests = respBody['teacherLeaveRequests'];

        if (leaveRequests.isNotEmpty) {
          for (var leaveRequest in leaveRequests) {
            var leaveRequestId = leaveRequest['id'];

            var leaveRequestTeacher = leaveRequest['staff_id'];

            int leaveRequestTeacherId = 0;
            String leaveRequestTeacherName = "";
            if (leaveRequestTeacher.isNotEmpty) {
              leaveRequestTeacherId = leaveRequestTeacher[0];
              leaveRequestTeacherName = leaveRequestTeacher[1].toString();
            }

            var leaveType = leaveRequest['name'];

            String leaveTypeName = "";
            int leaveTypeId = 0;
            if (leaveType.isNotEmpty && leaveType.length == 2) {
              leaveTypeId = leaveType[0];
              leaveTypeName = leaveType[1].toString();
            }
            if (kDebugMode) {
              log('5');
            }

            String leaveFromDate = leaveRequest['start_date'];

            String leaveToDate = leaveRequest['end_date'];

            String leaveDays = leaveRequest['days'].toString();

            String leaveReason = leaveRequest['reason'];
            String leaveRequestStatus = leaveRequest['state'];

            Map<String, Object> data = {};
            data['leaveRequestId'] = leaveRequestId;
            data['leaveRequestTeacherId'] = leaveRequestTeacherId;
            data['leaveTypeId'] = leaveTypeId;
            data['leaveTypeName'] = leaveTypeName;
            data['leaveFromDate'] = leaveFromDate;
            data['leaveToDate'] = leaveToDate;
            data['leaveDays'] = leaveDays;
            data['leaveReason'] = leaveReason;
            data['leaveRequestStatus'] = leaveRequestStatus;
            data['leaveRequestEditable'] = 'true';

            await DBProvider.db.dynamicInsert("TeacherLeaveRequest", data);
          }
        }
      }
    }
  } catch (e) {
    log("error fetch leave types");
    log(e.toString());
  }
}

Future<void> attendanceSyncHandler(attendanceRecordQuery) async {
  try {
    var valueQ = await DBProvider.db.getCredentials();
    var value = valueQ.toList();
    final userName = value[0]['userName'];
    final userPassword = value[0]['userPassword'];
    final dbname = value[0]['dbname'];

    var schoolsQ = await DBProvider.db.getSchool();
    var schools = schoolsQ.toList();

    var school = schools[0];
    var schoolId = school['school_id'];
    var schoolName = school['school_name'];
    var attendanceRecords = attendanceRecordQuery.toList();

    var responses = [];
    for (var attendance in attendanceRecords) {
      var className = attendance['class_name'];
      var classIdQ = await DBProvider.db.getClassId(className);
      var teacherIdQ = await DBProvider.db.getTeacherId();
      var classId = classIdQ.toList();
      var teacherId = teacherIdQ.toList();
      var submissionDate = attendance['submission_date'];

      var absentees = attendance['absenteeString'];

      Map<String, dynamic> queryParams = {
        'userName': userName as String,
        'userPassword': userPassword as String,
        'dbname': dbname as String,
        'date': attendance['date'],
        'className': className,
        'classId': classId[0]['class_id'],
        'teacherId': teacherId[0]['teacher_id'],
        'submissionDate': submissionDate,
        'absentees': absentees,
        'schoolId': schoolId,
        'schoolName': schoolName,
        'sync': '1'
      };
      if (kDebugMode) {
        log(queryParams.toString());
      }
      // print(attendance['class_name']);
      var body = jsonEncode(queryParams);
      print('sending request to sync attendance');
      var a = await http.post(
        Uri.parse('${uri_paths.baseURL}${uri_paths.syncAttendance}'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      responses.add(a);
    }

    if (responses.isNotEmpty) {
      for (var response in responses) {
        print(response.statusCode);
        print("response loop");
        if (response.statusCode == 200 || response.statusCode == '200') {
          print(response.body.runtimeType);
          var resp = jsonDecode(response.body);
          log(resp.toString());
        }
      }
      await DBProvider.db.updateAttendance();
    }
  } catch (e) {}
}

String resultKeyGen(resultName) {
  switch (resultName) {
    case 'Achieved':
      return 'acc';
    case 'Not Achieved':
      return 'noacc';

    case 'Not Evaluated':
      return 'noeval';

    default:
      return 'noeval';
  }
}

Future<void> numericSyncHandler(assessmentRecords) async {
  try {
    print('user 1 numeric');
    DBProvider.db.getCredentials().then((usersQ) async {
      var users = usersQ.toList();
      print('school 1');
      var schoolQ = await DBProvider.db.getSchool();
      var schools = schoolQ.toList();
      // print(schools);

      var school = schools[0];
      var schoolId = school['school_id'];
      var schoolName = school['school_name'];
      print('teacher 1');
      var teacherIdQ = await DBProvider.db.getTeacherId();
      var teacherIds = teacherIdQ.toList();
      var teacherId = teacherIds[0]['teacher_id'];

      final userName = users[0]['userName'];
      final userPassword = users[0]['userPassword'];
      final dbname = users[0]['dbname'];

      print('for 1');
      var responses = [];

      for (var assessment in assessmentRecords) {
        print('sending numeric request');

        // print('request');
        var className = assessment['class_name'];
        var classesQ = await DBProvider.db.getClassId(className);

        var classes = classesQ.toList();
        var classId = classes[0]['class_id'];

        var date = assessment['date'];
        var submissionDate = assessment['submission_date'];
        var entries = assessment['stringData'];
        var decodedEntries = jsonDecode(entries);
        print('here');
        for (var index = 0; index < decodedEntries.length; index++) {
          var entry = decodedEntries[index];
          var studentID = entry.keys.toList()[0];
          var levelName = entry[studentID][0];
          var resultName = entry[studentID][1];
          var result = resultKeyGen(resultName);
          if (levelName != '0' && resultName != 'Not Evaluated') {
            var levelIdQ = await DBProvider.db
                .getNumericLevelId(className, levelName);
            var levelId = levelIdQ.toList()[0]['levelId'];

            decodedEntries[index][studentID][0] = levelId;
            decodedEntries[index][studentID][1] = result;
          } else {
            decodedEntries[index][studentID][1] = result;
          }
        }
        Map<String, dynamic> body = {
          'userName': userName,
          'userPassword': userPassword,
          'dbname': dbname,
          'date': date,
          'className': className,
          'classId': classId,
          'teacherId': teacherId,
          'schoolId': schoolId,
          'schoolName': schoolName,
          'submissionDate': submissionDate,
          'entries': decodedEntries,
          'numeric': '1'
        };

        var requestBOdy = jsonEncode(body);
        if (kDebugMode) {
          print('hgh');

          print(requestBOdy);
        }
        // print(requestBOdy);
        var response = await http.post(
            Uri.parse('${uri_paths.baseURL}${uri_paths.syncAssessment}'),
            headers: {'Content-Type': 'application/json'},
            body: requestBOdy);
        responses.add(response);
      }
      if (responses.isNotEmpty) {
        for (var response in responses) {
          print(response.statusCode);
          if (response.statusCode == 200 || response.statusCode == '200') {
            print(response.body.runtimeType);
            print(response.body.toString());
            var resp = jsonDecode(response.body);
            if (resp['classId'] != null &&
                resp['date'] != null &&
                resp['stringData'] != null) {
              var cN = resp['classId'];
              var d = resp['date'];
              var stringData = resp['stringData'];
              for (var i = 0; i < stringData.length; i++) {
                var stringRecord = stringData[i];
                var sId = stringRecord.keys.toList()[0];
                var levelId = int.parse(stringRecord[sId][0]);
                var levelName = '0';
                var result = resultMap[stringRecord[sId][1]];
                if (levelId != 0) {
                  var levelNameQ =
                      await DBProvider.db.getNumericLevelName(levelId);
                  // levelName = levelNameQ.toList();
                  levelName = levelNameQ.toList()[0]['name'];
                  // print(levelName);
                }
                stringData[i][sId] = [levelName, result];
              }
              await DBProvider.db.updateNumericAssessment(cN, d);
            } else {
              print('fault');
              print(resp);
            }
          }
        }
      }
    });
  } catch (e) {}
}

Future<void> basicSyncHandler(assessmentRecords) async {
  try {
    print('user 1 basic');
    var usersQ = await DBProvider.db.getCredentials();
    var users = usersQ.toList();
    print('school 1');
    var schoolQ = await DBProvider.db.getSchool();
    var schools = schoolQ.toList();

    var school = schools[0];
    var schoolId = school['school_id'];
    var schoolName = school['school_name'];
    print('teacher 1');
    var teacherIdQ = await DBProvider.db.getTeacherId();
    var teacherIds = teacherIdQ.toList();
    var teacherId = teacherIds[0]['teacher_id'];

    final userName = users[0]['userName'];
    final userPassword = users[0]['userPassword'];
    final dbname = users[0]['dbname'];

    print('for 1');
    var responses = [];

    for (var assessment in assessmentRecords) {
      // print(assessment.toString());
      print('sending basic request');

      var date = assessment['date'];
      var className = assessment['class_name'];
      var classesQ = await DBProvider.db.getClassId(className);

      var classes = classesQ.toList();
      var classId = classes[0]['class_id'];
      var languageName = assessment['language'];
      var langId = "";
      var langIdQ = await DBProvider.db.getLangId(languageName, className);

      if (langIdQ.toList()[0]['langId'] != null) {
        langId = langIdQ.toList()[0]['langId'];
      }
      var entries = assessment['stringData'];

      var decodedEntries = jsonDecode(entries);
      for (var index = 0; index < decodedEntries.length; index++) {
        var entry = decodedEntries[index];
        var studentID = entry.keys.toList()[0];
        var levelName = entry[studentID][0];
        var resultName = entry[studentID][1];
        var result = resultKeyGen(resultName);
        if (levelName != '0' && resultName != 'Not Evaluated') {
          var levelIdQ = await DBProvider.db
              .getBasicLevelId(className, languageName, levelName);
          var levelId = levelIdQ.toList()[0]['levelId'];

          decodedEntries[index][studentID][0] = levelId;
          decodedEntries[index][studentID][1] = result;
        } else {
          decodedEntries[index][studentID][1] = result;
        }
      }
      Map<String, dynamic> body = {
        'userName': userName as String,
        'userPassword': userPassword as String,
        'dbname': dbname as String,
        'date': date,
        'classId': classId,
        'className': className,
        'teacherId': teacherId,
        'schoolId': schoolId,
        'schoolName': schoolName,
        'language': languageName,
        'langId': langId,
        'entries': decodedEntries,
        'basic': '1'
      };
      var requestBOdy = jsonEncode(body);
      // print(requestBOdy);

      var response = await http.post(
          Uri.parse('${uri_paths.baseURL}${uri_paths.syncAssessment}'),
          headers: {'Content-Type': 'application/json'},
          body: requestBOdy);
      responses.add(response);
    }
    if (responses.isNotEmpty) {
      for (var response in responses) {
        print(response.statusCode);
        if (response.statusCode == 200 || response.statusCode == '200') {
          print('aay');
          // print(response.body.runtimeType);
          var resp = jsonDecode(response.body);

          var rc = resp['rc'];

          if (rc != null) {
            print('aay4');
            var classId = resp['classId'];
            var date = resp['date'];
            var language = resp['langauge'];
            var langId = resp['langId'];
            var stringData = resp['stringData'];
            if (classId != null &&
                date != null &&
                language != null &&
                stringData != null) {
              DBProvider.db.updateBasicAssessment(classId, language, date);
            }
          }
        }
      }
    }
  } catch (e) {}
}

Future<void> paceSyncHandler(assessmentRecords) async {
  try {
    print('user 1 pace');
    var usersQ = await DBProvider.db.getCredentials();
    var users = usersQ.toList();
    print('school 1');
    var schoolQ = await DBProvider.db.getSchool();
    var schools = schoolQ.toList();

    var school = schools[0];
    var schoolId = school['school_id'];
    var schoolName = school['school_name'];
    print('teacher 1');
    var teacherIdQ = await DBProvider.db.getTeacherId();
    var teacherIds = teacherIdQ.toList();
    var teacherId = teacherIds[0]['teacher_id'];

    final userName = users[0]['userName'];
    final userPassword = users[0]['userPassword'];
    final dbname = users[0]['dbname'];

    print('for 1');
    var responses = [];

    for (var assessmentQ in assessmentRecords) {
      print('sending pace request');
      var assessment = {};
      assessmentQ.forEach((k, v) => assessment[k] = v);
      // print(assessment.runtimeType);

      var assessmentName = assessment['assessmentName'];
      var subjectName = assessment['subject_name'];
      var mediumName = assessment['medium_name'];
      var qpCode = assessment['qp_code'];

      // if (kDebugMode) {
      //   print("pace 1");
      // }

      var scheduledDate = assessment['scheduledDate'];
      var uploadDate = assessment['uploadDate'];
      var className = assessment['class_name'];
      var classesQ = await DBProvider.db.getClassId(className);
      // if (kDebugMode) {
      //   print("pace 11");
      // }
      var classes = classesQ.toList();
      var classId = classes[0]['class_id'];
      // if (kDebugMode) {
      //   print("pace 12");
      // }
      var markSheet = jsonDecode(assessment['marksheet']);
      var result = jsonDecode(assessment['result']);
      // if (kDebugMode) {
      //   print("pace 13");
      // }
      var entries = [];

      var studentIds = markSheet.keys.toList();
      var keys = assessment.keys.toList();
      // if (kDebugMode) {
      //   print("pace 14");
      // }
      var asVal = await DBProvider.db
          .getTotalMarksPace(assessmentName, scheduledDate, qpCode);
      // if (kDebugMode) {
      //   print("pace 5");
      // }
      var subjectId = asVal.toList()[0]['subject_id'];
      // print(subjectId);
      var totmarkS = asVal.toList()[0]['totmarks'];
      // print(totmarks.runtimeType);
      var standardId = asVal.toList()[0]['standard_id'];

      var mediumId = asVal.toList()[0]['medium_id'];
      // if (kDebugMode) {
      //   print("pace 16");
      // }
      var assessmentId = asVal.toList()[0]['id'];
      // if (kDebugMode) {
      //   print("pace 1 $totmarkS");
      // }
      if (int.tryParse(totmarkS) != null) {
        var totmarks = int.parse(totmarkS);
        // if (kDebugMode) {
        //   print("pace 18 $studentIds");
        // }
        for (var id in studentIds) {
          var res = resultKeyGen(result[id]);
          // if (kDebugMode) {
          //   print("pace 1 $res");
          // }
          var record = {};
          // int sumOfMarks = int.parse(markSheet[id]);

          if (kDebugMode) {
            print(('vdbkhsdfjbvjsfd'));
            print("pres ${totmarks.runtimeType}");
            // print(int.parse(markSheet[id]));
            print("more");

            // print("pres ${markSheet[id].runtimeType}");
          }

          if (res == 'acc' || res == 'noacc') {
            var sumOfMarksString = markSheet[id];
            int sumOfMarks = double.parse(sumOfMarksString).toInt();
            // var
            if (kDebugMode) {
              print("pres ${sumOfMarks <= totmarks}");
            }
            // print(id);
            // print(marks);

            // num sumOfMarks = 0;
            // for (num mark in marks) {
            //   sumOfMarks = sumOfMarks + mark;
            // }

            if (sumOfMarks <= totmarks) {
              var percentage = (sumOfMarks / totmarks) * 100;
              if (kDebugMode) {
                print("pace 1 $percentage");
              }

              record['sId'] = id;
              record['res'] = res;
              record['sum'] = sumOfMarks;
              record['percentage'] = percentage;

              entries.add(record);
            }
          }
        }
      }

      Map<String, dynamic> body = {
        'pace': '1',
        'userName': userName as String,
        'userPassword': userPassword as String,
        'dbname': dbname as String,
        'scheduledDate': scheduledDate,
        'uploadDate': uploadDate,
        'classId': classId,
        'schoolId': schoolId,
        'teacherId': teacherId,
        'className': className,
        'standardId': standardId,
        'assessmentName': assessmentName,
        'assessmentId': assessmentId,
        'subjectId': subjectId,
        'mediumName': mediumName,
        'mediumId': mediumId,
        'qpCode': qpCode,
        'entries': entries
      };
      var requestBOdy = jsonEncode(body);

      if (kDebugMode) {
        log(requestBOdy.toString());
        log(assessmentRecords.toString());
      }

      var response = await http.post(
          Uri.parse('${uri_paths.baseURL}${uri_paths.syncAssessment}'),
          headers: {'Content-Type': 'application/json'},
          body: requestBOdy);
      responses.add(response);
    }
    if (responses.isNotEmpty) {
      for (var response in responses) {
        print(response.statusCode);
        if (response.statusCode == 200 || response.statusCode == '200') {
          print(response.body.runtimeType);
          print(response.body.toString());
        }

        await DBProvider.db.updatePace();
      }
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<void> leaveRequestSyncHandler(leaveRequests) async {
  try {
    var usersQ = await DBProvider.db.getCredentials();
    var users = usersQ.toList();
    final userName = users[0]['userName'];
    final userPassword = users[0]['userPassword'];
    final dbname = users[0]['dbname'];
    var schoolQ = await DBProvider.db.getSchool();
    var schools = schoolQ.toList();

    var school = schools[0];
    var schoolId = school['school_id'];

    var teacherIdQ = await DBProvider.db.getTeacherId();
    var teacherIds = teacherIdQ.toList();
    var teacherId = teacherIds[0]['teacher_id'];
    if (kDebugMode) {
      print("here");
      print(teacherId);
      print(schoolId);
      print(leaveRequests.toString());
    }

    var requestBody = {
      "userName": userName,
      "userPassword": userPassword,
      "dbname": dbname,
      "schoolId": schoolId,
      "teacherId": teacherId,
      "sync": 1
    };
    var responses = [];

    for (var leaveRequest in leaveRequests) {
      var leaveTypeId = leaveRequest['leaveTypeId'];
      var startDate = leaveRequest['leaveFromDate'];
      var endDate = leaveRequest['leaveToDate'];
      var days = leaveRequest['leaveDays'];
      var reason = leaveRequest['leaveReason'];
      var state = leaveRequest['leaveRequestStatus'];

      requestBody['leaveTypeId'] = leaveTypeId;
      requestBody['start_date'] = startDate;
      requestBody['end_date'] = endDate;
      requestBody['reason'] = reason;
      requestBody['days'] = double.parse(days).toInt();

      if (kDebugMode) {
        print("o");
        print(requestBody.toString());
      }

      var response = await http.post(
          Uri.parse('${uri_paths.baseURL}${uri_paths.syncLeaveRequest}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          log(response.body);
        }
        responses.add(response.statusCode);
      }
    }
    await DBProvider.db.updateLeave();
  } catch (e) {
    log(e.toString());
  }
}

// headmaster mode

// fetch teacher profile
Future<void> fetchTeacherProfileFromServerHeadMasterMode() async {
  try {
    var value = await DBProvider.db.getCredentials();
    final userName = value[0]['userName'];
    final userPassword = value[0]['userPassword'];
    final dbname = value[0]['dbname'];

    Map<String, String> queryParams = {
      'userName': userName as String,
      'userPassword': userPassword as String,
      'dbname': dbname as String,
      'Persistent': '1',
    };
    if (kDebugMode) {
      log(queryParams.toString());
    }
    var requestURL = Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchTeacherProfiles,
        queryParameters: (queryParams));
    if (kDebugMode) {
      print('sending persistent');
      // log()
    }

    var response = await http.get(requestURL);
    if (kDebugMode) {
      log(response.statusCode.toString());
      // log(response.body);
    }

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(requestURL);
        log("response.bod");
        print('persistent fetched');
        log(response.body);
        // assessments can be empty
      }
      var resp = jsonDecode(response.body);
      var teachers = resp['teachers'];

      // if (kDebugMode) {
      //   log(teachers[0].toString());
      // }
      var index = 0;
      for (var teacher in teachers) {
        var teacherId = teacher['id'];
        var teacherName = teacher['name'];
        var school = teacher['school_id'];
        // var schoolId = -1;
        // var schoolName = "";
        var emp = teacher['employee_id'];
        var teacherCode = teacher['teacher_code'];
        var user = teacher['user_id'];
        var profilePic =
            teacher['photo'] != null && teacher['photo'] != false
                ? teacher['photo']
                : defaultString;

        if (kDebugMode) {
          log("null check");
          var a = school != null &&
              school != false &&
              emp != null &&
              emp != false &&
              user != null &&
              user != false &&
              user.runtimeType == List &&
              school.runtimeType == List &&
              emp.runtimeType == List;
          if (a == false) {
            log("1\n2\n3");
            log("print a $a");
            log('teacher name is ${teacherId.toString()}');

            log('teacher name is ${teacherName.toString()}');
            log('school is ${school.toString()}');

            log("(school != null).toString() ${(school != null).toString()}");
            log((school != false).toString());
            log('emp');
            log("(emp != null).toString() ${(emp != null).toString()}");
            log("(emp != false).toString() ${(emp != null).toString()}");
            log("print user");
            log("$user");
            log("u(user != null).toString() ${user != null}");
            log("(user.runtimeType == List).toString() ${(user.runtimeType == List).toString()}");
            log("(emp.runtimeType == List).toString() ${(emp.runtimeType == List).toString()}");
            log("1\n2\n3");
          }
        }
        if (school != null &&
            school != false &&
            emp != null &&
            emp != false &&
            user != null &&
            user != false &&
            user.runtimeType == List &&
            school.runtimeType == List &&
            emp.runtimeType == List) {
          var schoolId = school[0];
          var empId = emp[0];
          var userId = user[0];
          var dbEntry = <String, Object>{
            "teacherId": teacherId,
            "teacherName": teacherName,
            "schoolId": schoolId,
            "empId": empId,
            "userId": userId,
            'profilePic': profilePic,
          };

          // if (kDebugMode) {
          //   log("teacher is ${teacher['id']}");
          //   log("index is $index");
          //   index = index + 1;
          //   log("entry is $dbEntry");
          // }

          await DBProvider.db.dynamicInsert("TeacherProfile", dbEntry);
        }
      }
    } else {
      if (kDebugMode) {
        print('some not 200 statuscode');
      }
    }

    var records = await DBProvider.db.dynamicRead(
        "SELECT * FROM TeacherProfile "
        "WHERE schoolId = (SELECT schoolId FROM users WHERE loginstatus=1);",
        []);

    if (records != null && records.isNotEmpty) {
      return records;
    }
  } catch (e) {
    if (kDebugMode) {
      log(e.toString());
    }
    if (e is SocketException) {
      var records = await DBProvider.db.dynamicRead(
          "SELECT * FROM TeacherProfile "
          "WHERE schoolId = (SELECT schoolId FROM users WHERE loginstatus=1);",
          []);

      if (records != null && records.isNotEmpty) {
        return records;
      }
    }
  }
}

// fetch leave types
Future<void> fetchTeacherLeaveTypesFromServerHeadMasterMode() async {
  try {} catch (e) {
    if (kDebugMode) {
      log(e.toString());
    }
  }
}

Future<void> fetchPersistentHeadMaster() async {
  try {
    var value = await DBProvider.db.getCredentials();
    final userName = value[0]['userName'];
    final userPassword = value[0]['userPassword'];
    final dbname = value[0]['dbname'];

    Map<String, String> queryParams = {
      'userName': userName as String,
      'userPassword': userPassword as String,
      'dbname': dbname as String,
      'Persistent': '2',
    };
    var requestURL = Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchSchool,
        queryParameters: queryParams);
    if (kDebugMode) {
      log('sending fetch school');
      log(requestURL.toString());
      log(queryParams.toString());
    }

    var response = await http.get(requestURL);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        log('school fetched');
        log(response.body.toString());
        log("response can be empty");
      }
      var resp = jsonDecode(response.body);
      if (kDebugMode) {
        log("kfjehjsgjhdsgvmjgdsmj school ${response.body.runtimeType}");
      }
      var school = resp['school'];
      if (school != null && school != false) {
        await DBProvider.db.dynamicInsert("school", <String, Object>{
          'school_id': school['school_id'],
          'school_name': school['school_name'],
        });
      }
    } else {
      if (kDebugMode) {
        print('some not 200 statuscode');
      }
    }

    await fetchLeaveTypeAndRequests();
    var leaveTypesResponse = await http.get(Uri(
        scheme: "http",
        host: uri_paths.baseURLA,
        path: uri_paths.fetchLeaveTypes,
        queryParameters: queryParams));

    if (kDebugMode) {
      // log('response leave type ${leaveTypesResponse.statusCode}');
      // log(leaveTypesResponse.body.toString());
    }
    if (leaveTypesResponse.statusCode == 200) {
      var respBody = jsonDecode(leaveTypesResponse.body);
      if (respBody['message'] != null &&
          respBody['message'].toString().toLowerCase() == 'success' &&
          respBody['leaveTypes'] != null &&
          respBody['leaveTypes'].isNotEmpty) {
        var leaveTypes = respBody['leaveTypes'];
        for (var leaveType in leaveTypes) {
          var id = leaveType['id'];
          var name = leaveType['name'];
          Map<String, Object> leaveTypeEntry = {
            "leaveTypeId": id,
            "leaveTypeName": name,
          };

          await DBProvider.db
              .dynamicInsert("TeacherLeaveAllocation", leaveTypeEntry);
          await DBProvider.db.dynamicInsert("LeaveTypes", leaveTypeEntry);
        }
      }
    }

    var timeTableResponse = await http.get(
      Uri(
          scheme: "http",
          host: uri_paths.baseURLA,
          path: uri_paths.fetchTeacherTimeTable,
          queryParameters: queryParams),
    );

    if (kDebugMode) {
      log('fetch time table');
      log(timeTableResponse.statusCode.toString());
      log(timeTableResponse.body);
    }
    if (kDebugMode) {
      log(response.statusCode.toString());
      log(response.body);
    }
    if (timeTableResponse.statusCode == 200) {
      var res = jsonDecode(timeTableResponse.body);
      if (res['message'].toString().toLowerCase() == 'success') {
        var timeTable = res['timeTable'];
        for (var record in timeTable) {
          if (record['teacher_id'] != null &&
              record['teacher_id'] != false &&
              record['teacher_id'].runtimeType == List &&
              record['period'] != null &&
              record['period'] != false &&
              record['week_day'] != null &&
              record['week_day'] != false &&
              record['school_id'] != null &&
              record['school_id'] != false &&
              record['school_id'].runtimeType == List) {
            var timeTableId = record['id'];
            var period = record['period'];
            var weekDay = record['week_day'];
            var teacherId = record['teacher_id'][0];
            var schoolId = record['school_id'][0];

            var data = <String, Object>{
              "timeTableId": timeTableId,
              "teacherId": teacherId,
              "schoolId": schoolId,
              "weekDay": weekDay,
              "period": period,
            };
            await DBProvider.db.dynamicInsert("TeacherTimeTable", data);
          }
        }
      }
    }
  } catch (e) {
    // return e;
    if (kDebugMode) {
      log(e.toString());
    }
  }
}

Future<dynamic> fetchTimeTableFromLocalDB(
    teacherId, String weekDay) async {
  try {
    var query = "SELECT timeTableId, weekDay, period "
        "FROM TeacherTimeTable "
        "WHERE "
        "schoolId = ("
        "SELECT schoolId FROM users WHERE loginstatus=1"
        ") "
        "AND "
        "teacherId=? "
        "AND "
        "weekDay=?"
        ";";
    var params = [teacherId, weekDay];
    var res = await DBProvider.db.dynamicRead(query, params);

    if (res != null && res.isNotEmpty) {
      return res;
    }
  } catch (e) {
    if (kDebugMode) {
      log("er period");
      log(e.toString());
    }
  }
}

Future<dynamic> getAllTeachersWhoDontHaveSamePeriodOnSameDay(
    int thisTeacherId,
    String weekDay,
    String periodName,
    List availableTeachers) async {
  try {
    var query = "SELECT teacherId, teacherName FROM TeacherProfile WHERE "
        "teacherId=("
        "SELECT teacherId FROM TeacherTimeTable "
        "WHERE "
        "weekDay = ? AND "
        "period != ? AND "
        "teacherId !=?"
        ");";
    // List availableTeacherIds = [];
    // for (var teacher in availableTeachers) {
    //   availableTeacherIds.add(teacher['teacherId']);
    // }
    // var dumDum = "('" + availableTeacherIds.join(",") + "')";
    var params = [
      weekDay,
      periodName,
      thisTeacherId,
    ];

    var teachers = await DBProvider.db.dynamicRead(query, params);
    if (kDebugMode) {
      log("message");
      // log(teachers.toString());
    }

    if (teachers != null && teachers.isNotEmpty) {
      return teachers;
    }
  } catch (e) {
    if (kDebugMode) {
      log("er period");
      log(e.toString());
    }
  }
}
