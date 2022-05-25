// ignore_for_file: avoid_print, duplicate_ignore, unused_import, prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

// import 'package:workmanager/workmanager.dart';
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
              title: SizedBox(
                height: 0,
              ),
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

  void showAlert(message) async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            title: SizedBox(
              height: 0,
            ),
            content: Text(message),
          );
        });
  }

  void _onClickLogin(BuildContext context) async {
    try {
      final enteredUserName = usernameController.text;
      final enteredUserPassword = userPasswordController.text;

      if (enteredUserPassword.isEmpty ||
          enteredUserName.isEmpty ||
          enteredUserName == "" ||
          enteredUserPassword == "") {
        var message = "UserName and Password fields cannot be empty";
        showAlert(message);
      } else {
        if (kDebugMode) {
          print('clicked');
        }

        var connResponse = await request_handler.sendTestRequest();
        var conn = connResponse;

        if (kDebugMode) {
          // log(connResponse.toString());
          log('login');
          log(conn.runtimeType.toString());
        }

        if (connResponse.runtimeType != SocketException) {
          if (connResponse.statusCode == 200) {
            var g = jsonDecode(connResponse.body);
            if (kDebugMode) {
              print('connection: ' + connResponse.statusCode.toString());
              print('connection: ' + g['connected'].runtimeType.toString());
            }
            if (g != null && g['connected'] == "true") {
              if (enteredUserPassword.isNotEmpty &&
                  enteredUserPassword != "" &&
                  enteredUserName.isNotEmpty &&
                  enteredUserName != "") {
                var tryLoginRequest = await request_handler.tryLogin(
                    enteredUserName, enteredUserPassword);
                if (kDebugMode) {
                  print('try login: ' + tryLoginRequest.statusCode.toString());
                  print('try login: ' + tryLoginRequest.body.toString());
                }

                if (tryLoginRequest.statusCode == 200) {
                  var loginRespBody = jsonDecode(tryLoginRequest.body);
                  if (loginRespBody != null && loginRespBody.isNotEmpty) {
                    if (kDebugMode) {
                      print('try login: ' + loginRespBody['user'].toString());
                      print(
                          'try login: ' + loginRespBody['password'].toString());
                      print('try login: ' + loginRespBody['dbname'].toString());
                      print('try login: ' +
                          loginRespBody['login_status'].toString());
                      print('try login: ' + loginRespBody['userID'].toString());
                      print(
                          'try login: ' + loginRespBody['isOnline'].toString());
                    }

                    if (loginRespBody['login_status'] == 1 ||
                        loginRespBody['login_status'] == '1') {
                      setState(() {
                        _messageCode = '1LO200';
                      });
                      await saveUserToDB(loginRespBody);
                      _showAlertDialog();
                    } else {
                      setState(() {
                        _messageCode = '1LO01';
                      });
                      _showAlertDialog();
                    }
                  }
                }
              }
            }
          } else {
            if (kDebugMode) {
              print('remote server down, offline attempt');
            }
            var offlineLoginAttempt =
                await offlineLogin(enteredUserName, enteredUserPassword);
            if (kDebugMode) {
              print(offlineLoginAttempt.toString());
            }
            if (offlineLoginAttempt['no_user'] == 1) {
              // if no user record was found
              setState(() {
                _messageCode = '0LO01';
              });
              _showAlertDialog();
            } else {
              // if user record was found
              if (offlineLoginAttempt['loginstatus'] == 1 ||
                  offlineLoginAttempt['loginstatus'] == '1') {
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
          }
        } else {
          if (kDebugMode) {
            print('remote server down, offline attempt');
          }
          var offlineLoginAttempt =
              await offlineLogin(enteredUserName, enteredUserPassword);

          if (offlineLoginAttempt['no_user'] == 1) {
            // if no user record was found
            setState(() {
              _messageCode = '0LO01';
            });
            _showAlertDialog();
          } else {
            // if user record was found
            if (offlineLoginAttempt['loginstatus'] == 1 ||
                offlineLoginAttempt['loginstatus'] == '1') {
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
        }
      }
    } catch (e) {
      log('error');
      log(e.toString());
    }
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                              alignment: Alignment.centerLeft,
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
                              alignment: Alignment.center,
                              // margin: const EdgeInsets.only(
                              //   bottom: 15.0,
                              //   top: 8.0,
                              // ),
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
                              alignment: Alignment.centerLeft,
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
                            Container(
                              alignment: Alignment.center,
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
                                          icon: Icon(
                                            _isObscure
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            size: 25,
                                          ),
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
                              const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
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
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Color(0xffffffff),
                                  fontSize: 16,
                                ),
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
