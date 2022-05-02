import 'package:flutter/material.dart';

import '../widgets/sticky_attendance_widget.dart';
import './leave.dart';

class AttedanceLeaveScreen extends StatelessWidget {
  static const routeName = "/screen-attendance-leave";
  const AttedanceLeaveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var appBarHeight = kToolbarHeight;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          alignment: Alignment.topCenter,
          child: const Text(
            "Attendance/Leave",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height -
            (statusBarHeight + appBarHeight + 1),
        decoration: const BoxDecoration(),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              width: MediaQuery.of(context).size.width * 0.60,
              height: MediaQuery.of(context).size.height * 0.30,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(StickyAttendance.routeName);
//
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/dashboardIcons/leave.png'),
                    const Text(
                      'Attendance',
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
              width: MediaQuery.of(context).size.width * 0.60,
              height: MediaQuery.of(context).size.height * 0.30,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(LeaveScreen.routeName);
//
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/dashboardIcons/leave.png'),
                    const Text(
                      'Leaves',
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
    );
  }
}
