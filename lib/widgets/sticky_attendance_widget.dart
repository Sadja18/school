// ignore_for_file: prefer_const_literals_to_create_immutables, unused_element, unused_field, unused_import

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

import '../screens/login.dart';
import '../screens/dashboard.dart';
import '../services/database_handler.dart';
import './class_dropdown.dart';
import './date_widget.dart';
import '../services/helper_db.dart';
import './attendance_edit_widget.dart';

class StickyAttendance extends StatefulWidget {
  static const routeName = "attendance-new";
  const StickyAttendance({Key? key}) : super(key: key);

  @override
  _StickyAttendanceState createState() => _StickyAttendanceState();
}

class _StickyAttendanceState extends State<StickyAttendance> {
  // var stickyKey = UniqueKey();

  /// since the database stores date in fullYear-fullMonth-fullDate format
  /// we need a formatter to enable it
  final DateFormat format = DateFormat('yyyy-MM-dd');

  // a variable to store the selected date
  String? _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// since, there needs to be a dropdown which helps selections of the class
  /// classesList variable stores the list of classes for the current user
  List<Map<String, Object?>> classesList = [];

  /// this variable is required to store the class selected by the user.
  String? _selectedClass = "";

  /// when the class is selected by the user
  /// all the students in that class are fetched
  /// this variable stores that list of students
  List<dynamic> studentList = [];

  // to maintain uniform scrollability
  // scroll controllers are required
  ScrollController verticalBodyController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController verticalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalBodyController =
      ScrollController(initialScrollOffset: 0.0);

  // reverse call back function to handle class dropdown
  void selectClass(String selectedClass) {
    setState(() {
      _selectedClass = selectedClass;
    });
    if (kDebugMode) {
      print('reverse classData callback');
    }
  }

  // to process fetched student records
  List<dynamic> fetchedStudentProcessor(List<dynamic> students) {
    var studentProcessed = [];

    for (int i = 0; i < students.length; i++) {
      students[i].remove('notEvaluated');
      students[i].remove('level');
      students[i].remove('result');
    }

    studentProcessed = students;

    return studentProcessed;
  }
  // to process fetched student records end

  // reverse call back function to handle fetch list of students in the selected
  // class
  void getAllStudents(List<dynamic> students) {
    var studentsProcessed = fetchedStudentProcessor(students);

    setState(() {
      studentList = studentsProcessed;
    });

    if (kDebugMode) {
      print('studentList');
    }
  }
  // reverse call back function to handle fetch list of students in the selected
  // class end

  // reverse call back to store the selected Date
  void selectedDate(String? selectDate) {
    setState(() {
      _selectedDate = selectDate.toString();
    });
    if (kDebugMode) {
      print('reverse date callback');
    }
  }
  // reverse call back to store the selected Date end

  int columnsLengthCalculator() {
    return 1;
  }

  int rowsLengthCalculator() {
    return studentList.length;
  }

  ScrollControllers scrollControllers() {
    return ScrollControllers(
      verticalTitleController: verticalTitleController,
      verticalBodyController: verticalBodyController,
      horizontalTitleController: horizontalTitleController,
      horizontalBodyController: horizontalBodyController,
    );
  }

  // builder for column headers
  Widget columnTitleBuilder(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: MediaQuery.of(context).size.width * 2.00,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: ScrollController(initialScrollOffset: 0.0),
        child: Row(
          children: [
            const Text(
              'Present',
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // builder for column headers end

  // builder for entries for each row header
  Widget rowsTitleBuilder(int index) {
    var isEven = index % 2 == 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: isEven ? Colors.lightBlueAccent : Colors.blueGrey,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width * 2.00,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              studentList[index]['rollNo'],
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            Text(
              studentList[index]['studentName'],
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
              softWrap: false,
              textAlign: TextAlign.left,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
          ],
        ),
      ),
    );
  }
  // builder for entries for each row header

  // builder for row header legends
  Widget legendCellBuilder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: MediaQuery.of(context).size.width * 2.00,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: ScrollController(initialScrollOffset: 0.0),
        child: Row(
          children: [
            const Text(
              'Roll No',
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            const Text(
              'Name',
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
          ],
        ),
      ),
    );
  }
  // builder for row header legends

  // a future builder to check whether an attendance for selected class and Date exists
  Widget createOrEdit() {
    var selectiondate = _selectedDate;
    var selectionClass = _selectedClass;

    return FutureBuilder(
        key: ObjectKey(selectionClass),
        future: editOrCreateNewAttendance(
          selectiondate!,
          selectionClass!,
        ),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              var record = snapshot.data;

              if (record['edit'] != null && record['edit'] == 'no') {
                var selectedDate = _selectedDate;

                return EditAttendance(
                    absentees: [],
                    studentList: studentList,
                    selectedDate: selectedDate!);
                ;
              } else {
                var absenteeString = record['absenteeString'];

                if (record['editable'] == 'false') {
                  return const Text('Attendance for this date exists');
                } else {
                  var absentIds = jsonDecode(absenteeString);

                  var selectedDate = _selectedDate;
                  return EditAttendance(
                      key: ObjectKey(studentList),
                      absentees: absentIds,
                      studentList: studentList,
                      selectedDate: selectedDate!);
                }
              }

              // return Text(record.toString());
            } else {
              return Text('$selectionClass $selectiondate');
            }
          }
          return const Text('');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // print('Home');
              Navigator.of(context).popAndPushNamed(Dashboard.routeName);
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              // ignore: avoid_print
              // print('logout');
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Login.routeName, (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        title: const Text('Attendance'),
        backgroundColor: Theme.of(context).primaryColor,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xfff21bce),
                Color(0xff826cf0),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8.0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 10.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          right: 28.0,
                        ),
                        child: const Text(
                          'Class:',
                          softWrap: true,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ClassDropDown(
                        // key: UniqueKey(),
                        selectClass: selectClass,
                        getAllStudents: getAllStudents,
                      ),
                    ],
                  ),
                ),
                DateShow(selectedDate: selectedDate),
                (studentList.isEmpty) ? const Text('') : createOrEdit(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
