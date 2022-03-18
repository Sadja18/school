// import 'dart:html';
// ignore_for_file: prefer_const_constructors_in_immutables

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
    return OutlinedButton(
      onPressed: () => _selectDate(context),
      child: Text(
        DateFormat('E, MMM dd, yyyy').format(date),
      ),
    );
  }
}
