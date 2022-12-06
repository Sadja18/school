// ignore_for_file: unused_import, prefer_const_literals_to_create_immutables, prefer_const_constructors

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
  // ignore: library_private_types_in_public_api
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
  Map<String, Color> bgColorSheet = {};

  int currentRowIndex = 0;

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
      _selectedClass = "";
      studentList = [];
    });
    if (kDebugMode) {
      print('reverse date callback');
    }
  }

  void selectLanguage(String? selectedLang) async {
    if (kDebugMode) {
      print('reverse language callback');
    }
    setState(() {
      _selectedLanguage = selectedLang;
    });
    // get levels here

    // if (kDebugMode) {
    // }
    if (_selectedClass != null || _selectedClass != '') {
      var records = await DBProvider.db
          .getReadingLevels(_selectedClass, _selectedLanguage);
      if (records.isNotEmpty) {
        var levelRecords = records.toList();
        if (kDebugMode) {
          log("Levels are");

          log("levelNames");
          log(levelRecords.toString());
        }
        List<String> levelName = [];
        for (var levelRecord in levelRecords) {
          levelName.add(levelRecord['name']);
        }
        setState(() {
          levelNames = levelName;
          // levelNames.insert(0, 'NE');
        });

        for (var student in studentList) {
          setState(() {
            resultSheet[student['studentId'].toString()] = 'NE';
            levelSheet[student['studentId'].toString()] = '';
            bgColorSheet[student['studentId'].toString()] = Colors.blue;
          });
        }
      }
    }
  }

  void getAllStudents(List<dynamic> students) {
    setState(() {
      studentList = students;
    });
  }

  int columnsLengthCalculator() {
    return 0;
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
    // var headers = ["Level", "Result"];
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
      String newWord =
          toBeginningOfSentenceCase(word.toLowerCase()).toString();
      formattedName = formattedName + newWord;
      if (i < studentName.split(" ").length - 1) {
        formattedName = formattedName + " ";
      }
    }

    return formattedName;
  }

  void userInputHandler(
      int studentRowIndex, String result, String selectedLevelName) {
    var studentIdString =
        studentList[studentRowIndex]['studentId'].toString();
    setState(() {
      studentList[studentRowIndex]['level'] = selectedLevelName;
      studentList[studentRowIndex]['result'] = result;
      levelSheet[studentIdString] = selectedLevelName;
      resultSheet[studentIdString] = result;
      (selectedLevelName != "" && result != "NE")
          ? bgColorSheet[studentIdString] = Colors.green
          : bgColorSheet[studentIdString] = Colors.blue;
    });
    if (kDebugMode) {
      print("User input handler set complete $studentRowIndex");
      print(levelSheet.toString());
      print(resultSheet.toString());
      // print(selectedLevelName);
    }
  }

  void showUserInputDialogBox(int studentRowIndex) async {
    String rollNo = studentList[studentRowIndex]['rollNo'].toString();
    String studentName =
        studentList[studentRowIndex]['studentName'].toString();
    String profilePic =
        studentList[studentRowIndex]['profilePic'].toString();

    if (kDebugMode) {
      log(studentRowIndex.toString());
    }

    if (levelNames.isNotEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(0),
              content: UserInputWidget(
                  rollNo: rollNo.toString(),
                  studentName: studentName,
                  profilePic: profilePic,
                  result: resultSheet[studentList[studentRowIndex]
                              ['studentId']]
                          .toString()
                          .isNotEmpty
                      ? resultSheet[studentList[studentRowIndex]
                              ['studentId']]
                          .toString()
                      : "",
                  levelNames: levelNames,
                  studentRowIndex: studentRowIndex,
                  selectedLevel: levelSheet[studentList[studentRowIndex]
                                  ['studentId']
                              .toString()] ==
                          null
                      ? ""
                      : levelSheet[studentList[studentRowIndex]
                                  ['studentId']
                              .toString()]!
                          .toString(),
                  userInputHandler: userInputHandler),
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text("No Reading Levels"),
              content: const Text(
                  "The assessment cannot be marked as no reading levels are configured for this class.\nPlease contact Dept Admin"),
            );
          });
    }
  }

  double verticalRowScrollOffset() {
    double scrollOffset = 112.0;
    if (currentRowIndex == 0.0) {
      return 0.0;
    } else {
      return scrollOffset * currentRowIndex;
    }
  }

  Widget rowsTitleBuilder(int index) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Card(
        color: Colors.blue,
        clipBehavior: Clip.none,
        shadowColor: Colors.purple.shade200,
        elevation: 8.0,
        child: InkWell(
          onTap: () {
            setState(() {
              currentRowIndex = index;
            });
            showUserInputDialogBox(index);
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              // borderRadius: BorderRadius.circular(4.0),
              color:
                  bgColorSheet[studentList[index]['studentId'].toString()],
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: const BoxDecoration(),
                            alignment: Alignment.center,
                            width:
                                MediaQuery.of(context).size.width * 0.60,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                nameForamtter(
                                    studentList[index]['studentName']),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                // border: Border.all(),
                                ),
                            width:
                                MediaQuery.of(context).size.width * 0.80,
                            child: Table(
                              columnWidths: const {
                                0: FractionColumnWidth(0.40),
                                1: FractionColumnWidth(0.60),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            // border: Border.all(),
                                            ),
                                        alignment: Alignment.center,
                                        child: Table(
                                          columnWidths: const {
                                            0: FractionColumnWidth(0.50),
                                            1: FractionColumnWidth(0.60),
                                          },
                                          children: [
                                            TableRow(
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.center,
                                                  decoration:
                                                      BoxDecoration(),
                                                  child: const Text(
                                                    "Roll: ",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  decoration: BoxDecoration(
                                                      // border: Border.all(),
                                                      ),
                                                  child: Text(
                                                    studentList[index]
                                                            ['rollNo']
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    (levelSheet[studentList[index]
                                                    ['studentId']
                                                .toString()] !=
                                            "")
                                        ? TableCell(
                                            child: Container(
                                              alignment: Alignment.topLeft,
                                              decoration: BoxDecoration(
                                                  // border: Border.all(),
                                                  ),
                                              child: Table(
                                                columnWidths: const {
                                                  0: FractionColumnWidth(
                                                      0.45),
                                                  1: FractionColumnWidth(
                                                      0.50),
                                                },
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      TableCell(
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          decoration:
                                                              BoxDecoration(),
                                                          child:
                                                              const Text(
                                                            "Level: ",
                                                            style:
                                                                TextStyle(
                                                              color: Colors
                                                                  .white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableCell(
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          decoration:
                                                              BoxDecoration(),
                                                          child: Text(
                                                            levelSheet[studentList[index]['studentId'].toString()].toString() ==
                                                                        "" ||
                                                                    levelSheet[studentList[index]['studentId'].toString()].toString() ==
                                                                        'null'
                                                                ? "0"
                                                                : levelSheet[
                                                                        studentList[index]['studentId'].toString()]
                                                                    .toString(),
                                                            style:
                                                                TextStyle(
                                                              color: Colors
                                                                  .white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
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

  Widget topRow(BuildContext context) {
    return Container(
      // alignment: Alignment.topCenter,
      decoration: const BoxDecoration(),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.058,
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide.none,
          outside: BorderSide.none,
        ),
        columnWidths: const <int, TableColumnWidth>{
          0: FractionColumnWidth(0.30),
          1: FractionColumnWidth(0.35),
          2: FractionColumnWidth(0.25)
        },
        children: [
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  height: MediaQuery.of(context).size.height * 0.075,
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
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.078,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0.0,
                    vertical: 0.0,
                  ),
                  child: ClassDropDown(
                    key: ObjectKey(_selectedDate),
                    selectClass: selectClass,
                    getAllStudents: getAllStudents,
                  ),
                ),
              ),
              (studentList.isEmpty)
                  ? TableCell(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.078,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          border: Border.all(
                            color: Colors.white,
                          ),
                        ),
                        child: const Text(
                          "Select Language",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : TableCell(
                      child: Container(
                        decoration: BoxDecoration(
                          // border: Border.all(),
                          color: Colors.deepPurpleAccent,
                          border: Border.all(
                            color: Colors.white,
                          ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.078,
                        child: LanguageDropDown(
                          className: _selectedClass!,
                          selectLanguage: selectLanguage,
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
    return Container(
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(),
      child: StickyHeadersTable(
        cellAlignments: CellAlignments.fixed(
            contentCellAlignment: Alignment.topCenter,
            stickyColumnAlignment: Alignment.topCenter,
            stickyRowAlignment: Alignment.topCenter,
            stickyLegendAlignment: Alignment.topCenter),
        cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
            columnWidths: [],
            rowHeights: List<double>.generate(
                studentList.length, (int index) => 112),
            stickyLegendWidth: MediaQuery.of(context).size.width,
            stickyLegendHeight: 0),
        initialScrollOffsetX: 0.0,
        initialScrollOffsetY: verticalRowScrollOffset(),
        scrollControllers: scrollControllers(),
        columnsLength: columnsLengthCalculator(),
        rowsLength: rowsLengthCalculator(),
        columnsTitleBuilder: columnsTitleBuilder,
        rowsTitleBuilder: rowsTitleBuilder,
        contentCellBuilder: (i, j) => Container(
          height: 0,
        ),
        legendCell: legendCellBuilder(),
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
            child: const Text(' Cancel'),
          ),
        ],
        content: Text(message),
      ),
    );
  }

  void dataSave(submissionDate) async {
    if (kDebugMode) {
      log("Pressed submit confirm");
      // log(resultSheet.toString());
      // log(levelSheet.toString());
      // for (var student in studentList) {
      var student = studentList[0];
      if (student['level'] != '0') {
        log(student['studentName']);
        log(student['studentId'].toString());
        log("level");
        log(student['level'].toString());
        log("level");
        log("result");
        log(student['result'].toString());
        log("result");
      }
      // }
    }

    await basicAssessmentProcessor(
        studentList, _selectedDate, _selectedLanguage, submissionDate);
    // Navigator.of(context).pop();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text("Assessment Saved Successfully"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget dataPreviewBeforeSave() {
    return Container(
      decoration: BoxDecoration(),
      height: MediaQuery.of(context).size.height * 0.80,
      width: MediaQuery.of(context).size.width * 0.80,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FractionColumnWidth(0.15),
                1: FractionColumnWidth(0.55),
                2: FractionColumnWidth(0.30),
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
                    TableCell(
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: const Text(
                          "Level",
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
                0: FractionColumnWidth(0.15),
                1: FractionColumnWidth(0.55),
                2: FractionColumnWidth(0.30),
              },
              children: List.generate(studentList.length, (index) {
                if (studentList[index]['result'] != "" &&
                    studentList[index]['level'] != '0') {
                  return TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            studentList[index]['rollNo'].toString(),
                            style: const TextStyle(
                              // fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
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
                            nameForamtter(studentList[index]['studentName']
                                .toString()),
                            style: const TextStyle(
                                // fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            studentList[index]['level'].toString(),
                            style: const TextStyle(
                                // fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return TableRow(
                    children: [
                      TableCell(
                        child: SizedBox(
                          height: 0,
                        ),
                      ),
                      TableCell(
                        child: SizedBox(
                          height: 0,
                        ),
                      ),
                      TableCell(
                        child: SizedBox(
                          height: 0,
                        ),
                      ),
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  void showAlertFinal(
      String title, String message, String submissionDate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog(
        title: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xfff21bce),
                Color(0xff826cf0),
              ],
            ),
          ),
          child: const Text(
            "Preview",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
              dataSave(submissionDate);
            },
            child: const Text('Confirm'),
          ),
        ],
        content: dataPreviewBeforeSave(),
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
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.079,
                // decoration: BoxDecoration(
                //   border: Border.all(),
                // ),
                child: topRow(context),
              ),
              (studentList.isNotEmpty &&
                      (_selectedLanguage != null &&
                          _selectedLanguage != ''))
                  ? Container(
                      alignment: Alignment.topCenter,
                      height: MediaQuery.of(context).size.height * 0.74,
                      width: MediaQuery.of(context).size.width,
                      child: assessmentTable(),
                    )
                  : const Text(''),
              (studentList.isNotEmpty &&
                      (_selectedLanguage != null &&
                          _selectedLanguage != ''))
                  ? Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 6.0),
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 245, 97, 220),
                        ),
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

class UserInputWidget extends StatefulWidget {
  final String studentName;
  final String rollNo;
  final String profilePic;
  final String result;
  final List<String> levelNames;
  final int studentRowIndex;
  final String selectedLevel;
  final Function(int, String, String) userInputHandler;
  // final String
  const UserInputWidget(
      {Key? key,
      required this.studentName,
      required this.rollNo,
      required this.profilePic,
      required this.result,
      required this.levelNames,
      required this.studentRowIndex,
      required this.selectedLevel,
      required this.userInputHandler})
      : super(key: key);

  @override
  State<UserInputWidget> createState() => _UserInputWidgetState();
}

class _UserInputWidgetState extends State<UserInputWidget> {
  bool isEvaluated = false;
  late String rollNo;
  late String studentName;
  late String profilePic;
  late String result;
  late List<String> levelNames = [];
  late String selectedLevel;

  String nameForamtter(studentName) {
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

  Widget topRow() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xfff21bce),
            Color(0xff826cf0),
          ],
        ),
      ),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.80,
      height: MediaQuery.of(context).size.height * 0.12,
      child: Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FractionColumnWidth(0.20),
          1: FractionColumnWidth(0.70),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                child: AvatarGeneratorNewTwo(base64Code: profilePic),
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
                          nameForamtter(studentName),
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
                          mainAxisAlignment: MainAxisAlignment.start,
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
    );
  }

  Widget absentNeCheckBox() {
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(),
      child: Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FractionColumnWidth(0.50),
          1: FractionColumnWidth(0.50),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                child: Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: const Text("Absent/NE:"),
                ),
              ),
              TableCell(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Checkbox(
                    value: isEvaluated,
                    onChanged: (bool? selection) {
                      setState(() {
                        isEvaluated = !isEvaluated;
                      });

                      if (isEvaluated == true) {
                        setState(() {
                          selectedLevel = "";
                        });
                        widget.userInputHandler(
                            widget.studentRowIndex, "NE", "");
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

  void updateLevel(selectedLevel, int studentRowIndex) {
    if (kDebugMode) {
      print("inside user inut widget");
    }
    setState(() {
      selectedLevel = selectedLevel;
    });
    widget.userInputHandler(studentRowIndex, "Achieved", selectedLevel!);
  }

  Widget dropdownSelection() {
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(),
      child: Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FractionColumnWidth(0.50),
          1: FractionColumnWidth(0.50),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                child: Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: const Text("Level:"),
                ),
              ),
              TableCell(
                child: Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(),
                  child: LevelDropDown(
                    index: widget.studentRowIndex,
                    updateLevel: updateLevel,
                    levelNames: levelNames,
                    bgColor: Colors.deepPurpleAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget checkBoxAndDropdown() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        absentNeCheckBox(),
        (isEvaluated == true)
            ? SizedBox(
                height: 0,
                width: 0,
              )
            : dropdownSelection(),
      ],
    );
  }

  Widget rows(String headerName, String value) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      columnWidths: const <int, TableColumnWidth>{
        0: FractionColumnWidth(0.50),
        1: FractionColumnWidth(0.50),
      },
      children: [
        TableRow(
          children: [
            TableCell(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(),
                child: Text(headerName),
              ),
            ),
            TableCell(
              child: Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(),
                child: Text(value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget instantiatedView() {
    return Container(
      decoration: BoxDecoration(),
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rows("Result: ", result),
          (isEvaluated == true)
              ? SizedBox(
                  height: 0,
                  width: 0,
                )
              : selectedLevel == "" || selectedLevel.isEmpty
                  ? SizedBox(
                      height: 0,
                    )
                  : rows("Level: ", selectedLevel),
          checkBoxAndDropdown(),
        ],
      ),
    );
  }

  Widget inputFields() {
    return Container(
      decoration: BoxDecoration(),
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.28,
      child: instantiatedView(),
    );
  }

  @override
  void initState() {
    setState(() {
      profilePic = widget.profilePic;
      rollNo = widget.rollNo;
      studentName = widget.studentName;
      result = widget.result;
      levelNames = widget.levelNames;
      selectedLevel = widget.selectedLevel;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          // color: Colors.blue,
          ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.450,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            topRow(),
            inputFields(),
          ],
        ),
      ),
    );
  }
}
