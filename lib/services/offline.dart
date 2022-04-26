import 'package:flutter/foundation.dart';

import '../services/database_handler.dart';
// import '../services/helper_db.dart';

Future<dynamic> offlineLogin(enteredUserName, enteredUserPassword) async {
//

  var user = await DBProvider.db.isUser(enteredUserName, enteredUserPassword);
  if (user.isNotEmpty) {
    if (kDebugMode) {
      print("printing user data");
      print(user.toString());
    }
    var userID = user[0]['userID'];
    if (kDebugMode) {
      print(userID.runtimeType);
      print(userID);
    }
    // var login = await DBProvider.db.makeUserOfflineLogin(userID);

    // if (kDebugMode) {
    //   print("login.toString(");
    //   print(login.toString());
    // }

    return {'no_user': 1};

    // return user[0];
  } else {
    return {'no_user': 1};
  }
  // return DBProvider.db.readUsers().then((users) {
  //   if(kDebugMode){
  //     print("log");
  //     print(users.toString());
  //   }
  //   if (users.isNotEmpty) {
  //     for (var user in users) {
  //       if (user.userName == enteredUserName &&
  //           user.userPassword == enteredUserPassword) {
  //           var res = await DBProvider.db.makeUserOfflineLogin(user.userName, user.userPassword);
  //         return {'login_status': '1', 'userID': user.userId};
  //       }
  //     }
  //     return {};
  //   } else {
  //     return {'no_user': 1};
  //   }
  // });
}
