# school

DNH DD DoE ERP Project

### Workflow
To enable that app is able work in offline mode as well as online mode; following approach was taken:
- The app utilizes the Sqlite3 database which comes with every Android/iOS smartphone later than Android 8 (Oreo)
- Following Tables are created:
    - The `school` table has two fields: `school_id` and `school_name`. The `school_id` field is set as the primary key for the table.

    - The `teacher` table has three fields: `teacher_id`, `teacher_name`, and `userID`. The `teacher_id` field is set as the primary key for the table, and the `userID` field is set as not null, meaning that a value must be entered for this field.

    - The `academic` table has one field: academic_year. The academic_year field is set as not null, meaning that a value must be entered for this field.
    - The `classes` table has seven fields: `class_id`, `class_name`, `standard_id`, `standard_name`, `medium_id`, `medium_name`, and `division_id`. The `class_id` field is the primary key and is used to uniquely identify each row in the table. 

    - The `TeacherProfile` table has six fields: `teacherId`, `teacherName`, `userId`, `empId`, `schoolId`, and `profilePic`. The `teacherId` field is the primary key and is used to uniquely identify each row in the table. 

    - The `students` table has seven fields: `student_id`, `student_roll_no`, `student_name`, `profile_pic`, `class_id`, `class_name`, and `class_name`. The `student_id` field is the primary key and is used to uniquely identify each row in the table. 

    - The `languages` table has three fields: `langId`, `langName`, and `standard_id`. The `langId` field is the primary key and is used to uniquely identify each row in the table. 

    - The `attendance` table has six fields: `date`, `submission_date`, `class_name`, `absenteeString`, `editable`, and `synced`. The combination of `date`, `class_name`, `editable`, and `synced` fields are unique and used to identify each row in the table.
    
    - The table, `pacegrade`, stores the result of a PACE assessment from a range of marks. The `from_marks` and `to_marks` fields are required, and the `result` field holds a text value indicating the result of the assessment.

    - The table, `basicLevels`, stores the basic reading levels. It has five fields: `levelId`, `standard_id`, `name`, `subject_id` and `subject_name`. Each of these fields is required, and the combination of them is unique.

    - The table, `numericLevels`, stores the numeric ability levels. It has three fields: `levelId`, `standard_id` and `name`. Each of these fields is required, and the combination of them is unique.

    - The table, `paceSchedule`, stores the scheduled PACE assessments. It has eleven fields: `id`, `name`, `subject_id`, `subject_name`, `qp_code`, `qp_code_name`, `date`, `standard_id`, `standard_name`, `medium_id` and `medium_name`.

    - The table `qPaper` is used to store question paper information. It has the following fields: 
        * `id`: This is the primary key field of the table which is used to uniquely identify a record in the table.
        * `qp_code`: This field stores the code of the question paper.
        * `medium_id`: This field stores the id of the medium of the question paper.
        * `subject_id`: This field stores the id of the subject of the question paper.
        * `standard_id`: This field stores the id of the standard of the question paper.
        * `totques`: This field stores the total number of questions in the question paper.
        * `totmarks`: This field stores the total marks of the question paper.

    - The second table `TeacherLeaveAllocation` is used to store teacher leave allocation information. It has the following fields:
        * `leaveTypeId`: This field stores the unique id of the leave type.
        * `leaveTypeName`: This field stores the name of the leave type.
        * `leaveAllocated`: This field stores the number of leaves allocated to the teacher.
        * `leavePending`: This field stores the number of leaves pending for the teacher.
        * `leaveAvailable`: This field stores the number of leaves available for the teacher.

    - The table `TeacherLeaveRequest` is used to store teacher leave request information. It has the following fields:
        * `leaveRequestId`: This field stores the unique id of the leave request.
        * `leaveRequestTeacherId`: This field stores the id of the teacher making the leave request.
        * `leaveTypeId`: This field stores the unique id of the leave type.
        * `leaveTypeName`: This field stores the name of the leave type.
        * `leaveAppliedDate`: This field stores the date on which the leave request was applied.
        * `leaveFromDate`: This field stores the from date of the leave request.
        * `leaveToDate`: This field stores the to date of the leave request.
        * `leaveDays`: This field stores the total number of days for which the leave request is made.
        * `leaveReason`: This field stores the reason for the leave request.
        * `leaveAttachment`: This field stores the attachment of the leave request.
        * `leaveRequestStatus`: This field stores the status of the leave request.
        * `leaveRequestEditable`: This field stores whether the leave request is editable or not.
        * `leaveRequestSynced`: This field stores whether the leave request is synced with the server or not.

    - The table `LeaveTypes` is used to store leave type information. It is accessible only by headmaster login. It has the following fields:
        * `leaveTypeId`: This is the primary key field of the table which is used to uniquely identify a record in the table.
        * `leaveTypeName`: This field stores the name of the leave type.

    - The table, `TeacherAttendance`, has six fields. The `date` field is the primary key and is of type TEXT. The `headMasterUserId` is an integer that is not null. The `totalPresent` and `totalAbsent` fields are both integers and are also not null. The `attendanceJSONified` field is of type TEXT and is also not null. Finally, the `uploadDate` is of type TEXT and is also not null. The `isSynced` field is of type TEXT and is set to 'no' by default. 

    - The table, `TeacherTimeTable`, has five fields. The `timeTableId` is the primary key and is of type INTEGER. The `weekDay` and `period` fields are both of type TEXT and are not null. The `teacherId` and `schoolId` fields are both of type INTEGER and are also not null.

- When user installs the app; he should be connected to a stable, reliable and fast internet. Once the login is successful in the offline mode, the app will save the   login credentials to the internal Sqlite3 database named as school.db making offline login possible afterwards.
- Once, a user has successfully logged in; he/she should do a Sync Data while connected to the internet and wait for the process to complete. App should not be closed or put in background until this process is completed.
- Following info are fetched on Sync Data process for Teacher Login: 
    - Teacher Profile
    - School Details
    - Academic Year
    - Medium of Teaching
    - Grades for PACE
    - Levels For Numeric Ability
    - Levels For Basic Reading
    - Classes Taught By the user (Class Teacher, Secondary Teacher, Tertiary Teacher)
    - Students in the classes taught by the user.
    - Leave Types assigned to the user.
    - Leave Allocations to the user.
    - Details and Status of the Leaves applied by the user.
- Following info are sent to the Proxy redirect PHP API endpoints to create/update new records:
    - Newly created Attendance Sheets
    - Newly created Leave Requests
    - Newly created PACE+FLN Assessment Sheets
- After the data has been synced, the app can work in the offline mode.


---
### Steps for Installing Flutter Packages

1. **http: ^0.13.4**  
This package provides a base class for making HTTP requests and receiving HTTP responses in the Dart programming language. It supports making requests and receiving responses over HTTP and HTTPS, and includes support for persistent connections and the ability to send and receive data encoded in various formats, including JSON, XML and UTF-8.

2. **sqflite: ^2.0.2+1**  
This package provides an interface to SQLite databases in the Dart programming language. It includes support for executing SQL queries, creating and dropping tables, inserting and deleting data, and more.

3. **intl: ^0.18.0**  
This package provides internationalization and localization support for the Dart programming language. It includes support for formatting and parsing dates, times and numbers, as well as support for plurals, genders, and more.

4. **table_sticky_headers: ^2.0.0**  
This package provides a widget for displaying tabular data with sticky headers in the Flutter framework. It supports displaying data in a table-like format, with the ability to freeze headers

---
The changes in the assets section is explained below:

This section of the pubspec.yaml file is specific to Flutter and contains information about assets and fonts used in the project. The `uses-material-design` flag specifies that the Material Icons font is included in the project. The `assets` section provides a list of all the assets (images, background images, logos, etc.) that are used in the project. The `fonts` section contains a list of all the fonts that are used in the project, along with the path to the font files. In this example, the project is using the Merriweather, Roboto and Poppins fonts.

---
The entry point of flutter project is ```main.dart```
The behaviour of is explained as below:
## MyApp
MyApp is a stateful widget, which is used to build the material application.

### Constructor
The constructor takes a key as an argument.

### Variables
fetchOne is a constant which is used to fetch data from the database.

### Methods

#### myWidget
This method takes a build context as an argument and returns a FutureBuilder.
If the user is already logged in, the dashboard will be shown. Otherwise,
the login screen is shown.

#### build
This method builds the Material App. It takes a build context as an argument 
and returns a MaterialApp widget. It has a title, theme and various routes. 
The home route is the widget returned by myWidget method. The other routes 
map to various widgets which are defined in the lib/screens directory.

---
In the ```lib/models/urlPaths.dart```
// # API Endpoints

This file provides the documentation for the API endpoints used in the application. The base URL for all the endpoints is `http://62.77.157.49` or `http://10.0.2.2`

#### `checkIfOnline`
This route is used to check if the user is online. It will return a boolean indicating if the user is online or not.

#### `onlineLogin`
This route is used for user authentication and returns a token which can be used to access the other routes.

#### `fetchRelevantData`
This route is used to fetch relevant data from the server, such as user information, settings, etc.

#### `syncAttendance`
This route is used to sync attendance data from the server to the client. It will return an array of attendance records.

#### `syncAssessment`
This route is used to sync assessment data from the server to the client. It will return an array of assessment records.

#### `fetchYear`
This route is used to fetch the year from the server. It will return an integer representing the year.

#### `fetchTeacher`
This route is used to fetch a teacher's information from the server. It will return an object containing the teacher's details.

#### `fetchSchool`
This route is used to fetch school information from the server. It will return an object containing the school's details.

#### `fetchClasses`
This route is used to fetch the classes from the server. It will return an array of objects containing the class details.

#### `fetchStudents`
This route is used to fetch the students from the server. It will return an array of objects containing the student's details.

#### `fetchLanguages`
This route is used to fetch the languages from the server. It will return an array of strings representing the languages.

#### `fetchReadingLevels`
This route is used to fetch the reading levels from the server. It will return an array of integers representing the reading levels.

#### `fetchNumericLevels`
This route is used to fetch the numeric levels from the server. It will return an array of integers representing the numeric levels.

#### `fetchAssessments`
This route is used to fetch the assessments from the server. It will return an array of objects containing the assessment details.

#### `fetchQPapers`
This route is used to fetch the question papers from the server. It will return an array of objects containing the question paper details.

#### `fetchGrading`
This route is used to fetch the grading system from the server. It will return an array of objects containing the grading system details.

#### `fetchLeaveTypes`
This route is used to fetch the leave types from the server. It will return an array of objects containing the leave type details.

#### `fetchLeaveRequests`
This route is used to fetch the leave requests from the server. It will return an array of objects containing the leave request details.

#### `syncLeaveRequest`
This route is used to sync the leave requests from the server. It will return an array of objects containing the updated leave request details.

#### `fetchTeacherProfiles`
This route is used to fetch the teacher profiles from the server. It will return an array of objects containing the teacher profile details.

#### `fetchTeacherTimeTable`
This route is used to fetch the teacher's timetable from the server. It will return an array of objects containing the timetable details.

#### `pushTeacherAttendance`
This route is used to push the teacher's attendance to the server. It will return an object containing the updated attendance details.
---
`lib/screens` directory contains the code for various scaffolds which will be behaving like the main screen for every main feature;
All the screens related to headmaster user login is kept inside headmaster folder. All the screens outside are for teacher login.
