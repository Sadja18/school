// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import, unused_field, unused_local_variable, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

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
  List<double> zeroMarksList = [];
  Map<int, List<double>> studentIdMarksMap = {};
  Map<int, String> studentIdResultSheet = {};
  Map<int, bool> studentIdCheckboxVal = {};

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

  void sheetMapsInitiator(int studentId) {
    studentIdResultSheet[studentId] = '';
    studentIdCheckboxVal[studentId] = false;
    studentIdMarksMap[studentId] = zeroMarksList;
  }

  void getAllStudents(List<dynamic> students) {
    if (students.isNotEmpty) {
      for (var index = 0; index < students.length; index++) {
        students[index].remove('level');
        students[index]['result'] = '';
        var studentId = students[index]['studentId'];
        sheetMapsInitiator(studentId);
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
  }

  Future<void> _getGradingSystem() async {
    var value = await DBProvider.db.getPaceGrading();
    if (kDebugMode) {
      print("fetch grades");
      print(value.toString());
    }
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

      if (totQues > 0) {
        for (var i = 0; i < totQues; i++) {
          zeroMarksList.add(0.0);
        }
      }
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

  Widget widgetSubmitButton() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(),
      child: ElevatedButton(
          onPressed: () {
            if (kDebugMode) {
              print('submit Button clicked');
              print(studentIdMarksMap.toString());
              print(studentIdCheckboxVal.toString());
              print(studentIdResultSheet.toString());
            }
          },
          child: const Text("Submit")),
    );
  }

  Future<void> showAlert(String title, String message) {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
              title: Text(title),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Re-enter'),
                ),
              ],
              content: Text(message),
            ));
  }

  Widget textFormFieldForMarks(int index, String initialValue) {
    var title = "";
    var message = "";

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.10,
      child: TextFormField(
        // key: marksFieldKeys[index],
        initialValue: initialValue,
        // controller: TextEditingController(text: initialValue),
        decoration: InputDecoration(hintText: 'Q${index + 1}'),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (kDebugMode) {
            print(value.toString());
          }
          // initialValue = value.toString();

          if (double.tryParse(value.toString()) != null) {
            var mark = double.parse(value.toString());

            if (mark >= 0) {
              if (mark > _totmarks) {
                title = "Invalid Marks";
                message = "Marks can not be more than total marks";

                showAlert(title, message);
              } else {
                setState(() {
                  studentIdMarksMap[currentStudentId]![index] = mark;
                });
              }
            } else {
              title = "Invalid Marks";
              message = "Marks cannot be less than zero";

              showAlert(title, message);
            }
          }
        },
      ),
    );
  }

  Widget markFields(int totalQuestions, BuildContext context) {
    List<Widget> inputFieldList = [];
    for (var i = 0; i < totalQuestions; i++) {
      String initialValue = '0';
      var marksList = studentIdMarksMap[currentStudentId];

      if (marksList![i] != double.parse(initialValue) && marksList[i] > 0) {
        initialValue = marksList[i].toString();
      }
      inputFieldList.add(
        textFormFieldForMarks(i, initialValue),
      );
    }
    // inputFieldList.add(textFormFieldForMarks(0, "0.0"));
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(left: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: inputFieldList,
        ),
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

  Widget tableContainerZero(
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
          0: FixedColumnWidth(30),
          1: FixedColumnWidth(260),
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
                  alignment: Alignment.center,
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

  double calcPercentage(double total) {
    return (total / _totmarks) * 100;
  }

  String calcGrade(percentage) {
    if (kDebugMode) {
      print(percentage.runtimeType);
    }

    var resultVal = "";
    if (kDebugMode) {
      print('grades');
      print(_grading.toString());
    }

    for (int i = 0; i < _grading.length; i++) {
      if (kDebugMode) {
        print(_grading[i].toString());
      }
      var gradeEntry = _grading[i];
      // print(gradeEntry['from_marks'].runtimeType);

      if (gradeEntry['from_marks'] != null && gradeEntry['to_marks'] != null) {
        var fromMarks = gradeEntry['from_marks'];
        var toMarks = gradeEntry['to_marks'];

        if (percentage >= fromMarks && percentage <= toMarks) {
          resultVal = gradeEntry['result'];
        }
      }
    }
    return resultVal;
  }

  String totalCalculator() {
    List<double> marks = studentIdMarksMap[currentStudentId]!;

    if (studentIdCheckboxVal[currentStudentId] == false) {
      double total = 0;
      for (var mark in marks) {
        total = total + mark;
      }
      String result = calcGrade(calcPercentage(total));

      if (result == 'acc' || result == 'noacc') {
        studentIdResultSheet[currentStudentId] = result;
      }

      if (kDebugMode) {
        print('total marks for $currentStudentId is $total');
        print('result for $currentStudentId is $result');
      }
      return total.toString();
    } else {
      return "0.0";
    }
  }

  String resultFormatter() {
    String resultVal = studentIdResultSheet[currentStudentId]!;

    if (resultVal == 'noacc') {
      return 'Not Achieved';
    } else if (resultVal == 'acc') {
      return 'Achieved';
    } else if (resultVal == 'noeval') {
      return 'Not Evaluated';
    } else {
      return '';
    }
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
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // widgetSelectorFields(),
              widgetTop(context),
              (_selectedClass!.isEmpty || _selectedAssessment.isEmpty)
                  ? const Text("")
                  : Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 12.0,
                      ),
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.40,
                      child: Card(
                        shadowColor: Colors.pink,
                        elevation: 10.0,
                        child: Container(
                          alignment: Alignment.topCenter,
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                tableContainerZero(
                                  studentList[currentStudentIndex]['rollNo'],
                                  Container(
                                    decoration: BoxDecoration(),
                                    child: Text(
                                      nameForamtter(
                                          studentList[currentStudentIndex]
                                              ['studentName']),
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  context,
                                ),
                                tableContainer(
                                  "Not Evaluated",
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(),
                                    child: Checkbox(
                                      value: studentIdCheckboxVal[
                                          currentStudentId],
                                      onChanged: (bool? newValue) {
                                        var checkBoxValue =
                                            studentIdCheckboxVal[
                                                currentStudentId];
                                        if (kDebugMode) {
                                          setState(() {
                                            studentIdCheckboxVal[
                                                currentStudentId] = newValue!;
                                            if (newValue == true) {
                                              setState(() {
                                                studentIdResultSheet[
                                                        currentStudentId] =
                                                    'noeval';
                                              });
                                            }
                                          });
                                          if (checkBoxValue == false) {
                                            print(newValue.toString());
                                            print(checkBoxValue.toString());
                                          } else if (checkBoxValue == true) {
                                            print(newValue.toString());
                                            print(checkBoxValue.toString());
                                          } else {
                                            print("in else");
                                          }
                                        }
                                        setState(() {
                                          checkBoxValue = newValue as bool;
                                        });
                                        // widget.userActionHandler(newValue as bool);
                                        // widget.userActionHandler();
                                      },
                                    ),
                                  ),
                                  context,
                                ),
                                (studentIdCheckboxVal[currentStudentId] ==
                                        false)
                                    ? tableContainer(
                                        "Marks",
                                        markFields(totQues, context),
                                        context,
                                      )
                                    : const Text(""),
                                (studentIdCheckboxVal[currentStudentId] ==
                                        false)
                                    ? tableContainer(
                                        "Total",
                                        Container(
                                          decoration: BoxDecoration(),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            totalCalculator(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ),
                                        context,
                                      )
                                    : const Text(""),
                                (studentIdCheckboxVal[currentStudentId] ==
                                        false)
                                    ? tableContainer(
                                        "Result",
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          decoration: BoxDecoration(),
                                          child: Text(
                                            resultFormatter(),
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        context)
                                    : const Text(''),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

              (_selectedClass!.isEmpty || _selectedAssessment.isEmpty)
                  ? const Text("")
                  : Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(),
                      width: MediaQuery.of(context).size.width * 0.90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (currentStudentIndex > 0 &&
                                  currentStudentIndex < studentList.length)
                              ? Container(
                                  decoration: BoxDecoration(),
                                  child: TextButton(
                                    onPressed: () {
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
                                      }
                                    },
                                    child: Icon(
                                      Icons.arrow_back_outlined,
                                      size: 40,
                                    ),
                                  ),
                                )
                              : const Text(""),
                          (currentStudentIndex >= 0 &&
                                  currentStudentIndex < studentList.length - 1)
                              ? Container(
                                  decoration: BoxDecoration(),
                                  child: TextButton(
                                    onPressed: () {
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
                                      }
                                    },
                                    child: Icon(
                                      Icons.arrow_forward_outlined,
                                      size: 40,
                                    ),
                                  ),
                                )
                              : const Text(""),
                        ],
                      ),
                    ),
              (_selectedClass!.isEmpty || _selectedAssessment.isEmpty)
                  ? const Text("")
                  : widgetSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}
