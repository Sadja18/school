// ignore_for_file: unused_import, unused_field, empty_statements

import 'dart:developer';

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
import './assist/image_assist.dart';

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

  // void getLevels(selectedClass) async {
  //   var queryResult = await DBProvider.db.getNumericLevels(selectedClass);
  //   var levels = queryResult.toList();
  //   List<String> levelList = [];
  //   if (kDebugMode) {
  //     print('llevels');
  //     print(levels.toString());
  //   }
  // }

  void selectClass(String selectedClass) {
    setState(() {
      _selectedClass = selectedClass;
    });
    if (kDebugMode) {
      print('reverse classData callback');
      print(selectedClass);
    }
    // getLevels(selectedClass);
    DBProvider.db.getNumericLevels(selectedClass).then((queryResult) {
      // print(levels.runtimeType);
      var levels = queryResult.toList();
      List<String> levelList = [];
      if (levels.isNotEmpty) {
        for (var level in levels) {
          levelList.add(level['name']);
        }
        setState(() {
          levelList.insert(0, 'NE');
          // levelList.insert(0, '0');
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
    // if (kDebugMode) {
    //   log(students.toString());
    // }
    setState(() {
      studentList = students;
    });
  }

  void updateLevel(dynamic levelVal, int index) {
    var studentIdInt = studentList[index]['studentId'];
    var studentId = studentIdInt.toString();

    var levelString = "";
    if (levelVal != '' && levelVal != '0' && levelVal != 'NE') {
      levelString = 'Achieved';
    } else {
      levelString = 'NE';
    }
    setState(() {
      studentList[index]['level'] = levelVal;
      // update here
      if (levelVal != '' && levelVal != '0' && levelVal != 'NE') {
        studentList[index]['result'] = 'Achieved';
        resultSheet[studentId] = 'Achieved';
      } else {
        studentList[index]['result'] = 'NE';
        resultSheet[studentId] = 'NE';
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
    return 1;
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
    var headers = ["Roll", "Level", "Result"];
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.deepPurpleAccent),
        child: const Text(""));
    // return Container(
    //   alignment: Alignment.center,
    //   decoration: BoxDecoration(
    //     border: Border.all(
    //       color: 1 == 2 ? Colors.lightBlueAccent : Colors.blueGrey,
    //     ),
    //     // borderRadius: BorderRadius.circular(4.0),
    //     color: Colors.blue.shade400,
    //   ),
    //   width: MediaQuery.of(context).size.width,
    //   height: MediaQuery.of(context).size.height,
    //   child: Text(
    //     headers[index],
    //     softWrap: false,
    //     style: const TextStyle(
    //       fontWeight: FontWeight.bold,
    //       fontSize: 16,
    //       color: Colors.white,
    //     ),
    //     overflow: TextOverflow.ellipsis,
    //     textAlign: TextAlign.left,
    //     maxLines: 4,
    //   ),
    // );
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
                        decoration: const BoxDecoration(),
                        width: MediaQuery.of(context).size.width * 0.60,
                        child: Text(
                          nameForamtter(studentList[index]['studentName']),
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
                              studentList[index]['rollNo'],
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
            ]),
          ],
        ),
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
        'Name',
        softWrap: false,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
      ),
    );
  }

  dynamic getBgColor(int studentRowIndex) {
    var studentIdInt = studentList[studentRowIndex]['studentId'];
    var studentId = studentIdInt.toString();
    var bgColor = Colors.transparent;
    switch (resultSheet[studentId]) {
      case 'NE':
        return bgColor = Colors.blue;
      // break;
      case 'Not Achieved':
        return bgColor = Colors.red;
      // break;
      case 'Achieved':
        return bgColor = Colors.green;
      // break;
      default:
        return bgColor = Colors.blue;
// break;
    }
  }

  Widget studentDropDown(int studentRowIndex) {
    if (kDebugMode) {
      print(getBgColor(studentRowIndex));
    }
    return LevelDropDown(
      index: studentRowIndex,
      updateLevel: updateLevel,
      levelNames: _levelNames,
      bgColor: getBgColor(studentRowIndex),
    );
  }

  Widget resultWidget(int studentRowIndex) {
    var studentIdInt = studentList[studentRowIndex]['studentId'];
    var studentId = studentIdInt.toString();
    if (resultSheet[studentId] != null) {
      switch (resultSheet[studentId]) {
        case 'NE':
          return Container(
            decoration: const BoxDecoration(color: Colors.blue),
          );
        case 'Not Achieved':
          return Container(
            decoration: const BoxDecoration(color: Colors.red),
          );
        case 'Achieved':
          return Container(
            decoration: const BoxDecoration(color: Colors.green),
          );
        default:
          return Container(
            decoration: const BoxDecoration(color: Colors.transparent),
          );
      }
    } else {
      return Container(
        decoration: const BoxDecoration(color: Colors.blue),
      );
    }
  }

  Widget cellWidget(int columnIndex, int studentRowIndex) {
    var isEven = studentRowIndex % 2 == 0;

    switch (columnIndex) {
      case 0:
        return Card(
          elevation: 8.0,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              color: getBgColor(studentRowIndex),
            ),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: studentDropDown(studentRowIndex),
            ),
          ),
        );
      case 1:
        return Card(
          elevation: 8.0,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              color: isEven
                  ? const Color.fromARGB(127, 120, 165, 255)
                  : const Color.fromARGB(255, 120, 165, 255),
            ),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: resultWidget(studentRowIndex),
            ),
          ),
        );
      case -1:
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
              studentList[studentRowIndex]['rollNo'],
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
        child: (1 == 2)
            ? const Text("")
            : StickyHeadersTable(
                cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
                    columnWidths: [
                      MediaQuery.of(context).size.width * 0.12,
                    ],
                    rowHeights: List<double>.generate(
                        studentList.length, (int index) => 68),
                    stickyLegendWidth: MediaQuery.of(context).size.width * 0.85,
                    stickyLegendHeight: 0),
                initialScrollOffsetX: 0.0,
                initialScrollOffsetY: 0.0,
                scrollControllers: scrollControllers(),
                columnsLength: columnsLengthCalculator(),
                rowsLength: rowsLengthCalculator(),
                columnsTitleBuilder: columnsTitleBuilder,
                rowsTitleBuilder: rowsTitleBuilder,
                contentCellBuilder: (i, j) => cellWidget(i, j),
                legendCell: const Text(""),
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

  Widget topRow(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.06,
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide.none,
          outside: BorderSide.none,
        ),
        columnWidths: const <int, TableColumnWidth>{
          0: FractionColumnWidth(0.50),
          1: FractionColumnWidth(0.50),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  decoration: const BoxDecoration(),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0.0,
                    vertical: 0.0,
                  ),
                  child: DateShow(
                    selectedDate: selectedDate,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  // width: MediaQuery.of(context).size.width * 0.20,
                  decoration: const BoxDecoration(),
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
        // margin: const EdgeInsets.symmetric(
        //   horizontal: 8.0,
        // ),
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
                width: MediaQuery.of(context).size.width,
                child: topRow(context),
              ),
              (studentList.isNotEmpty)
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.72,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 0.0,
                      ),
                      child: assessmentTable(),
                    )
                  : const Text(''),
              (studentList.isNotEmpty)
                  ? Container(
                      margin: const EdgeInsets.only(top: 6.0),
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
