import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class DateShowNew extends StatefulWidget {
  final Function(String?) dateSelector;
  const DateShowNew({Key? key, required this.dateSelector}) : super(key: key);

  @override
  _DateShowNewState createState() => _DateShowNewState();
}

class _DateShowNewState extends State<DateShowNew> {
  DateTime date = DateTime.now();

  DateTime startDate = DateTime(
      DateTime.now().year, DateTime.now().month + 12, DateTime.now().day);

  DateTime firstDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 7);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: firstDate,
      lastDate: startDate,
      locale: const Locale('en'),
    );
    if (picked != null && picked != date) {
      widget.dateSelector(DateFormat('yyyy-MM-dd').format(picked).toString());
      setState(() {
        date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: OutlinedButton(
        onPressed: () => _selectDate(context),
        child: Text(
          DateFormat('E, MMM, dd yyyy').format(date),
        ),
      ),
    );
  }
}
