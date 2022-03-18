// ignore_for_file: unused_import, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:school/services/helper_db.dart';
// import 'package:school/screens/dummy.dart';
import 'package:workmanager/workmanager.dart';

import '../main.dart';
import '../screens/new_assessment.dart';
import '../services/request_handler.dart';
import '../screens/login.dart';
import '../services/database_handler.dart';
import '../services/sync_services.dart';
import '../widgets/sticky_attendance_widget.dart';

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
    fetchPersistent();
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    Workmanager().registerOneOffTask("1", fetchOne);
    Workmanager().registerPeriodicTask("2",
        fetchOne, //This is the value that will be returned in the callbackDispatcher
        frequency: const Duration(minutes: 30, hours: 5));
    setUserName();
  }

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
        child: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.shade100,
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10.0)),
                child: ListTile(
                  title: Text(userName!),
                  tileColor: Colors.transparent,
                ),
              ),
              ListTile(
                title: Center(
                  child: OutlinedButton(
                    onPressed: () {
                      wrapper();
                    },
                    child: const Text('Sync Data'),
                  ),
                ),
              ),
              ListTile(
                title: Center(
                  child: OutlinedButton(
                    onPressed: () {
                      _onLogout();
                    },
                    child: const Text('Logout'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  // ignore: avoid_print
                  // print('Attendance');
                  // Navigator.of(context).pushNamed(Dummy.routeName);
                  Navigator.of(context).pushNamed(StickyAttendance.routeName);
//
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/dashboardIcons/leave.png'),
                    const Text('Attendance'),
                  ],
                ),
              ),
              TextButton(
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
                    const Text('Assessment'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
