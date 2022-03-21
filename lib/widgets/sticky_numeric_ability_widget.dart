// ignore_for_file: unused_import, unused_field, empty_statements

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import '../services/database_handler.dart';
import '../services/presave_processor.dart';
import '../services/pre_submit_validation.dart';

import './class_dropdown.dart';
import '../screens/dashboard.dart';
import '../screens/login.dart';
import './date_widget.dart';
import './row_handler.dart';

class StickyNumericAbility extends StatefulWidget {
  static const routeName = '/numeric-new';
  const StickyNumericAbility({Key? key}) : super(key: key);

  @override
  _StickyNumericAbilityState createState() => _StickyNumericAbilityState();
}

class _StickyNumericAbilityState extends State<StickyNumericAbility> {
  List<dynamic> studentList = [];
  String? _selectedClass = '';
  String? _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<String> _levelNames = [];
  Map<String?, Object?> levelSheet = {};
  Map<String?, String?> resultSheet = {};

  ScrollController verticalBodyController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController verticalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalBodyController =
      ScrollController(initialScrollOffset: 0.0);

  void selectClass(String selectedClass) {
    setState(() {
      _selectedClass = selectedClass;
    });
    if (kDebugMode) {
      print('reverse classData callback');
    }
    DBProvider.db.getNumericLevels(selectedClass).then((queryResult) {
      // print(levels.runtimeType);
      var levels = queryResult.toList();
      List<String> levelList = [];
      if (levels.isNotEmpty) {
        for (var level in levels) {
          levelList.add(level['name']);
        }
        setState(() {
          // levelList.insert(0, 'Not Evaluated');
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
    if (kDebugMode) {
      print('reverse date callback');
    }
  }

  void getAllStudents(List<dynamic> students) {
    setState(() {
      studentList = students;
    });
  }

  void updateLevel(dynamic levelVal, int index) {
    var studentIdInt = studentList[index]['studentId'];
    var studentId = studentIdInt.toString();

    var levelString = "";
    if (levelVal != '' && levelVal != '0') {
      levelString = 'Achieved';
    } else {
      levelString = 'Not Achieved';
    }
    setState(() {
      studentList[index]['level'] = levelVal;
      // update here
      if (levelVal != '' && levelVal != '0') {
        studentList[index]['result'] = 'Achieved';
        resultSheet[studentId] = 'Achieved';
      } else {
        studentList[index]['result'] = 'Not Achieved';
        resultSheet[studentId] = 'Not Achieved';
      }
      levelSheet[studentId] = levelString;
    });

    if (kDebugMode) {
      print(studentId.runtimeType);

      print(levelSheet.toString());
      print(resultSheet.runtimeType);
    }
  }

  int columnsLengthCalculator() {
    return 3;
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

  Widget columnsTitleBuilder(int index) {
    var headers = ["Name", "Level", "Result"];
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: 1 == 2 ? Colors.lightBlueAccent : Colors.blueGrey,
        ),
        // borderRadius: BorderRadius.circular(4.0),
        color: Colors.blue.shade400,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Text(
        headers[index],
        softWrap: false,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        maxLines: 4,
      ),
    );
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

  Widget studentDropDown(int studentRowIndex) {
    return LevelDropDown(
      index: studentRowIndex,
      updateLevel: updateLevel,
      levelNames: _levelNames,
    );
  }

  Widget resultWidget(int studentRowIndex) {
    var studentIdInt = studentList[studentRowIndex]['studentId'];
    var studentId = studentIdInt.toString();
    if (resultSheet[studentId] != null) {
      return Text(
        '${resultSheet[studentId]}',
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 4,
      );
    } else {
      return const Text('Not Evaluated');
    }
  }

  Widget cellWidget(int columnIndex, int studentRowIndex) {
    var isEven = studentRowIndex % 2 == 0;

    switch (columnIndex) {
      case 1:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            color: isEven
                ? const Color.fromARGB(127, 120, 165, 255)
                : const Color.fromARGB(255, 120, 165, 255),
          ),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: studentDropDown(studentRowIndex),
          ),
        );
      case 2:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            color: isEven
                ? const Color.fromARGB(127, 120, 165, 255)
                : const Color.fromARGB(255, 120, 165, 255),
          ),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Center(
              child: resultWidget(studentRowIndex),
            ),
          ),
        );
      case 0:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            color: isEven
                ? const Color.fromARGB(127, 120, 165, 255)
                : const Color.fromARGB(255, 120, 165, 255),
          ),
          alignment: Alignment.center,
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
      default:
        return const Text('');
    }
  }

  Widget assessmentTable() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
        ),
        // padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 24.0),
        child: StickyHeadersTable(
          cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
              columnWidths: List<double>.generate(
                  columnsLengthCalculator(), (int index) => 120),
              rowHeights:
                  List<double>.generate(studentList.length, (int index) => 100),
              stickyLegendWidth: 100,
              stickyLegendHeight: 100),
          initialScrollOffsetX: 0.0,
          initialScrollOffsetY: 0.0,
          scrollControllers: scrollControllers(),
          columnsLength: columnsLengthCalculator(),
          rowsLength: rowsLengthCalculator(),
          columnsTitleBuilder: columnsTitleBuilder,
          rowsTitleBuilder: rowsTitleBuilder,
          contentCellBuilder: (i, j) => cellWidget(i, j),
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
              if (kDebugMode) {
                print(studentList);
              }
              numericAssessmentProcessor(
                  studentList, _selectedDate, submissionDate);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Numeric Ability',
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
        margin: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
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
                        selectClass: selectClass,
                        getAllStudents: getAllStudents),
                  ],
                ),
              ),
              DateShow(selectedDate: selectedDate),
              (studentList.isNotEmpty)
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.50,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                            // color: Colors.blue,
                            ),
                      ),
                      child: assessmentTable(),
                    )
                  : const Text(''),
              (studentList.isNotEmpty)
                  ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 12.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (studentList.isEmpty ||
                              levelSheet.isEmpty ||
                              resultSheet.isEmpty) {
                            var title = "No Records";
                            var message =
                                "There is no valid assessment done.\nSubmitting will ignore it.";
                            showAlert(title, message);
                          } else {
                            var title = "Confirm Submit";
                            var message =
                                "Pressing Confirm will save the record.\n"
                                "After confirm please sync to server";
                            var submissionDateUnformatted = DateTime.now();
                            DateFormat submissionFormat =
                                DateFormat('yyyy-MM-dd HH:mm:ss');

                            var submissionDate = submissionFormat
                                .format(submissionDateUnformatted);

                            if (kDebugMode) {
                              print('Submitting to local');

                              print(submissionDate);
                              print(studentList);
                              print(_selectedDate);
                            }
                            showAlertFinal(title, message, submissionDate);
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    )
                  : const Text(''),
            ],
          ),
        ),
      ),
    );
  }
}
