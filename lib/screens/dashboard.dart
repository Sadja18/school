// ignore_for_file: unused_import, duplicate_ignore, prefer_const_constructors

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import './attendance_leave.dart';
import './leave.dart';
import '../services/helper_db.dart';
// import 'package:school/screens/dummy.dart';
// import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../screens/new_assessment.dart';
import '../services/request_handler.dart';
import '../screens/login.dart';
import '../services/database_handler.dart';
import '../services/sync_services.dart';
import '../widgets/pace_assessment.dart';
import '../models/urlPaths.dart' as uri_paths;
import './headmaster/attendance.dart';

const fetchOne = "fetch Persistent";

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';

  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  String? userName = '';
  void _onLogout() async {
    // read data from db to get user where login-status = 1;
    await DBProvider.db.logoutUser();
    Navigator.of(context).pushReplacementNamed(Login.routeName);
  }

  Future<void> setUserName() async {
    var val = await getUserName();

    setState(() {
      userName = val;
    });
  }

  @override
  void initState() {
    super.initState();
    // fetchPersistent();
    // fetchLeaveTypeAndRequests();
    // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    // // Workmanager().registerOneOffTask("1", fetchOne);
    // Workmanager().registerPeriodicTask("2",
    //     fetchOne, //This is the value that will be returned in the callbackDispatcher
    //     frequency: const Duration(minutes: 00, hours: 12));
    setUserName();
  }

  void offlineSyncPressDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: SizedBox(
              child: const Text("No Internet"),
            ),
            // titlePadding: const EdgeInsets.all(0),
            // contentPadding: const EdgeInsets.all(0),
            content: const Text("Cannot sync in offline mode"),
          );
        });
  }

  void showAlertDialog() async {
    try {
      var response = await http.get(
          Uri.parse(uri_paths.baseURL + uri_paths.checkIfOnline + '?get=1'));

      if (response.statusCode == 200) {
        showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                title: SizedBox(
                  height: 0,
                ),
                titlePadding: const EdgeInsets.all(0),
                content: Container(
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: BoxDecoration(),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.40,
                        height: MediaQuery.of(context).size.height * 0.10,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: Colors.purpleAccent,
                          strokeWidth: 1.0,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.40,
                        height: MediaQuery.of(context).size.height * 0.30,
                        alignment: Alignment.center,
                        child:
                            const Text("Please wait for syncing to complete."),
                      ),
                    ],
                  ),
                ),
                contentPadding: const EdgeInsets.all(0),
              );
            });
        await wrapper();
        Navigator.of(context).pop();
      } else {
        offlineSyncPressDialog();
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
        log("offline no sync available");
        offlineSyncPressDialog();
      }
    }
  }

  // void getLeaveTypes() async {
  //   String query = "SELECT leaveTypeName FROM TeacherLeaveAllocation;";
  //   var leaveTypes = await DBProvider.db.dynamicRead(query, []);
  //   if (kDebugMode) {
  //     print('leave thypes');
  //     print(leaveTypes.toString());
  //   }
  // }
  void showAlertDialogHeadMaster() async {
    try {
      var response = await http.get(
          Uri.parse(uri_paths.baseURL + uri_paths.checkIfOnline + '?get=1'));

      if (response.statusCode == 200) {
        showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                title: SizedBox(
                  height: 0,
                ),
                titlePadding: const EdgeInsets.all(0),
                content: Container(
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: BoxDecoration(),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.40,
                        height: MediaQuery.of(context).size.height * 0.10,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: Colors.purpleAccent,
                          strokeWidth: 1.0,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.40,
                        height: MediaQuery.of(context).size.height * 0.30,
                        alignment: Alignment.center,
                        child:
                            const Text("Please wait for syncing to complete."),
                      ),
                    ],
                  ),
                ),
                contentPadding: const EdgeInsets.all(0),
              );
            });
        await wrapperHeadMaster();
        Navigator.of(context).pop();
      } else {
        offlineSyncPressDialog();
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
        log("offline no sync available");
        offlineSyncPressDialog();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var appBarHeight = kToolbarHeight;
    return FutureBuilder(
      future: isHeadMasterLoggedIn(),
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Dashboard"),
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasError ||
              snapshot.hasData != true ||
              snapshot.data == null ||
              snapshot.data.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Error'),
              ),
              body: const Text("No user found"),
            );
          } else {
            var login = snapshot.data;
            if (kDebugMode) {
              log('in dashboard');
              log("login.toString()");
            }
            if (login['isHeadMaster'] != 'yes') {
              return Scaffold(
                key: scaffoldKey,
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text('Dashboard'),
                  actions: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: () =>
                            scaffoldKey.currentState?.openEndDrawer(),
                        tooltip: MaterialLocalizations.of(context)
                            .openAppDrawerTooltip,
                      ),
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
                endDrawer: Container(
                  padding:
                      EdgeInsets.only(top: statusBarHeight + appBarHeight + 1),
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: MediaQuery.of(context).size.height,
                  child: Drawer(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.shade100,
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                userName!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            tileColor: Colors.transparent,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(),
                          alignment: Alignment.center,
                          child: Center(
                            child: OutlinedButton(
                              onPressed: () {
                                if (kDebugMode) {
                                  print('clicked');
                                }
                                showAlertDialog();
                                // wrapper();
                              },
                              child: const Text(
                                'Sync Data',
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(),
                          alignment: Alignment.center,
                          child: Center(
                            child: OutlinedButton(
                              onPressed: () {
                                _onLogout();
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // ListTile(
                        //   title: Center(
                        //     child: OutlinedButton(
                        //       onPressed: () {
                        //         // DBProvider.db.fetchQuery();
                        //         DBProvider.db.dynamicRead("Select * FROM pace;", []);
                        //         // syncLeaveRequest();
                        //         // syncAttendance();
                        //         syncPace();
                        //         // fetchLeaveTypeAndRequests();
                        //         // Navigator.of(context).pushNamed(PaceAssessmentScreen.routeName );
                        //       },
                        //       child: const Text('Test'),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
                body: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/background/img1.jpg'),
                      fit: BoxFit.fill,
                    ),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 4.0,
                            ),
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                          ),
                          margin: const EdgeInsets.only(
                            bottom: 4.0,
                          ),
                          width: MediaQuery.of(context).size.width * 0.60,
                          height: MediaQuery.of(context).size.height * 0.30,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(AttedanceLeaveScreen.routeName);
                              //
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset('assets/dashboardIcons/leave.png'),
                                const Text(
                                  'Attendance/Leave',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 4.0,
                            ),
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                          ),
                          margin: const EdgeInsets.only(
                            top: 4.0,
                          ),
                          width: MediaQuery.of(context).size.width * 0.60,
                          height: MediaQuery.of(context).size.height * 0.30,
                          child: TextButton(
                            onPressed: () {
                              // ignore: avoid_print
                              // print("assesment");
                              Navigator.of(context)
                                  .pushNamed(AssessmentScreen.routeName);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                    'assets/dashboardIcons/assessment.png'),
                                const Text(
                                  'Assessment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: const Text('Dashboard'),
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
                    bottom: TabBar(
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.create_outlined,
                                semanticLabel: 'Mark New Attendance',
                                size: 40,
                              ),
                              Text(
                                'Mark',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            children: const [
                              Icon(
                                Icons.view_list_outlined,
                                semanticLabel: 'View marked attendance',
                                size: 40,
                              ),
                              Text(
                                'View',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  endDrawer: Container(
                    padding: EdgeInsets.only(
                        top: statusBarHeight + appBarHeight + 1),
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: MediaQuery.of(context).size.height,
                    child: Drawer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 5.0,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent.shade100,
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: ListTile(
                              title: Center(
                                child: Text(
                                  userName!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                              tileColor: Colors.transparent,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(),
                            alignment: Alignment.center,
                            child: Center(
                              child: OutlinedButton(
                                onPressed: () {
                                  if (kDebugMode) {
                                    print('clicked');
                                  }
                                  showAlertDialogHeadMaster();
                                  // wrapper();
                                },
                                child: const Text(
                                  'Sync Data',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(),
                            alignment: Alignment.center,
                            child: Center(
                              child: OutlinedButton(
                                onPressed: () {
                                  if (kDebugMode) {
                                    print('clicked');
                                  }
                                  syncTeacherAttendance();
                                  // showAlertDialogHeadMaster();
                                  // wrapper();
                                },
                                child: const Text(
                                  'Test',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(),
                            alignment: Alignment.center,
                            child: Center(
                              child: OutlinedButton(
                                onPressed: () {
                                  _onLogout();
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // ListTile(
                          //   title: Center(
                          //     child: OutlinedButton(
                          //       onPressed: () {
                          //         // DBProvider.db.fetchQuery();
                          //         DBProvider.db.dynamicRead("Select * FROM pace;", []);
                          //         // syncLeaveRequest();
                          //         // syncAttendance();
                          //         syncPace();
                          //         // fetchLeaveTypeAndRequests();
                          //         // Navigator.of(context).pushNamed(PaceAssessmentScreen.routeName );
                          //       },
                          //       child: const Text('Test'),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  body: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.50,
                        height: MediaQuery.of(context).size.height,
                        alignment: Alignment.center,
                        child: MarkTeacherAttendanceFuture(),
                      ),
                      Card(
                        elevation: 10.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.topCenter,
                          child:
                              FutureBuilderForTeacherAttendanceCalendarView(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        }
      },
    );
  }
}

class FutureBuilderForTeacherAttendanceCalendarView extends StatelessWidget {
  const FutureBuilderForTeacherAttendanceCalendarView({Key? key})
      : super(key: key);
  Future<dynamic> getAllAttendanceEntries() async {
    try {
      var query = "SELECT date, totalPresent, totalAbsent, isSynced "
          "FROM TeacherAttendance "
          "WHERE headMasterUserId = "
          "("
          "SELECT userId FROM users WHERE loginstatus=1 AND "
          "isHeadMaster=?"
          ");";
      var params = ['yes'];
      var records = await DBProvider.db.dynamicRead(query, params);
      if (records != null && records.isNotEmpty) {
        return records;
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getAllAttendanceEntries(),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError ||
                snapshot.hasData != true ||
                snapshot.data == null ||
                snapshot.data == false ||
                snapshot.data.isEmpty) {
              return const SizedBox(
                child: Text("No attendance entry found for teachers"),
              );
            } else {
              var attendances = snapshot.data;
              if (kDebugMode) {
                log("teacher attendance calendar view future");
                log(attendances.toString());
              }
              return TeacherAttendanceCalendarView(
                attendances: attendances,
              );
            }
          }
        });
  }
}

class TeacherAttendanceCalendarView extends StatefulWidget {
  final List attendances;
  const TeacherAttendanceCalendarView({Key? key, required this.attendances})
      : super(key: key);

  @override
  State<TeacherAttendanceCalendarView> createState() =>
      _TeacherAttendanceCalendarViewState();
}

class _TeacherAttendanceCalendarViewState
    extends State<TeacherAttendanceCalendarView> {
  final CalendarController _controller = CalendarController();
  List attendanceData = [];

  Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: Colors.black,
        // ),
        // borderRadius: BorderRadius.circular(28.0),
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                // color: Colors.lightBlueAccent,
                ),
            margin: const EdgeInsets.symmetric(
              vertical: 2.5,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 1.0,
              horizontal: 4.0,
            ),
            child: Text(
              details.date.day.toString(),
              textAlign: TextAlign.left,
            ),
          )
        ],
      ),
    );
  }

  List<Attendance> _getAttendance() {
    List<Attendance> attendanceViewData = <Attendance>[];
    if (attendanceData.isNotEmpty) {
      for (var i = 0; i < attendanceData.length; i++) {
        var record = attendanceData[i];

        DateTime startDateParsed = DateTime.parse(record['date']);
        DateTime endDateParsed = DateTime.parse("${record['date']} 23:59:59");
        String subject =
            "Present: ${record['totalPresent']}, Absent: ${record['totalAbsent']}";
        // DateTime submissionDateUn = DateTime.parse(record['submission_date']);
        bool synced = record['isSynced'] == 'yes' ? true : false;

        // String subject = DateFormat('MMMM yyyy')
        Attendance entry =
            Attendance(startDateParsed, endDateParsed, subject, true, synced);
        attendanceViewData.add(entry);
      }
    }

    return attendanceViewData;
  }

  @override
  void initState() {
    // initState();
    setState(() {
      attendanceData = widget.attendances;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.80,
      child: SfCalendar(
        allowDragAndDrop: false,
        allowAppointmentResize: false,
        controller: _controller,
        view: CalendarView.month,
        viewHeaderStyle: ViewHeaderStyle(
          dateTextStyle: TextStyle(),
          dayTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17.0,
          ),
        ),
        firstDayOfWeek: 1,
        showNavigationArrow: true,
        headerStyle: CalendarHeaderStyle(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        monthViewSettings: MonthViewSettings(
          dayFormat: 'EE',
          agendaItemHeight: 40.0,
          showTrailingAndLeadingDates: false,
          showAgenda: true,
          agendaStyle: AgendaStyle(
            dayTextStyle: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
            dateTextStyle: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 20.0),
            appointmentTextStyle: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // dayFormat: 'EE',
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        appointmentTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 22.0,
        ),
        monthCellBuilder: monthCellBuilder,
        dataSource: AttendanceDataSource(_getAttendance()),
      ),
    );
  }
}

class Attendance {
  DateTime startDate;
  DateTime endDate;
  String subject;
  // String className="";
  bool synced;
  bool isAllDay = true;

  Attendance(
      this.startDate, this.endDate, this.subject, this.isAllDay, this.synced);
}

class AttendanceDataSource extends CalendarDataSource {
  AttendanceDataSource(List<Attendance> source) {
    appointments = source;
  }
  @override
  DateTime getStartTime(int index) {
    return appointments![index].startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endDate;
  }

  @override
  Color getColor(int index) {
    if (appointments![index].synced == "true" ||
        appointments![index].synced == true) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
    // return colorVal;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }
}
