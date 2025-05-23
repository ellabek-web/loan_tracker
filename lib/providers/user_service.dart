import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserServiceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, String> _userNames = {};

  Map<String, String> get userNames => _userNames;

  Future<String> getUserFullName(String uid) async {
    if (_userNames.containsKey(uid)) return _userNames[uid]!;

    final doc = await _firestore.collection('users').doc(uid).get();
    String fullName = 'Unknown User';

    if (doc.exists) {
      final data = doc.data();
      final firstName = data?['firstName'] ?? '';
      final lastName = data?['lastName'] ?? '';
      fullName = '$firstName $lastName';
    }

    _userNames[uid] = fullName;
    notifyListeners();
    return fullName;
  }

  Future<List<String>> getMemberNames(List<String> uids) async {
    return Future.wait(uids.map(getUserFullName));
  }

  void clearCache() {
    _userNames.clear();
    notifyListeners();
  }
}
