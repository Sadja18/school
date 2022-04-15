// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school/services/database_handler.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

class EditAttendance extends StatefulWidget {
  final List<dynamic> absentees;
  final List<dynamic> studentList;
  final String selectedDate;

  const EditAttendance({
    Key? key,
    required this.absentees,
    required this.studentList,
    required this.selectedDate,
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
  ScrollController verticalBodyController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController verticalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalBodyController =
      ScrollController(initialScrollOffset: 0.0);

  int columnsLengthCalculator() {
    return 2;
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

  Widget countBoxWidget(String headerString, int value) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.height * 0.05,
      margin: const EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 2.5,
      ),
      // padding: const EdgeInsets.symmetric(
      //   vertical: 1.0,
      //   horizontal: 1.0,
      // ),
      decoration: BoxDecoration(
        border: Border.all(),
        // color: Colors.red,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              headerString,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
          Center(
            child: Text(
              '$value',
              style: const TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
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

  var columnTitleColor = Color.fromARGB(255, 156, 45, 175);
  var textColor = Color.fromARGB(255, 230, 100, 253);

  Widget columnTitleBuilder(int index) {
    switch (index) {
      case 0:
        return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(
        //     12.0,
        //   ),
        // ),
        color: columnTitleColor,
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const Text(
        'Name',
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

      case 1:
        return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(
            12.0,
          ),
        ),
        color: columnTitleColor,
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const Text(
        'Present',
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

      default:
        return const Text('');
    }
  }

  Widget rowsTitleBuilder(int index) {
    var isEven = index % 2 == 0;
    String studentId = studentList[index]['studentId'].toString();

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        // borderRadius: BorderRadius.circular(4.0),
        color: (rowColor[studentId] == null)
            ? isEven
                ? Color.fromARGB(124, 204, 93, 248)
                : textColor
            : rowColor[studentId],
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Text(
        studentList[index]['rollNo'],
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          color: (rowTextColor[studentId] == null)
              ? Colors.black
              : rowTextColor[studentId],
        ),
        softWrap: false,
        textAlign: TextAlign.left,
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
    var isEven = studentRowIndex % 2 == 0;
    switch (columnIndex) {
      case 0:
        return Container(
          // margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 5.0),
          // padding: const EdgeInsets.symmetric(horizontal: 0.60),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(
            left: 2.0,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            // borderRadius: BorderRadius.circular(4.0),
            color: (rowColor[studentId] == null)
                ? isEven
                    ? Color.fromARGB(124, 204, 93, 248)
                    : textColor
                : rowColor[studentId],
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              nameForamtter(
                studentList[studentRowIndex]['studentName'],
              ),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: (rowColor[studentId] == null)
                    ? Colors.black
                    : rowTextColor[studentId],
              ),
              softWrap: false,
              textAlign: TextAlign.left,
            ),
          ),
        );
      // return ;
      case 1:
        return Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            // borderRadius: BorderRadius.circular(4.0),
            color: (rowColor[studentId] == null)
                ? isEven
                    ? Color.fromARGB(124, 204, 93, 248)
                    : textColor
                : rowColor[studentId],
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Checkbox(
            activeColor: Colors.green,
            // checkColor: Color.fromARGB(255, 110, 255, 115),
            value: checkBoxVals[studentId],
            onChanged: (bool? selection) {
              if (kDebugMode) {
                print('in checkbox onchange');
                print(selection.toString());
              }
              setState(() {
                checkBoxVals[studentId] = selection!;
              });
              if (selection == true) {
                rowColor[studentId] = Color.fromARGB(255, 6, 158, 85);
                rowTextColor[studentId] = Colors.white;
                // print('true');
                if (_absentees.contains(studentId)) {
                  _absentees.removeWhere((item) => item == studentId);
                  setState(() {
                    totalAbsent = totalAbsent - 1;
                    totalPresent = totalPresent + 1;
                  });
                }
              } else {
                // print('false');
                rowColor[studentId] = Color.fromARGB(255, 216, 37, 37);
                rowTextColor[studentId] = Colors.white;

                if (!_absentees.contains(studentId)) {
                  _absentees.add(studentId);
                  setState(() {
                    totalAbsent = totalAbsent + 1;
                    totalPresent = totalPresent - 1;
                  });
                }
              }
              if (kDebugMode) {
                print(_absentees);
                print(checkBoxVals);
              }
            },
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
        'Roll',
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
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.0),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              12.0,
            ),
            topRight: Radius.circular(
              12.0,
            ),
          ),
          // borderRadius: BorderRadius.circular(2.0),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.6,
        // padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
        child: StickyHeadersTable(
          cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
            columnWidths: [260, 80],
            rowHeights:
                List<double>.generate(studentList.length, (int index) => 50),
            stickyLegendWidth: 60,
            stickyLegendHeight: 50,
          ),
          initialScrollOffsetX: 0.0,
          initialScrollOffsetY: 0.0,
          scrollControllers: scrollControllers(),
          columnsLength: columnsLengthCalculator(),
          rowsLength: rowsLengthCalculator(),
          columnsTitleBuilder: (i) => columnTitleBuilder(i),
          rowsTitleBuilder: (i) => rowsTitleBuilder(i),
          contentCellBuilder: (i, j) => cellWidget2(i, j),
          legendCell: legendCellBuilder(),
        ),
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
            child: const Text('Re-enter'),
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
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Re-enter'),
          ),
          TextButton(
            onPressed: () {
              var className = studentList[0]['className'];
              if (kDebugMode) {
                print(className);
              }

              var absentees = _absentees;
              var selectedDate = _selectedDate;

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
        content: Text(message),
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      _absentees = widget.absentees;
      studentList = widget.studentList;
      _selectedDate = widget.selectedDate;
    });

    if (studentList.isNotEmpty) {
      checkBoxValsInitializer();
      countInitializer();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (reset == 0)
          ? SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          countBoxWidget("T: ", totalStudent),
                          countBoxWidget("P: ", totalPresent),
                          countBoxWidget("A: ", totalAbsent),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          12.0,
                        ),
                        topRight: Radius.circular(
                          12.0,
                        ),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    // decoration: const BoxDecoration(color: Colors.green),
                    child: attendanceTableEdit(),
                    height: MediaQuery.of(context).size.height * 0.50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (studentList.isNotEmpty) {
                        var title = "Confirm Submit";
                        var message =
                            "Press Confirm to Submit\nUse Sync Data button in the dashboard sidebar to sync this to to server";
                        var submissionDateUnformatted = DateTime.now().toUtc();
                        DateFormat submissionFormat =
                            DateFormat('yyyy-MM-dd HH:mm:ss');

                        var submissionDate =
                            submissionFormat.format(submissionDateUnformatted);
                        if (kDebugMode) {
                          print('Submitting to local');

                          print(submissionDate);
                        }
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
                ],
              ),
            )
          : const Text(''),
    );
  }
}
