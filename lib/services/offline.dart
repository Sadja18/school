import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../services/database_handler.dart';
// import '../services/helper_db.dart';

Future<dynamic> offlineLogin(enteredUserName, enteredUserPassword) async {
//

  var user = await DBProvider.db.isUser(enteredUserName, enteredUserPassword);
  if (user != null && user.isNotEmpty) {
    if (kDebugMode) {
      log("printing user data");
      log(user.toString());
    }
    var userID = user[0]['userID'];
    if (kDebugMode) {
      log("user Id make User Offline isUser");
      log(userID.runtimeType.toString());
      log(userID.toString());
    }
    var login = await DBProvider.db.makeUserOfflineLogin(userID);
    return {"loggedIn": 1};
  } else {
    return {'loggedIn': 0};
  }
}
