// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import '../services/database_handler.dart';
import './assessment_select.dart';
import './class_dropdown.dart';
import '../services/pre_submit_validation.dart';
import '../screens/dashboard.dart';
import '../screens/login.dart';

class PaceAssessmentScreen extends StatefulWidget {
  static const routeName = "pace_screen_new_route";
  const PaceAssessmentScreen({Key? key}) : super(key: key);

  @override
  State<PaceAssessmentScreen> createState() => _PaceAssessmentScreenState();
}

class _PaceAssessmentScreenState extends State<PaceAssessmentScreen> {
  String? _selectedClass = '';
  List<dynamic> studentList = [];
  dynamic _grading = [];
  late final double _totmarks;
  var _selectedAssessment = {};

  var currentStudentId = -10;
  int currentStudentIndex = 0;

  int totQues = 0;
  void classSelector(selectedClass) {
    if (kDebugMode) {
      print('Selected Class: ' + selectedClass.runtimeType.toString());
      print('Selected Class: ' + selectedClass.toString());
    }
    if (selectedClass != "" && selectedClass != null) {
      setState(() {
        _selectedClass = selectedClass;
      });
    }
  }

  void getAllStudents(List<dynamic> students) {
    for (var index = 0; index < students.length; index++) {
      students[index].remove('level');
      // students[index]['notEvaluated'] = false;
      students[index]['result'] = '';
    }
    setState(() {
      studentList = students;
      currentStudentId = studentList[0]['studentId'];
    });

    _getGradingSystem();

    if (kDebugMode) {
      print('student list gen');
      print(studentList.runtimeType);
    }
  }

  Future<void> _getGradingSystem() async {
    var value = await DBProvider.db.getPaceGrading();
    if (value.isNotEmpty) {
      // print(value);
      setState(() {
        _grading = value.toList();
      });
      if (kDebugMode) {
        print(value.runtimeType);
        // print(_grading.runtimeType());
      }
    }
    // print(value);
  }

  void assessmentSelector(dynamic value) {
    try {
      var map = {};
      value.forEach((k, v) => map[k] = v);
      if (kDebugMode) {
        print('assessment select gen');
        // print(map.runtimeType);
      }
      // print(value.toString());
      if (double.tryParse(map['totmarks']) != null) {
        _totmarks = double.parse(map['totmarks']);
      } else {
        _totmarks = double.parse('1');
      }
      setState(() {
        _selectedAssessment = map;
        totQues = int.parse(map['totques']);
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  String displayDate(String date) {
    return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
  }

  Widget tableContainer(
      String cellName, Widget secondWidget, BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      // width: MediaQuery.of(context).size.width * 0.80,
      // height: MediaQuery.of(context).size.height * 0.05,
      margin: const EdgeInsets.symmetric(
        horizontal: 6.0,
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const <int, TableColumnWidth>{
          0: FixedColumnWidth(120),
          1: FixedColumnWidth(300),
        },
        border: TableBorder.symmetric(
          outside: BorderSide.none,
          inside: BorderSide.none,
        ),
        children: [
          TableRow(
            children: [
              TableCell(
                child: Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(),
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: Text(
                    cellName,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              TableCell(
                child: secondWidget,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget widgetTop(context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          tableContainer(
            "Class",
            ClassDropDown(
              getAllStudents: getAllStudents,
              selectClass: classSelector,
            ),
            context,
          ),
          (_selectedClass == "")
              ? const Text("")
              : tableContainer(
                  "Assessment",
                  AssessmentsDropDown(
                      selectClass: _selectedClass,
                      selectAssessment: assessmentSelector),
                  context,
                ),
          (_selectedClass == "" || _selectedAssessment.isEmpty)
              ? const Text("")
              : tableContainer(
                  "Assessment Date",
                  Container(
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: MediaQuery.of(context).size.height * 0.06,
                    decoration: BoxDecoration(),
                    child: Text(
                      displayDate(_selectedAssessment['date'].toString()),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  context,
                ),
          (_selectedClass == "" || _selectedAssessment.isEmpty)
              ? const Text("")
              : tableContainer(
                  "Subject",
                  Container(
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: MediaQuery.of(context).size.height * 0.06,
                    decoration: BoxDecoration(),
                    child: Text(
                      _selectedAssessment['subject_name'].toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  context,
                ),
          (_selectedClass == "" || _selectedAssessment.isEmpty)
              ? const Text("")
              : tableContainer(
                  "Question Paper",
                  Container(
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: MediaQuery.of(context).size.height * 0.06,
                    decoration: BoxDecoration(),
                    child: Text(
                      _selectedAssessment['qp_code_name'].toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  context,
                ),
        ],
      ),
    );
  }

  String nameForamtter(studentName) {
    String formattedName = "";

    for (var i = 0; i < studentName.split(" ").length; i++) {
      String word = studentName.split(" ")[i];
      String newWord = toBeginningOfSentenceCase(word.toLowerCase()).toString();
      formattedName = formattedName + newWord;
      if (i < studentName.split(" ").length - 1) {
        formattedName = formattedName + " ";
      }
    }

    return formattedName;
  }

  Widget studentEntryView(BuildContext context) {
    return (studentList.isEmpty ||
            _selectedAssessment.isEmpty ||
            _selectedClass == "")
        ? const Text("")
        : Card(
          // shape: ShapeBorder.lerp(ShapeBorder(),
            elevation: 12.0,
            child: Container(
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.45,
              margin: const EdgeInsets.only(
                top: 20.0,
                bottom: 4.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    tableContainer(
                      "Roll No:",
                      Container(
                        key: ObjectKey(currentStudentIndex),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(),
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: Text(studentList[0]['rollNo'].toString()),
                      ),
                      context,
                    ),
                    tableContainer(
                      "Name:",
                      Container(
                        key: ObjectKey(currentStudentIndex),
                        width: MediaQuery.of(context).size.width*0.40,
                        decoration: BoxDecoration(),
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            nameForamtter(
                              studentList[0]['studentName'].toString(),
                            ),
                          ),
                        ),
                      ),
                      context,
                    ),
                    tableContainer(
                      "Not Evaluated:",
                      Container(
                          key: ObjectKey(currentStudentIndex),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(),
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: Checkbox(
                            value: true,
                            onChanged: (bool? newVal) {},
                          )),
                      context,
                    ),
                    tableContainer(
                      "Marks Q1:",
                      Container(
                        key: ObjectKey(currentStudentIndex),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(),
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      context,
                    ),
                    tableContainer(
                      "Total:",
                      Container(
                          key: ObjectKey(currentStudentIndex),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(),
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: Text(
                            '0',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      context,
                    ),
                    tableContainer(
                      "Result:",
                      Container(
                          key: ObjectKey(currentStudentIndex),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(),
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: Text(
                            'Not Evaluated',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      context,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (currentStudentIndex <= 0)
                              ? const Text("")
                              : Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent,
                                    border: Border.all(),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      if (kDebugMode) {
                                        print('Enter for previous');
                                      }
                                      if (currentStudentIndex > 0 &&
                                          currentStudentIndex <
                                              studentList.length) {
                                        setState(() {
                                          currentStudentIndex =
                                              currentStudentIndex - 1;
                                          currentStudentId =
                                              studentList[currentStudentIndex]
                                                  ['studentId'];
                                        });

                                        if (kDebugMode) {
                                          print(studentList[currentStudentIndex]
                                              .toString());
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Prev",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                          (currentStudentIndex >= studentList.length)
                              ? const Text("")
                              : Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent,
                                    border: Border.all(),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      if (kDebugMode) {
                                        print('Enter for next');
                                      }
                                      if (currentStudentIndex >= 0 &&
                                          currentStudentIndex <
                                              studentList.length - 1) {
                                        setState(() {
                                          currentStudentIndex =
                                              currentStudentIndex + 1;
                                          currentStudentId =
                                              studentList[currentStudentIndex]
                                                  ['studentId'];
                                        });
                                        if (kDebugMode) {
                                          print(studentList[currentStudentIndex]
                                              .toString());
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Next",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }

  Widget widgetSubmitButton() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(),
      child: ElevatedButton(
          onPressed: () {
            if (kDebugMode) {
              print('submit Button clicked');
            }
          },
          child: const Text("Submit")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Pace Assessment',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration:  BoxDecoration(
          color: Colors.grey.shade400,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // widgetSelectorFields(),
              widgetTop(context),
              studentEntryView(context),
              widgetSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentCard extends StatefulWidget {
  final Map<String, Object> studentData;
  final int studentId;
  final int rowIndex;
  final Function(List? marks, double? total,String? result) selection;
  const StudentCard({ Key? key, required this.studentData, required this.studentId, required this.rowIndex, required this.selection }) : super(key: key);

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(),
        child: const Text('child card'),
      ),
    );
  }
}