// ignore_for_file: avoid_print, duplicate_ignore, unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import 'package:workmanager/workmanager.dart';
import '../services/offline.dart';
import '../services/database_handler.dart';
import '../services/helper_db.dart';
import '../models/response_struct.dart';
import '../models/message_config.dart';
import '../screens/dashboard.dart';
import '../services/request_handler.dart' as request_handler;

// ignore: use_key_in_widget_constructors
class Login extends StatefulWidget {
  static const routeName = '/login';
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final usernameController = TextEditingController();
  final userPasswordController = TextEditingController();

  bool _isObscure = true;
  // late UserDatabaseHandler _handler;

  Map<String, dynamic> _connection = {};
  String _messageCode = '';

  Future<void> _showAlertDialog() {
    String message = confs[_messageCode] as String;
    print(_messageCode);
    print('kijd');
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) => AlertDialog(
              title: Text(_messageCode),
              content: Text(message),
              actions: [
                TextButton(
                  child: const Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_messageCode == '1LO200' || _messageCode == '0LO200') {
                      print('move to dashboard');
                      Navigator.of(context)
                          .pushReplacementNamed(Dashboard.routeName);
                    }
                  },
                ),
              ],
            ));
  }

  // ignore: duplicate_ignore, duplicate_ignore
  void _onClickLogin(BuildContext context) {
    final enteredUserName = usernameController.text;
    final enteredUserPassword = userPasswordController.text;

    if (enteredUserPassword.isEmpty || enteredUserName.isEmpty) {
      return;
    }

    print('clicked');

    var conn = request_handler.sendTestRequest();

    conn.then((response) {
      if (response.runtimeType == Response) {
        if (response.statusCode == 200) {
          setState(() {
            _connection = jsonDecode(response.body);
          });
          // print('_connection');
          if (_connection['connected'] == 'true' ||
              _connection['connected'] == true) {
            // print(_connection.toString());

            if (enteredUserPassword.isNotEmpty &&
                enteredUserPassword.isNotEmpty) {
              request_handler
                  .tryLogin(enteredUserName, enteredUserPassword)
                  .then((response) {
                if (response.runtimeType == Response) {
                  // print('gerhqah');
                  if (response.statusCode == 200) {
                    var respBody = jsonDecode(response.body);
                    if (respBody['login_status'] == 1) {
                      setState(() {
                        _messageCode = '1LO200';
                      });
                      _showAlertDialog();

                      // print(respBody.runtimeType);
                      saveUserToDB(respBody);
                    } else {
                      setState(() {
                        _messageCode = '1LO01';
                      });
                      _showAlertDialog();
                    }
                  }
                } else {
                  print('offline mode on');
                }
              });
            }
          }
        }
        if (response.statusCode == 402) {
          print('offline mode, remote server down');
          offlineLogin(enteredUserName, enteredUserPassword).then((value) {
            print('here 1');
            if (value['no_user'] == 1) {
              setState(() {
                _messageCode = '0LO01';
              });
              _showAlertDialog();

              print('here no');
            } else {
              print('here 2');

              if (value['login_status'] == 1 || value['login_status'] == '1') {
                setState(() {
                  _messageCode = '0LO200';
                });
                _showAlertDialog();

                print('here 3');
              } else {
                setState(() {
                  _messageCode = '0LO02';
                });
                _showAlertDialog();

                print('here 4');
              }
            }
          });
        }
      } else {
        print('offline mode');
        offlineLogin(enteredUserName, enteredUserPassword).then((value) {
          print('here 1');
          if (value['no_user'] == 1) {
            setState(() {
              _messageCode = '0LO01';
            });
            _showAlertDialog();

            print('here no');
          } else {
            print('here 2');

            if (value['login_status'] == 1 || value['login_status'] == '1') {
              setState(() {
                _messageCode = '0LO200';
              });
              _showAlertDialog();

              print('here 3');
            } else {
              setState(() {
                _messageCode = '0LO02';
              });
              _showAlertDialog();

              print('here 4');
            }
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // _handler = UserDatabaseHandler();
    // _handler.initializeDB();
    // DBProvider.db.initDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: const Text('Login'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xfff21bce),
                Color(0xff826cf0),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/image_back_1.jpeg'),
            scale: 1,
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.80,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15.0),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                'User Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.purpleAccent.shade400,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                bottom: 15.0,
                                top: 8.0,
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.purpleAccent.shade100,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                      4.0, 20.0, 5.0, 1.0),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      // border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      // disabledBorder: InputBorder.none,
                                      constraints:
                                          BoxConstraints.tightForFinite(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.09,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                      ),
                                      hintText: 'User Name',
                                      contentPadding: const EdgeInsets.only(
                                        left: 15,
                                        bottom: 11,
                                        top: 11,
                                        right: 15,
                                      ),
                                    ),
                                    controller: usernameController,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'Password',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Colors.purpleAccent.shade400,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      4.0, 20.0, 5.0, 0.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.purpleAccent.shade100,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      constraints:
                                          BoxConstraints.tightForFinite(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.09,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                      ),
                                      hintText: 'Password',
                                      contentPadding: const EdgeInsets.only(
                                        left: 15,
                                        bottom: 11,
                                        top: 11,
                                        right: 15,
                                      ),
                                      suffixIcon: Container(
                                        padding: const EdgeInsets.all(0.1),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.purpleAccent.shade100,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: const Color.fromARGB(
                                              180, 143, 52, 235),
                                        ),
                                        child: IconButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              _isObscure = !_isObscure;
                                            });
                                          },
                                          icon: Icon(_isObscure
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                        ),
                                      ),
                                    ),
                                    obscureText: _isObscure,
                                    controller: userPasswordController,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin:
                              const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                          width: MediaQuery.of(context).size.width * 0.90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            gradient: const LinearGradient(
                              begin: Alignment(-0.95, 0.0),
                              end: Alignment(1.0, 0.0),
                              colors: [
                                Color(0xfff21bce),
                                Color(0xff826cf0),
                              ],
                              stops: [0.0, 1.0],
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              _onClickLogin(context);
                            },
                            style: TextButton.styleFrom(
                              primary: Colors.transparent,
                              onSurface: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Color(0xffffffff),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                            vertical: 12.0,
                          ),
                          height: MediaQuery.of(context).size.height * 0.15,
                          child: Image.asset('assets/icons/icon-144x144.png'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
