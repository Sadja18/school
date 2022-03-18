// ignore_for_file: avoid_print, unused_import

import 'package:flutter/material.dart';
import '../services/database_handler.dart';

import './dashboard.dart';
import './login.dart';
import '../widgets/sticky_pace_widget.dart';
import '../widgets/sticky_basic_reading_widget.dart';
import '../widgets/sticky_numeric_ability_widget.dart';

class AssessmentScreen extends StatefulWidget {
  static const routeName = '/assessment';
  const AssessmentScreen({Key? key}) : super(key: key);

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  void _onLogout() {
    // read data from db to get user where login-status = 1;
    DBProvider.db.logoutUser().then((value) {
      // print(value.runtimeType);
      // print(value);
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Login.routeName, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popAndPushNamed(Dashboard.routeName);
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              _onLogout();
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
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/img1.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        margin: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                width: 2.0, color: Colors.blue),
                          ),
                          onPressed: () {
                            print("khgasdh");
                            // Navigator.of(context).pushNamed(PaceScreen.routeName);
                            Navigator.of(context)
                                .pushNamed(StickyPaceWidget.routeName);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                    'assets/dashboardIcons/assessment.png'),
                                const Text('PACE'),
                              ],
                            ),
                          ),
                        ),
                      ), // end of pace selection
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.1,
                      ),
                      Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                width: 2.0, color: Colors.blue),
                          ),
                          onPressed: () {
                            print("khgasdh 1");
                            Navigator.of(context)
                                .pushNamed(StickyBasicReading.routeName);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                    'assets/dashboardIcons/assessment.png'),
                                const Text('Basic Reading'),
                              ],
                            ),
                          ),
                        ),
                      ), // end of basic selection
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.1,
                      ),
                      Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                width: 2.0, color: Colors.blue),
                          ),
                          onPressed: () {
                            print("khgasdh 2");
                            Navigator.of(context)
                                .pushNamed(StickyNumericAbility.routeName);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                    'assets/dashboardIcons/assessment.png'),
                                const Text('Numerical Ability'),
                              ],
                            ),
                          ),
                        ),
                      ), // end of numerical selection
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
