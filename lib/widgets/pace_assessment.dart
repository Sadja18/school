// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import, unused_field, unused_local_variable, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

import '../services/database_handler.dart';
import './assessment_select.dart';
import './class_dropdown.dart';
import '../services/pre_submit_validation.dart';
import '../screens/dashboard.dart';
import '../screens/login.dart';
import './assist/image_assist.dart';

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
    setState(() {
      studentIdResultSheet[studentId] = '';
      studentIdCheckboxVal[studentId] = false;
      studentIdMarksMap[studentId] = zeroMarksList;
    });
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

        // for(var student in studentList){
        //  var studentId =  student['studentId'];
        // }
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

  Widget topRow(context) {
    return Container(
      decoration: const BoxDecoration(),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.06,
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(
            width: 3.0,
            color: Color.fromARGB(255, 204, 204, 204),
          ),
          outside: BorderSide.none,
        ),
        columnWidths: const <int, TableColumnWidth>{
          0: FractionColumnWidth(0.335),
          1: FractionColumnWidth(0.665),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: const BoxDecoration(),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0.0,
                    vertical: 0.0,
                  ),
                  child: ClassDropDown(
                    getAllStudents: getAllStudents,
                    selectClass: classSelector,
                  ),
                ),
              ),
              (_selectedClass != "")
                  ? TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        // width: MediaQuery.of(context).size.width * 0.20,
                        decoration: const BoxDecoration(
                          color: Colors.deepPurpleAccent,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 0.0,
                          vertical: 0.0,
                        ),
                        height: MediaQuery.of(context).size.height * 0.06,

                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: AssessmentsDropDown(
                            selectClass: _selectedClass,
                            selectAssessment: assessmentSelector,
                          ),
                        ),
                      ),
                    )
                  : TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        // width: MediaQuery.of(context).size.width * 0.20,
                        decoration: const BoxDecoration(
                          color: Colors.deepPurpleAccent,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 0.0,
                          vertical: 0.0,
                        ),
                        height: MediaQuery.of(context).size.height * 0.06,

                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: const Text(""),
                        ),
                      ),
                    ),
            ],
          )
        ],
      ),
    );
  }

  Widget secondRow() {
    return (_selectedAssessment.isNotEmpty)
        ? Container(
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
            ),
            width: MediaQuery.of(context).size.width,
            child: Table(
              border: TableBorder.symmetric(
                inside: BorderSide(
                  width: 3.0,
                  color: Color.fromARGB(255, 204, 204, 204),
                ),
                outside: BorderSide.none,
              ),
              columnWidths: const <int, TableColumnWidth>{
                0: FractionColumnWidth(0.30),
                1: FractionColumnWidth(0.30),
                2: FractionColumnWidth(0.30),
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Container(
                        alignment: Alignment.center,
                        // width: MediaQuery.of(context).size.width * 0.80,
                        // height: MediaQuery.of(context).size.height * 0.06,
                        decoration: BoxDecoration(),
                        child: Text(
                          displayDate(_selectedAssessment['date'].toString()),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        alignment: Alignment.center,
                        // width: MediaQuery.of(context).size.width * 0.80,
                        // height: MediaQuery.of(context).size.height * 0.06,
                        decoration: BoxDecoration(),
                        child: Text(
                          _selectedAssessment['subject_name'].toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        // height: MediaQuery.of(context).size.height * 0.06,
                        decoration: BoxDecoration(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            _selectedAssessment['qp_code_name'].toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : const Text("");
  }

  Widget widgetTop(context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          topRow(context),
          (_selectedClass == "" || _selectedAssessment.isEmpty)
              ? const Text("")
              : secondRow(),
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

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      width: MediaQuery.of(context).size.width * 0.10,
      child: Column(
        children: [
          Text(
            'Q${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          TextFormField(
            // key: marksFieldKeys[index],
            initialValue: initialValue,
            // controller: TextEditingController(text: initialValue),
            decoration: InputDecoration(hintText: 'Q${index + 1}'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (kDebugMode) {
                print(value.toString());
                print(_totmarks.toString());
                
                print(studentIdResultSheet.toString());
                print(studentIdMarksMap.toString());
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
        ],
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

  List<Widget> marksFieldList() {
    int totalQuestions = totQues;
    List<Widget> inputFieldList = [];
    for (var i = 0; i < totalQuestions; i++) {
      String initialValue = '0';
      var marksList = studentIdMarksMap[currentStudentId];

      if (kDebugMode) {
        print(marksList);
      }

      if (marksList![i] != double.parse(initialValue) && marksList[i] > 0) {
        initialValue = marksList[i].toString();
      }
      inputFieldList.add(
        textFormFieldForMarks(i, initialValue),
      );
    }
    return inputFieldList;
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

  ScrollController verticalBodyController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController verticalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalBodyController =
      ScrollController(initialScrollOffset: 0.0);

  Widget userInputWidget(studentId, int studentRowIndex) {
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.blue,
      // ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.60,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(
                  8.0,
                ),
                color: Colors.white,
              ),
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width,
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(3),
                  1: FixedColumnWidth(200),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: AvatarGeneratorNew(
                            base64Code: studentList[studentRowIndex]
                                ['profilePic']),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: const BoxDecoration(),
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  nameForamtter(studentList[studentRowIndex]
                                      ['studentName']),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  softWrap: false,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Roll: ",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    Text(
                                      studentList[studentRowIndex]['rollNo'],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                        color: Colors.black,
                                      ),
                                      softWrap: false,
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Wrap(
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                children: marksFieldList(),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
              child: Column(
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    totalCalculator(),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.10,
              child: SizedBox(
                child: Column(
                  children: [
                    Text(
                      'Result',
                      style: TextStyle(
                        fontSize: 16,
                      fontWeight: FontWeight.bold,

                      ),
                    ),
                    Text(
                      resultFormatter(),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showUserInputWidget(studentRowIndex) {
    var studentId = studentList[studentRowIndex]['studentId'];
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Container(
              height: 0,
            ),
            content: userInputWidget(studentId, studentRowIndex),
            actions: [
              TextButton(
                onPressed: () {
                  if (kDebugMode) {
                    print('Close dialog');
                    // print(object)
                  }
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 35,
                ),
              ),
            ],
          );
        });
  }

  Widget rowsTitleBuilder(int studentRowIndex) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.transparent,
        shadowColor: Colors.purple.shade200,
        elevation: 8.0,
        child: InkWell(
          onTap: () {
            if (kDebugMode) {
              print('this student');
              print(studentList[studentRowIndex]['studentName'].toString());
            }
            var studentId = studentList[studentRowIndex]['studentId'];
            setState(() {
              currentStudentId = studentId;
            });
            if (kDebugMode) {
              print('this student');
              print(currentStudentId.toString());
              print(studentIdResultSheet.toString());
              print(studentIdMarksMap.toString());
            }
            showUserInputWidget(studentRowIndex);
          },
          child: Container(
            // alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              // borderRadius: BorderRadius.circular(4.0),
              color: Colors.white,
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 2.5,
            ),
            padding: const EdgeInsets.only(
              left: 8.0,
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(3),
                1: FixedColumnWidth(200),
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: AvatarGeneratorNew(
                          base64Code: studentList[studentRowIndex]
                              ['profilePic']),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: const BoxDecoration(),
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: Text(
                                nameForamtter(studentList[studentRowIndex]
                                    ['studentName']),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Roll: ",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  Text(
                                    studentList[studentRowIndex]['rollNo'],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                      color: Colors.black,
                                    ),
                                    softWrap: false,
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String resultName(studentResultVal) {
    String result = '';
    if(kDebugMode){
      print(_totmarks);
      print(studentResultVal);
    }

    switch (studentResultVal) {
      case 'noacc':
        result = 'Not Achieved';
        break;
      case 'acc':
        result = 'Achieved';
        break;
      case 'noeval':
        result = 'NE';
        break;
      default:
        result = 'NE';
        break;
    }
    ;
    return result;
  }

  Widget contentCellBuilder(int columnIndex, int studentRowIndex) {
    return Card(
      elevation: 8.0,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(
            8.0,
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Text(
            (studentIdResultSheet[studentList[studentRowIndex]['studentId']] !=
                        null &&
                    studentIdResultSheet[studentList[studentRowIndex]
                            ['studentId']] !=
                        "")
                ? resultName(studentIdResultSheet[studentList[studentRowIndex]
                    ['studentId']]!)
                : 'NE',
          ),
        ),
      ),
    );
  }

  Widget assessmentTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: StickyHeadersTable(
          initialScrollOffsetX: 0.0,
          initialScrollOffsetY: 0.0,
          scrollControllers: ScrollControllers(
            verticalBodyController: verticalBodyController,
            verticalTitleController: verticalTitleController,
            horizontalBodyController: horizontalBodyController,
            horizontalTitleController: horizontalTitleController,
          ),
          cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
              columnWidths: [
                90,
              ],
              rowHeights:
                  List<double>.generate(studentList.length, (int index) => 68),
              stickyLegendWidth: 320,
              stickyLegendHeight: 0),
          columnsLength: 1,
          rowsLength: studentList.length,
          columnsTitleBuilder: (i) => const Text(""),
          rowsTitleBuilder: (i) => rowsTitleBuilder(i),
          contentCellBuilder: (i, j) => contentCellBuilder(i, j)),
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
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.68,
                      child: assessmentTable(),
                      // Card(
                      //   shadowColor: Colors.pink,
                      //   elevation: 10.0,
                      //   child: Container(
                      //     alignment: Alignment.topCenter,
                      //     width: MediaQuery.of(context).size.width * 0.90,
                      //     child: SingleChildScrollView(
                      //       scrollDirection: Axis.vertical,
                      //       child: Column(
                      //         mainAxisAlignment: MainAxisAlignment.start,
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           tableContainerZero(
                      //             studentList[currentStudentIndex]['rollNo'],
                      //             Container(
                      //               decoration: BoxDecoration(),
                      //               child: Text(
                      //                 nameForamtter(
                      //                     studentList[currentStudentIndex]
                      //                         ['studentName']),
                      //                 style: const TextStyle(
                      //                   fontSize: 18.0,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //             ),
                      //             context,
                      //           ),
                      //           tableContainer(
                      //             "Not Evaluated",
                      //             Container(
                      //               alignment: Alignment.centerLeft,
                      //               decoration: BoxDecoration(),
                      //               child: Checkbox(
                      //                 value: studentIdCheckboxVal[
                      //                     currentStudentId],
                      //                 onChanged: (bool? newValue) {
                      //                   var checkBoxValue =
                      //                       studentIdCheckboxVal[
                      //                           currentStudentId];
                      //                   if (kDebugMode) {
                      //                     setState(() {
                      //                       studentIdCheckboxVal[
                      //                           currentStudentId] = newValue!;
                      //                       if (newValue == true) {
                      //                         setState(() {
                      //                           studentIdResultSheet[
                      //                                   currentStudentId] =
                      //                               'noeval';
                      //                         });
                      //                       }
                      //                     });
                      //                     if (checkBoxValue == false) {
                      //                       print(newValue.toString());
                      //                       print(checkBoxValue.toString());
                      //                     } else if (checkBoxValue == true) {
                      //                       print(newValue.toString());
                      //                       print(checkBoxValue.toString());
                      //                     } else {
                      //                       print("in else");
                      //                     }
                      //                   }
                      //                   setState(() {
                      //                     checkBoxValue = newValue as bool;
                      //                   });
                      //                   // widget.userActionHandler(newValue as bool);
                      //                   // widget.userActionHandler();
                      //                 },
                      //               ),
                      //             ),
                      //             context,
                      //           ),
                      //           (studentIdCheckboxVal[currentStudentId] ==
                      //                   false)
                      //               ? tableContainer(
                      //                   "Marks",
                      //                   markFields(totQues, context),
                      //                   context,
                      //                 )
                      //               : const Text(""),
                      //           (studentIdCheckboxVal[currentStudentId] ==
                      //                   false)
                      //               ? tableContainer(
                      //                   "Total",
                      //                   Container(
                      //                     decoration: BoxDecoration(),
                      //                     alignment: Alignment.centerLeft,
                      //                     child: Text(
                      //                       totalCalculator(),
                      //                       style: const TextStyle(
                      //                         // fontWeight: FontWeight.bold,
                      //                         fontSize: 18.0,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   context,
                      //                 )
                      //               : const Text(""),
                      //           (studentIdCheckboxVal[currentStudentId] ==
                      //                   false)
                      //               ? tableContainer(
                      //                   "Result",
                      //                   Container(
                      //                     alignment: Alignment.centerLeft,
                      //                     decoration: BoxDecoration(),
                      //                     child: Text(
                      //                       resultFormatter(),
                      //                       style: const TextStyle(
                      //                         fontSize: 18.0,
                      //                         // fontWeight: FontWeight.bold,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   context)
                      //               : const Text(''),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ),

              // (_selectedClass!.isEmpty || _selectedAssessment.isEmpty)
              //     ? const Text("")
              //     : Container(
              //         alignment: Alignment.center,
              //         decoration: BoxDecoration(),
              //         width: MediaQuery.of(context).size.width * 0.90,
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             (currentStudentIndex > 0 &&
              //                     currentStudentIndex < studentList.length)
              //                 ? Container(
              //                     decoration: BoxDecoration(),
              //                     child: TextButton(
              //                       onPressed: () {
              //                         if (currentStudentIndex > 0 &&
              //                             currentStudentIndex <
              //                                 studentList.length) {
              //                           setState(() {
              //                             currentStudentIndex =
              //                                 currentStudentIndex - 1;
              //                             currentStudentId =
              //                                 studentList[currentStudentIndex]
              //                                     ['studentId'];
              //                           });
              //                         }
              //                       },
              //                       child: Icon(
              //                         Icons.arrow_back_outlined,
              //                         size: 40,
              //                       ),
              //                     ),
              //                   )
              //                 : const Text(""),
              //             (currentStudentIndex >= 0 &&
              //                     currentStudentIndex < studentList.length - 1)
              //                 ? Container(
              //                     decoration: BoxDecoration(),
              //                     child: TextButton(
              //                       onPressed: () {
              //                         if (currentStudentIndex >= 0 &&
              //                             currentStudentIndex <
              //                                 studentList.length - 1) {
              //                           setState(() {
              //                             currentStudentIndex =
              //                                 currentStudentIndex + 1;
              //                             currentStudentId =
              //                                 studentList[currentStudentIndex]
              //                                     ['studentId'];
              //                           });
              //                         }
              //                       },
              //                       child: Icon(
              //                         Icons.arrow_forward_outlined,
              //                         size: 40,
              //                       ),
              //                     ),
              //                   )
              //                 : const Text(""),
              //           ],
              //         ),
              //       ),
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
