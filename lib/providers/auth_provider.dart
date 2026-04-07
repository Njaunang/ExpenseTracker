import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:lookup/database/database_helper.dart';
import 'package:lookup/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> signup(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // check if username or email already exists
      User? existingUser = await _dbHelper.getUserByEmailOrUsername(email);
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false; // user already exists
      }

      existingUser = await _dbHelper.getUserByEmailOrUsername(username);
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false; // user already exist
      }

      // create user
      User newUser = User(
        username: username,
        email: email,
        password: _hashPassword(password),
        createdAt: DateTime.now(),
      );
      int id = await _dbHelper.insertUser(newUser);
      newUser.id = id;
      _currentUser = newUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      String hashedPassword = _hashPassword(password);
      bool isValid = await _dbHelper.checkUserCredentials(
        identifier,
        hashedPassword,
      );
      if (isValid) {
        User? user = await _dbHelper.getUserByEmailOrUsername(identifier);
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(String username, String? avatarPath) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser!.username = username;
      _currentUser!.avatar = avatarPath;
      _currentUser!.updatedAt = DateTime.now();

      await _dbHelper.updateUser(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
