// ignore_for_file: prefer_const_literals_to_create_immutables, unused_element, unused_field, unused_import, prefer_const_constructors

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
import './date_class_attendance.dart';

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

  Widget topRow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.06,
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide.none,
          outside: BorderSide.none,
        ),
        columnWidths: <int, TableColumnWidth>{
          0: FractionColumnWidth(0.50),
          1: FractionColumnWidth(0.50),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: DateShow(
                  selectedDate: selectedDate,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  // width: MediaQuery.of(context).size.width * 0.20,
                  decoration: BoxDecoration(),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0.0,
                    vertical: 0.0,
                  ),

                  child: ClassDropDown(
                    selectClass: selectClass,
                    getAllStudents: getAllStudents,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  children: [
                    Icon(
                      Icons.create_outlined,
                      semanticLabel: 'Mark Attendance',
                      size: 40,
                    ),
                    Text(
                      'Mark New',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1.8),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Icon(
                      Icons.view_list_outlined,
                      semanticLabel: 'View Attendance',
                      size: 40,
                    ),
                    Text(
                      'View Marked',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Container(
              decoration: BoxDecoration(
                  // color: Colors.blue,
                  ),
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.05,
                    decoration: BoxDecoration(
                        // border: Border.all(),
                        ),
                    child: topRow(
                      context,
                    ),
                  ),
                  // Text('${MediaQuery.of(context).size.height}'),

                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.76,
                      // decoration: BoxDecoration(color: Colors.amber),
                      child: (studentList.isEmpty)
                          ? const Text('')
                          : createOrEdit(),
                    ),
                  )
                  // Container(
                  //         alignment: Alignment.topCenter,
                  //         margin: const EdgeInsets.only(
                  //           top: 6.0,
                  //         ),
                  //         decoration: BoxDecoration(
                  //             // color: Colors.amber.shade100,
                  //             ),
                  //         height: MediaQuery.of(context).size.height * 0.76,
                  //         width: MediaQuery.of(context).size.width,
                  //         child: createOrEdit(),
                  //       ),
                ],
              ),
            ),
            ViewTakenAttendance(),
          ],
        ),
      ),
    );
  }
}
