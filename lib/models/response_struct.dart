class User {
  String? userName;
  String? userPassword;
  String? dbname;
  int? loginStatus;
  int? userId;
  int? isOnline;
  String? isHeadMaster;

  User({
    this.userName,
    this.userPassword,
    this.dbname,
    this.loginStatus,
    this.userId,
    this.isOnline,
    this.isHeadMaster,
  });

  User.fromMap(Map<String, dynamic> res)
      : userName = res['userName'],
        userPassword = res['userPassword'],
        dbname = res['dbname'],
        loginStatus = res['loginstatus'],
        userId = res['userID'],
        isOnline = res['isOnline'],
        isHeadMaster = res['isHeadMaster'];

  Map<String, Object?> toMap() {
    return {
      'userName': userName,
      'userPassword': userPassword,
      'dbname': dbname,
      'loginstatus': loginStatus,
      'userID': userId,
      'isOnline': isOnline,
      'isHeadMaster': isHeadMaster
    };
  }
}

class School {
  int? schoolId;
  String? schoolName;

  School({this.schoolId, this.schoolName});

  School.fromMap(Map<String, dynamic> res)
      : schoolId = res['school_id'],
        schoolName = res['school_name'];

  Map<String, Object?> toMap() {
    return {'school_id': schoolId, 'school_name': schoolName};
  }
}

class Teacher {
  int? teacherId;
  String? teacherName;

  Teacher({this.teacherId, this.teacherName});

  Teacher.fromMap(Map<String, dynamic> res)
      : teacherId = res['teacher_id'],
        teacherName = res['teacher_name'];

  Map<String, Object?> toMap() {
    return {'teacher_id': teacherId, 'teacher_name': teacherName};
  }
}

class Classes {
  int? classId;
  String? className;

  Classes({this.classId, this.className});

  Classes.fromMap(Map<String, dynamic> res)
      : classId = res['class_id'],
        className = res['class_name'];

  Map<String, Object?> toMap() {
    return {
      'class_id': classId,
      'class_name': className,
    };
  }
}

class Student {
  int? studentId;
  String? rollNo;
  String? studentName;
  String? className;

  Student({this.studentId, this.rollNo, this.studentName, this.className});

  Student.fromMap(Map<String, dynamic> res)
      : studentId = res['student_id'],
        rollNo = res['student_roll_no'],
        studentName = res['student_name'],
        className = res['class_name'];

  Map<String, Object?> toMap() {
    return {
      'student_name': studentName,
      'student_id': studentId,
      'student_roll_no': rollNo,
      'class_name': className
    };
  }
}
