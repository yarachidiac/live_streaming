import 'package:flutter/material.dart';
import 'package:project_live_streaming/models/user.dart';

class UserProvider extends ChangeNotifier{
  User _user = User(uid: '', username: '', email: '');

  User get user => _user;

      setUser(User user){
        _user = user;
        notifyListeners();
      }
}