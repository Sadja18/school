// ignore_for_file: avoid_print, unused_local_variable, unnecessary_brace_in_string_interps, depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import '../models/response_struct.dart';

const defaultString =
    "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";

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
        "student_roll_no INTEGER,"
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
        "editable TEXT DEFAULT 'true' NOT NULL,"
        "synced TEXT DEFAULT 'false' NOT NULL,"
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
        "editable TEXT DEFAULT 'true' NOT NULL,"
        "synced TEXT DEFAULT 'false' NOT NULL,"
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
        "editable TEXT DEFAULT 'true' NOT NULL,"
        "synced TEXT DEFAULT 'false' NOT NULL,"
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
        "editable TEXT DEFAULT 'true' NOT NULL,"
        "synced TEXT DEFAULT 'false' NOT NULL,"
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

  /// teacher time table
  String _createTableTeacherTimeTable() {
    return "CREATE TABLE TeacherTimeTable("
        "timeTableId INTEGER PRIMARY KEY,"
        "weekDay TEXT NOT NULL,"
        "period TEXT NOT NULL,"
        "teacherId INTEGER NOT NULL,"
        "schoolId INTEGER NOT NULL"
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
      dbBatch.execute(_createTableTeacherTimeTable());

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
      var result = await db
          .rawQuery('SELECT userName FROM users WHERE loginStatus=1');

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
        'SET loginstatus = 0, isOnline = 0 ;');

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
        log('Inserted in $tableName $res');
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
      if (kDebugMode) {
        print(teacher);
      }
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
              studentName = "$studentName ${student['middle']}";
            }
            if (student['last'] != "" &&
                student['last'] != null &&
                student['last'] != false &&
                student['last'] != "false") {
              studentName = "$studentName ${student['last']}";
            }

            var classId = student['standard_id'][0];
            var className = student['standard_id'][1];
            var studentPhoto =
                student['photo'] != null && student['photo'] != ""
                    ? student['photo'].toString()
                    : defaultString;

            Map<String, Object> data = {
              "student_id": studentId,
              "student_name": studentName,
              "student_roll_no": rollNo,
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
      if (languages.isNotEmpty &&
          languages != null &&
          languages.length > 0) {
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
    var students = await db.rawQuery(
        'SELECT * FROM students '
        'WHERE class_name = ? '
        'ORDER BY '
        'student_roll_no ASC,'
        'student_name ASC ;',
        [className]);
    // await db
    //     .query('students', where: 'class_name=?', whereArgs: [className]);
    return students.toList();
  }

  Future<void> saveAttendance(
      selectedDate, className, submissionDate, absenteeString) async {
    try {
      final db = await initDB();
      // print(submisssionDate);
      if (kDebugMode) {
        log(className);
        log(selectedDate);
        log(absenteeString);
        log(submissionDate.toString());
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
        log("Attenbdance is saved?");
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
    return await db
        .rawQuery("Select * FROM pace WHERE synced='false';", []);
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
    var result = await db.rawQuery(
        "Select name From numericLevels WHERE levelId=?;", [levelId]);
    return result;
  }

  Future<dynamic> getBasicLevelId(
      className, subjectName, levelName) async {
    final db = await initDB();
    var result = await db.rawQuery(
        "Select levelId From basicLevels WHERE name=? AND subject_name=? AND standard_id=(SELECT standard_id FROM classes WHERE class_name=?);",
        [levelName, subjectName, className]);
    return result;
  }

  Future<dynamic> getBasicLevelName(levelId) async {
    final db = await initDB();
    var result = await db.rawQuery(
        "Select name From basicLevels WHERE levelId=?;", [levelId]);
    return result;
  }

  Future<void> updateAttendance(String date, String className) async {
    final db = await initDB();

    //  final db = value.batch();
    await db.rawDelete(
        "UPDATE attendance SET synced='true', editable='false' WHERE date=? AND class_name=?;",
        [date, className]);
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
      var resQ = await db
          .rawQuery("SELECT * FROM attendance WHERE editable='true';");

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
  Future<dynamic> isEditableNumericDate(
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
      var res = await db.rawQuery("SELECT * FROM attendance;");

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
      var query =
          "SELECT * FROM users WHERE userName = ? AND userPassword=?;";

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
          print('user is $params');
          print(user.runtimeType.toString());
        }
        return user;
      } else {
        var userQ = await db.rawQuery(query, params);

        var user = userQ.toList();

        if (kDebugMode) {
          log('user is $params');
          log(user.runtimeType.toString());
          log(" f ${user != null} g ${user.isNotEmpty}");
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
