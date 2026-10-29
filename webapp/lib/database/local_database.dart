import 'dart:convert';
import 'package:mobilis/model/manager_model.dart';
import 'package:universal_html/html.dart';
import 'package:crypto/crypto.dart';


class LocalDatabaseWeb {
  static const _key = 'users';
  
  static void initializeOnce() {
  if (!window.localStorage.containsKey(_key)) {
    _saveUsers([]);
    print('[INIT] Database initialized');
  } else {
    print('[INIT] Database already exists');
  }
}


  static List<Manager> _getUsers() {
    final raw = window.localStorage[_key];
    if (raw == null) return [];
    List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((user) => Manager.fromJson(user)).toList();
  }

  static void _saveUsers(List<Manager> users) {
    window.localStorage[_key] = jsonEncode(users.map((user) => user.toJson()).toList());
  }

  static List<Manager> readUsers() {
    return _getUsers();
  }

  static bool addUser(Manager user) {
  final users = _getUsers();
  final existingUser = users.any((u) => u.email == user.email);

  if (existingUser) {
    print('[SIGN-UP] Failed: User with email ${user.email} already exists.');
    return false;
  }

  users.add(user);
  _saveUsers(users);
  print('[SIGN-UP] Success: User ${user.email} added.');
  return true;
}

static bool updateUser(Manager updatedUser) {
  final users = _getUsers();
  final index = users.indexWhere((u) => u.email == updatedUser.email);

  if (index == -1) {
    print('[UPDATE USER] Failed: No user found with email ${updatedUser.email}.');
    return false;
  }

  users[index] = updatedUser;
  _saveUsers(users);
  print('[UPDATE USER] Success: User with email ${updatedUser.email} updated.');
  return true;
}


static String updateUserPassword(String email, String currentPassword, String newPassword) {
    final users = _getUsers();
    final index = users.indexWhere((u) => u.email == email);

    if (index == -1) {
      print('[UPDATE PASSWORD] Failed: No user found with email $email.');
      return 'USER_NOT_FOUND';
    }

    // Hash the provided current password and compare with stored password
    final hashedCurrentPassword = hashPassword(currentPassword);
    if (users[index].password != hashedCurrentPassword) {
      print('[UPDATE PASSWORD] Failed: Current password is incorrect for $email.');
      return 'INVALID_CURRENT';
    }

    // Hash and store the new password
    final hashedNewPassword = hashPassword(newPassword);
    users[index].password = hashedNewPassword;
    _saveUsers(users);
    
    print('[UPDATE PASSWORD] Success: Password updated for user $email.');
    return 'SUCCESS';
  }

static Manager? getUserByEmail(String email) {
    try {
      return _getUsers().firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static void printAllUsers() {
  final users = _getUsers();
  if (users.isEmpty) {
    print('[DEBUG] No users found in localStorage.');
  } else {
    print('[DEBUG] Total users: ${users.length}');
    for (final user in users) {
      print('→ Name: ${user.name}, Email: ${user.email}, Role: ${user.role}');
    }
  }
}

}
