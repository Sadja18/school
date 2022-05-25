import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_handler.dart';
import '../../services/helper_db.dart';
import '../../services/request_handler.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

// import '../../widgets/assist/image_assist.dart';
import '../../widgets/date_widget.dart';

class MarkTeacherAttendanceFuture extends StatefulWidget {
  const MarkTeacherAttendanceFuture({Key? key}) : super(key: key);

  @override
  State<MarkTeacherAttendanceFuture> createState() =>
      _MarkTeacherAttendanceFutureState();
}

class _MarkTeacherAttendanceFutureState
    extends State<MarkTeacherAttendanceFuture> {
  late final Future? teacherFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    teacherFuture = fetchTeacherProfileFromServerHeadMasterMode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(),
      alignment: Alignment.topCenter,
      child: FutureBuilder(
          future: teacherFuture,
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data.isNotEmpty) {
                var teachers = snapshot.data;
                return MarkTeacherAttendanceWidget(
                  // key: ObjectKey(teachers),
                  teachers: teachers,
                );
              } else {
                return const SizedBox(
                  height: 0,
                );
              }
            }
          }),
    );
  }
}

class MarkTeacherAttendanceWidget extends StatefulWidget {
  // static const routeName = "hm-teacher-mark-attendance";
  final List teachers;
  const MarkTeacherAttendanceWidget({Key? key, required this.teachers})
      : super(key: key);

  @override
  State<MarkTeacherAttendanceWidget> createState() =>
      _MarkTeacherAttendanceWidgetState();
}

class _MarkTeacherAttendanceWidgetState
    extends State<MarkTeacherAttendanceWidget> {
  late List teachers;
  int currentRowIndex = 0;
  List absentees = [];
  Map reasonMap = {};
  // late Map<int, bool> absenteeCheckBox = {};
  late String currentReason = "";
  String? _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // get reasonMapTmp => null;
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

  void leaveReasonCallBack(int teacherId, String reasonName) {
    if (kDebugMode) {
      log("Change occurred");
      log(teacherId.toString());
      log(reasonName);
    }
    // var tmp = absenteeCheckBox =
    setState(() {
      reasonMap[teacherId] = reasonName;

      // absentees.add(teacherId);
    });
    var tmp = reasonMap.keys.toList();
    setState(() {
      absentees = tmp;
    });
    if (kDebugMode) {
      log("Changes done after occurred");
      log(absentees.toString());
      log(reasonMap.toString());
    }
  }

  void showSelectionDialog(teacherId) async {
    if (kDebugMode) {
      log("teacher id is $teacherId");
    }
    return showDialog(
      context: context,
      builder: (BuildContext _) {
        return AlertDialog(
          title: const Text("Select Reason"),
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            (absentees.contains(teacherId))
                ? InkWell(
                    onTap: () {
                      var reasonMapTmp = reasonMap;
                      reasonMap.removeWhere((key, value) => key == teacherId);
                      var newAbsentee = reasonMapTmp.keys.toList();

                      setState(() {
                        reasonMap = reasonMapTmp;
                        absentees = newAbsentee;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 5.0,
                      ),
                      child: const Text(
                        "Undo Absent",
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
          ],
          content: Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(color: Colors.grey.shade100),
            width: MediaQuery.of(context).size.width * 0.50,
            height: MediaQuery.of(context).size.height * 0.40,
            child: FutureBuilder(
                future: getLeaveTypesFromDB(),
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (kDebugMode) {
                      log("snapshot \n ${snapshot.hasData} \n ${snapshot.data} \n ${snapshot.data.runtimeType} ");
                    }
                    if (snapshot.hasError ||
                        snapshot.hasData != true ||
                        snapshot.data == null ||
                        snapshot.data.isEmpty) {
                      return const SizedBox(
                        child: Text("No Leave Reason found"),
                      );
                    } else {
                      var leaveReasons = snapshot.data;
                      // String initialReason = reasonMap[teacherId]!=null && reasonMap[teacherId]!=false? reasonMap[teacherId]:

                      return DropdownForReason(
                        teacherId: teacherId,
                        leaveReasons: leaveReasons,
                        leaveReasonCallBack: leaveReasonCallBack,
                      );
                    }
                  }
                }),
          ),
        );
      },
    );
  }

  Widget rowCell(teacherProfile, index) {
    var teacherId = teacherProfile['teacherId'];

    return InkWell(
      onTap: () {
        setState(() {
          currentRowIndex = index;
          showSelectionDialog(teacherId);
        });
      },
      child: Card(
        elevation: 8.0,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: (absentees.contains(teacherId)) ? Colors.red : Colors.green,
            border: Border.all(
              color: Colors.white,
            ),
          ),
          alignment: Alignment.center,
          child: Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FractionColumnWidth(0.20),
              1: FractionColumnWidth(0.80),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.10,
                      child: ClipOval(
                        child: Image(
                          image: Image.memory(
                            const Base64Decoder().convert(
                              teacherProfile['profilePic'],
                            ),
                          ).image,
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.10,
                        ),
                      ),
                    ),
                    // AvatarGeneratorNew(base64Code: teacherProfile['photo']),
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
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.60,
                            child: Text(
                              nameForamtter(teacherProfile['teacherName']),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          (reasonMap[teacherId] != null &&
                                  reasonMap[teacherId] != false)
                              ? Container(
                                  decoration: const BoxDecoration(),
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
                                  child: Text(
                                    "Reason: ${reasonMap[teacherId]}",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                    textAlign: TextAlign.left,
                                  ),
                                )
                              : const SizedBox(
                                  height: 0,
                                ),
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
    );
  }

  double verticalRowScrollOffset() {
    double scrollOffset = 80.0;
    if (currentRowIndex == 0.0) {
      return 0.0;
    } else {
      return scrollOffset * currentRowIndex;
    }
  }

  ScrollControllers scrollControllers() {
    return ScrollControllers(
      verticalTitleController: verticalTitleController,
      verticalBodyController: verticalBodyController,
      horizontalTitleController: horizontalTitleController,
      horizontalBodyController: horizontalBodyController,
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

  Future<List> preSubmitProcessor() async {
    List submissionListMap = [];
    for (var teacherId in reasonMap.keys.toList()) {
      var dataMap = {};
      var reasonId = -1;
      var reasonName = reasonMap[teacherId];

      var reasonData = await DBProvider.db.dynamicRead(
          "SELECT leaveTypeId FROM LeaveTypes "
          "WHERE leaveTypeName=?;",
          [reasonName]);

      if (reasonData.isNotEmpty) {
        var reason = reasonData[0];
        // reasonId = reason['leaveTypeId'];
        if (reason['leaveTypeId'] != null && reason['leaveTypeId'] != false) {
          reasonId = reason['leaveTypeId'];
        } else {
          continue;
        }
      } else {
        continue;
      }
      dataMap['teacherId'] = teacherId;
      var teacherName = "";
      for (var t in teachers) {
        if (t['teacherId'] == teacherId) {
          teacherName = t['teacherName'];
        }
      }
      dataMap['teacherName'] = teacherName;
      dataMap['absent'] = true;
      dataMap['reasonName'] = reasonMap[teacherId];

      dataMap['reasonId'] = reasonId;
      submissionListMap.add(dataMap);
    }
    return submissionListMap;
  }

  Widget dynamicPreviewTable(String teacherName, String teacherReason) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      columnWidths: const {
        0: FractionColumnWidth(0.60),
        1: FractionColumnWidth(0.40),
      },
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            TableCell(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  left: 4.0,
                ),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  nameForamtter(teacherName),
                ),
              ),
            ),
            TableCell(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  left: 4.0,
                ),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  nameForamtter(teacherReason),
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void savingLoader(submissionData) async {
    var jsonifiedData = jsonEncode(submissionData);
    var uploadDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    var total = teachers.length;
    var absent = absentees.length;
    var present = teachers.length - absentees.length;
    var dateSelected = _selectedDate;
    var attendanceDate = dateSelected;

    // await DBProvider.db.dynamicInsert("TeacherAttendance", data)
    showDialog(
        context: context,
        builder: (BuildContext _) {
          return const AlertDialog(
            title: Text("Saving the attendance sheet"),
            content: CircularProgressIndicator(),
          );
        });
    await saveTeacherAttendanceToLocalDB(
        jsonifiedData, attendanceDate, uploadDate, total, present, absent);

    Navigator.of(context).pop();
  }

  void saveAttendanceDialog() async {
    var submissionData = await preSubmitProcessor();

    showDialog(
        context: context,
        builder: (BuildContext _) {
          return AlertDialog(
            title: const Text("Absent Teachers"),
            contentPadding: const EdgeInsets.only(
              left: 0,
              right: 0,
            ),
            content: (absentees.isNotEmpty)
                ? Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    height: MediaQuery.of(context).size.height * 0.50,
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: (absentees.isEmpty)
                            ? [
                                const SizedBox(
                                  height: 0,
                                  width: 0,
                                )
                              ]
                            : submissionData.map((e) {
                                var teacherName = e['teacherName'];
                                var teacherReason = e['reasonName'];
                                return dynamicPreviewTable(
                                  teacherName,
                                  teacherReason,
                                );
                              }).toList(),
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (kDebugMode) {
                    log("Saving to local DB");
                  }
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Confirm",
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          );
        });
    savingLoader(submissionData);
  }

  void selectedDate(String? selectDate) {
    setState(() {
      _selectedDate = selectDate.toString();
      // _selectedClass = "";
      // studentList = [];
    });
    if (kDebugMode) {
      print('reverse date callback');
    }
  }

  @override
  void initState() {
    setState(() {
      teachers = widget.teachers;
    });
    super.initState();
    // teacherFuture = fetchTeacherLeaveTypesFromServerHeadMasterMode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(
          255,
          208,
          202,
          202,
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.80,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(),
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(
                horizontal: 0.0,
                vertical: 0.0,
              ),
              child: DateShow(
                selectedDate: selectedDate,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(),
              alignment: Alignment.center,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FractionColumnWidth(0.30),
                  1: FractionColumnWidth(0.30),
                  2: FractionColumnWidth(0.30),
                  // 3: FractionColumnWidth(0.24),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'Total: ${teachers.length}',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'Present: ${teachers.length - absentees.length}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 44, 130, 46),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'Absent: ${absentees.length}',
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              height: MediaQuery.of(context).size.height * 0.58,
              margin: const EdgeInsets.symmetric(
                vertical: 6.0,
              ),
              child: StickyHeadersTable(
                cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
                  columnWidths: [],
                  rowHeights:
                      List<double>.generate(teachers.length, (int index) => 80),
                  stickyLegendWidth: MediaQuery.of(context).size.width,
                  stickyLegendHeight: 0,
                ),
                initialScrollOffsetX: 0.0,
                initialScrollOffsetY: verticalRowScrollOffset(),
                scrollControllers: scrollControllers(),
                columnsLength: 0,
                rowsLength: teachers.length,
                columnsTitleBuilder: (i) => const SizedBox(
                  height: 0,
                ),
                rowsTitleBuilder: (i) => rowCell(teachers[i], i),
                contentCellBuilder: (i, j) => const SizedBox(
                  height: 0,
                ),
                legendCell: const SizedBox(
                  height: 0,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(),
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
              ),
              child: InkWell(
                onTap: () {
                  saveAttendanceDialog();
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.30,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: const BoxDecoration(color: Colors.purple),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DropdownForReason extends StatefulWidget {
  final List leaveReasons;
  final int teacherId;
  // teacherId, leave reason
  final Function(int, String) leaveReasonCallBack;
  const DropdownForReason({
    Key? key,
    required this.leaveReasons,
    required this.leaveReasonCallBack,
    required this.teacherId,
  }) : super(key: key);

  @override
  State<DropdownForReason> createState() => _DropdownForReasonState();
}

class _DropdownForReasonState extends State<DropdownForReason> {
  late String selectedReason;
  late List leaveReasons;
  late int teacherId;
  @override
  void initState() {
    setState(() {
      leaveReasons = widget.leaveReasons;
      selectedReason = widget.leaveReasons[0]['leaveTypeName'];
      teacherId = widget.teacherId;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // width: MediaQuery.of(context).size.width * 0.40,
        alignment: Alignment.topCenter,
        child: DropdownButton(
          // value: currentReason,
          onChanged: (selection) {
            // List absenteesTmp = absentees;
            // Map reasonMapTmp = reasonMap;
            if (kDebugMode) {
              log("Sekected $selection");
            }
            widget.leaveReasonCallBack(teacherId, selection.toString());
            // }

            if (kDebugMode) {
              // log(absentees.toString());
              // log(reasonMap.toString());
              log('piokvdskhb');
            }
            Navigator.of(context).pop();
          },
          items: widget.leaveReasons.map<DropdownMenuItem<String>>((e) {
            return DropdownMenuItem(
              child: Text(
                e['leaveTypeName'].toString(),
              ),
              value: e['leaveTypeName'],
            );
          }).toList(),
        ));
  }
}
