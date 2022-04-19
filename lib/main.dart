// ignore_for_file: prefer_const_constructors, avoid_print, unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import './screens/new_assessment.dart';
import '../services/helper_db.dart';
import './screens/dashboard.dart';
import './screens/login.dart';
import './services/sync_services.dart';
// import './screens/dummy.dart';
import './widgets/sticky_basic_reading_widget.dart';
import './widgets/sticky_numeric_ability_widget.dart';
import './widgets/sticky_attendance_widget.dart';
import './widgets/pace_assessment.dart';

const fetchOne = "fetch Persistent";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // print("Native called background task: $task");
    wrapper(); //simpleTask will be emitted here.S
    return Future.value(true);
  });
}

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
        future: isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // if (kDebugMode) {
          //   print("is login");
          //   print(snapshot.data.toString());
          // }
          if (snapshot.hasData &&
              (snapshot.data == 1 || snapshot.data == "1")) {
            // print();
            // return StickyAttendance();
            return Dashboard();
            // return PaceAssessmentScreen();
            // return StickyPaceWidget();
          } else {
            return Login();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        /// all the widgets mapped to the routes are defined in <project_home>/lib/screens direcory
        Dashboard.routeName: (ctx) => Dashboard(),
        Login.routeName: (ctx) => Login(),
        AssessmentScreen.routeName: (ctx) => AssessmentScreen(),
        StickyBasicReading.routeName: (ctx) => StickyBasicReading(),
        StickyNumericAbility.routeName: (ctx) => StickyNumericAbility(),
        StickyAttendance.routeName: (ctx) => StickyAttendance(),
        PaceAssessmentScreen.routeName: (ctx) => PaceAssessmentScreen()
      },
    );
  }
}
