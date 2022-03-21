// ignore_for_file: unnecessary_import, prefer_final_fields, unused_field, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import '../services/database_handler.dart';
import '../services/presave_processor.dart';
import 'assessment_select.dart';
import 'class_dropdown.dart';
import '../services/pre_submit_validation.dart';
import '../screens/dashboard.dart';
import '../screens/login.dart';

class StickyPaceWidget extends StatefulWidget {
  static const routeName = '/pace-new';

  const StickyPaceWidget({Key? key}) : super(key: key);

  @override
  _StickyPaceWidgetState createState() => _StickyPaceWidgetState();
}

class _StickyPaceWidgetState extends State<StickyPaceWidget> {
  Color _color = Colors.blueGrey.shade50;
  List<dynamic> studentList = [];

  String? _selectedClass = '';
  dynamic _selectedAssessment = '';
  dynamic _markSheet = {};
  dynamic _grading = [];
  dynamic _result = {};

  int totQues = 0;
  late final double _totmarks;
  void selectClass(String selectedClass) {
    setState(() {
      _selectedClass = selectedClass;
    });
  }

  String displayDate(String date) {
    return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
  }

  void selectAssessment(dynamic value) {
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
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void getAllStudents(List<dynamic> students) {
    for (var index = 0; index < students.length; index++) {
      students[index].remove('level');
      // students[index]['notEvaluated'] = false;
      students[index]['result'] = '';
    }
    setState(() {
      studentList = students;
    });

    _getGradingSystem();

    if (kDebugMode) {
      print('student list gen');
      print(studentList.runtimeType);
    }
  }

  Future<void> _getGradingSystem() async {
    var value = await DBProvider.db.getPaceGrading();
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

  double calcPercentage(studentId) {
    num total = 0;
    var marks = _markSheet[studentId];
    for (var mark in marks) {
      total = total + mark;
    }
    return (total / _totmarks) * 100;
  }

  String calcGrade(percentage) {
    if (kDebugMode) {
      print(percentage.runtimeType);
    }

    var resultVal = "";

    for (int i = 0; i < _grading.length; i++) {
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

  void updateResult(studentId) {
    var marksheet = _markSheet;
    var result = _result;

    if (marksheet.isNotEmpty) {
      if (result[studentId] == null || marksheet[studentId] == null) {
        result[studentId] = 'Not Evaluated';
      } else {
        // student Id record exists
        var grade = calcGrade(calcPercentage(studentId));
        if (kDebugMode) {
          print(grade.runtimeType);
        }
        result[studentId] = (grade == 'noacc')
            ? 'Not Achieved'
            : (grade == 'acc')
                ? 'Achieved'
                : 'Not Evaluated';
      }
    } else {
      result[studentId] = '';
    }
    setState(() {
      _result = result;
    });
  }

  void markSheetHandler(marksOne, questionIndex, studentRowIndex) {
    var marksheet = _markSheet;

    var studentId = studentList[studentRowIndex]['studentId'];

    if (marksheet.isEmpty) {
      // marsheet is empty
      // no records
      // create a new entry
      marksheet[studentId] = [];
      for (var i = 0; i < totQues; i++) {
        marksheet[studentId].add(0.0);
      }
      marksheet[studentId][questionIndex] = marksOne;
    } else {
      // if marksheet is not empty
      // check if the record for current student exists
      if (marksheet[studentId] != null && marksheet[studentId].isNotEmpty) {
        // if student record marksheet already exists
        // just update
        marksheet[studentId][questionIndex] = marksOne;
      } else {
        // if this student does not exist
        // create a new entry for this student
        marksheet[studentId] = [];
        for (var i = 0; i < totQues; i++) {
          marksheet[studentId].add(0.0);
        }
        marksheet[studentId][questionIndex] = marksOne;
      }

      // after all process
      // set state of _markSheet to updated entries

      setState(() {
        _markSheet = marksheet;
      });
    }
  }

  int titleColumnLengthCalculator() {
    var colLength = 4 + totQues;

    if (kDebugMode) {
      print('collength');
      // print(colLength);
    }
    return colLength;
  }

  int titleRowLengthCalculator() {
    return studentList.length;
  }

  String makeTitleColumn(int index) {
    var titleHeader = ['Name', 'NE'];
    for (int i = 0; i < totQues; i++) {
      titleHeader.add('Q${i + 1}');
    }
    titleHeader.add('Total Marks');
    titleHeader.add('Result');
    return titleHeader[index];
  }

  Widget makeTitleRow(int index) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        color: index % 2 == 0
            ? const Color.fromARGB(127, 120, 165, 255)
            : const Color.fromARGB(255, 120, 165, 255),
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          "${studentList[index]['rollNo']}",
          softWrap: false,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget checkBoxHandle(int studentRowIndex) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Checkbox(
          activeColor: Colors.red,
          value: studentList[studentRowIndex].isEmpty
              ? false
              : studentList[studentRowIndex]['notEvaluated'],
          onChanged: (bool? value) {
            if (kDebugMode) {
              // print(value.toString());
            }
            setState(() {
              studentList[studentRowIndex]['notEvaluated'] = value;
            });
            if (value != null && value == true) {
              setState(() {
                _result[studentList[studentRowIndex]['studentId']] =
                    'Not Evaluated';
              });
              if (kDebugMode) {
                // print(studentList.toString());
                print('checkBoxHandler');
              }
            } else {
              if (value == false) {
                _result.remove(studentList[studentRowIndex]['studentId']);
                // _result[] = '';
                if (kDebugMode) {
                  print("checkBoxhandler else");
                }
              }
            }

            // print(studentList.toString());
          },
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
            ));
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
                    paceAssessmentProcessor(studentList, submissionDate,
                        _selectedAssessment, _markSheet, _result);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Confirm'),
                ),
              ],
              content: Text(message),
            ));
  }

  Widget getTotMarks(int studentListIndex) {
    var stId = studentList[studentListIndex]['studentId'];
    var j = studentListIndex;
    if (_markSheet.isNotEmpty) {
      if (_markSheet[stId] != null) {
        num total = 0;
        var marks = _markSheet[stId];
        for (var mark in marks) {
          total = total + mark;
        }
        if (total == 0) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: const Text('0'),
          );
        }
        if (total > 0) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: Text('$total'),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: const Text('0'),
          );
        }
      } else {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
          ),
          child: const Text(''),
        );
      }
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: const Text(''),
      );
    }
  }

  Widget getResult(int studentRowIndex) {
    var j = studentRowIndex;
    if (_result.isNotEmpty) {
      var studentId = studentList[studentRowIndex]['studentId'];
      var result = _result[studentId];
      if (kDebugMode) {
        // print(_result.toString());
      }
      if (result != null) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Text(result),
        );
      } else {
        if (studentList[studentRowIndex]['notEvaluated'] == false) {
          return Container(
            decoration: BoxDecoration(
                border: Border.all(
              color: Colors.black,
            )),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Text(''),
          );
        }
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: const Text('Not Evaluated'),
        );
      }
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: const Text(''),
      );
    }
  }

  Widget marksField(int studentRowIndex, int questionIndex) {
    // var marksController = TextEditingController();
    var title = "";
    var message = "";

    if (questionIndex >= 1 &&
        questionIndex <= totQues &&
        studentList[studentRowIndex]['notEvaluated'] == false) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(),
          color: studentRowIndex % 2 == 0
              ? const Color.fromARGB(127, 120, 165, 255)
              : const Color.fromARGB(255, 120, 165, 255),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: TextField(
          cursorWidth: 4.0,
          decoration: InputDecoration(
            hintText: 'Q$questionIndex',
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
                width: 2.0,
              ),
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
            fillColor: _color,
            filled: true,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (double.tryParse(value) != null) {
              var marksValue = double.parse(value);

              if (marksValue > _totmarks) {
                title = "Invalid Marks";
                message = "Marks can not be more than total marks";

                showAlert(title, message);
              }
              if (kDebugMode) {
                // print('$studentRowIndex $questionIndex $marksValue');
                print('onchange of marks');
                markSheetHandler(
                    marksValue, questionIndex - 1, studentRowIndex);
                var studentId = studentList[studentRowIndex]['studentId'];
                updateResult(studentId);
              }
            } else {
              title = "Invalid marks";
              message = "Marks can only be a number";
              showAlert(title, message);
            }
          },
        ),
      );
    }
    return const Text(
      '',
      softWrap: true,
    );
  }

  Widget CellWidget(i, j) {
    var totMaksField = totQues + 2;
    var resultField = totQues + 3;

    // return Text("$i $j");
    if (i == 0 || i == 1) {
      if (i == 0) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            // borderRadius: BorderRadius.circular(4.0),
            color: j % 2 == 0
                ? const Color.fromARGB(127, 120, 165, 255)
                : const Color.fromARGB(255, 120, 165, 255),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              "${studentList[j]['studentName']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        );
      } else {
        // to handle the not evaluated field
        return checkBoxHandle(j);
      }
    } else {
      // if(_result[j])
      if (i >= 2 && i < totMaksField) {
        return marksField(j, i - 1);
      } else {
        if (i == totMaksField) {
          return getTotMarks(j);
        } else {
          if (i == resultField && _result[studentList[j]] != "Not Evaluated") {
            return getResult(j);
          }
        }
      }
      return Text("$i $j");
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

  Widget assessmentTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: StickyHeadersTable(
        cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
            columnWidths: List<double>.generate(
                titleColumnLengthCalculator(), (int index) => 120),
            rowHeights:
                List<double>.generate(studentList.length, (int index) => 100),
            stickyLegendWidth: 100,
            stickyLegendHeight: 100),
        initialScrollOffsetX: 0.0,
        initialScrollOffsetY: 0.0,
        scrollControllers: ScrollControllers(
          verticalBodyController: verticalBodyController,
          verticalTitleController: verticalTitleController,
          horizontalBodyController: horizontalBodyController,
          horizontalTitleController: horizontalTitleController,
        ),
        columnsLength: titleColumnLengthCalculator(),
        rowsLength: titleRowLengthCalculator(),
        columnsTitleBuilder: (i) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Text(
            makeTitleColumn(i),
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
        rowsTitleBuilder: (i) => makeTitleRow(i),
        contentCellBuilder: (i, j) => CellWidget(i, j),
        legendCell: Container(
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
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
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
        margin: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
                              getAllStudents: getAllStudents,
                            ),
                          ],
                        ))),
                (_selectedClass!.isEmpty)
                    ? const Text('')
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 8.0,
                                ),
                                child: const Text(
                                  'Assessment:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              AssessmentsDropDown(
                                  selectClass: _selectedClass,
                                  selectAssessment: selectAssessment),
                            ],
                          ),
                        ),
                      ),
                (_selectedAssessment!.isEmpty)
                    ? const Text('')
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 8.0,
                                ),
                                child: const Text(
                                  'Assessment Date:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(displayDate(_selectedAssessment['date'])),
                            ],
                          ),
                        ),
                      ),
                (_selectedAssessment!.isEmpty)
                    ? const Text('')
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 8.0,
                                ),
                                child: const Text(
                                  'Subject:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(_selectedAssessment['subject_name']),
                            ],
                          ),
                        ),
                      ),
                (_selectedAssessment!.isEmpty)
                    ? const Text('')
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 8.0,
                                ),
                                child: const Text(
                                  'Assessment Medium:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(_selectedAssessment['medium_name']),
                            ],
                          ),
                        ),
                      ),
                (_selectedAssessment!.isEmpty)
                    ? const Text('')
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 8.0,
                                ),
                                child: const Text(
                                  'Question Paper:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(_selectedAssessment['qp_code_name']),
                            ],
                          ),
                        ),
                      ),
                (_selectedAssessment!.isEmpty || _selectedClass!.isEmpty)
                    ? const Text('')
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(),
                            ),
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: MediaQuery.of(context).size.width,
                            child: assessmentTable(),
                          ),
                        ),
                      ),
                (_selectedAssessment!.isEmpty || _selectedClass!.isEmpty)
                    ? const Text('')
                    : Container(
                        margin: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.04),
                        height: MediaQuery.of(context).size.height * 0.04,
                        child: ElevatedButton(
                          onPressed: () {
                            var submissionDateUnformatted = DateTime.now();
                            DateFormat submissionFormat =
                                DateFormat('yyyy-MM-dd HH:mm:ss');

                            var submissionDate = submissionFormat
                                .format(submissionDateUnformatted);
                            if (kDebugMode) {
                              print('Submit');
                              // print(_markSheet.toString());
                              // print(_grading.toString());
                              // print(_result.toString());
                              print(submissionDate.toString());
                            }
                            var validity = paceSubmitValidation(
                                studentList, _markSheet, _result);

                            if (validity["0"] == "Okay") {
                              var title = "Confirm Submit";
                              var message =
                                  "Pressing Confirm will save the record.\n"
                                  "After confirm, please sync to server";
                              showAlertFinal(title, message, submissionDate);
                            } else {
                              var title = validity["0"];
                              var message = "Cannot submit an empty form";

                              showAlert(title, message);
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
