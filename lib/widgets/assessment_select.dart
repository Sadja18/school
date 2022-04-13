// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../services/database_handler.dart';

class AssessmentsDropDown extends StatefulWidget {
  final String? selectClass;
  final Function(dynamic) selectAssessment;
  const AssessmentsDropDown(
      {Key? key, required this.selectClass, required this.selectAssessment})
      : super(key: key);

  @override
  _AssessmentsDropDownState createState() => _AssessmentsDropDownState();
}

class _AssessmentsDropDownState extends State<AssessmentsDropDown> {
  List<dynamic> assessmentOptions = [];
  String? _selectedAssessment = '';

  Future<dynamic> _getAllPaceAssessments() async {
    return DBProvider.db.getAllPace(widget.selectClass).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          assessmentOptions = value.toList();
        });
        return value.toList();
      }
    });
    // return assessmentOptions;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getAllPaceAssessments(),
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Text('Fetching Scheduled Assessments');
          } else {
            // return Text(assessmentOptions.toString());
            // print(_selectedAssessment.toString());
            return DropdownButton(
                hint: const Text('Select Assessment',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    )),
                underline: Container(
                  height: 2,
                  color: Colors.transparent,
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurpleAccent),
                value: _selectedAssessment!.isNotEmpty
                    ? _selectedAssessment
                    : null,
                items: assessmentOptions.map((element) {
                  return DropdownMenuItem(
                      child: Text(
                        element['name'],
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: element['name']);
                }).toList(),
                onChanged: (selectedValue) {
                  setState(() {
                    _selectedAssessment = selectedValue.toString();
                  });
                  for (var assessment in assessmentOptions) {
                    // print(assessment.toString());

                    if (assessment['name'] == selectedValue.toString()) {
                      // print(assessment['totques'].runtimeType);
                      widget.selectAssessment(assessment);
                    }
                  }
                });
          }
        } else {
          return const Text('No Assessments Found');
        }
      },
    );
  }
}
