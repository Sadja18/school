// ignore_for_file: avoid_print, unused_local_variable, empty_catches

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/database_handler.dart';
import '../models/urlPaths.dart' as uri_paths;

const resultMap = {
  'noacc': 'Not Achieved',
  'noeval': 'Not Evaluated',
  'acc': 'Achieved'
};

Future<dynamic> sendTestRequest() async {
  try {
    var response = await http
        .get(Uri.parse(uri_paths.baseURL + uri_paths.checkIfOnline + '?get=1'));

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
    return response;
  } catch (e) {
    return e;
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
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchRelevantData,
        queryParameters: queryParams);
    if (kDebugMode) {
      print('sending persistent');
    }
    var yearResp = await http.get(Uri(
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchYear,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending year');
    }
    var teacherResp = await http.get(Uri(
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchTeacher,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending teacher');
    }
    var schoolResp = await http.get(Uri(
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchSchool,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending school');
    }
    var classResp = await http.get(Uri(
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchClasses,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending class');
    }
    var studentsResp = await http.get(Uri(
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchStudents,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending students');
    }
    var languagesResp = await http.get(Uri(
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchLanguages,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending languages');
    }
    var readingLevelResp = await http.get(Uri(
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchReadingLevels,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending reading');
    }
    var numericLevelResp = await http.get(Uri(
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchNumericLevels,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending numeric');
    }
    var assessmentsResp = await http.get(Uri(
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchAssessments,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending assessment');
    }
    var qPaperResp = await http.get(Uri(
        scheme: 'http',
        host: uri_paths.baseURLA,
        path: uri_paths.fetchQPapers,
        queryParameters: queryParams));
    if (kDebugMode) {
      print('sending grading');
    }
    var gradingResp = await http.get(Uri(
        scheme: 'http',
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
        print(grading.toString());
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
        scheme: 'http',
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
        scheme: 'http',
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
        if (response.statusCode == 200 || response.statusCode == '200') {
          print(response.body.runtimeType);
          var resp = jsonDecode(response.body);
          log(resp.toString());
        }
      }
      DBProvider.db.updateAttendance();
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
            var levelIdQ =
                await DBProvider.db.getNumericLevelId(className, levelName);
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
        print('hgh');
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
              DBProvider.db.updateNumericAssessment(cN, d);
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

      var scheduledDate = assessment['scheduledDate'];
      var uploadDate = assessment['uploadDate'];
      var className = assessment['class_name'];
      var classesQ = await DBProvider.db.getClassId(className);

      var classes = classesQ.toList();
      var classId = classes[0]['class_id'];

      var markSheet = jsonDecode(assessment['marksheet']);
      var result = jsonDecode(assessment['result']);

      var entries = [];

      var studentIds = markSheet.keys.toList();
      var keys = assessment.keys.toList();

      var asVal = await DBProvider.db
          .getTotalMarksPace(assessmentName, scheduledDate, qpCode);

      var subjectId = asVal.toList()[0]['subject_id'];
      // print(subjectId);
      var totmarkS = asVal.toList()[0]['totmarks'];
      // print(totmarks.runtimeType);
      var standardId = asVal.toList()[0]['standard_id'];

      var mediumId = asVal.toList()[0]['medium_id'];

      var assessmentId = asVal.toList()[0]['id'];
      if (int.tryParse(totmarkS) != null) {
        var totmarks = int.parse(totmarkS);
        for (var id in studentIds) {
          var res = resultKeyGen(result[id]);
          var record = {};

          if (res == 'acc' || res == 'noacc') {
            var marks = markSheet[id];
            // print(id);
            // print(marks);

            num sumOfMarks = 0;
            for (num mark in marks) {
              sumOfMarks = sumOfMarks + mark;
            }

            if (sumOfMarks <= totmarks) {
              var percentage = (sumOfMarks / totmarks) * 100;

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
      print(requestBOdy);
      print('sending body pace');

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

        DBProvider.db.updatePace();
      }
    }
  } catch (e) {}
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
