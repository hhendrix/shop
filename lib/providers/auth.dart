import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import '../models/http_exception.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expireDate;
  String? _userId;
  Timer? _autTimer;

  bool get isAuth {
    if (token != null) {
      return true;
    }
    //return token != null;
    return false;
  }

  String? get token {
    if (_expireDate != null &&
        _expireDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }

    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final urlString =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDc62yrUNU2J7LoxfLLmV1ob6KmZXy7tc8';

    final url = Uri.parse(urlString);

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefes = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiresDate': _expireDate.toString()
      });
      prefes.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extracteduserData =
        json.decode(prefs.getString('userData')!) as Map<String, Object>;
    final expireDate =
        DateTime.parse(extracteduserData['expiresDate'] as String);

    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extracteduserData['token'] as String;
    _userId = extracteduserData['userId'] as String;
    _expireDate = expireDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_autTimer != null) {
      _autTimer!.cancel();
      _autTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_autTimer != null) {
      _autTimer!.cancel();
    }
    final timeToExpire = _expireDate != null
        ? _expireDate!.difference(DateTime.now()).inSeconds
        : 0;

    Timer(Duration(seconds: timeToExpire), logout);
  }
}
