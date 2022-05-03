import 'package:flutter/material.dart';

class LeaveTypeDropdown extends StatefulWidget {
  final List<String> leaveTypeNames;
  final Function(String) leaveTypeSelector;
  const LeaveTypeDropdown(
      {Key? key, required this.leaveTypeNames, required this.leaveTypeSelector})
      : super(key: key);

  @override
  State<LeaveTypeDropdown> createState() => _LeaveTypeDropdownState();
}

class _LeaveTypeDropdownState extends State<LeaveTypeDropdown> {
  late String selectionValue;
  late List<String> leaveTypeNames;
  @override
  void initState() {
    setState(() {
      selectionValue = widget.leaveTypeNames[0];
      leaveTypeNames = widget.leaveTypeNames;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.50,
      height: MediaQuery.of(context).size.height * 0.10,
      child: DropdownButton(
        dropdownColor: Colors.deepPurpleAccent,
        value: selectionValue,
        onChanged: (value) {
          setState(() {
            selectionValue = value.toString();
          });
          widget.leaveTypeSelector(value.toString());
        },
        items: leaveTypeNames.map<DropdownMenuItem<String>>((String e) {
          return DropdownMenuItem<String>(
            value: e.toString(),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.30,
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(color: Colors.purpleAccent),
              child: Text(
                e.toString(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
