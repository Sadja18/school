import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LeaveViewApplied extends StatefulWidget {
  const LeaveViewApplied({Key? key}) : super(key: key);

  @override
  State<LeaveViewApplied> createState() => _LeaveViewAppliedState();
}

class _LeaveViewAppliedState extends State<LeaveViewApplied> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: const Text("FutureBuilder view"),
    );
  }
}
