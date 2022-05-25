// ignore_for_file: avoid_print, unused_local_variable, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import '../models/response_struct.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

final DateFormat format = DateFormat('yyyy-MM-dd');

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static const int version = 1;
  static late Database _database;
  static const dbname = 'school.db';

  Future<Database> get database async {
    // ignore: unnecessary_null_comparison
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  String _createSchoolTable() {
    return "CREATE TABLE school("
        "school_id INTEGER PRIMARY KEY,"
        "school_name TEXT);";
  }

  String _createTeacherTable() {
    return "CREATE TABLE teacher("
        "teacher_id INTEGER PRIMARY KEY,"
        "teacher_name TEXT,"
        "userID INTEGER NOT NULL"
        ");";
  }

  String _createAcademicYearTable() {
    return "CREATE TABLE academic(academic_year TEXT NOT NULL);";
  }

  String _createClassTable() {
    return "CREATE TABLE classes("
        "class_id INTEGER PRIMARY KEY,"
        "class_name TEXT,"
        "standard_id TEXT,"
        "standard_name NAME,"
        "medium_id TEXT,"
        "medium_name TEXT,"
        "division_id TEXT,"
        "division_name TEXT"
        ");";
  }

  String _createTeacherProfileTable() {
    return "CREATE TABLE TeacherProfile("
        "teacherId INTEGER PRIMARY KEY,"
        "teacherName TEXT NOT NULL,"
        "userId INTEGER NOT NULL,"
        "empId INTEGER NOT NULL,"
        "schoolId INTEGER NOT NULL,"
        "profilePic TEXT NOT NULL"
        ");";
  }

  String _createStudentTable() {
    return "CREATE TABLE students("
        "student_id INTEGER PRIMARY KEY,"
        "student_roll_no TEXT,"
        "student_name TEXT,"
        "profile_pic TEXT,"
        "class_id INTEGER NOT NULL,"
        "class_name TEXT NOT NULL);";
  }

  String _createLanguagesTable() {
    return "CREATE TABLE languages("
        "langId TEXT NOT NULL,"
        "langName TEXT NOT NULL,"
        "standard_id TEXT NOT NULL"
        ");";
  }

  String _createAttendanceTable() {
    return "CREATE TABLE attendance("
        "date TEXT NOT NULL,"
        "submission_date TEXT NOT NULL,"
        "class_name TEXT NOT NULL,"
        "absenteeString TEXT,"
        'editable TEXT DEFAULT "true" NOT NULL,'
        'synced TEXT DEFAULT "false" NOT NULL,'
        "UNIQUE(date, class_name, editable, synced)"
        ");";
  }

  // table to save the marks percentage required for passing PACE assessment
  String _createPaceGrader() {
    return "CREATE TABLE pacegrade("
        "id INTEGER PRIMARY KEY,"
        "from_marks INTEGER NOT NULL,"
        "to_marks INTEGER NOT NULL,"
        "result TEXT NOT NULL);";
  }

  // table to save Basic Reading Levels
  String _createBasicLevels() {
    return "CREATE TABLE basicLevels("
        "levelId TEXT NOT NULL,"
        "standard_id TEXT NOT NULL,"
        "name TEXT NOT NULL,"
        "subject_id TEXT NOT NULL,"
        "subject_name TEXT NOT NULL,"
        "UNIQUE(levelId, standard_id, name, subject_id, subject_name)"
        ");";
  }

  // table to save Numeric Ability Levels
  String _createNumericLevels() {
    return "CREATE TABLE numericLevels("
        "levelId TEXT NOT NULL,"
        "standard_id TEXT NOT NULL,"
        "name TEXT NOT NULL,"
        "UNIQUE(levelId, standard_id, name)"
        ");";
  }

  // table for saving scheduled PACE assessments
  String _createPaceSchedule() {
    return "CREATE TABLE paceSchedule("
        "id INTEGER PRIMARY KEY,"
        "name TEXT,"
        "subject_id TEXT,"
        "subject_name TEXT,"
        "qp_code TEXT,"
        "qp_code_name TEXT,"
        "date TEXT,"
        "standard_id TEXT,"
        "standard_name TEXT,"
        "medium_id TEXT,"
        "medium_name TEXT"
        ");";
  }

  // table for saving numeric assessment result
  String _createNumericTable() {
    return "CREATE TABLE numeric("
        "date TEXT NOT NULL,"
        "submission_date TEXT NOT NULL,"
        "class_name TEXT NOT NULL,"
        "stringData TEXT NOT NULL,"
        'editable TEXT DEFAULT "true" NOT NULL,'
        'synced TEXT DEFAULT "false" NOT NULL,'
        "UNIQUE(date, class_name, submission_date, editable, synced)"
        ");";
  }

  // table for saving basic reading assessment result
  String _createBasicTable() {
    return "CREATE TABLE basic("
        "date TEXT NOT NULL,"
        "submission_date TEXT NOT NULL,"
        "class_name TEXT NOT NULL,"
        "language TEXT NOT NULL,"
        "stringData TEXT NOT NULL,"
        'editable TEXT DEFAULT "true" NOT NULL,'
        'synced TEXT DEFAULT "false" NOT NULL,'
        "UNIQUE(date, class_name, submission_date, language, editable, synced)"
        ");";
  }

  // table to save pace assessment result
  String _createPaceTable() {
    return "CREATE TABLE pace("
        "assessmentName TEXT NOT NULL,"
        "subject_name TEXT NOT NULL,"
        "medium_name TEXT NOT NULL,"
        "qp_code TEXT NOT NULL,"
        "scheduledDate TEXT NOT NULL,"
        "uploadDate TEXT NOT NULL,"
        "class_name TEXT NOT NULL,"
        "marksheet TEXT NOT NULL,"
        "result TEXT NOT NULL,"
        'editable TEXT DEFAULT "true" NOT NULL,'
        'synced TEXT DEFAULT "false" NOT NULL,'
        "UNIQUE(assessmentName, scheduledDate, uploadDate, class_name, editable, synced)"
        ");";
  }

  // table to store qpapers
  String _createQuestionPaperTable() {
    return "CREATE TABLE qPaper("
        "id TEXT PRIMARY KEY,"
        "qp_code TEXT NOT NULL,"
        "medium_id TEXT NOT NULL,"
        "subject_id TEXT NOT NULL,"
        "standard_id TEXT NOT NULL,"
        "totques TEXT NOT NULL,"
        "totmarks TEXT NOT NULL);";
  }

  String _createTeacherLeaveTypeAllocationTable() {
    return "CREATE TABLE TeacherLeaveAllocation("
        "leaveTypeId INTEGER NOT NULL,"
        "leaveTypeName TEXT NOT NULL,"
        "leaveAllocated TEXT,"
        "leavePending TEXT DEFAULT '0',"
        "leaveAvailable TEXT DEFAULT '0',"
        "UNIQUE(leaveTypeId)"
        ");";
  }

  String _createTeacherLeaveRequestTable() {
    return "CREATE TABLE TeacherLeaveRequest("
        "leaveRequestId INTEGER,"
        "leaveRequestTeacherId INTEGER NOT NULL,"
        "leaveTypeId INTEGER NOT NULL,"
        "leaveTypeName TEXT NOT NULL,"
        "leaveAppliedDate TEXT,"
        "leaveFromDate TEXT NOT NULL,"
        "leaveToDate TEXT NOT NULL,"
        "leaveDays TEXT NOT NULL,"
        "leaveReason TEXT NOT NULL,"
        "leaveAttachment TEXT,"
        "leaveRequestStatus TEXT NOT NULL,"
        "leaveRequestEditable TEXT DEFAULT 'false',"
        "leaveRequestSynced TEXT DEFAULT 'false',"
        "UNIQUE(leaveTypeId, leaveTypeName, leaveRequestTeacherId, "
        " leaveFromDate, leaveToDate, leaveDays, leaveReason)"
        ");";
  }

  /// accessible only by headmaster login
  String _createTableTeacherLeaveType() {
    return "CREATE TABLE LeaveTypes("
        "leaveTypeId INTEGER PRIMARY KEY,"
        "leaveTypeName TEXT NOT NULL"
        ");";
  }

  // List<Map<String, String>> attendanceJSONified = [
  //   {
  //     "teacherId": "id from school.teacher",
  //     "isPresent": 'true/false',
  //     "reasonId": 'id from LeaveTypes table',
  //   },
  //   {},
  // ];
  String _createTeacherAttendanceTable() {
    return "CREATE TABLE TeacherAttendance("
        "date TEXT PRIMARY KEY,"
        "headMasterUserId INTEGER NOT NULL,"
        "totalPresent INTEGER NOT NULL,"
        "totalAbsent INTEGER NOT NULL,"
        "attendanceJSONified TEXT NOT NULL,"
        "uploadDate TEXT NOT NULL,"
        "isSynced TEXT DEFAULT 'no'"
        ");";
  }

  Future initDB() async {
    String path = join(await getDatabasesPath(), dbname);
    return await openDatabase(path, version: version, onOpen: (db) {},
        onConfigure: (Database db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    }, onCreate: (Database db, int version) async {
      var dbBatch = db.batch();
      await db.execute('PRAGMA foreign_keys = ON');
      dbBatch.execute('CREATE TABLE users('
          "userID INTEGER PRIMARY KEY,"
          "userName TEXT ,"
          "userPassword TEXT,"
          "dbname TEXT DEFAULT 'doednhdd',"
          "loginstatus INTEGER DEFAULT 0,"
          "isHeadMaster TEXT DEFAULT 'no',"
          "isOnline INTEGER DEFAULT 0,"
          "schoolId INTEGER NOT NULL,"
          "UNIQUE(userName, userPassword)"
          ");");

      dbBatch.execute(_createSchoolTable());
      dbBatch.execute(_createTeacherTable());
      dbBatch.execute(_createAcademicYearTable());
      dbBatch.execute(_createLanguagesTable());
      dbBatch.execute(_createClassTable());
      dbBatch.execute(_createStudentTable());
      dbBatch.execute(_createTeacherProfileTable());

      dbBatch.execute(_createQuestionPaperTable());

      dbBatch.execute(_createPaceSchedule());
      dbBatch.execute(_createPaceGrader());

      dbBatch.execute(_createBasicLevels());
      dbBatch.execute(_createNumericLevels());

      dbBatch.execute(_createAttendanceTable());

      dbBatch.execute(_createPaceTable());
      dbBatch.execute(_createBasicTable());
      dbBatch.execute(_createNumericTable());

      dbBatch.execute(_createTeacherAttendanceTable());
      dbBatch.execute(_createTableTeacherLeaveType());
      dbBatch.execute(_createTeacherLeaveTypeAllocationTable());
      dbBatch.execute(_createTeacherLeaveRequestTable());
      await dbBatch.commit(noResult: true);
    }, onUpgrade: (Database db, currentVersion, nextVersion) async {
      final upgradeCalls = {
        2: (Database db, Batch dbBatch) async {},
      };
      var dbBatch = db.batch();
      upgradeCalls.forEach((version, call) async {
        if (version > currentVersion) await call(db, dbBatch);
      });
      await dbBatch.commit(noResult: true);
    });
  }

  Future<dynamic> insertUser(User user) async {
    final db = await initDB();
    var res = await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print("$res jhgfgskjg");

    return res;
  }

  Future<List<User>> readUsers() async {
    final db = await initDB();
    final users = await db.query('users');
    return List.generate(users.length, (index) {
      return User(
          userName: users[index]['userName'] as String,
          userPassword: users[index]['userPassword'] as String,
          userId: users[index]['userID'],
          loginStatus: users[index]['loginstatus'] as int,
          isOnline: users[index]['isOnline'] as int,
          dbname: 'doednhdd');
    });
  }

  Future<dynamic> readUserName() async {
    try {
      final db = await initDB();
      var result =
          await db.rawQuery('SELECT userName FROM users WHERE loginStatus=1');

      return result;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<dynamic> logoutUser() async {
    final db = await initDB();
    var updateCount = await db.rawQuery('UPDATE users '
        'SET loginstatus = 0, isOnline = 0 '
        'WHERE loginstatus=1;');

    if (kDebugMode) {
      log("update count");
      log(updateCount.toString());
    }
    return updateCount;
  }

  Future<dynamic> getCredentials() async {
    final db = await initDB();

    return db.rawQuery(
        'SELECT userName, userPassword, dbname from users WHERE loginstatus=?;',
        [1]);
  }

  // dynamic method for inserting data
  Future<dynamic> dynamicInsert(
      String tableName, Map<String, Object?> data) async {
    try {
      if (kDebugMode) {
        print(tableName);
      }
      final db = await initDB();
      var res = await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.replace);

      if (kDebugMode) {
        print('Inserted in $tableName $res');
      }
    } catch (e) {
      log(e.toString());
    }
  }
  // dynamic method for inserting data end

  // dynamic method for inserting data ignore
  Future<dynamic> dynamicInsertIgnore(
      String tableName, Map<String, Object?> data) async {
    try {
      if (kDebugMode) {
        print(tableName);
      }
      final db = await initDB();
      var res = await db.insert(tableName, data,
          conflictAlgorithm: ConflictAlgorithm.ignore);

      if (kDebugMode) {
        print('Inserted in $tableName $res');
      }
    } catch (e) {
      log(e.toString());
    }
  }
  // dynamic method for inserting data end ignore

  Future<void> saveFetchedData(
      year,
      teacher,
      school,
      classes,
      students,
      assessments,
      grading,
      qpapers,
      readingLevels,
      numericLevels,
      languages) async {
    try {
      final db = await initDB();
      String tableName = "";

      // insert academic year
      if (year != null && year.isNotEmpty) {
        Map<String, Object> data = {"academic_year": year};
        tableName = "academic";

        await db.rawQuery("DELETE FROM academic;");

        var res = await db.insert(tableName, data,
            conflictAlgorithm: ConflictAlgorithm.replace);
        if (kDebugMode) {
          print('Inserted in $tableName $res');
        }
      }
      // insert academic year

      // insert teacher
      if (teacher.isNotEmpty && teacher != null) {
        tableName = 'teacher';

        await db.rawQuery("DELETE FROM teacher;");

        Map<String, Object> data = {
          "teacher_id": teacher['teacher_id'],
          "teacher_name": teacher['teacher_name'],
          "userID": teacher['userID'],
        };

        var res = await db.insert(tableName, data,
            conflictAlgorithm: ConflictAlgorithm.replace);

        if (kDebugMode) {
          print('Inserted in $tableName $res');
        }
      }
      // insert teacher

      // insert school
      if (school.isNotEmpty && school != null) {
        tableName = 'school';

        await db.rawQuery("DELETE FROM school;");

        Map<String, Object> data = {
          "school_id": school['school_id'],
          "school_name": school['school_name']
        };

        var res = await db.insert(tableName, data,
            conflictAlgorithm: ConflictAlgorithm.replace);

        if (kDebugMode) {
          print('Inserted in $tableName $res');
        }
      }
      // insert school

      // insert classes
      if (classes.isNotEmpty) {
        await db.rawQuery("DELETE FROM classes;");

        if (classes.length > 0 && classes.runtimeType == List<dynamic>) {
          for (var a = 0; a < classes.length; a++) {
            // print(a.runtimeType);
            if (classes[a].isNotEmpty && classes.runtimeType != String) {
              var classRecord = classes[a];
              var classId = classes[a]['id'];
              var className = classes[a]['name'];
              var standard = classes[a]['standard_id'];
              var medium = classes[a]['medium_id'];
              var division = classes[a]['division_id'];

              Map<String, Object> data = {
                'class_id': classId,
                'class_name': className,
                'standard_id': standard[0],
                'standard_name': standard[1],
                'medium_id': medium[0],
                'medium_name': medium[1],
                'division_id': division[0],
                'division_name': division[1]
              };
              tableName = "classes";

              var res = await db.insert(tableName, data,
                  conflictAlgorithm: ConflictAlgorithm.replace);

              if (kDebugMode) {
                print('Inserted in $tableName $res');
              }
            }
          }
        }
      }
      // insert classes

      // insert student

      if (students.isNotEmpty && students != null) {
        await db.rawQuery("DELETE FROM students;");

        if (students.length > 0) {
          tableName = "students";
          for (var i = 0; i < students.length; i++) {
            var student = students[i];
            var studentId = student['id'];
            var rollNo = student['roll_no'];

            var studentName = student['name'].toString();
            if (student['middle'] != "" &&
                student['middle'] != null &&
                student['middle'] != false &&
                student['middle'] != "false") {
              studentName = studentName + " " + student['middle'].toString();
            }
            if (student['last'] != "" &&
                student['last'] != null &&
                student['last'] != false &&
                student['last'] != "false") {
              studentName = studentName + " " + student['last'].toString();
            }

            var classId = student['standard_id'][0];
            var className = student['standard_id'][1];
            var studentPhoto = student['photo'].toString();

            Map<String, Object> data = {
              "student_id": studentId,
              "student_name": studentName,
              "student_roll_no": rollNo.toString(),
              "class_id": classId,
              "class_name": className.toString(),
              "profile_pic": studentPhoto
            };

            var res = await db.insert(tableName, data,
                conflictAlgorithm: ConflictAlgorithm.replace);

            if (kDebugMode) {
              print('Inserted in $tableName $res');
            }
          }
        }
      }
      // insert student

      //insert languages
      if (languages.isNotEmpty && languages != null && languages.length > 0) {
        await db.rawQuery("DELETE FROM languages;");

        tableName = "languages";
        for (var a = 0; a < languages.length; a++) {
          var language = languages[a];

          var langId = language['medium_id'][0];
          var langName = language['medium_id'][1].toString();
          var standardId = language['standard_id'][0];

          Map<String, Object> data = {
            "langId": langId.toString(),
            "langName": langName,
            "standard_id": standardId.toString(),
          };

          var res = await db.insert(tableName, data,
              conflictAlgorithm: ConflictAlgorithm.replace);
          if (kDebugMode) {
            print('Inserted in $tableName $res');
          }
        }
      }
      // insert languages

      // insert grading
      if (grading.isNotEmpty && grading != null && grading.length > 0) {
        await db.rawQuery('DELETE FROM pacegrade;');
        var tableName = 'pacegrade';
        // if(kDebugMode){
        //   print('inserting grades pace');
        //   print(grading.toString());
        // }

        for (var i = 0; i < grading.length; i++) {
          var grade = grading[i];

          var id = grade['id'];
          var fromMarks = grade['from_mark'];
          var toMarks = grade['to_mark'];
          var result = grade['result'];

          Map<String, Object> data = {
            'id': id,
            'from_marks': fromMarks,
            'to_marks': toMarks,
            'result': result,
          };

          var res = await db.insert(tableName, data,
              conflictAlgorithm: ConflictAlgorithm.replace);

          if (kDebugMode) {
            print('Inserted in $tableName $res');
          }
        }
      }
      // insert grading

      // insert qpapers
      if (qpapers.isNotEmpty && qpapers != null && qpapers.length > 0) {
        await db.rawQuery("DELETE FROM qPaper;");

        tableName = 'qPaper';

        for (var i = 0; i < qpapers.length; i++) {
          var qpaper = qpapers[i];
          var qpaperName = qpaper['qp_code'];
          var qpaperId = qpaper['id'];
          var qpaperMedium = qpaper['medium'];
          var qpaperStdId = qpaper['standard_id'];
          var qpaperSubj = qpaper['subject'];
          var totques = qpaper['totques'];
          var totmarks = qpaper['totmarks'];
          Map<String, Object> data = {
            'id': qpaperId,
            'qp_code': qpaperName,
            'medium_id': qpaperMedium[0],
            'subject_id': qpaperSubj[0],
            'standard_id': qpaperStdId[0],
            'totques': totques,
            'totmarks': totmarks
          };
          var res = await db.insert(tableName, data,
              conflictAlgorithm: ConflictAlgorithm.replace);

          if (kDebugMode) {
            print('Inserted in $tableName $res');
          }
        }
      }
      // insert qpapers

      // insert reading levels
      if (readingLevels != null &&
          readingLevels.isNotEmpty &&
          readingLevels.length > 0) {
        await db.rawQuery('DELETE FROM basicLevels');
        tableName = 'basicLevels';

        for (var i = 0; i < readingLevels.length; i++) {
          var readingLevel = readingLevels[i];
          var levelId = readingLevel['id'];
          var standard = readingLevel['standard'];
          var standardId = standard[0];
          var name = readingLevel['name'];
          var subject = readingLevel['subject'];
          var subjectId = subject[0];
          var subjectName = subject[1];

          Map<String, Object> data = {
            'levelId': levelId,
            'standard_id': standardId,
            'name': name,
            'subject_id': subjectId,
            "subject_name": subjectName
          };

          var res = await db.insert(tableName, data,
              conflictAlgorithm: ConflictAlgorithm.replace);

          if (kDebugMode) {
            print('Inserted $res in $tableName');
          }
        }
      }
      // insert reading levels

      // insert numeric levels
      if (numericLevels != null &&
          numericLevels.isNotEmpty &&
          numericLevels.length > 0) {
        await db.rawQuery('DELETE FROM numericLevels');
        tableName = 'numericLevels';

        for (var i = 0; i < numericLevels.length; i++) {
          var numericLevel = numericLevels[i];
          var levelId = numericLevel['id'];
          var standard = numericLevel['standard'];
          var standardId = standard[0];
          var name = numericLevel['name'];

          Map<String, Object> data = {
            'levelId': levelId,
            'standard_id': standardId,
            'name': name,
          };

          var res = await db.insert(tableName, data,
              conflictAlgorithm: ConflictAlgorithm.replace);

          if (kDebugMode) {
            print('Inserted $res in $tableName');
          }
        }
      }
      // insert numeric levels

      // insert assessments
      if (assessments != null &&
          assessments.isNotEmpty &&
          assessments.length > 0) {
        tableName = 'paceSchedule';

        for (var i = 0; i < assessments.length; i++) {
          var assessment = assessments[i];
          var id = assessment['id'];
          var name = assessment['name'];
          var subjectId = assessment['subject'][0];
          var subjectName = assessment['subject'][1];
          var qpCode = assessment['qp_code'][0];
          var qpCodeName = assessment['qp_code'][1];
          var date = assessment['date'];
          var standardId = assessment['standard_id'][0];
          var standardName = assessment['standard_id'][1];
          var mediumId = assessment['medium'][0];
          var mediumName = assessment['medium'][1];
          // print('${qpCode} :: ${qpCodeName}');

          Map<String, Object> data = {
            'id': id,
            'name': name,
            'subject_id': subjectId,
            'subject_name': subjectName,
            'qp_code': qpCode,
            'qp_code_name': qpCodeName,
            'date': date,
            'standard_id': standardId,
            'standard_name': standardName,
            'medium_id': mediumId,
            'medium_name': mediumName
          };

          var res = await db.insert(tableName, data,
              conflictAlgorithm: ConflictAlgorithm.replace);
          if (kDebugMode) {
            print('Inserted in $tableName $res');
          }
        }
      }
      // insert assessments

    } catch (e) {
      log(e.toString());
    }
  }

  Future<dynamic> getAcademicYear() async {
    final db = await initDB();
    var academicYear = db.query('academic');
    print('academic_year');
    return academicYear;
  }

  Future<dynamic> getSchool() async {
    final db = await initDB();
    var school = await db.query('school');
    return school;
  }

  Future<Teacher> getTeacher() async {
    final db = await initDB();
    var teacher = db.query('teacher');
    return Teacher(
        teacherId: teacher['teacher_id'],
        teacherName: teacher['teacherName'] as String);
  }

  Future<dynamic> getClass() async {
    final db = await initDB();
    var classes = await db.query('classes');
    return classes;
  }

  Future getStudents(String className) async {
    final db = await initDB();
    var students = await db
        .query('students', where: 'class_name=?', whereArgs: [className]);
    return students.toList();
  }

  Future<void> saveAttendance(
      selectedDate, className, submissionDate, absenteeString) async {
    try {
      final db = await initDB();
      // print(submisssionDate);
      if (kDebugMode) {
        // print(className);
        // print(selectedDate);
        // print(absenteeString);
        print(submissionDate.toString());
      }
      var resQ = await db.insert(
          'attendance',
          {
            'date': selectedDate.toString(),
            'class_name': className,
            'submission_date': submissionDate,
            'absenteeString': absenteeString
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (kDebugMode) {
        print(resQ.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<dynamic> getAllPace(String? className) async {
    final db = await initDB();
    return await db.rawQuery(
        "SELECT paceSchedule.name, paceSchedule.subject_name, paceSchedule.date, paceSchedule.medium_name, paceSchedule.qp_code, paceSchedule.qp_code_name, qPaper.totques, qPaper.totmarks from paceSchedule"
        " INNER JOIN qPaper ON paceSchedule.qp_code_name = qPaper.qp_code"
        " WHERE "
        "paceSchedule.standard_id=(Select standard_id from classes WHERE class_name=?)"
        " AND "
        "paceSchedule.medium_id = (Select medium_id from classes WHERE class_name=?);",
        [className, className]);
  }

  Future<dynamic> getAllLanguages(String? className) async {
    final db = await initDB();

    return await db.rawQuery(
        'SELECT DISTINCT langName FROM languages WHERE standard_id=(SELECT standard_id FROM classes WHERE class_name=?);',
        [className]);
  }

  Future<dynamic> getLangId(String langName, String? className) async {
    final db = await initDB();
    return await db.rawQuery(
        'SELECT langId FROM languages WHERE langName = ? AND standard_id=(SELECT standard_id FROM classes WHERE class_name=?)',
        [langName, className]);
  }

  Future<dynamic> getPaceGrading() async {
    final db = await initDB();

    return await db.query('pacegrade');
  }

  Future<void> saveNumericAssessment(assessmentData) async {
    // print(assessmentData.toString());
    final dba = initDB();
    dba.then((db) async {
      final batch = db.batch();

      var date = assessmentData['date'];
      var className = assessmentData['className'];
      var result = assessmentData['result'];
      var submissionDate = assessmentData['submissionDate'];
      if (date != null &&
          className != null &&
          submissionDate != null &&
          result.isNotEmpty) {
        print('inserting num');
        var p = [];
        for (var i = 0; i < result.length; i++) {
          var k = result[i].keys;
          // k = k.toString();
          var q = {};
          for (var j in k) {
            // print(result[i][j].runtimeType);
            // print(result[i][j]);
            q[j.toString()] = result[i][j];
          }
          p.add(q);
        }
        var vResult = jsonEncode(p);
        // print(vResult);

        batch.insert('numeric', {
          'date': date,
          'class_name': className,
          "submission_date": submissionDate,
          'stringData': vResult
        });
        await batch.commit(noResult: true);
        print('done');
      }
    });
  }

  Future<void> saveReadingAssessment(assessmentData) async {
    // print(assessmentData.toString());
    final dba = initDB();
    dba.then((db) async {
      var batch = db.batch();
      var date = assessmentData['date'];
      var className = assessmentData['className'];
      var language = assessmentData['language'];
      var submissionDate = assessmentData['submissionDate'];
      var result = assessmentData['result'];

      if (date != null &&
          className != null &&
          language != null &&
          result.isNotEmpty) {
        print('inserting num');
        var p = [];
        for (var i = 0; i < result.length; i++) {
          var k = result[i].keys;
          // k = k.toString();
          var q = {};
          for (var j in k) {
            // print(result[i][j].runtimeType);
            // print(result[i][j]);
            q[j.toString()] = result[i][j];
          }
          p.add(q);
        }
        var vResult = jsonEncode(p);
        // print(vResult);
        print('inserting basic');
        batch.insert('basic', {
          'date': date,
          'class_name': className,
          'language': language,
          "submission_date": submissionDate,
          'stringData': vResult
        });
        await batch.commit(noResult: true);
        print('done');
      }
    });
  }

  Future<void> savePaceAssessment(assessmentData) async {
    // print(assessmentData.toString());
    try {
      if (kDebugMode) {
        print("save to db pace");
      }
      var assessmentName = assessmentData['assessmentName'];
      var subjectName = assessmentData['subjectName'];
      var mediumName = assessmentData['medium_name'];
      var qpCode = assessmentData['qp_code'];
      var qpCodeName = assessmentData['qp_code_name'];
      var scheduledDate = assessmentData['scheduledDate'];
      var uploadDate = assessmentData['uploadDate'];
      var className = assessmentData['className'];
      var result = assessmentData['result'];
      var markSheet = assessmentData['marksheet'];
      if (kDebugMode) {
        print("assessment name");
        print(assessmentName != null);
        print("subject name");

        print(subjectName != null);
        print("medium name");

        print(mediumName != null);
        print("qpcode");

        print(qpCode != null);
        print("qpcode name");

        print(qpCodeName != null);
        print("scheduled date name");

        print(scheduledDate != null);
        print("upload date");

        print(uploadDate != null);
        print("class name");

        print(className != null);
        print("marksheet");

        print(markSheet.isNotEmpty);
        print("result");

        print(result.isNotEmpty);
      }

      if (assessmentName != null &&
          subjectName != null &&
          mediumName != null &&
          qpCode != null &&
          qpCodeName != null &&
          scheduledDate != null &&
          uploadDate != null &&
          className != null &&
          markSheet.isNotEmpty &&
          result.isNotEmpty) {
        print('inserting assessment pace');
        final batch = await initDB();
        var vResult = {};
        var vMarkSheet = {};

        for (var vk in result.keys) {
          vResult[vk.toString()] = result[vk];
        }
        for (var mk in markSheet.keys) {
          vMarkSheet[mk.toString()] = markSheet[mk];
        }
        var vResults = jsonEncode(vResult);
        var vMarkSheets = jsonEncode(vMarkSheet);
        Map<String, Object> values = {
          'assessmentName': assessmentName,
          'subject_name': subjectName,
          'medium_name': mediumName,
          'qp_code': qpCode,
          'scheduledDate': scheduledDate,
          'uploadDate': uploadDate,
          'class_name': className,
          'marksheet': vMarkSheets,
          'result': vResults
        };

        if (kDebugMode) {
          log(values.toString());
        }

        var res = await batch.insert('pace', values,
            conflictAlgorithm: ConflictAlgorithm.replace);

        if (kDebugMode) {
          log("saving pace");
          log(values.toString());
          log("res");
          log(res.toString());
        }
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
    }
  }

  Future<dynamic> readAllAttendance(
      DateTime todayDate, DateTime lastMonthDate) async {
    final db = await initDB();
    var endDate = format.format(todayDate);
    var startDate = format.format(lastMonthDate);
    return await db.rawQuery(
        "SELECT * FROM attendance WHERE date>= ? AND date<=? AND synced='false';",
        [startDate, endDate]);
  }

  Future<dynamic> readAllNumeric(
      DateTime todayDate, DateTime lastMonthDate) async {
    final db = await initDB();
    var endDate = format.format(todayDate);
    var startDate = format.format(lastMonthDate);

    return await db.rawQuery(
        "Select * FROM numeric WHERE date>=? AND date<=? AND synced='false';",
        [startDate, endDate]);
  }

  Future<dynamic> readAllBasic(
      DateTime todayDate, DateTime lastMonthDate) async {
    final db = await initDB();
    var endDate = format.format(todayDate);
    var startDate = format.format(lastMonthDate);
    return await db.rawQuery(
        "Select * FROM basic WHERE date>=? AND date<=? AND synced='false';",
        [startDate, endDate]);
  }

  Future<dynamic> readAllPace(
      DateTime todayDate, DateTime lastMonthDate) async {
    final db = await initDB();
    var endDate = format.format(todayDate);
    var startDate = format.format(lastMonthDate);
    return await db.rawQuery("Select * FROM pace WHERE synced='false';", []);
  }

  Future<dynamic> getReadingLevels(className, subjectName) async {
    final db = await initDB();

    return await db.rawQuery(
        "SELECT levelId, name, subject_id, subject_name from basicLevels WHERE subject_name = ? AND standard_id = (SELECT standard_id from classes where class_name = ?);",
        [subjectName, className]);
  }

  Future<dynamic> getNumericLevels(className) async {
    final db = await initDB();
    return await db.rawQuery(
        "SELECT levelId, name from numericLevels where standard_id = (SELECT standard_id from classes where class_name = ?) ORDER By name;",
        [className]);
  }

  Future<dynamic> getClassId(className) async {
    final db = await initDB();
    return await db.rawQuery(
        "SELECT class_id FROM classes WHERE class_name=?", [className]);
  }

  Future<dynamic> getTeacherId() async {
    final db = await initDB();
    return await db.rawQuery('SELECT teacher_id FROM teacher');
  }

  Future<dynamic> checkIfThisTableExists(tableName) async {
    final db = await initDB();

    return await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]);
  }

  Future<dynamic> getNumericLevelId(className, levelName) async {
    final db = await initDB();
    var result = await db.rawQuery(
        "Select levelId From numericLevels WHERE name=? AND standard_id=(SELECT standard_id FROM classes WHERE class_name=?);",
        [levelName, className]);
    return result;
  }

  Future<dynamic> getNumericLevelName(levelId) async {
    final db = await initDB();
    var result = await db
        .rawQuery("Select name From numericLevels WHERE levelId=?;", [levelId]);
    return result;
  }

  Future<dynamic> getBasicLevelId(className, subjectName, levelName) async {
    final db = await initDB();
    var result = await db.rawQuery(
        "Select levelId From basicLevels WHERE name=? AND subject_name=? AND standard_id=(SELECT standard_id FROM classes WHERE class_name=?);",
        [levelName, subjectName, className]);
    return result;
  }

  Future<dynamic> getBasicLevelName(levelId) async {
    final db = await initDB();
    var result = await db
        .rawQuery("Select name From basicLevels WHERE levelId=?;", [levelId]);
    return result;
  }

  Future<void> updateAttendance() async {
    final db = await initDB();

    //  final db = value.batch();
    await db.rawDelete(
      "UPDATE attendance SET synced='true', editable='false' WHERE synced='false';",
    );
  }

  Future<void> updateNumericAssessment(classId, date) async {
    final dba = initDB();

    dba.then((value) async {
      final db = value.batch();
      await db.rawDelete(
          "UPDATE numeric SET synced='true', editable='false' WHERE class_name=(SELECT class_name FROM classes where class_id=?) AND date=? AND editable='true' AND synced='false';",
          [classId, date]);
      db.commit();
    });
  }

  Future<void> updateBasicAssessment(classId, languageId, date) async {
    final dba = initDB();

    print('a');
    // await db.commit(noResult: true);
    // print(a);
    dba.then((d) async {
      final db = d.batch();
      var r = await db.rawDelete(
          "UPDATE basic SET synced='true', editable='false' WHERE date=? AND editable='true' AND synced='false';",
          [date]);

      db.commit();
      print('r');
    });
  }

  Future<void> updatePace() async {
    try {
      final db = await initDB();

      var res = await db.rawQuery(
          "UPDATE pace SET synced='true', editable='false' WHERE synced='false';");
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> updateLeave() async {
    try {
      final db = await initDB();
      var res = await db.rawQuery(
          "UPDATE TeacherLeaveRequest SET leaveRequestEditable='true' WHERE leaveRequestEditable='false';");
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> dum() async {
    final db = await initDB();
    var res = await db.rawQuery("SELECT * FROM basic;");
    print('get');
    print(res.toString());
  }

  Future<dynamic> getTotalMarksPace(
      assessmentName, scheduledDate, qpCode) async {
    final db = await initDB();

    var result = await db.rawQuery(
        "SELECT paceSchedule.name, paceSchedule.id, paceSchedule.standard_id, paceSchedule.medium_id, paceSchedule.subject_id, paceSchedule.date, qPaper.totques, qPaper.totmarks from paceSchedule"
        " INNER JOIN qPaper ON paceSchedule.qp_code_name = qPaper.qp_code"
        " WHERE "
        "paceSchedule.name=?"
        " AND "
        "paceSchedule.date=?"
        " AND "
        "paceSchedule.qp_code=?;",
        [assessmentName, scheduledDate, qpCode]);

    return result;
  }

  // read all editable attendances
  Future<dynamic> allEditableAttendance() async {
    try {
      final db = await initDB();
      var resQ =
          await db.rawQuery('SELECT * FROM attendance WHERE editable="true";');

      return resQ;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
  // read all editable attendances end

  // read isExists and isEditable attendance on selected date (format YYYY-mm-dd)
  Future<dynamic> isEditableAttendanceDate(
      String selectedDate, String className) async {
    try {
      final db = await initDB();
      var resQ = await db.rawQuery(
          'SELECT * FROM attendance WHERE date=? AND class_name=?;',
          [selectedDate, className]);

      return resQ;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
  // read isExists and isEditable attendance on selected date end

  // read isExists and isEditable Numeric Assessment on selected date
  Future<dynamic> isEditableNumericeDate(
      String selectedDate, String className) async {
    try {
      final db = await initDB();
      var resQ = await db.rawQuery(
          'SELECT * FROM numeric WHERE date=? AND class_name=?;',
          [selectedDate, className]);

      return resQ;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
  // read isExists and isEditable Numeric Assessment on selected date end

  // read isExists and isEditable basic Assessment on selected date
  Future<dynamic> isEditableBasicDate(
      String selectedDate, String className, String language) async {
    try {
      final db = await initDB();
      var resQ = await db.rawQuery(
          'SELECT * FROM basic WHERE date=? ANDS class_name=? AND language=?;',
          [selectedDate, className, language]);

      return resQ;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
  // read isExists and isEditable basic Assessment on selected date end

  // read isExists and isEditable PACE Assessment on selected date
  Future<dynamic> isEditablePaceDate(
      String selectedDate, String assessmentName, String className) async {
    try {
      final db = await initDB();
      var resQ = await db.rawQuery(
          'SELECT * FROM pace WHERE uploadDate=? AND assessmentName=? AND class_name=?;',
          [selectedDate, assessmentName, className]);

      return resQ;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
  // read isExists and isEditable PACE Assessment on selected date end

  // read all attendance in date range
  Future<dynamic> readAllAttendanceDateRange(startDate, lastDate) async {
    try {
      final db = await initDB();
      var res = await db.rawQuery(
          "SELECT * FROM attendance WHERE date>= ? AND date<=?;",
          [startDate, lastDate]);

      var resl = res.toList();
      return resl;
    } catch (e) {
      log(e.toString());
    }
  }
  // read all attendance in date range end

  Future<void> fetchQuery() async {
    try {
      final db = await initDB();
      var query = 'SELECT * FROM attendance;';
      var query2 = "SELECT * FROM numeric;";
      var query3 = "SELECT * FROM basic;";
      var query4 = "SELECT * FROM pace;";
      var res = await db.rawQuery(query);
      var res2 = await db.rawQuery(query2);
      var res3 = await db.rawQuery(query3);
      var res4 = await db.rawQuery(query4);
      if (kDebugMode) {
        log("attendance");
        log(res.toString());
        log("numeric");
        log(res2.toString());
        log("basic");
        log(res3.toString());
        log("pace");
        log(res4.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
    }
  }

  Future<dynamic> isUser(enteredUserName, enteredPassword) async {
    try {
      final db = await initDB();
      var query = "SELECT * FROM users WHERE userName = ? AND userPassword=?;";

      var params = [enteredUserName, enteredPassword];

      var userQ = await db.rawQuery(query, params);

      var user = userQ.toList();

      // if (kDebugMode) {
      //   print('user is');
      //   print(user.toString());
      // }
      return user;
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
    }
  }

  Future<dynamic> makeUserOfflineLogin(userID) async {
    try {
      if (kDebugMode) {
        print("entereduser $userID");
        print("offline login");
      }
      final db = await initDB();
      var query =
          "UPDATE users SET loginStatus = 1, isOnline=0 WHERE userID = ?;";

      // var params = [enteredUserName, enteredPassword];

      var result = await db.rawQuery(query, [userID]);
      if (kDebugMode) {
        print('user is');
        print(result.toString());
      }
      query = 'SELECT * FROM users WHERE loginstatus = 1';
      var params = [];
      var userQ = await db.rawQuery(query, params);

      var user = userQ.toList();

      if (kDebugMode) {
        print('user is');
        print(user.toString());
      }
      return user;
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
    }
  }

  Future<dynamic> dynamicRead(query, params) async {
    try {
      final db = await initDB();

      if (params.isEmpty) {
        var userQ = await db.rawQuery(query);

        var user = userQ.toList();

        if (kDebugMode) {
          print('user is');
          print(user.runtimeType.toString());
        }
        return user;
      } else {
        var userQ = await db.rawQuery(query, params);

        var user = userQ.toList();

        if (kDebugMode) {
          log('user is');
          print(user.runtimeType.toString());
        }
        return user;
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
    }
  }
}
