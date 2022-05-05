import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class LeaveCalendarView extends StatefulWidget {
  final List leaveRequests;
  const LeaveCalendarView({Key? key, required this.leaveRequests})
      : super(key: key);

  @override
  State<LeaveCalendarView> createState() => _LeaveCalendarViewState();
}

class _LeaveCalendarViewState extends State<LeaveCalendarView> {
  final CalendarController _controller = CalendarController();

  List<Leaves> _getLeaves() {
    List<Leaves> leaveViewData = <Leaves>[];

    if (widget.leaveRequests.isNotEmpty) {
      for (var i = 0; i < widget.leaveRequests.length; i++) {
        var record = widget.leaveRequests[i];
        // if (kDebugMode) {
        //   log(record.toString());
        // }
        DateTime startDateParsed = DateTime.parse(record['leaveFromDate']);
        DateTime endDateParsed =
            DateTime.parse("${record['leaveToDate']} 23:59:59");
        String subject = record['leaveReason'];
        String leaveRequestStatus = record['leaveRequestStatus'];
        Color backColor = Colors.white;

        if (leaveRequestStatus == 'draft' ||
            leaveRequestStatus == 'toapprove') {
          backColor = Colors.blue;
        } else if (leaveRequestStatus == 'approve') {
          backColor = Colors.green;
        } else {
          backColor = Colors.red;
        }

        Leaves entry =
            Leaves(startDateParsed, endDateParsed, subject, backColor, true);
        leaveViewData.add(entry);
      }
    }
    return leaveViewData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(),
      child: (1 == 1)
          ? SfCalendar(
              allowAppointmentResize: false,
              allowDragAndDrop: false,
              controller: _controller,
              view: CalendarView.month,
              viewHeaderStyle: const ViewHeaderStyle(
                dateTextStyle: TextStyle(),
                dayTextStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              firstDayOfWeek: 1,
              showNavigationArrow: true,
              headerStyle: const CalendarHeaderStyle(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              monthViewSettings: const MonthViewSettings(
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
              appointmentTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 22.0,
              ),
              dataSource: LeaveDataSource(_getLeaves()),
            )
          : Text(widget.leaveRequests.toString()),
    );
  }
}

class Leaves {
  DateTime startDate;
  DateTime endDate;
  String reason;
  Color backColors;
  // String className="";
  // bool synced;
  bool isAllDay = true;
  Leaves(
    this.startDate,
    this.endDate,
    this.reason,
    this.backColors,
    this.isAllDay,
  );
}

class LeaveDataSource extends CalendarDataSource {
  LeaveDataSource(List<Leaves> source) {
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
    return appointments![index].backColors;
    // return colorVal;
  }

  @override
  bool isAllDay(int index) {
    return true;
  }

  @override
  String getSubject(int index) {
    return appointments![index].reason;
  }
}
