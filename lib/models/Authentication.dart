import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:no_signal/Pages/HomePage.dart';
import 'package:no_signal/Pages/LoginPage.dart';
import 'package:no_signal/models/user.dart';

class Authentication {
  final Client client = Client();
  late Account account;
  late bool _isLoggedIn;
  User? _user;

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;

  Authentication() {
    client
        .setEndpoint('http://192.168.1.26:5000/v1')
        .setProject('61372edb59641')
        .setSelfSigned(status: true);
    account = Account(client);
    _isLoggedIn = false;
    checkIsLoggedIn();
  }

  Future<void> checkIsLoggedIn() async {
    try {
      _user = await _getAccount();
      print(_user);
      if (_user != null)
        _isLoggedIn = true;
      else
        _isLoggedIn = false;
    } catch (e) {
      print(e);
    }
  }

  Future<User?> _getAccount() async {
    try {
      Response<dynamic> res = await account.get();
      if (res.data != null) {
        print(res.data);
        return User.fromMap(res.data);
      } else {
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      var data = await account.createSession(email: email, password: password);
      print(data);
      await Navigator.pushReplacementNamed(context, HomePage.routename);
    } catch (e) {
      print(e);
      await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('Error Occured'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Ok"))
                ],
              ));
    }
  }

  Future<void> signUp(
      String email, String password, BuildContext context) async {
    try {
      final acc = await account.create(email: email, password: password);
      await Navigator.pushReplacementNamed(context, HomePage.routename);
      print(acc);
    } catch (e) {
      print(e);
      await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('Error Occured'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Ok"))
                ],
              ));
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await account.deleteSession(sessionId: 'current');
      await Navigator.of(context).pushReplacementNamed(LoginPage.routename);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Logged out Successfully"),
      ));
    } catch (e) {
      print(e);
      await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('Error Occured'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Ok"))
                ],
              ));
    }
  }
}
