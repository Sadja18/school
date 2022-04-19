// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/foundation.dart';
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
    var value = await DBProvider.db.getAllPace(widget.selectClass);
    // if (kDebugMode) {
    //   print('assessments in getallpace');
    //   print(value.toString());
    // }
    var valueList = value.toList();
    setState(() {
      assessmentOptions = valueList;
    });
    return valueList;
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
                hint: Container(
                  alignment: Alignment.center,
                  child: Center(
                    child: const Text(
                      'Select Assessment',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
                dropdownColor: Colors.deepPurpleAccent,
                // elevation: 16,
                style: const TextStyle(color: Colors.deepPurpleAccent),
                value: _selectedAssessment!.isNotEmpty
                    ? _selectedAssessment
                    : null,
                items: assessmentOptions.map((element) {
                  return DropdownMenuItem(
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        child: Text(
                          element['name'],
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
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
