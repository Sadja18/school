// ignore_for_file: unused_import, unused_field, empty_statements, prefer_const_constructors, prefer_const_literals_to_create_immutables

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
  Map<String, Object?> levelSheet = {};
  Map<String, String?> resultSheet = {};
  Map<String, Color> bgColorSheet = {};

  ScrollController verticalBodyController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController verticalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalBodyController =
      ScrollController(initialScrollOffset: 0.0);

  void selectClass(String selectedClass) async {
    setState(() {
      _selectedClass = selectedClass;
    });
    if (kDebugMode) {
      print('reverse classData callback');
      print(selectedClass);
    }

    var queryResult = await DBProvider.db.getNumericLevels(selectedClass);
    if (kDebugMode) {
      print('get numeric levels');
      print(queryResult.toString());
    }

    var levels = queryResult.toList();
    List<String> levelList = [];
    if (levels.isNotEmpty) {
      for (var level in levels) {
        levelList.add(level['name']);
      }
      setState(() {
        _levelNames = levelList;
      });
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

  void getAllStudents(List<dynamic> students) {
    setState(() {
      studentList = students;
    });
    // print(students[0].toString());
    for (var student in studentList) {
      setState(() {
        resultSheet[student['studentId'].toString()] = 'NE';
        levelSheet[student['studentId'].toString()] = '';
        bgColorSheet[student['studentId'].toString()] = Colors.blue;
      });
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
    // var headers = ["Roll", "Level", "Result"];
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.deepPurpleAccent),
        child: const Text(""));
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

  void userInputHandler(
      int studentRowIndex, String result, String selectedLevel) {
    if (kDebugMode) {
      print("Student Row $studentRowIndex $result $selectedLevel");
    }
    var studentIdString = studentList[studentRowIndex]['studentId'].toString();
    setState(() {
      resultSheet[studentIdString] = result;
      levelSheet[studentIdString] = selectedLevel;
    });
  }

  Future<void> showUserInputWidget(int studentRowIndex) async {
    String studentIdString =
        studentList[studentRowIndex]['studentId'].toString();
    String studentName = studentList[studentRowIndex]['studentName'].toString();
    String rollNo = studentList[studentRowIndex]['rollNo'].toString();
    String selectedLevel = levelSheet[studentIdString].toString();
    String result = resultSheet[studentIdString]!;
    String profilePic = studentList[studentRowIndex]['profilePic'] == null ||
            studentList[studentRowIndex]['profilePic'] == null
        ? ""
        : studentList[studentRowIndex]['profilePic'].toString();
    List<String> levelNames = _levelNames;
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            contentPadding: const EdgeInsets.all(0),
            title: SizedBox(
              height: 0,
            ),
            content: UserInputWidget(
                studentName: studentName,
                rollNo: rollNo,
                studentRowIndex: studentRowIndex,
                selectedLevel: selectedLevel,
                result: result,
                userInputHandler: userInputHandler,
                levelNames: levelNames,
                profilePic: profilePic),
          );
        });
  }

  Widget rowsTitleBuilder(int index) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.purple.shade200,
      elevation: 8.0,
      child: InkWell(
        onTap: () {
          if (kDebugMode) {
            print(bgColorSheet.toString());
          }
          showUserInputWidget(index);
        },
        child: Container(
          // alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              8.0,
            ),
            color: bgColorSheet[studentList[index]['studentId'].toString()],
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

  Widget cellWidget(int columnIndex, int studentRowIndex) {
    return SizedBox(
      height: 0,
    );
  }

  Widget assessmentTable() {
    return Center(
      child: Container(
        child: (1 == 2)
            ? const Text("")
            : StickyHeadersTable(
                cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
                    columnWidths: [
                      MediaQuery.of(context).size.width * 0,
                    ],
                    rowHeights: List<double>.generate(
                        studentList.length, (int index) => 68),
                    stickyLegendWidth: MediaQuery.of(context).size.width,
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

class UserInputWidget extends StatefulWidget {
  final String profilePic;
  final String studentName;
  final String rollNo;
  final int studentRowIndex;
  final List<String> levelNames;
  final String selectedLevel;
  final String result;
  final Function(int, String, String) userInputHandler;
  const UserInputWidget(
      {Key? key,
      required this.studentName,
      required this.rollNo,
      required this.studentRowIndex,
      required this.selectedLevel,
      required this.result,
      required this.userInputHandler,
      required this.levelNames,
      required this.profilePic})
      : super(key: key);

  @override
  State<UserInputWidget> createState() => _UserInputWidgetState();
}

class _UserInputWidgetState extends State<UserInputWidget> {
  bool isEvaluated = false;
  late String profilePic;
  late String studentName;
  late String rollNo;
  late String selectedLevel;
  late String result;
  late List<String> levelNames;

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
      alignment: Alignment.centerLeft,
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
    studentName = widget.studentName;
    rollNo = widget.rollNo;
    profilePic = widget.profilePic;
    selectedLevel = widget.selectedLevel;
    levelNames = widget.levelNames;
    result = widget.result;
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
