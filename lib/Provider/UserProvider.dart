// user_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocal_emotion/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<void> fetchUserData() async {
    // Get the current user's UID from Firebase Authentication
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users') // Your collection name
          .doc(uid)
          .get();

      if (userDoc.exists) {
        _currentUser = UserModel(
          uid: uid,
          username: userDoc['username'] ?? 'Guest',
          email: userDoc['email'] ?? 'dummy',
          imageUrl: userDoc['imageUrl'] ?? '',
        );
        notifyListeners(); // Notify listeners of state change
      }
    }
  }
}
