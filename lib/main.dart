// ignore_for_file: prefer_const_constructors, avoid_print, unused_import

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:workmanager/workmanager.dart';

import './screens/new_assessment.dart';
import '../services/helper_db.dart';
import './screens/dashboard.dart';
import './screens/login.dart';
import './screens/attendance_leave.dart';
import './screens/leave.dart';
import './services/sync_services.dart';
// import './screens/dummy.dart';
import './widgets/sticky_basic_reading_widget.dart';
import './widgets/sticky_numeric_ability_widget.dart';
import './widgets/sticky_attendance_widget.dart';
import './widgets/pace_assessment.dart';

const fetchOne = "fetch Persistent";

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     // print("Native called background task: $task");
//     wrapper(); //simpleTask will be emitted here.S
//     return Future.value(true);
//   });
// }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// myWidget method returns a future builder
  /// if the user already logged in the application in any previous session
  /// show the dashboard
  /// else show the login screen
  Widget myWidget(BuildContext context) {
    return FutureBuilder(
        future: isHeadMasterLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // if (kDebugMode) {
          //   print("is login");
          //   print(snapshot.data.toString());
          // }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(),
              body: const SizedBox(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData && (snapshot.data.isNotEmpty)) {
            // print();
            // return StickyAttendance();
            // return PaceAssessmentScreen();
            // return StickyNumericAbility();
            // return LeaveScreen();

            // return StickyBasicReading();
            var login = snapshot.data;
            return Dashboard();
          } else {
            return Login();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // debugShowMaterialGrid: true,
      title: 'School Erp',
      theme: ThemeData(
        primaryColor: Colors.purpleAccent,
        fontFamily: 'Poppins',
        backgroundColor: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: 1.20,
              fontSizeDelta: 0.5,
              fontFamily: 'Poppins',
            ),
      ),
      initialRoute: '/',
      routes: {
        /// the home route; keyed by '/'; should always be the widget returned by the myWidget method
        '/': (ctx) => myWidget(ctx),

        /// the other paths are just specifying which Navigation route maps to which widget
        /// all the widgets mapped to the routes are defined in <project_home>/lib/screens directory
        Login.routeName: (ctx) => Login(),
        Dashboard.routeName: (ctx) => Dashboard(),
        AttedanceLeaveScreen.routeName: (ctx) => AttedanceLeaveScreen(),
        StickyAttendance.routeName: (ctx) => StickyAttendance(),
        LeaveScreen.routeName: (ctx) => LeaveScreen(),
        AssessmentScreen.routeName: (ctx) => AssessmentScreen(),
        StickyBasicReading.routeName: (ctx) => StickyBasicReading(),
        StickyNumericAbility.routeName: (ctx) => StickyNumericAbility(),
        PaceAssessmentScreen.routeName: (ctx) => PaceAssessmentScreen(),
      },
    );
  }
}
