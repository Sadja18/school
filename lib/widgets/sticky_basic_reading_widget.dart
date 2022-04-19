// ignore_for_file: unused_import

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
import './language_widget.dart';
import './row_handler.dart';
import './assist/image_assist.dart';

class StickyBasicReading extends StatefulWidget {
  static const routeName = '/basic-new';
  const StickyBasicReading({Key? key}) : super(key: key);

  @override
  _StickyBasicReadingState createState() => _StickyBasicReadingState();
}

class _StickyBasicReadingState extends State<StickyBasicReading> {
  List<dynamic> studentList = [];
  String? _selectedClass = '';
  String? _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? _selectedLanguage = '';
  List<String> levelNames = [];
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
  }

  void selectedDate(String? selectDate) {
    setState(() {
      _selectedDate = selectDate.toString();
    });
    if (kDebugMode) {
      print('reverse date callback');
    }
  }

  void selectLanguage(String? selectedLang) {
    if (kDebugMode) {
      print('reverse language callback');
    }
    setState(() {
      _selectedLanguage = selectedLang;
    });
    // get levels here
    if (_selectedClass != null || _selectedClass != '') {
      DBProvider.db
          .getReadingLevels(_selectedClass, _selectedLanguage)
          .then((records) {
        if (records.isNotEmpty) {
          var levelRecords = records.toList();
          if (kDebugMode) {
            log(levelRecords.toString());
          }
          List<String> levelName = [];
          for (var levelRecord in levelRecords) {
            levelName.add(levelRecord['name']);
          }
          setState(() {
            levelNames = levelName;
            levelNames.insert(0, 'NE');
          });

          for (var student in studentList) {
            setState(() {
              resultSheet[student['studentId'].toString()] = 'NE';
            });
          }
        }
      });
    }
  }

  dynamic getBgColor(int studentRowIndex) {
    var studentIdInt = studentList[studentRowIndex]['studentId'];
    var studentId = studentIdInt.toString();
    var bgColor = Colors.transparent;
    // if(kDebugMode){
    //   print("get BG coloe");
    //   print(resultSheet.toString());
    //   print(resultSheet[studentId]);
    // }
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

  void getAllStudents(List<dynamic> students) {
    setState(() {
      studentList = students;
    });
  }

  void updateLevel(dynamic levelVal, int index) {
    var studentIdInt = studentList[index]['studentId'];
    var studentId = studentIdInt.toString();

    if (levelVal == 'NE' || levelVal == '0' || levelVal == "") {
      setState(() {
        levelSheet[studentId] = 'NE';
      });
    } else {
      levelSheet[studentId] = levelVal.toString();
    }

    if (kDebugMode) {
      // print(studentId.runtimeType);
      print('valskbhacf');
      print(levelVal.runtimeType);
      print(levelVal.toString());

      // print(levelSheet.toString());
      // print(resultSheet.runtimeType);
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
    var headers = ["Level", "Result"];
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: 1 == 2 ? Colors.lightBlueAccent : Colors.blueGrey,
        ),
        // borderRadius: BorderRadius.circular(4.0),
        color: Colors.blue.shade400,
      ),
      child: const Text(
        "",
        softWrap: false,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        maxLines: 4,
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

  Widget rowsTitleBuilder(int index) {
    var isEven = index % 2 == 0;

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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
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
        '',
        softWrap: true,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget studentDropDown(int studentRowIndex) {
    return LevelDropDown(
      index: studentRowIndex,
      updateLevel: updateLevel,
      levelNames: levelNames,
      bgColor: getBgColor(studentRowIndex),
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
      case 0:
        return Card(
          elevation: 8.0,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              color: getBgColor(studentRowIndex),
            ),
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: studentDropDown(studentRowIndex),
              ),
            ),
          ),
        );
      case 1:
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            color: isEven
                ? const Color.fromARGB(127, 120, 165, 255)
                : const Color.fromARGB(255, 120, 165, 255),
          ),
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: resultWidget(studentRowIndex),
          ),
        );
      // case 0:
      //   return Container(
      //     decoration: BoxDecoration(
      //       border: Border.all(
      //         color: Colors.black,
      //       ),
      //       color: isEven
      //           ? const Color.fromARGB(127, 120, 165, 255)
      //           : const Color.fromARGB(255, 120, 165, 255),
      //     ),
      //     alignment: Alignment.center,
      //     child: Text(
      //       studentList[studentRowIndex]['rollNo'],
      //       overflow: TextOverflow.ellipsis,
      //       style: const TextStyle(
      //         fontWeight: FontWeight.bold,
      //         fontSize: 15.0,
      //         color: Colors.black,
      //       ),
      //       softWrap: false,
      //       textAlign: TextAlign.left,
      //     ),
      //   );
      default:
        return const Text('');
    }
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

  Widget assessmentTable() {
    return Center(
      child: Container(
        decoration: const BoxDecoration(),
        child: StickyHeadersTable(
          cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
              columnWidths: [MediaQuery.of(context).size.width * 0.12],
              rowHeights:
                  List<double>.generate(studentList.length, (int index) => 68),
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
              basicAssessmentProcessor(studentList, _selectedDate,
                  _selectedLanguage, submissionDate);
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
          'Basic Reading',
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
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: topRow(context),
              ),
              (studentList.isEmpty)
                  ? const Text('')
                  : Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 2.0,
                        // horizontal: 8.0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 1.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: LanguageDropDown(
                          className: _selectedClass!,
                          selectLanguage: selectLanguage),
                    ),
              (studentList.isNotEmpty &&
                      (_selectedLanguage != null && _selectedLanguage != ''))
                  ? Container(
                      alignment: Alignment.topCenter,
                      // decoration: BoxDecoration(
                      //     // border: Border.all(),
                      //     ),
                      height: MediaQuery.of(context).size.height * 0.67,
                      width: MediaQuery.of(context).size.width,
                      child: assessmentTable(),
                    )
                  : const Text(''),
              (studentList.isNotEmpty &&
                      (_selectedLanguage != null && _selectedLanguage != ''))
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
                                "After confirm, please sync to server";
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
                              print(_selectedLanguage);
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
