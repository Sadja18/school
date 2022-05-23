import 'package:flutter/material.dart';

class HeadMasterHomeScreen extends StatelessWidget {
  const HeadMasterHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Head Master"),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  children: const [
                    Icon(
                      Icons.create_outlined,
                      semanticLabel: 'Mark New Attendance',
                      size: 40,
                    ),
                    Text(
                      'Apply',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: const [
                    Icon(
                      Icons.view_list_outlined,
                      semanticLabel: 'View marked attendance',
                      size: 40,
                    ),
                    Text(
                      'View',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            InkWell(
              onTap: () {},
              child: Card(
                elevation: 10.0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  height: MediaQuery.of(context).size.height * 0.70 * 0.50,
                  alignment: Alignment.center,
                  child: Text("Mark Attendance"),
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Card(
                elevation: 10.0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  height: MediaQuery.of(context).size.height * 0.70 * 0.50,
                  alignment: Alignment.center,
                  child: Text("View Attendance"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
