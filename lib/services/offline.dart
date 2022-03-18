import '../services/database_handler.dart';
// import '../services/helper_db.dart';

Future<dynamic> offlineLogin(enteredUserName, enteredUserPassword) async {
//
  return DBProvider.db.readUsers().then((users) {
    if (users.isNotEmpty) {
      for (var user in users) {
        if (user.userName == enteredUserName &&
            user.userPassword == enteredUserPassword) {
          return {'login_status': '1', 'userID': user.userId};
        }
      }
      return {};
    } else {
      return {'no_user': 1};
    }
  });
}
