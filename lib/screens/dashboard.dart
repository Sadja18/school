// ignore_for_file: unused_import, duplicate_ignore, prefer_const_constructors

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var appBarHeight = kToolbarHeight;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
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
        padding: EdgeInsets.only(top: statusBarHeight + appBarHeight + 1),
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
              ListTile(
                title: Center(
                  child: OutlinedButton(
                    onPressed: () {
                      // DBProvider.db.fetchQuery();
                      // DBProvider.db.dynamicRead(
                      //     "Select * FROM TeacherLeaveRequest;", []);

                      // fetchLeaveTypeAndRequests();
                      // Navigator.of(context).pushNamed(PaceAssessmentScreen.routeName );
                    },
                    child: const Text('Test'),
                  ),
                ),
              ),
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
                    Navigator.of(context).pushNamed(AssessmentScreen.routeName);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/dashboardIcons/assessment.png'),
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
  }
}
