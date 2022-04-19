// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import '../services/database_handler.dart';

class ClassDropDown extends StatefulWidget {
  final Function(String) selectClass;
  final Function(List<dynamic>) getAllStudents;
  const ClassDropDown(
      {Key? key, required this.selectClass, required this.getAllStudents})
      : super(key: key);

  @override
  State<ClassDropDown> createState() => _ClassDropDownState();
}

class _ClassDropDownState extends State<ClassDropDown> {
  String _selectedClass = "";

  Future<void> _getClasses() async {
    var classes = await DBProvider.db.getClass().then((classes) {
      return classes;
    });
    return classes.toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getClasses(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Text('Loading');
          } else {
            var classes = snapshot.data;
            // print(classes.toString());
            List<String> classNames = [];
            for (var classRecord in classes) {
              classNames.add(classRecord['class_name']);
            }
            return Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.06,
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
              ),
              child: DropdownButton<String>(
                dropdownColor: Color.fromARGB(255, 209, 37, 201),
                hint: const Text(
                  'Select Class',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurpleAccent),
                value: _selectedClass.isNotEmpty ? _selectedClass : null,
                items: classNames.map<DropdownMenuItem<String>>(
                  (String element) {
                    return DropdownMenuItem<String>(
                      child: Container(
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                        ),
                        child: Text(
                          element,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      value: element,
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  print(value);
                  setState(() {
                    _selectedClass = value.toString();
                  });
                  widget.selectClass(value.toString());
                  var list = [];

                  DBProvider.db.getStudents(_selectedClass).then((value) {
                    if (value.length > 0) {
                      for (var index = 0; index < value.length; index++) {
                        // print(index);
                        var a = {
                          'className': value[index]['class_name'],
                          'studentId': value[index]['student_id'],
                          'studentName': value[index]['student_name'],
                          'rollNo': value[index]['student_roll_no'],
                          'profilePic': value[index]['profile_pic'],
                          'notEvaluated': false,
                          'level': '0',
                          'result': ''
                        };
                        list.add(a);
                      }
                    }
                    if (list.isNotEmpty) {
                      widget.getAllStudents(list);
                    }
                  });
                },
              ),
            );
          }
        } else {
          return const Text('no classes');
        }
      },
    );
  }
}
