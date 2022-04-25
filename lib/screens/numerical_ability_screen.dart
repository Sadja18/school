// ignore_for_file: avoid_print, unused_field

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_handler.dart';
import '../services/presave_processor.dart';
import '../widgets/class_dropdown.dart';
import '../widgets/date_widget.dart';
import '../widgets/row_handler.dart';
import '../screens/dashboard.dart';
import '../screens/login.dart';

class NumAbScreen extends StatefulWidget {
  static const routeName = '/numerical';
  const NumAbScreen({Key? key}) : super(key: key);

  @override
  _NumAbScreenState createState() => _NumAbScreenState();
}

class _NumAbScreenState extends State<NumAbScreen> {
  List<dynamic> studentList = [];
  String? _selectedClass = '';
  List<String> _levelNames = [];
  String? _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  void selectClass(String selectedClass) {
    setState(() {
      _selectedClass = selectedClass;
    });
    print(selectedClass);
    DBProvider.db.getNumericLevels(selectedClass).then((queryResult) {
      // print(levels.runtimeType);
      var levels = queryResult.toList();
      List<String> levelList = [];
      if (levels.isNotEmpty) {
        for (var level in levels) {
          levelList.add(level['name']);
        }
        setState(() {
          levelList.insert(0, 'Not Evaluated');
          levelList.insert(0, '0');
          _levelNames = levelList;
        });
      }
    });
  }

  void selectedDate(String? selectDate) {
    setState(() {
      _selectedDate = selectDate.toString();
    });
    print(selectDate);
  }

  void updateLevel(dynamic levelVal, int index) {
    setState(() {
      studentList[index]['level'] = levelVal;
      if (levelVal == '0') {
        studentList[index]['result'] = 'Not Achieved';
      } else {
        if (levelVal == 'Not Evaluated') {
          studentList[index]['result'] = 'Not Evaluated';
        } else {
          studentList[index]['result'] = 'Achieved';
        }
      }
    });
    // print(studentList.toString());
  }

  void getAllStudents(List<dynamic> students) {
    setState(() {
      studentList = students;
    });
  }

  Widget onChangeWidget(int index) {
    if (studentList[index]['level'] == studentList[index]['result']) {
      return const Text('Not Evaluated');
    } else {
      return Text(
          'Level ${studentList[index]['level']} :: ${studentList[index]['result']}');
    }
  }

  Widget assessmentTable() => DataTable(
        border: TableBorder.symmetric(
          inside: const BorderSide(
            width: 1.0,
            color: Colors.black,
          ),
          outside: BorderSide(width: 2.0, color: Colors.red.shade300),
        ),
        columnSpacing: 6,
        columns: const <DataColumn>[
          DataColumn(
            label: Center(child: Text('Roll No')),
            tooltip: 'Roll No of the student',
          ),
          DataColumn(
            label: Center(child: Text('Name')),
            tooltip: "Name of student",
          ),
          DataColumn(
            label: Center(child: Text('Level')),
            tooltip: 'Level Achieved',
          ),
          DataColumn(
            label: Center(child: Text('Result')),
            tooltip: 'Result',
          ),
        ],
        rows: List.generate(studentList.length, (index) {
          return DataRow(cells: [
            DataCell(
              Center(child: Text('${studentList[index]['rollNo']}')),
              placeholder: false,
              showEditIcon: false,
            ),
            DataCell(
              Center(child: Text('${studentList[index]['studentName']}')),
              placeholder: false,
              showEditIcon: false,
            ),
            DataCell(
              Center(
                child: LevelDropDown(
                  index: index,
                  updateLevel: updateLevel,
                  levelNames: _levelNames,
                  bgColor: Colors.green,
                ),
              ),
            ),
            DataCell(
              Center(
                child: onChangeWidget(index),
              ),
            )
          ]);
        }),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Numerical Ability Assessment'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popAndPushNamed(Dashboard.routeName);
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Login.routeName, (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                ClassDropDown(
                  selectClass: selectClass,
                  getAllStudents: getAllStudents,
                ),
                DateShow(selectedDate: selectedDate),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: (_selectedClass!.isNotEmpty)
                            ? assessmentTable()
                            : const Text(''),
                      ),
                    ),
                  ),
                ),
                (studentList.isNotEmpty)
                    ? ElevatedButton(
                        onPressed: () {
                          print('Submitting to local');
                          var submissionDateUnformatted = DateTime.now();
                          DateFormat submissionFormat =
                              DateFormat('yyyy-MM-dd HH:mm:ss');

                          var submissionDate = submissionFormat
                              .format(submissionDateUnformatted);
                          numericAssessmentProcessor(
                              studentList, _selectedDate, submissionDate);
                        },
                        child: const Text('Submit Assessment'),
                      )
                    : const Text(''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
