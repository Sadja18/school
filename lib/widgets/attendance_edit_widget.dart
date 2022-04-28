// ignore_for_file: prefer_const_constructors, unnecessary_import, unused_import

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school/services/database_handler.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import './assist/image_assist.dart';

class EditAttendance extends StatefulWidget {
  final dynamic isSynced;
  final List<dynamic> absentees;
  final List<dynamic> studentList;
  final String selectedDate;

  const EditAttendance({
    Key? key,
    required this.absentees,
    required this.studentList,
    required this.selectedDate,
    required this.isSynced,
  }) : super(key: key);

  @override
  _EditAttendanceState createState() => _EditAttendanceState();
}

class _EditAttendanceState extends State<EditAttendance> {
  String _selectedDate = '';
  List _absentees = [];

  int reset = 0;

  int totalStudent = 0;
  int totalPresent = 0;
  int totalAbsent = 0;

  List<dynamic> studentList = [];
  Map<String, bool> checkBoxVals = {};

  int currentRowIndex = 0;

  TextEditingController absenteeCSVController = TextEditingController();

  ScrollController verticalBodyController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController verticalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalBodyController =
      ScrollController(initialScrollOffset: 0.0);

  int columnsLengthCalculator() {
    return 1;
  }

  int rowsLengthCalculator() {
    return studentList.length;
  }

  void countInitializer() {
    setState(() {
      totalStudent = studentList.length;
      totalAbsent = _absentees.length;
      totalPresent = studentList.length - _absentees.length;
    });
  }

  void checkBoxValsInitializer() {
    for (var i = 0; i < studentList.length; i++) {
      var record = studentList[i];

      var studentIdInt = record['studentId'];
      var studentId = studentIdInt.toString();

      if (_absentees.contains(studentId)) {
        checkBoxVals[studentId] = false;
      } else {
        checkBoxVals[studentId] = true;
      }
    }
  }

  Widget countBoxWidget(String headerString, int value, boxColor) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.28,
      height: MediaQuery.of(context).size.height * 0.05,
      margin: const EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 1.0,
      ),
      decoration: BoxDecoration(
          // border: Border.all(),

          // color: boxColor,
          ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: InkWell(
          onTap: () {
            if (_absentees.isNotEmpty) {
              if (kDebugMode) {
                print(_absentees[0].runtimeType);
              }
              if (headerString == "Absent: ") {
                showAbsentStudentsPreview();
              }
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  headerString,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: boxColor,
                  ),
                  maxLines: 1,
                ),
              ),
              Center(
                child: Text(
                  '$value',
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: boxColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ScrollControllers scrollControllers() {
    return ScrollControllers(
      verticalTitleController: verticalTitleController,
      verticalBodyController: verticalBodyController,
      horizontalTitleController: horizontalTitleController,
      horizontalBodyController: horizontalBodyController,
    );
  }

  double verticalRowScrollOffset() {
    double scrollOffset = 75.0;
    if (currentRowIndex == 0.0) {
      return 0.0;
    } else {
      return scrollOffset * currentRowIndex;
    }
  }

  var columnTitleColor = Color.fromARGB(255, 156, 45, 175);
  var textColor = Color.fromARGB(255, 230, 100, 253);

  Widget columnTitleBuilder(int index) {
    switch (index) {
      default:
        return const Text('');
    }
  }

  Widget rowsTitleBuilder(int index) {
    var isEven = index % 2 == 0;
    String studentId = studentList[index]['studentId'].toString();

    return Card(
      color: Colors.transparent,
      shadowColor: Colors.purple.shade200,
      elevation: 8.0,
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
            TableRow(children: [
              TableCell(
                child: AvatarGeneratorNew(
                    base64Code: studentList[index]['profilePic']),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(),
                        width: MediaQuery.of(context).size.width * 0.60,
                        child: Text(
                          nameForamtter(studentList[index]['studentName']),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
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
                            Text(
                              "Roll: ",
                              style: TextStyle(
                                fontSize: 15.0,
                              ),
                            ),
                            Text(
                              studentList[index]['rollNo'],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
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
            ]),
          ],
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

  Map<String, Color> rowColor = {};
  Map<String, Color> rowTextColor = {};

  Widget cellWidget2(int columnIndex, int studentRowIndex) {
    // return const Text('data');
    var studentIdInt = studentList[studentRowIndex]['studentId'];
    var studentId = studentIdInt.toString();
    // var isEven = studentRowIndex % 2 == 0;
    switch (columnIndex) {
      case 0:
        return Card(
          color: Colors.transparent,
          elevation: 8.0,
          shadowColor: Colors.purple.shade200,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(
              vertical: 2.5,
            ),
            decoration: BoxDecoration(
              // border: Border.all(),
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              color: (rowColor[studentId] == null)
                  ? Color.fromARGB(255, 46, 122, 116)
                  : rowColor[studentId]!,
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  currentRowIndex = studentRowIndex;
                });
                if (widget.isSynced == 'false' || widget.isSynced == false) {
                  if (checkBoxVals[studentId] == true ||
                      _absentees.contains(studentId) == false) {
                    // if student was marked present previously
                    // mark him/her absent
                    rowColor[studentId] = Colors.red;
                    rowTextColor[studentId] = Colors.white;

                    if (!_absentees.contains(studentId)) {
                      setState(() {
                        _absentees.add(studentId);
                        _absentees.sort();
                        totalAbsent = totalAbsent + 1;
                        totalPresent = totalPresent - 1;
                      });
                    }
                    setState(() {
                      rowColor[studentId] = Colors.red;
                      checkBoxVals[studentId] = false;
                    });
                  } else {
                    // if student was marked absent previously
                    // mark him/her present

                    if (_absentees.contains(studentId)) {}
                    setState(() {
                      _absentees.removeWhere((item) => item == studentId);
                      _absentees.sort();
                      totalAbsent = totalAbsent - 1;
                      totalPresent = totalPresent + 1;
                    });
                    setState(() {
                      rowColor[studentId] = Color.fromARGB(255, 46, 122, 116);
                      checkBoxVals[studentId] = true;
                    });
                  }
                }
              },
              child: Text(
                checkBoxVals[studentId] == true ? 'P' : 'A',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );

      default:
        return const Text('');
    }
  }

  Widget legendCellBuilder() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            12.0,
          ),
        ),
        color: columnTitleColor,
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const Text(
        'Student',
        softWrap: false,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget attendanceTableEdit() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      height: MediaQuery.of(context).size.height * 0.635,
      width: MediaQuery.of(context).size.width,
      // padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
      child: StickyHeadersTable(
        cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
          columnWidths: [MediaQuery.of(context).size.width * 0.12],
          rowHeights:
              List<double>.generate(studentList.length, (int index) => 75),
          stickyLegendWidth: MediaQuery.of(context).size.width * 0.85,
          stickyLegendHeight: 0,
        ),
        initialScrollOffsetX: 0.0,
        initialScrollOffsetY: verticalRowScrollOffset(),
        scrollControllers: scrollControllers(),
        columnsLength: columnsLengthCalculator(),
        rowsLength: rowsLengthCalculator(),
        columnsTitleBuilder: (i) => columnTitleBuilder(i),
        rowsTitleBuilder: (i) => rowsTitleBuilder(i),
        contentCellBuilder: (i, j) => cellWidget2(i, j),
        legendCell: const Text(''),
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
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
        content: Text(message),
      ),
    );
  }

  Future<void> showAlertFinal(
      String title, String message, String submissionDate) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        titlePadding: const EdgeInsets.all(0),
        contentPadding: const EdgeInsets.all(0),
        title: title == ""
            ? SizedBox(
                height: 0,
              )
            : Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xfff21bce),
                      Color(0xff826cf0),
                    ],
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              var className = studentList[0]['className'];
              if (kDebugMode) {
                print(className);
              }

              var absentees = _absentees;
              var selectedDate = _selectedDate;

              if (kDebugMode) {
                print(absentees.toString());
                print(selectedDate);
              }

              DBProvider.db.saveAttendance(selectedDate, className,
                  submissionDate, jsonEncode(absentees));
              setState(() {
                _absentees = [];
                studentList = [];
                _selectedDate = '';
                reset = 1;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
        content: showAbsentStudentsPreviewOnSubmit(),
      ),
    );
  }

  int absentMarkerOneGo(List<String> csvNames) {
    if (kDebugMode) {
      print(csvNames);
    }
    int popIt = 0;

    for (var rollNo in csvNames) {
      for (var student in studentList) {
        if (student['rollNo'].toString() == rollNo) {
          var studentId = student['studentId'].toString();
          if (_absentees.contains(studentId) == false) {
            setState(() {
              _absentees.add(studentId);
              _absentees.sort();
              totalAbsent = _absentees.length;
              totalPresent = totalStudent - _absentees.length;
              rowColor[studentId] = Colors.red;
              checkBoxVals[studentId] = false;
            });
          }
        }
      }
    }
    popIt = 1;
    return popIt;
  }

  int shortCutDataProcessor(String value) {
    List<String> rollsUntrimmed = value.split(",");
    List<String> rolls = [];

    for (String rollUntrimmed in rollsUntrimmed) {
      String rollTrimmed = rollUntrimmed.trim();
      rolls.add(rollTrimmed);
    }

    if (kDebugMode) {
      print(rolls.toString());
    }
    int popIt = absentMarkerOneGo(rolls);
    return popIt;
  }

  Future<void> _displayAbsentMarkShortMode() async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Enter Roll No. of Absentees\n(use comma to enter multiple)',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  var value = absenteeCSVController.text;
                  if (kDebugMode) {
                    print('editing controller');
                    print(value.toString());
                  }
                  var popIt = 0;

                  if (value.toString().isNotEmpty &&
                      value.toString() != "" &&
                      value.toString().split(",")[0] != "") {
                    popIt = shortCutDataProcessor(value.toString());
                  }

                  if (popIt == 1) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Save"),
              ),
            ],
            content: TextField(
              controller: absenteeCSVController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 15.0,
              ),
              onChanged: (value) {
                if (kDebugMode) {
                  // print(value.toString());
                  print("onchange");
                }
              },
            ),
          );
        });
  }

  int showAbsenteeTableFlag = 0;
  void showAbsenteeTableOnClick() {
    if (showAbsenteeTableFlag == 0) {
      setState(() {
        showAbsenteeTableFlag = 1;
      });
    } else {
      showAbsenteeTableFlag = 0;
    }
  }

  Map<String, String> dataReturner(index) {
    var details = {"studentName": "", "studentRoll": "", "studentPhoto": ""};
    for (var student in studentList) {
      if (student['studentId'] == _absentees[index]) {
        details['studentName'] = student['studentName'];
        details['studentPhoto'] = student['profilePic'];
        details['studentRoll'] = student['rollNo'];
      }
    }
    return details;
  }

  Widget absenteeRowTitleBuilder(index) {
    String studentPhoto = '';
    String studentName = '';
    String studentRoll = '';

    var details = dataReturner(index);
    if (details.isNotEmpty &&
        details['studentPhoto'] != null &&
        details['studentName'] != null &&
        details['studentRoll'] != null) {
      studentPhoto = details['studentPhoto']!;
      studentName = details['studentName']!;
      studentRoll = details['studentRoll']!;
    }
    return Card(
      elevation: 8.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (studentPhoto != "")
                  ? AvatarGeneratorNew(base64Code: studentPhoto)
                  : const Text(""),
              Container(
                decoration: BoxDecoration(),
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      alignment: Alignment.centerRight,
                      child: Text(
                        nameForamtter(studentName),
                        style: const TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(),
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(),
                            child: Text(
                              'Roll: ',
                              style: const TextStyle(
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(),
                            child: Text(
                              studentRoll,
                              style: const TextStyle(
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget cellWidget() {
    return Card(
      elevation: 8.0,
      child: Container(
        alignment: Alignment.center,
        // decoration: ,

        child: const Text(
          'A',
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  Widget absenteeStickyTable() {
    return Container(
      decoration: BoxDecoration(),
      child: StickyHeadersTable(
        columnsLength: 1,
        scrollControllers: scrollControllers(),
        rowsLength: _absentees.length,
        initialScrollOffsetX: 0.0,
        initialScrollOffsetY: 0.0,
        rowsTitleBuilder: (i) => absenteeRowTitleBuilder(i),
        columnsTitleBuilder: (i) => const Text(""),
        contentCellBuilder: (i, j) => cellWidget(),
      ),
    );
  }

  @override
  void initState() {
    for (var studentId in widget.absentees) {
      rowColor[studentId] = Colors.red;
      checkBoxVals[studentId] = false;
    }
    setState(() {
      _absentees = widget.absentees;
      _absentees.sort();
      studentList = widget.studentList;
      _selectedDate = widget.selectedDate;
    });

    if (studentList.isNotEmpty) {
      checkBoxValsInitializer();
      countInitializer();
    }
    super.initState();
  }

  Widget studentData(String studentId) {
    String studentName = "";
    var rollNo;
    for (var student in studentList) {
      if (studentId == student['studentId'].toString()) {
        studentName = student['studentName'];
        rollNo = student['rollNo'];
      }
    }
    return Container(
      // alignment: ,
      decoration: BoxDecoration(),
      height: MediaQuery.of(context).size.height * 0.05,
      margin: const EdgeInsets.symmetric(
        vertical: 2.0,
      ),
      child: Table(
        columnWidths: const {
          0: FractionColumnWidth(0.10),
          1: FractionColumnWidth(0.80),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                child: Container(
                  decoration: BoxDecoration(
                      // border: Border.all(),
                      ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 5.0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    rollNo.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  decoration: BoxDecoration(
                      // border: Border.all(),
                      ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 5.0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nameForamtter(studentName),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget showAbsentStudentsPreviewOnSubmit() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      height: MediaQuery.of(context).size.height * 0.80,
      margin: const EdgeInsets.only(
        top: 8.0,
      ),
      decoration: BoxDecoration(),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FractionColumnWidth(0.25),
                1: FractionColumnWidth(0.75),
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: const Text(
                          "Roll",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: const Text(
                          "Name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FractionColumnWidth(0.25),
                1: FractionColumnWidth(0.75),
              },
              children: List.generate(_absentees.length, (index) {
                var studentId = _absentees[index];
                String rollNo = "";
                String studentName = "";

                for (var student in studentList) {
                  if (studentId == student['studentId'].toString()) {
                    studentName = nameForamtter(student['studentName']);
                    rollNo = student['rollNo'];
                  }
                }
                return TableRow(
                  children: [
                    TableCell(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          rollNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          left: 12.0,
                        ),
                        child: Text(
                          studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showAbsentStudentsPreview() async {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Container(
              height: MediaQuery.of(context).size.height * 0.08,
              alignment: Alignment.center,
              // height: 0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xfff21bce),
                    Color(0xff826cf0),
                  ],
                ),
              ),
              child: const Text(
                'Absent Students',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.all(0),
            titlePadding: const EdgeInsets.all(0),
            content: Container(
              // width: MediaQuery.of(context).size.width * 0.80,
              height: MediaQuery.of(context).size.height * 0.20,
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(_absentees.length, (index) {
                    return studentData(_absentees[index]);
                  }),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return (reset == 0)
        ? Container(
            decoration: BoxDecoration(
                // color: Colors.redAccent
                ),
            margin: const EdgeInsets.only(
              top: 8.0,
            ),
            height: MediaQuery.of(context).size.height * 0.95,
            child: Column(
              children: [
                // Text('${ MediaQuery.of(context).size.height }'),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.05,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 1.0,
                  ),
                  decoration: BoxDecoration(
                      // color: Colors.grey,
                      ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        countBoxWidget("Total: ", totalStudent,
                            Color.fromARGB(238, 95, 61, 247)),
                        countBoxWidget("Present: ", totalPresent,
                            Color.fromARGB(255, 46, 122, 116)),
                        countBoxWidget("Absent: ", totalAbsent, Colors.red),
                        Container(
                          decoration: BoxDecoration(
                            // color: Colors.deepPurpleAccent,
                            color: Colors.transparent,
                          ),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(
                            top: 2.0,
                          ),
                          child: TextButton(
                            // hoverColor: Colors.blue,
                            // iconSize: 35,
                            onPressed: () {
                              _displayAbsentMarkShortMode();
                            },
                            child: Image.asset(
                              'assets/icons/search_icon.jpeg',
                              fit: BoxFit.fill,
                              height: 50,
                              width: 35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                attendanceTableEdit(),
                (widget.isSynced == 'false' || widget.isSynced == false)
                    ? Container(
                        margin: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 0.0,
                        ),
                        width: MediaQuery.of(context).size.width * 0.30,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: ElevatedButton(
                          onPressed: () {
                            if (studentList.isNotEmpty) {
                              var title = "";
                              var message = "Press Confirm to Submit";
                              // \nUse Sync Data button in the dashboard sidebar to sync this to server";
                              var submissionDateUnformatted =
                                  DateTime.now().toUtc();
                              DateFormat submissionFormat =
                                  DateFormat('yyyy-MM-dd HH:mm:ss');

                              var submissionDate = submissionFormat
                                  .format(submissionDateUnformatted);
                              if (kDebugMode) {
                                print('Submitting to local');

                                print(submissionDate);
                              }
                              title = "Absent Students";
                              showAlertFinal(title, message, submissionDate);
                            } else {
                              var title = "No Records";
                              var message =
                                  "There is no valid attendance taken.\nSubmitting will ignore it.";
                              showAlert(title, message);
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      )
                    : SizedBox(
                        height: 0,
                      ),
              ],
            ),
          )
        : const Text('');
  }
}
