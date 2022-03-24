import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

import '../services/helper_db.dart';

class ViewTakenAttendance extends StatefulWidget {
  const ViewTakenAttendance({Key? key}) : super(key: key);

  @override
  State<ViewTakenAttendance> createState() => _ViewTakenAttendanceState();
}

class _ViewTakenAttendanceState extends State<ViewTakenAttendance> {
  DateTime _focusedDay = DateTime.now();
  DateTime _rangeStart = DateTime(DateTime.now().year, DateTime.now().month, 0);
  DateTime _rangeEnd = DateTime.now();

  void updateRange(date) {
    setState(() {
      _rangeStart = getFirstDate(date);
      _rangeEnd = getLastDate(date);
    });
    if (kDebugMode) {
      print(date);
      print(_rangeStart);
      print(_rangeEnd);
    }
  }

  DateTime getDateMonthBack(DateTime date) {
    return DateTime(date.year, date.month - 1, date.day);
  }

  DateTime getDateMonthAfter(DateTime date) {
    return DateTime(date.year, date.month + 1, date.day);
  }

  DateTime getFirstDate(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime getLastDate(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  void _onNextMonth() {
    if (kDebugMode) {
      print('Nh');
    }
    DateTime tmp = getDateMonthAfter(_focusedDay);

    setState(() {
      _focusedDay = tmp;
    });
    updateRange(tmp);
  }

  void _onPrevMonth() {
    if (kDebugMode) {
      print('Nh');
    }
    DateTime tmp = getDateMonthBack(_focusedDay);

    setState(() {
      _focusedDay = tmp;
    });
    updateRange(tmp);
  }

  Widget columnTitleBuild(columnIndex) {
    switch (columnIndex) {
      case 0:
        return Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            border: Border.all(),
            color: Colors.blue,
          ),
          child: const Text(
            'Class',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      case 1:
        return Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            border: Border.all(),
            color: Colors.blue,
          ),
          child: const Text(
            'Date Added',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      default:
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(),
          child: const Text(
            '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
    }
  }

  String dateFormatter(String date) {
    return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
  }

  Widget rowTitleBuild(rowIndex, data) {
    var isEven = rowIndex % 2 == 0;

    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        border: Border.all(),
        color: isEven ? Colors.lightBlue.shade200 : Colors.lightBlue.shade400,
      ),
      child: Text(
        dateFormatter(data[rowIndex]['date']),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget contentCellBuild(columnIndex, rowIndex, data) {
    switch (columnIndex) {
      case 0:
        var isEven = rowIndex % 2 == 0;

        return Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            border: Border.all(),
            color:
                isEven ? Colors.lightBlue.shade200 : Colors.lightBlue.shade400,
          ),
          child: Text(
            data[rowIndex]['class_name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        );
      case 1:
        var isEven = rowIndex % 2 == 0;

        return Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            border: Border.all(),
            color:
                isEven ? Colors.lightBlue.shade200 : Colors.lightBlue.shade400,
          ),
          child: Text(
            dateFormatter(data[rowIndex]['submission_date']),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        );
      default:
        var isEven = rowIndex % 2 == 0;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(),
            // color:
            // isEven ? Colors.lightBlue.shade200 : Colors.lightBlue.shade400,
          ),
          child: const Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        );
    }
  }

  ScrollController verticalBodyController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController verticalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalTitleController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController horizontalBodyController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollControllers scrollControllers() {
    return ScrollControllers(
      verticalTitleController: verticalTitleController,
      verticalBodyController: verticalBodyController,
      horizontalTitleController: horizontalTitleController,
      horizontalBodyController: horizontalBodyController,
    );
  }

  Widget stickyViewTable(data) {
    return Container(
      alignment: Alignment.topCenter,
      decoration: const BoxDecoration(),
      child: StickyHeadersTable(
        cellAlignments: const CellAlignments.fixed(
          contentCellAlignment: Alignment.center,
          stickyColumnAlignment: Alignment.center,
          stickyRowAlignment: Alignment.center,
          stickyLegendAlignment: Alignment.center,
        ),
        cellDimensions: CellDimensions.variableColumnWidthAndRowHeight(
            columnWidths: [130, 130],
            rowHeights: List<double>.generate(data.length, (int index) => 70),
            stickyLegendWidth: 140,
            stickyLegendHeight: 70),
        initialScrollOffsetX: 0.0,
        initialScrollOffsetY: 0.0,
        scrollControllers: scrollControllers(),
        columnsLength: 2,
        rowsLength: data.length,
        columnsTitleBuilder: (i) => columnTitleBuild(i),
        rowsTitleBuilder: (j) => rowTitleBuild(j, data),
        contentCellBuilder: (i, j) => contentCellBuild(i, j, data),
        legendCell: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            border: Border.all(),
            color: Colors.blue,
          ),
          child: const Text(
            'Date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      primary: Colors.red,
                      backgroundColor: Colors.black38,
                      padding: const EdgeInsets.all(10),
                    ),
                    onPressed: _onPrevMonth,
                    child: const Icon(
                      Icons.arrow_circle_left_outlined,
                      semanticLabel: 'Previous Month',
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: OutlinedButton(
                    onPressed: _onNextMonth,
                    style: OutlinedButton.styleFrom(
                      primary: Colors.red,
                      backgroundColor: Colors.black38,
                      padding: const EdgeInsets.all(10),
                    ),
                    child: const Icon(
                      Icons.arrow_circle_right_outlined,
                      size: 50,
                      semanticLabel: 'Next Month',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 10.0,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0,
            ),
            child: Text(
              DateFormat('MMMM, yyyy').format(_focusedDay).toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 21.4,
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width*0.98,
              alignment: Alignment.topCenter,
              child: FutureBuilder(
                future: readAllAttendanceActive(_rangeStart, _rangeEnd),
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                        'Internal Server Error.\nPlease try again later');
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data != null && snapshot.data.isNotEmpty) {
                      var data = snapshot.data;

                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.50,
                        child: stickyViewTable(data),
                      );
                    }
                  }
                  return const Text('');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
