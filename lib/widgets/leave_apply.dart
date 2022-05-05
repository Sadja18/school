// ignore_for_file: unused_import, prefer_final_fields, unused_field
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/database_handler.dart';

import './assist/date_selector.dart';
import './assist/leave_types_dropdown.dart';
import '../services/helper_db.dart';

class ApplyForLeaveWidget extends StatefulWidget {
  const ApplyForLeaveWidget({Key? key}) : super(key: key);

  @override
  State<ApplyForLeaveWidget> createState() => _ApplyForLeaveWidgetState();
}

class _ApplyForLeaveWidgetState extends State<ApplyForLeaveWidget> {
  TextEditingController _reasonController = TextEditingController();
  final FocusNode _reasonNode = FocusNode();
  // final ImagePicker _picker = ImagePicker();
  // late File _image;
  // String _image64Code = "";
  List<String> leaveTypeNames = [];

  String _selectedStartDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _selectedEndDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  double dateDiff = DateTime.now().difference(DateTime.now()).inHours / 24;

  double dateDiffCacl() {
    var to = DateTime.parse(_selectedEndDate);
    var from = DateTime.parse(_selectedStartDate);
    var dateDifference = (to.difference(from).inHours / 24);
    // if(dateDifference)
    dateDifference = dateDifference + 1;
    setState(() {
      dateDiff = dateDifference;
    });
    return dateDifference;
  }

  String _selectedLeaveType = "";

  Future<dynamic> getLeaveTypes() async {
    String query = "SELECT leaveTypeName FROM TeacherLeaveAllocation;";
    var leaveTypes = await DBProvider.db.dynamicRead(query, []);
    if (kDebugMode) {
      print('leave tgypes');
      print(leaveTypes.toString());
    }
    List<String> tmp = [];
    for (var leaveType in leaveTypes) {
      String name = leaveType['leaveTypeName'].toString();
      tmp.add(name);
    }
    if (tmp.isNotEmpty) {
      setState(() {
        leaveTypeNames = tmp;
        _selectedLeaveType = tmp[0];
      });
    }
    return tmp;
  }

  void leaveTypeSelector(String selectedLeaveType) {
    if (kDebugMode) {
      print('selectedLeaveType');
      print(selectedLeaveType);
    }
    if (selectedLeaveType.isNotEmpty && selectedLeaveType != '') {
      setState(() {
        _selectedLeaveType = selectedLeaveType;
      });
    }
  }

  void showAlertBoxForLeaveTypeSelection() async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const SizedBox(
              height: 0,
            ),
            titlePadding: const EdgeInsets.all(0),
            content: LeaveTypeDropdown(
              leaveTypeNames: leaveTypeNames,
              leaveTypeSelector: leaveTypeSelector,
            ),
          );
        });
  }

  void startDateSelector(String? selectedDate) {
    setState(() {
      _selectedStartDate = selectedDate!;
    });
    dateDiffCacl();
  }

  void endDateSelector(String? selectedDate) {
    setState(() {
      _selectedEndDate = selectedDate!;
    });
    dateDiffCacl();
  }

  Widget tableViewField(String fieldName, Widget fieldWidget) {
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      decoration: const BoxDecoration(),
      width: MediaQuery.of(context).size.width * 0.90,
      child: Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FractionColumnWidth(0.35),
          1: FractionColumnWidth(0.65),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              TableCell(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context),
                  child: Text(
                    fieldName,
                    style: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              TableCell(
                child: fieldWidget,
              ),
            ],
          )
        ],
      ),
    );
  }

  void showAlertBox(String title, String message) async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Container(
              decoration: const BoxDecoration(
                color: Colors.purple,
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            titlePadding: const EdgeInsets.only(
              top: 0,
              left: 0,
              right: 0,
            ),
            contentPadding: const EdgeInsets.only(
              top: 0,
              left: 0,
              right: 0,
            ),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(),
              child: Text(message),
            ),
          );
        });
  }

  void onConfirm() async {
    String fromDate = _selectedStartDate;
    String toDate = _selectedEndDate;
    String days = dateDiff.toString();
    String leaveType = _selectedLeaveType;
    String reason = _reasonController.text;
    // show saving dialog;
    await saveLeaveRequestToDB(fromDate, toDate, days, leaveType, reason);
    // show saved dialog;
    Navigator.of(context).pop();

    showAlertBox("Success", "Data Saved Successfully");
  }

  void showPreview() async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.purple,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  onConfirm();
                },
                child: const Text(
                  "Confirm",
                  style: TextStyle(
                    color: Colors.purple,
                  ),
                ),
              ),
            ],
            title: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.purple,
              ),
              child: const Text(
                "Preview",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            titlePadding: const EdgeInsets.all(0),
            content: Container(
              alignment: Alignment.topCenter,
              height: MediaQuery.of(context).size.height * 0.40,
              width: MediaQuery.of(context).size.width * 0.70,
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FractionColumnWidth(0.40),
                  1: FractionColumnWidth(0.60),
                },
                children: [
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          "From",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          DateFormat('EEE, MMM dd, yy').format(
                            DateTime.parse(_selectedStartDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          "To",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          DateFormat('EEE, MMM dd, yy').format(
                            DateTime.parse(_selectedEndDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          "Days",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          dateDiff.toString(),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          "Reason",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          _reasonController.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  dynamic dateValidation() {
    var to = DateTime.parse(_selectedEndDate);
    var from = DateTime.parse(_selectedStartDate);
    if (to.isBefore(from)) {
      return "From date cannot be after To Date";
    } else {
      var datdiff = dateDiffCacl();
      if (kDebugMode) {
        log(datdiff.toString());
      }
      if (dateDiff <= 0) {
        return "Internal error";
      } else {
        return "";
      }
    }
  }

  void onSubmit() {
    String title = "";
    String message = "";
    if (_selectedLeaveType.isEmpty || _selectedLeaveType == "") {
      message = "Please select a leave type";
      title = "Leave Type";
      return showAlertBox(title, message);
    } else {
      var text = _reasonController.text;
      if (text.isEmpty) {
        message = "Please enter reason for leave";
        title = "Empty Reason";
        return showAlertBox(title, message);
      } else {
        var message = dateValidation();
        if (message != "") {
          title = "Incorrect Dates";
          return showAlertBox(title, message);
        } else {
          title = "";
          message = "";
          showPreview();
        }
      }
    }
  }

  @override
  void initState() {
    // getLeaveTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var appBarHeight = kToolbarHeight;
    var formWidgetHeight = MediaQuery.of(context).size.height -
        (statusBarHeight + appBarHeight + 1);
    return Container(
      decoration: const BoxDecoration(),
      height: formWidgetHeight,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            tableViewField(
              "From:",
              Container(
                alignment: Alignment.centerLeft,
                child: DateShowNew(dateSelector: startDateSelector),
              ),
            ),
            tableViewField(
              "To:",
              Container(
                alignment: Alignment.centerLeft,
                child: DateShowNew(dateSelector: endDateSelector),
              ),
            ),
            tableViewField(
              'Leave Type:',
              Container(
                decoration: const BoxDecoration(),
                child: FutureBuilder(
                    future: getLeaveTypes(),
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data.isNotEmpty) {
                        return LeaveTypeDropdown(
                            leaveTypeNames: leaveTypeNames,
                            leaveTypeSelector: leaveTypeSelector);
                      } else {
                        return Container(
                          alignment: Alignment.topCenter,
                          child: const Text('No leave types found'),
                        );
                      }
                    }),
              ),
            ),
            tableViewField(
                "Reason:",
                Container(
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 3,
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 3,
                          color: Colors.purple,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    controller: _reasonController,
                    focusNode: _reasonNode,
                    onChanged: (value) {
                      if (kDebugMode) {
                        print("value change reason");
                        print(value.toString());
                      }
                    },
                  ),
                )),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 15.0,
              ),
              child: InkWell(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  onSubmit();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// void uploadedImagePreview() async {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext ctx) {
  //         return AlertDialog(
  //           title: const SizedBox(
  //             height: 0,
  //           ),
  //           titlePadding: const EdgeInsets.all(0),
  //           // contentPadding: const EdgeInsets.all(0),
  //           content: SizedBox(
  //             height: MediaQuery.of(context).size.height * 0.90,
  //             width: MediaQuery.of(context).size.width,
  //             child: SingleChildScrollView(
  //               child: Image(
  //                 image:
  //                     Image.memory(const Base64Decoder().convert(_image64Code))
  //                         .image,
  //                 fit: BoxFit.fill,
  //                 width: MediaQuery.of(context).size.width,
  //                 height: MediaQuery.of(context).size.height,
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  // }

  // Future getImageFromCamera() async {
  //   var image = await _picker.pickImage(source: ImageSource.camera);
  //   if (image != null) {
  //     if (image.path.isNotEmpty) {
  //       setState(() {
  //         _image = File(image.path);
  //       });
  //       List<int> imageBytes = await File(image.path).readAsBytes();
  //       String img64 = base64Encode(imageBytes);

  //       if (img64.isNotEmpty && img64 != "") {
  //         setState(() {
  //           _image64Code = img64;
  //         });
  //       }
  //     }

  //     if (kDebugMode) {
  //       print(_image64Code.toString());
  //     }
  //   }
  // }

  // Future getImagefromGallery() async {
  //   var image = await _picker.pickImage(source: ImageSource.gallery);

  //   if (image != null) {
  //     if (image.path.isNotEmpty) {
  //       setState(() {
  //         _image = File(image.path);
  //       });
  //       List<int> imageBytes = await File(image.path).readAsBytes();
  //       String img64 = base64Encode(imageBytes);

  //       if (img64.isNotEmpty && img64 != "") {
  //         setState(() {
  //           _image64Code = img64;
  //         });
  //       }
  //     }

  //     if (kDebugMode) {
  //       print(_image64Code.toString());
  //     }
  //   }
  // }
