// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import, unused_field, unused_local_variable, sized_box_for_whitespace, avoid_unnecessary_containers

import 'dart:developer';

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
  State<PaceAssessmentScreen> createState() =>
      _PaceAssessmentScreenState();
}

class _PaceAssessmentScreenState extends State<PaceAssessmentScreen> {
  String? _selectedClass = '';
  List<dynamic> studentList = [];
  dynamic _grading = [];
  late final double _totmarks;
  var _selectedAssessment = {};

  var currentStudentId = -10;
  int currentStudentIndex = 0;
  int currentRowIndex = 0;

  int totQues = 0;
  List<double> zeroMarksList = [];
  Map<int, List<double>> studentIdMarksMap = {};
  Map<int, String> studentIdResultSheet = {};
  Map<int, String> studentIdTotalSheet = {};
  Map<int, bool> studentIdCheckboxVal = {};

  void classSelector(selectedClass) {
    // if (kDebugMode) {
    //   print('Selected Class: ' + selectedClass.runtimeType.toString());
    //   print('Selected Class: ' + selectedClass.toString());
    // }
    if (selectedClass != "" && selectedClass != null) {
      setState(() {
        _selectedClass = selectedClass;
      });
    }
  }

  void sheetMapsInitiator(int studentId) {
    if (totQues > 0) {
      zeroMarksList = List.generate(totQues, (index) => 0.0);
    }

    setState(() {
      studentIdResultSheet[studentId] = 'NE';
      studentIdCheckboxVal[studentId] = false;
      studentIdMarksMap[studentId] =
          List.generate(totQues, (index) => 0.0);
      studentIdTotalSheet[studentId] = "0.0";
    });
    if (kDebugMode) {
      print('in sheet map in');
      // print(studentIdMarksMap.toString());
    }
  }

  void getAllStudents(List<dynamic> students) {
    if (students.isNotEmpty) {
      for (var index = 0; index < students.length; index++) {
        students[index].remove('level');
        students[index]['result'] = '';
        var studentId = students[index]['studentId'];
      }
      setState(() {
        studentList = students;
        currentStudentId = studentList[0]['studentId'];
      });

      _getGradingSystem();
    }
  }

  Future<void> _getGradingSystem() async {
    var value = await DBProvider.db.getPaceGrading();
    if (kDebugMode) {
      print("fetch grades");
      // print(value.toString());
    }
    if (value.isNotEmpty) {
      // print(value);
      setState(() {
        _grading = value.toList();
      });
      // if (kDebugMode) {
      //   print(value.runtimeType);
      //   // print(_grading.runtimeType());
      // }
    }
    // print(value);
  }

  void assessmentSelector(dynamic value) {
    try {
      var map = {};
      value.forEach((k, v) => map[k] = v);
      if (kDebugMode) {
        // print('assessment select gen');
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

      for (var index = 0; index < studentList.length; index++) {
        var studentId = studentList[index]['studentId'];
        sheetMapsInitiator(studentId);
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
      height: MediaQuery.of(context).size.height * 0.08,
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(
            width: 3.0,
            color: Color.fromARGB(255, 204, 204, 204),
          ),
          outside: BorderSide.none,
        ),
        columnWidths: const <int, TableColumnWidth>{
          0: FractionColumnWidth(0.350),
          1: FractionColumnWidth(0.620),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.08,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5.0,
                        ),
                        height: MediaQuery.of(context).size.height * 0.08,
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
                        height: MediaQuery.of(context).size.height * 0.08,
                        child: Center(
                          child: const Text(
                            "Select Assessment",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
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
            height: MediaQuery.of(context).size.height * 0.08,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.symmetric(
                inside: BorderSide(
                  color: Colors.white,
                ),
                outside: BorderSide(
                  color: Colors.white,
                ),
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
                      child: Card(
                        borderOnForeground: true,
                        // shape: ShapeBorder,
                        color: Colors.deepPurpleAccent,
                        elevation: 18.0,
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            displayDate(
                                _selectedAssessment['date'].toString()),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Card(
                        color: Colors.deepPurpleAccent,
                        borderOnForeground: true,
                        elevation: 18.0,
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
                    ),
                    TableCell(
                      child: Card(
                        color: Colors.deepPurpleAccent,
                        elevation: 18.0,
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2.0,
                          ),
                          decoration: BoxDecoration(),
                          child: Text(
                            _selectedAssessment['qp_code_name'].toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
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
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
          // color: Colors.green,
          ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          topRow(context),
          (_selectedClass == "" || _selectedAssessment.isEmpty)
              ? const Text("")
              : secondRow(),
        ],
      ),
    );
  }

  void saveDataToDB() async {
    Map<String, dynamic> assessmentData = {};
    assessmentData['assessmentName'] = _selectedAssessment['name'];
    assessmentData['subjectName'] = _selectedAssessment['subject_name'];
    assessmentData['medium_name'] = _selectedAssessment['medium_name'];
    assessmentData['qp_code'] = _selectedAssessment['qp_code'];
    assessmentData['qp_code_name'] = _selectedAssessment['qp_code_name'];
    assessmentData['scheduledDate'] = _selectedAssessment['date'];
    assessmentData['className'] = _selectedClass.toString();
    assessmentData['uploadDate'] =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    assessmentData['result'] = studentIdResultSheet;
    assessmentData['marksheet'] = studentIdTotalSheet;
    /*
{
  assessmentName: IGUJARATI/ENGLISH/2022-04-07029, 
  subjectName: ENGLISH, 
  mediumName: GUJARATI, 
  qp_code: 15, 
  qp_code_name: I/GUJARATI/ENGLISH/021, 
  scheduledDate: 2022-04-07, 
  className: I-A-GUJ, 
  uploadDate: 2022-04-26 11:10:31, 
  result: {
    2240: Not Achieved, 2242: NE, 2243: NE, 24603: NE, 24604: NE, 24605: NE, 
    24606: NE, 24607: NE, 24608: NE, 24609: NE, 24610: NE, 24611: NE, 24612: NE,
    24614: NE}, 
  marksheet: {
    2240: [5.0, 0.0, 0.0, 0.0, 0.0], 2242: [0.0, 0.0, 0.0, 0.0, 0.0], 
    2243: [0.0, 0.0, 0.0, 0.0, 0.0], 24603: [0.0, 0.0, 0.0, 0.0, 0.0], 
    24604: [0.0, 0.0, 0.0, 0.0, 0.0], 24605: [0.0, 0.0, 0.0, 0.0, 0.0], 
    24606: [0.0, 0.0, 0.0, 0.0, 0.0], 24607: [0.0, 0.0, 0.0, 0.0, 0.0], 
    24608: [0.0, 0.0, 0.0, 0.0, 0.0], 24609: [0.0, 0.0, 0.0, 0.0, 0.0], 
    24610: [0.0, 0.0, 0.0, 0.0, 0.0], 24611: [0.0, 0.0, 0.0, 0.0, 0.0], 
    24612: [0.0, 0.0, 0.0, 0.0, 0.0], 24614: [0.0, 0.0, 0.0, 0.0, 0.0],},
}
*/

    if (kDebugMode) {
      var result = assessmentData['result'];
      var markSheet = assessmentData['marksheet'];
      log(markSheet.toString());
      log("some 9");
      log(result.toString());
    }
    // assessmentData
    await DBProvider.db.savePaceAssessment(assessmentData);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: SizedBox(
              height: 0,
            ),
            titlePadding: const EdgeInsets.all(0),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.10,
              alignment: Alignment.center,
              child: const Text(
                "Assessment Saved Successfully",
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        });
  }

  Widget widgetSubmitButton() {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 245, 97, 220),
        ),
        onPressed: () {
          saveDataToDB();
        },
        child: const Text("Submit"),
      ),
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

  String nameFormatter(studentName) {
    String formattedName = "";

    for (var i = 0; i < studentName.split(" ").length; i++) {
      String word = studentName.split(" ")[i];
      String newWord =
          toBeginningOfSentenceCase(word.toLowerCase()).toString();
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

  ScrollController verticalBodyController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController verticalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalBodyController =
      ScrollController(initialScrollOffset: 0.0);

  void userInputHandler(int studentId, List<double> marksOfStudentId,
      String result, String totalMarksOfStudent) {
    if (kDebugMode) {
      print("For student $studentId");
      print(marksOfStudentId.toString());
      print(result);
      print(totalMarksOfStudent);
    }

    setState(() {
      studentIdResultSheet[studentId] = resultName(result);
      studentIdMarksMap[studentId] = marksOfStudentId;
      studentIdTotalSheet[studentId] = totalMarksOfStudent;
      // studentList[]
    });
  }

  Future<void> showUserInputWidget(studentRowIndex) {
    var studentId = studentList[studentRowIndex]['studentId'];
    var totMarks = _totmarks;
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext ctx) {
          return AlertDialog(
            // backgroundColor: Colors.deepPurpleAccent,
            titlePadding: const EdgeInsets.all(0),
            title: Container(
              height: 0,
            ),
            contentPadding: const EdgeInsets.all(0),
            content: UserInputWidget(
              studentId: studentId,
              maximumMarks: totMarks,
              totalQuestions: totQues,
              userInputHandler: userInputHandler,
              studentTotalMarks: 0.0,
              formatterStudentName: nameFormatter(
                  studentList[studentRowIndex]['studentName']!),
              profilePic: studentList[studentRowIndex]['profilePic']!,
              rollNo: studentList[studentRowIndex]['rollNo'].toString(),
              obtainedMarksList: studentIdMarksMap[
                  studentList[studentRowIndex]['studentId']]!,
              studentGrading: _grading,
              isEvaluated: studentIdCheckboxVal[
                  studentList[studentRowIndex]['studentId']]!,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (kDebugMode) {
                    print('Close dialog');
                    // print(object)
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("Save"),
              ),
            ],
          );
        });
  }

  Widget rowsTitleBuilder(int studentRowIndex) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.transparent,
        shadowColor: Colors.purple.shade200,
        elevation: 8.0,
        child: InkWell(
          onTap: () {
            var studentId = studentList[studentRowIndex]['studentId'];

            if (kDebugMode) {
              print('this student');
              // print(_totmarks);
            }

            setState(() {
              currentRowIndex = studentRowIndex;
            });

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
                              width:
                                  MediaQuery.of(context).size.width * 0.60,
                              child: Text(
                                nameFormatter(studentList[studentRowIndex]
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
                                    studentList[studentRowIndex]['rollNo']
                                        .toString(),
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
    if (kDebugMode) {
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
          // border: Border.all(),
          borderRadius: BorderRadius.circular(
            8.0,
          ),
          color: studentIdResultSheet[studentList[studentRowIndex]
                      ['studentId']] ==
                  'NE'
              ? Colors.blue
              : studentIdResultSheet[studentList[studentRowIndex]
                          ['studentId']] ==
                      'Not Achieved'
                  ? Colors.red
                  : Colors.green,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Text(
            studentIdResultSheet[studentList[studentRowIndex]
                        ['studentId']] ==
                    'NE'
                ? studentIdResultSheet[studentList[studentRowIndex]
                        ['studentId']]!
                    .toString()
                : studentIdTotalSheet[studentList[studentRowIndex]
                        ['studentId']]!
                    .toString(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  double verticalRowScrollOffset() {
    double scrollOffset = 112.0;
    if (currentRowIndex == 0.0) {
      return 0.0;
    } else {
      return scrollOffset * currentRowIndex;
    }
  }

  Widget assessmentTable() {
    return Container(
      child: StickyHeadersTable(
        initialScrollOffsetX: 0.0,
        initialScrollOffsetY: verticalRowScrollOffset(),
        scrollControllers: ScrollControllers(
          verticalBodyController: verticalBodyController,
          verticalTitleController: verticalTitleController,
          horizontalBodyController: horizontalBodyController,
          horizontalTitleController: horizontalTitleController,
        ),
        cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
            columnWidths: [
              MediaQuery.of(context).size.width * 0.12,
            ],
            rowHeights: List<double>.generate(
                studentList.length, (int index) => 112),
            stickyLegendWidth: MediaQuery.of(context).size.width * 0.85,
            stickyLegendHeight: 0),
        columnsLength: 1,
        rowsLength: studentList.length,
        columnsTitleBuilder: (i) => const Text(""),
        rowsTitleBuilder: (i) => rowsTitleBuilder(i),
        contentCellBuilder: (i, j) => contentCellBuilder(i, j),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'PACE',
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
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Login.routeName, (route) => false);
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
                      vertical: 6.0,
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.63,
                    child: assessmentTable(),
                  ),

            (_selectedClass!.isEmpty || _selectedAssessment.isEmpty)
                ? const Text("")
                : widgetSubmitButton(),
          ],
        ),
      ),
    );
  }
}

class UserInputWidget extends StatefulWidget {
  final int studentId;
  final double maximumMarks;
  final int totalQuestions;
  final double studentTotalMarks;
  final String profilePic;
  final String rollNo;
  final String formatterStudentName;
  final List<double>? obtainedMarksList;
  final bool isEvaluated;
  final Function(int, List<double>, String, String) userInputHandler;
  final dynamic studentGrading;
  const UserInputWidget(
      {Key? key,
      required this.studentId,
      required this.maximumMarks,
      required this.totalQuestions,
      required this.userInputHandler,
      required this.studentTotalMarks,
      required this.profilePic,
      required this.rollNo,
      required this.formatterStudentName,
      required this.obtainedMarksList,
      required this.studentGrading,
      required this.isEvaluated})
      : super(key: key);

  @override
  State<UserInputWidget> createState() => _UserInputWidgetState();
}

class _UserInputWidgetState extends State<UserInputWidget> {
  late double studentTotalMarks;
  late int studentId;
  late int totalQuestions;
  late double totMarks;
  late String rollNo;
  late String studentName;
  late String profilePic;
  bool enterTotal = true;
  List _grading = [];
  String studentResult = 'NE';
  List<double> obtainedMarks = [];

  bool isEvaluated = false;

  double calcPercentage(double total) {
    return (total / totMarks) * 100;
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

      if (gradeEntry['from_marks'] != null &&
          gradeEntry['to_marks'] != null) {
        var fromMarks = gradeEntry['from_marks'];
        var toMarks = gradeEntry['to_marks'];

        if (percentage >= fromMarks && percentage <= toMarks) {
          resultVal = gradeEntry['result'];
        }
      }
    }
    return resultVal;
  }

  void resultCalculator() {
    var percentage = calcPercentage(studentTotalMarks);
    var grade = calcGrade(percentage);

    if (kDebugMode) {
      print(grade);
      print(percentage);
      print(studentId);
    }

    setState(() {
      studentResult = grade;
    });
  }

  void totalCalculator() {
    double totalTmp = 0.0;
    if (kDebugMode) {
      print('total calculation called');
      print(studentTotalMarks.toString());
    }
    if (obtainedMarks.isNotEmpty) {
      for (var mark in obtainedMarks) {
        totalTmp = totalTmp + mark;
      }
    }

    if (studentTotalMarks > totMarks) {
      // show alert of marks greater than tot;
      showAlert("Error", "Student Marks total is more than maximum marks");
    }

    setState(() {
      studentTotalMarks = totalTmp;
    });

    if (kDebugMode) {
      print('total calculation');
      print(studentTotalMarks.toString());
    }
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

  String getTotalMarksInitialValue() {
    String total = "";
    double tmp = 0;
    for (var mark in obtainedMarks) {
      tmp = tmp + mark;
    }
    total = tmp.toString();
    return total;
  }

  Widget totalMarksField() {
    return Container(
      decoration: BoxDecoration(
          // border: Border.all(),
          ),
      alignment: Alignment.topCenter,
      child: Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FractionColumnWidth(0.60),
          1: FractionColumnWidth(0.30),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text("Total: "),
                ),
              ),
              TableCell(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: TextFormField(
                    initialValue: studentTotalMarks.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusColor: Colors.blue,
                    ),
                    onChanged: (value) {
                      if (kDebugMode) {
                        print("Inside total Marks field");
                      }
                      if (double.tryParse(value) != null) {
                        var nMark = double.parse(value);

                        if (nMark < 0) {
                          // show error marks cannot be ;less than zero
                          var title = "Invalid marks";
                          var message =
                              "Marks should not be less than zero";
                          showAlert(title, message);
                        } else {
                          // double totaltmp = nMark;
                          if (kDebugMode) {
                            print('$nMark for $studentId ');
                          }

                          if (nMark > totMarks) {
                            String title = "";
                            String message =
                                "Entered marks $nMark is greater than maximum marks $totMarks";
                            showAlert(title, message);
                          } else {
                            setState(() {
                              studentTotalMarks = nMark;
                            });

                            // totalCalculator();
                            resultCalculator();

                            if (kDebugMode) {
                              print("send tot user input handler");
                            }
                            widget.userInputHandler(
                                studentId,
                                obtainedMarks,
                                studentResult,
                                nMark.toString());
                          }
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textFields() {
    return Wrap(
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: List.generate(totalQuestions, (index) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.10,
          height: MediaQuery.of(context).size.height * 0.120,
          margin: const EdgeInsets.symmetric(
            horizontal: 8.0,
            // vertical: 5.0,
          ),
          child: Column(
            children: [
              Text(
                'Q${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(
                    8.0,
                  ),
                ),
                child: TextFormField(
                  initialValue: obtainedMarks[index].toString(),
                  textAlignVertical: TextAlignVertical.top,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '',
                    focusColor: Colors.blue,
                    contentPadding: EdgeInsets.zero,
                  ),

                  onChanged: (value) {
                    if (kDebugMode) {
                      print('onchange ${index + 1}');
                      // print(obtainedMarks);
                      print(
                          "Obtained marks here ${obtainedMarks[index].toString()} ");
                      print('tot');
                      print(totMarks);
                    }

                    if (double.tryParse(value) != null) {
                      var nMark = double.parse(value);

                      if (nMark < 0) {
                        // show error marks cannot be ;less than zero
                        var title = "Invalid marks";
                        var message = "Marks should not be less than zero";
                        showAlert(title, message);
                      } else {
                        if (kDebugMode) {
                          print('$nMark for $index ');
                        }
                        double totalTmp = 0.0;
                        for (var i = 0; i < totalQuestions; i++) {
                          if (index != i) {
                            totalTmp = totalTmp + obtainedMarks[i];
                          }
                        }
                        if (totalTmp + nMark > totMarks) {
                          String title = "";
                          String message =
                              "Total obtained marks exceeds the maximum marks by ${totalTmp + nMark - totMarks}";
                          showAlert(title, message);
                        } else {
                          setState(() {
                            obtainedMarks[index] = nMark;
                          });

                          totalCalculator();
                          resultCalculator();
                          widget.userInputHandler(studentId, obtainedMarks,
                              studentResult, studentTotalMarks.toString());
                        }
                      }
                    }
                  },
                  onEditingComplete: () {
                    if (kDebugMode) {
                      print('values');
                    }
                  },
                  onFieldSubmitted: (value) {},
                  // onSubmi
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Widget marksField() {
  //   return textFields();
  // }

  @override
  void initState() {
    setState(() {
      // studentTotalMarks = 0.0;
      studentId = widget.studentId;
      totalQuestions = widget.totalQuestions;
      totMarks = widget.maximumMarks;
      studentTotalMarks = widget.studentTotalMarks;
      rollNo = widget.rollNo;
      studentName = widget.formatterStudentName;
      profilePic = widget.profilePic;
      obtainedMarks = widget.obtainedMarksList!;
      _grading = widget.studentGrading;
      isEvaluated = widget.isEvaluated;
    });

    // if(kDebugMode){
    //   print(tot)
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: (isEvaluated == true)
          ? MediaQuery.of(context).size.height * 0.20
          : MediaQuery.of(context).size.height * 0.50,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Color(0xfff21bce),
                    Color(0xff826cf0),
                  ],
                ),
              ),
              // borderRadius: BorderRadius.circular(4.0),

              width: MediaQuery.of(context).size.width * 0.80,
              height: MediaQuery.of(context).size.height * 0.125,
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FractionColumnWidth(0.30),
                  1: FractionColumnWidth(0.70),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child:
                            AvatarGeneratorNewTwo(base64Code: profilePic),
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
                                width: MediaQuery.of(context).size.width *
                                    0.60,
                                child: Text(
                                  studentName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  softWrap: false,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Roll: ",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      rollNo,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                        color: Colors.white,
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
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              alignment: Alignment.topCenter,
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FractionColumnWidth(0.60),
                  1: FractionColumnWidth(0.30),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(),
                          child: const Text("Absent/NE"),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Checkbox(
                            value: isEvaluated,
                            onChanged: (value) {
                              setState(() {
                                isEvaluated = !isEvaluated;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            (isEvaluated == true)
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: const Text(""),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Table(
                          columnWidths: const <int, TableColumnWidth>{
                            0: FractionColumnWidth(0.60),
                            1: FractionColumnWidth(0.30),
                          },
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child:
                                        const Text('Enter total marks:'),
                                  ),
                                ),
                                TableCell(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Checkbox(
                                      value: enterTotal,
                                      onChanged: (bool? selection) {
                                        setState(() {
                                          enterTotal = !enterTotal;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        (enterTotal == true)
                            ? totalMarksField()
                            : Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height *
                                        0.190,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                                alignment: Alignment.topCenter,
                                child: SingleChildScrollView(
                                  child: textFields(),
                                ),
                              ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
