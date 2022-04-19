// ignore_for_file: prefer_const_constructors, unused_local_variable

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../services/helper_db.dart';

class StudentAttendanceCalendarView extends StatefulWidget {
  const StudentAttendanceCalendarView({Key? key}) : super(key: key);

  @override
  State<StudentAttendanceCalendarView> createState() =>
      _StudentAttendanceCalendarViewState();
}

class _StudentAttendanceCalendarViewState
    extends State<StudentAttendanceCalendarView> {
  final CalendarController _controller = CalendarController();
  int isInitiated = 0;

  List attendanceData = [];

  void initiate() async {
    DateTime _rangeStart =
        DateTime(DateTime.now().year, DateTime.now().month, 0);
    DateTime _rangeEnd = DateTime.now();
    var data = await readAllAttendanceActive(_rangeStart, _rangeEnd);

    // if (kDebugMode) {
    //   log(data.toString());
    // }
    setState(() {
      attendanceData = data;
      isInitiated = 1;
    });
  }

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
    if (attendanceData.isNotEmpty && isInitiated == 1) {
      for (var i = 0; i < attendanceData.length; i++) {
        var record = attendanceData[i];

        DateTime startDateParsed = DateTime.parse(record['date']);
        DateTime endDateParsed = DateTime.parse("${record['date']} 23:59:59");
        String subject = record['class_name'];
        DateTime submissionDateUn = DateTime.parse(record['submission_date']);
        bool synced = (record['synced']=='false')? false: true;
        // String subject = DateFormat('MMMM yyyy')
        Attendance entry =
            Attendance(startDateParsed, endDateParsed, subject, true, synced);
        attendanceViewData.add(entry);
      }

      // if (kDebugMode) {
      //   print(attendanceViewData.toString());
      // }
    }

    return attendanceViewData;
  }

  @override
  void initState() {
    // initState();
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (isInitiated == 1)
              ? SizedBox(
                  height: 0,
                  child: const Text(""),
                )
              : Container(
                  decoration: BoxDecoration(),
                  child: TextButton(
                    onPressed: () {
                      initiate();
                    },
                    child: const Text("Show"),
                  ),
                ),
          (isInitiated == 0)
              ? const Text("")
              : Container(
                  height: MediaQuery.of(context).size.height * 0.80,
                  decoration: const BoxDecoration(),
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
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                    ),
                    appointmentTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 22.0,
                    ),
                    monthCellBuilder: monthCellBuilder,
                    dataSource: AttendanceDataSource(_getAttendance()),
                  ),
                ),
        ],
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
    if(appointments![index].synced==false){
      return Colors.blue;
    }else{
      return Colors.green;
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
