// import 'dart:html';
// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateShow extends StatefulWidget {
  final Function(String?) selectedDate;
  DateShow({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<DateShow> createState() => _DateShowState();
}

class _DateShowState extends State<DateShow> {
  DateTime date = DateTime.now();

  DateTime startDate = DateTime.now();

  DateTime firstDate = DateTime(
      DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: firstDate,
      lastDate: startDate,
      locale: const Locale('en'),
    );
    if (picked != null && picked != date) {
      widget.selectedDate(DateFormat('yyyy-MM-dd').format(picked).toString());
      setState(() {
        date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          alignment: Alignment.center,
          backgroundColor: Colors.deepPurpleAccent,
        ),
        onPressed: () => _selectDate(context),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month,
              size: 25,
              color: Colors.white,
            ),
            Text(
              DateFormat('E, MMM dd, yyyy').format(date),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
