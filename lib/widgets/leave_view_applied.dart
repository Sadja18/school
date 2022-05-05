import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/helper_db.dart';
import './date_class_leave.dart';

class LeaveViewApplied extends StatefulWidget {
  const LeaveViewApplied({Key? key}) : super(key: key);

  @override
  State<LeaveViewApplied> createState() => _LeaveViewAppliedState();
}

class _LeaveViewAppliedState extends State<LeaveViewApplied> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: readAllLeaveRequest(),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Container(
              alignment: Alignment.topCenter,
              child: const Text("No leave requests found"),
            );
          } else {
            if (snapshot.hasData) {
              if (snapshot.data == null || snapshot.data.isEmpty) {
                return Container(
                  alignment: Alignment.topCenter,
                  child: const Text("No leave requests found"),
                );
              } else {
                var leaveRequests = snapshot.data;
                return LeaveCalendarView(
                  leaveRequests: leaveRequests,
                );
              }
            }
          }
          return Container(
            decoration: const BoxDecoration(),
            child: const Text("FutureBuilder view"),
          );
        });
  }
}
