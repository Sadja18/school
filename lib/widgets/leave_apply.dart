// ignore_for_file: unused_import, prefer_final_fields, unused_field
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ApplyForLeaveWidget extends StatefulWidget {
  const ApplyForLeaveWidget({Key? key}) : super(key: key);

  @override
  State<ApplyForLeaveWidget> createState() => _ApplyForLeaveWidgetState();
}

class _ApplyForLeaveWidgetState extends State<ApplyForLeaveWidget> {
  TextEditingController _reasonController = TextEditingController();
  final FocusNode _reasonNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  late File _image;
  String _image64Code = "";

  void uploadedImagePreview() async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const SizedBox(
              height: 0,
            ),
            titlePadding: const EdgeInsets.all(0),
            // contentPadding: const EdgeInsets.all(0),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.90,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Image(
                  image:
                      Image.memory(const Base64Decoder().convert(_image64Code))
                          .image,
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
          );
        });
  }

  Future getImageFromCamera() async {
    var image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      if (image.path.isNotEmpty) {
        setState(() {
          _image = File(image.path);
        });
        List<int> imageBytes = await File(image.path).readAsBytes();
        String img64 = base64Encode(imageBytes);

        if (img64.isNotEmpty && img64 != "") {
          setState(() {
            _image64Code = img64;
          });
        }
      }

      if (kDebugMode) {
        print(_image64Code.toString());
      }
    }
  }

  Future getImagefromGallery() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (image.path.isNotEmpty) {
        setState(() {
          _image = File(image.path);
        });
        List<int> imageBytes = await File(image.path).readAsBytes();
        String img64 = base64Encode(imageBytes);

        if (img64.isNotEmpty && img64 != "") {
          setState(() {
            _image64Code = img64;
          });
        }
      }

      if (kDebugMode) {
        print(_image64Code.toString());
      }
    }
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          tableViewField(
            "From:",
            Container(
              alignment: Alignment.centerLeft,
              child: const Text("From Date"),
            ),
          ),
          tableViewField(
            "To:",
            Container(
              alignment: Alignment.centerLeft,
              child: const Text("To Date"),
            ),
          ),
          tableViewField(
            'Leave Type',
            Container(
              decoration: const BoxDecoration(),
              child: const Text("Leave Type Selection Dropdown"),
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
          tableViewField(
            "Attachment:",
            Container(
              alignment: Alignment.centerLeft,
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FractionColumnWidth(0.40),
                  1: FractionColumnWidth(0.40)
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  getImagefromGallery();
                                },
                                child: const Icon(
                                  Icons.browse_gallery_outlined,
                                  size: 35,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  getImageFromCamera();
                                },
                                child: const Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 35,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TableCell(
                        child: (_image64Code == "")
                            ? const SizedBox(
                                height: 0,
                              )
                            : InkWell(
                                onTap: () {
                                  if (kDebugMode) {
                                    print("Show Preview");
                                  }
                                  uploadedImagePreview();
                                },
                                child: const Text(
                                  "Preview",
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                if (kDebugMode) {
                  print("reason submitted");
                  var reason = _reasonController.text;
                  print(reason);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
