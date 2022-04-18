import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LevelDropDown extends StatefulWidget {
  final Function(String, int) updateLevel;
  // ignore: prefer_typing_uninitialized_variables
  final int index;
  final dynamic bgColor;

  final List<String> levelNames;
  const LevelDropDown(
      {Key? key,
      required this.index,
      required this.updateLevel,
      required this.levelNames,
      this.bgColor})
      : super(key: key);

  @override
  State<LevelDropDown> createState() => _LevelDropDownState();
}

class _LevelDropDownState extends State<LevelDropDown> {
  String? _selectedLevel = '0';
  @override
  void initState() {
    if (kDebugMode) {
      print(widget.levelNames.toString());
    }

    setState(() {
      _selectedLevel = widget.levelNames[0];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      dropdownColor: widget.bgColor,
      items: widget.levelNames.map<DropdownMenuItem<String>>(
        (String element) {
          return DropdownMenuItem<String>(
            child: Container(
              alignment: Alignment.center,
              // decoration: BoxDecoration(
              //   border: Border.all(
              //       // color: Colors.black,
              //       ),
              //   // color: Colors.black,
              // ),
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.all(4.0),
              child: Center(
                  child: Text(
                element,
                style: const TextStyle(
                  color: Colors.white,
                ),
              )),
            ),
            value: element,
          );
        },
      ).toList(),
      onChanged: (selectedLevel) {
        // ignore: avoid_print
        print('Selected Level: $selectedLevel');
        widget.updateLevel(selectedLevel.toString(), widget.index);
        setState(() {
          _selectedLevel = selectedLevel.toString();
        });
      },
      value: _selectedLevel!,
    );
  }
}
