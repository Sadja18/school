import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:school/models/urlPaths.dart';
import '../../services/database_handler.dart';
import '../../services/helper_db.dart';
import '../../services/request_handler.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

// import '../../widgets/assist/image_assist.dart';
import '../../widgets/date_widget.dart';

const Map<int, String> weekDayMap = {
  1: 'monday',
  2: 'tuesday',
  3: 'wednesday',
  4: 'thursday',
  5: 'friday',
  6: 'saturday',
  7: 'sunday'
};

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
              if (snapshot.hasError == false &&
                  snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data.isNotEmpty) {
                var teachers = snapshot.data;
                return MarkTeacherAttendanceWidget(
                  // key: ObjectKey(teachers),
                  teachers: teachers,
                );
              } else {
                return const SizedBox(
                  // height: 0,
                  child: Text("No teacher profiles found"),
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

  /// {teacherId: {periodName: proxyTeacherId,}}
  Map proxyMap = {};
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

  void setProxyCallBack(int teacherId, Map periodWiseProxies) {
    if (kDebugMode) {
      log('proxies main callback');
      log(teacherId.toString());
      log(periodWiseProxies.toString());
    }
    setState(() {
      proxyMap[teacherId] = periodWiseProxies;
    });
  }

  List getTeacherIdsAvailableForProxy(teacherId) {
    List list = [];
    for (var element in teachers) {
      var tId = element['teacherId'];
      if (tId != teacherId &&
          absentees.contains(tId) == false &&
          proxyMap.keys.toList().contains(tId) == false) {
        // list.add(element);
        var tempMap = {};
        tempMap['teacherId'] = tId;
        tempMap['teacherName'] = element['teacherName'];
        list.add(tempMap);
      }
    }
    return list;
  }

  void showSelectionDialog(teacherId) async {
    if (kDebugMode) {
      log("teacher id is $teacherId");
    }
    var weekNum = DateTime.parse(_selectedDate.toString()).weekday;
    var weekDay = weekDayMap[weekNum].toString();
    // var teachersAvailableForProxy = getTeacherIdsAvailableForProxy(teacherId);
    return showDialog(
      context: context,
      builder: (BuildContext _) {
        return AlertDialog(
          title: const Text("Manage Attendance"),
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
                      var proxyMapTmp = proxyMap;
                      reasonMap.removeWhere((key, value) => key == teacherId);
                      proxyMapTmp.removeWhere((key, value) => key == teacherId);
                      var newAbsentee = reasonMapTmp.keys.toList();

                      setState(() {
                        reasonMap = reasonMapTmp;
                        proxyMap = proxyMapTmp;
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
            width: MediaQuery.of(context).size.width * 0.90,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              children: [
                FutureBuilder(
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

                /// first fetch all periods for which this teacher needs proxy
                FutureBuilder(
                    future: fetchTimeTableFromLocalDB(teacherId, weekDay),
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      } else {
                        if (snapshot.hasError ||
                            snapshot.hasData != true ||
                            snapshot.data == null ||
                            snapshot.data.isEmpty) {
                          if (kDebugMode) {}
                          return const SizedBox(
                            // height: 0,
                            child: Text("No Available Proxies Found"),
                          );
                        } else {
                          var thisTeacherTimeTable = snapshot.data;
                          // var currentTeacherId = teacherId;
                          var nonAbsentTeachers = [];
                          for (var teacher in teachers) {
                            if (absentees.contains(teacher['teacherId']) ==
                                    false &&
                                teacherId != teacher['teacherId']) {
                              nonAbsentTeachers.add({
                                "teacherId": teacher['teacherId'],
                                "teacherName": teacher['teacherName']
                              });
                            }
                          }
                          if (kDebugMode) {
                            log("vnfndflnv d");
                            // log(thisTeacherTimeTable.toString());
                          }
                          return ProxySelectionParentWrapper(
                            thisTeacherTimeTable: thisTeacherTimeTable,
                            thisTeacherId: teacherId,
                            nonAbsentTeachers: nonAbsentTeachers,
                            setProxyCallBack: setProxyCallBack,
                            weekDay: weekDay,
                          );
                        }
                      }
                    }),
              ],
            ),
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
            color:
                (proxyMap.keys.contains(teacherId)) ? Colors.red : Colors.green,
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
                          // (proxyMap[teacherId] != null &&
                          //         proxyMap[teacherId] != false)
                          //     ? Container(
                          //         decoration: const BoxDecoration(),
                          //         alignment: Alignment.center,
                          //         width:
                          //             MediaQuery.of(context).size.width * 0.60,
                          //         child: Text(
                          //           "Proxy: ${proxyMap[teacherId]['teacherName']}",
                          //           overflow: TextOverflow.ellipsis,
                          //           style: const TextStyle(
                          //             // fontWeight: FontWeight.bold,
                          //             fontSize: 18.0,
                          //             color: Colors.white,
                          //           ),
                          //           maxLines: 1,
                          //           softWrap: false,
                          //           textAlign: TextAlign.left,
                          //         ),
                          //       )
                          //     : const SizedBox(
                          //         height: 0,
                          //       ),
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
    double scrollOffset = 90.0;
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

      var proxies = proxyMap[teacherId];
      if (proxies != null && proxies.isNotEmpty) {
        dataMap['proxy'] = proxies;
      }
      submissionListMap.add(dataMap);
    }
    return submissionListMap;
  }

  Widget dynamicPreviewTable(String teacherName, String teacherReason) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      columnWidths: const {
        0: FractionColumnWidth(0.70),
        1: FractionColumnWidth(0.30),
        // 2: FractionColumnWidth(0.40),
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
            // TableCell(
            //   child: Container(
            //     alignment: Alignment.center,
            //     height: MediaQuery.of(context).size.height * 0.10,
            //     decoration: const BoxDecoration(),
            //     child: SingleChildScrollView(
            //       scrollDirection: Axis.vertical,
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: (proxyMapTeacherIdVal != null &&
            //                 proxyMapTeacherIdVal.isNotEmpty)
            //             ? proxyMapTeacherIdVal.keys
            //                 .toList()
            //                 .map<Widget>((periodName) {
            //                 return Text(
            //                     " $periodName : ${proxyMapTeacherIdVal[periodName]} ");
            //               }).toList()
            //             : [
            //                 const SizedBox(
            //                   height: 0,
            //                 )
            //               ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  void savingLoader(submissionData) async {
    var jsonifiedData = jsonEncode(submissionData);
    if (kDebugMode) {
      log(jsonifiedData);
    }
    var uploadDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    var total = teachers.length;
    var absent = absentees.length;
    var present = teachers.length - absentees.length;
    var dateSelected = _selectedDate;
    var attendanceDate = dateSelected;

    showDialog(
        context: context,
        builder: (BuildContext _) {
          return AlertDialog(
            title: const Text("Saving the attendance sheet"),
            content: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(),
              width: MediaQuery.of(context).size.width * 0.60,
              height: MediaQuery.of(context).size.height * 0.35,
              child: const CircularProgressIndicator.adaptive(),
            ),
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
                    width: MediaQuery.of(context).size.width * 0.90,
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
                                // var proxies = e['proxy'];
                                return dynamicPreviewTable(
                                  teacherName,
                                  teacherReason,
                                  // proxies,
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
                  savingLoader(submissionData);

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

  void checkIfAttendanceExists() async {
    try {
      var query = "SELECT * FROM TeacherAttendance "
          "WHERE "
          "date=? AND "
          "headMasterUserId=("
          "SELECT userID FROM users WHERE loginstatus=1"
          ");";
      var selectionDate = _selectedDate;
      var data = [selectionDate];

      var isAttendance = await DBProvider.db.dynamicRead(query, data);
      if (isAttendance != null && isAttendance.isNotEmpty) {
        var attendanceRecord = isAttendance[0];
        var absent = attendanceRecord['totalAbsent'];
        var present = attendanceRecord['totalPresent'];
        var dateSelection = DateFormat('MMM dd, yyyy')
            .format(DateTime.parse(_selectedDate.toString()));

        showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                title: const Text("Record exists"),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.50,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.symmetric(
                          vertical: 6.0,
                        ),
                        child: Text(
                          "Record exists for \n $dateSelection",
                        ),
                      ),
                      Table(
                        columnWidths: const {
                          0: FractionColumnWidth(0.50),
                          1: FractionColumnWidth(0.50),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Present',
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    present.toString(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              TableCell(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Absent',
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    absent.toString(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
      } else {
        saveAttendanceDialog();
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
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
                      List<double>.generate(teachers.length, (int index) => 90),
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
                  checkIfAttendanceExists();
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
        child: Column(
          children: [
            DropdownButton(
              hint: const Text("Select Reason"),
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
                // Navigator.of(context).pop();
              },
              items: widget.leaveReasons.map<DropdownMenuItem<String>>((e) {
                return DropdownMenuItem(
                  child: Text(
                    e['leaveTypeName'].toString(),
                  ),
                  value: e['leaveTypeName'],
                );
              }).toList(),
            ),
          ],
        ));
  }
}

class ProxySelectionParentWrapper extends StatefulWidget {
  final List thisTeacherTimeTable;
  final int thisTeacherId;
  final List nonAbsentTeachers;
  final String weekDay;

  /// int currentTeacher Id, map{string periodName, proxyteacherId}
  final Function(int, Map) setProxyCallBack;
  const ProxySelectionParentWrapper({
    Key? key,
    required this.thisTeacherTimeTable,
    required this.thisTeacherId,
    required this.nonAbsentTeachers,
    required this.setProxyCallBack,
    required this.weekDay,
  }) : super(key: key);

  @override
  State<ProxySelectionParentWrapper> createState() =>
      _ProxySelectionParentWrapperState();
}

class _ProxySelectionParentWrapperState
    extends State<ProxySelectionParentWrapper> {
  late List availableTeachers;
  late List thisTeacherTimeTable;
  late int thisTeacherId;
  int currentWidgetView = 0;

  /// {
  /// periodName: proxyTeacherId
  /// }
  late Map periodMap = {};
  void childCallBack(int thisTeacherId, int periodName, int proxyTeacherId) {
    var tmpAvail = availableTeachers;
    tmpAvail.removeWhere((element) => element['teacherId'] == proxyTeacherId);
    setState(() {
      periodMap[periodName] = proxyTeacherId;
      availableTeachers = tmpAvail;
    });
    if (kDebugMode) {
      log(availableTeachers.toString());
      log(periodMap.toString());
    }
  }

  /// periodName, proxyTeacherId
  void singleProxyDropdownCallBack(String periodName, int proxyTeacherId) {
    if (kDebugMode) {
      log("periodName $periodName");
      log('proxy TeacherId $proxyTeacherId');
    }
    setState(() {
      periodMap[periodName] = proxyTeacherId;
    });
  }

  @override
  void initState() {
    if (kDebugMode) {
      log('create wrapper called');
      // log(widget.nonAbsentTeachers.toString());
      log(widget.thisTeacherTimeTable.toString());
      // log(periodMap.toString());
    }
    setState(() {
      availableTeachers = widget.nonAbsentTeachers;
      thisTeacherId = widget.thisTeacherId;
      thisTeacherTimeTable = widget.thisTeacherTimeTable;

      // periodMap[widget.thisTeacherId] = [];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.90,
      height: MediaQuery.of(context).size.height * 0.30,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(
              bottom: 6.0,
            ),
            child: FutureBuilder(
              future: getAllTeachersWhoDontHaveSamePeriodOnSameDay(
                thisTeacherId,
                widget.weekDay,
                thisTeacherTimeTable[currentWidgetView]['period'],
                availableTeachers,
              ),
              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    child: CircularProgressIndicator.adaptive(),
                  );
                } else {
                  if (snapshot.hasError ||
                      snapshot.hasData != true ||
                      snapshot.data == null ||
                      snapshot.data.isEmpty) {
                    return SizedBox(
                      // height: 0,
                      child: Text(
                          "No Teachers free for the ${thisTeacherTimeTable[currentWidgetView]['period']} period"),
                    );
                  } else {
                    var availableTeacherValues = snapshot.data;
                    // return Text(availableTeacherValues[0].toString());

                    return SingleProxyDropdown(
                      proxyTeachers: availableTeacherValues,
                      periodName: widget.thisTeacherTimeTable[currentWidgetView]
                              ['period']
                          .toString(),
                      parentCallBack: singleProxyDropdownCallBack,
                    );
                  }
                }
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width * 0.90,
            child: Table(
              columnWidths: const {
                0: FractionColumnWidth(0.50),
                2: FractionColumnWidth(0.50),
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: (currentWidgetView > 0 &&
                              currentWidgetView <= thisTeacherTimeTable.length)
                          ? Container(
                              width: MediaQuery.of(context).size.width * 0.50,
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () {
                                  if (kDebugMode) {
                                    log(currentWidgetView.toString());
                                  }
                                  setState(() {
                                    currentWidgetView = currentWidgetView - 1;
                                  });
                                  if (kDebugMode) {
                                    log(currentWidgetView.toString());
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.bottomLeft,
                                  child: const Icon(
                                    Icons.arrow_back_sharp,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                    ),
                    TableCell(
                      child: (currentWidgetView >= 0 &&
                              currentWidgetView <
                                  thisTeacherTimeTable.length - 1)
                          ? Container(
                              width: MediaQuery.of(context).size.width * 0.50,
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  if (kDebugMode) {
                                    log(currentWidgetView.toString());
                                  }
                                  setState(() {
                                    currentWidgetView = currentWidgetView + 1;
                                  });
                                  if (kDebugMode) {
                                    log(currentWidgetView.toString());
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.bottomRight,
                                  child: const Icon(
                                    Icons.arrow_forward_sharp,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          (periodMap.keys.length == thisTeacherTimeTable.length)
              ? Center(
                  child: InkWell(
                    onTap: () {
                      if (kDebugMode) {
                        log('final sending to parent periodmap wrapper');
                        log(periodMap.toString());
                      }
                      widget.setProxyCallBack(widget.thisTeacherId, periodMap);
                      Navigator.of(context).pop();
                    },
                    child: Card(
                      elevation: 18.0,
                      color: const Color.fromARGB(255, 204, 101, 222),
                      borderOnForeground: true,
                      // shape: ShapeBorder.le,
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.80,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 204, 101, 222),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(
                  height: 0,
                ),
        ],
      ),
    );
  }
}

class SingleProxyDropdown extends StatefulWidget {
  final List proxyTeachers;
  final String periodName;

  /// periodName, proxyTeacherId
  final Function(String, int) parentCallBack;
  const SingleProxyDropdown({
    Key? key,
    required this.proxyTeachers,
    required this.periodName,
    required this.parentCallBack,
  }) : super(key: key);

  @override
  State<SingleProxyDropdown> createState() => _SingleProxyDropdownState();
}

class _SingleProxyDropdownState extends State<SingleProxyDropdown> {
  @override
  void initState() {
    if (kDebugMode) {
      log('proxy');
      log(widget.proxyTeachers.toString());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      height: MediaQuery.of(context).size.height * 0.20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(
              bottom: 6.0,
            ),
            alignment: Alignment.center,
            child: Text("${widget.periodName} Period"),
          ),
          Container(
            alignment: Alignment.center,
            child: DropdownButton(
              hint: const Text("Assign Teacher"),
              items: widget.proxyTeachers.map<DropdownMenuItem<String>>((e) {
                return DropdownMenuItem(
                  child: Text(
                    e['teacherName'],
                  ),
                  value: e['teacherName'],
                );
              }).toList(),
              onChanged: (selection) {
                if (kDebugMode) {
                  log("Selected Teacher $selection");
                }

                var selectedTeacherId = 0;
                for (var teacher in widget.proxyTeachers) {
                  if (teacher['teacherName'] == selection.toString()) {
                    selectedTeacherId = teacher['teacherId'];
                    break;
                  }
                }
                if (selectedTeacherId != 0) {
                  widget.parentCallBack(widget.periodName, selectedTeacherId);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
