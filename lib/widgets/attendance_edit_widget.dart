import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school/services/database_handler.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

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
      width: MediaQuery.of(context).size.width * 0.30,
      height: MediaQuery.of(context).size.height * 0.08,
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 2.5,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 0.2,
        horizontal: 0.2,
      ),
      decoration: BoxDecoration(
        border: Border.all(),
        // color: Colors.red,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            headerString,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.5,
            ),
            maxLines: 2,
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.5,
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

  Widget columnTitleBuilder(int index) {
    switch (index) {
      case 0:
        return Container(
          // margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 5.0),
          // padding: const EdgeInsets.symmetric(horizontal: 0.60),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: 1 == 2 ? Colors.lightBlueAccent : Colors.blueGrey,
            ),
            // borderRadius: BorderRadius.circular(4.0),
            color: Colors.blue.shade400,
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: const Text(
            'Name',
            softWrap: false,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
        );

      case 1:
        return Container(
          // margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 5.0),
          // padding: const EdgeInsets.symmetric(horizontal: 0.60),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: 1 == 2 ? Colors.lightBlueAccent : Colors.blueGrey,
            ),
            // borderRadius: BorderRadius.circular(4.0),
            color: Colors.blue.shade400,
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: const Text(
            'Present',
            softWrap: false,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
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

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        // borderRadius: BorderRadius.circular(4.0),
        color: isEven
            ? const Color.fromARGB(127, 120, 165, 255)
            : const Color.fromARGB(255, 120, 165, 255),
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Text(
        studentList[index]['rollNo'],
        softWrap: false,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
          color: Colors.black,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
      ),
    );
  }

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
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            // borderRadius: BorderRadius.circular(4.0),
            color: isEven
                ? const Color.fromARGB(127, 120, 165, 255)
                : const Color.fromARGB(255, 120, 165, 255),
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              studentList[studentRowIndex]['studentName'],
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
                color: Colors.black,
              ),
              softWrap: false,
              textAlign: TextAlign.left,
            ),
          ),
        );
      // return ;
      case 1:
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            // borderRadius: BorderRadius.circular(4.0),
            color: isEven
                ? const Color.fromARGB(127, 120, 165, 255)
                : const Color.fromARGB(255, 120, 165, 255),
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
        // borderRadius: BorderRadius.circular(4.0),
        color: Colors.blue.shade400,
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const Text(
        'Roll No',
        softWrap: false,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
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
          border: Border.all(color: Colors.black),
          // borderRadius: BorderRadius.circular(2.0),
        ),
        width: MediaQuery.of(context).size.width * 0.80,
        height: MediaQuery.of(context).size.height * 0.6,
        // padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
        child: StickyHeadersTable(
          cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
              columnWidths: List<double>.generate(2, (int index) => 120),
              rowHeights:
                  List<double>.generate(studentList.length, (int index) => 75),
              stickyLegendWidth: 100,
              stickyLegendHeight: 75),
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          countBoxWidget("Students", totalStudent),
                          countBoxWidget("Toal Present", totalPresent),
                          countBoxWidget("Total Absent", totalAbsent),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    child: attendanceTableEdit(),
                    height: MediaQuery.of(context).size.height * 0.5,
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
