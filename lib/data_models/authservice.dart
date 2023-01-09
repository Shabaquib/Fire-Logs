import 'package:firebase_auth/firebase_auth.dart';

import 'global_data.dart';
import 'user.dart';


class AuthService {
  final FirebaseAuth _instance = FirebaseAuth.instance;

  //create CustomUser from SignedUser User
  CustomUser? _userfromFireUser(User? user) {
    return (user != null)
        ? CustomUser(
            uid: user.uid,
            displayName: user.displayName,
            email: user.email,
            isAnonymous: user.isAnonymous,
            emailVerified: user.emailVerified,
            createdOn: user.metadata.creationTime,
            lastSignTime: user.metadata.lastSignInTime)
        : null;
  }

  //set up auth stream
  Stream<CustomUser?> get userCred {
    return _instance
        .authStateChanges()
        .map((User? user) => _userfromFireUser(user));
  }

  //sign in anon
  Future signinAnon() async {
    try {
      UserCredential result = await _instance.signInAnonymously();
      if (result.user != null) {
        User user = result.user!;
        return _userfromFireUser(user);
      }
    } catch (e) {
      return null;
    }
  }

  //sign up with email & password
  Future signUpEmailandPassword(String email, String password) async {
    try {
      UserCredential result = await _instance.createUserWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        User user = result.user!;

        return _userfromFireUser(user);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        errorCode.value = "Invalid email, try again!";
      } else if (e.code == "operation-not-allowed") {
        errorCode.value = "That was unexpected";
      } else if (e.code == "email-already-in-use") {
        errorCode.value = "try logging in with that email";
      } else if (e.code == "weak-password") {
        errorCode.value = "try a strong password!";
      } else if (e.code == "network-request-failed") {
        errorCode.value = "Check your network connection \n & try again!";
      } else {
        errorCode.value = "Try again";
      }
      return null;
    }
  }

  //sign in with email & password
  Future logInEmailandPassword(String email, String password) async {
    try {
      UserCredential result = await _instance.signInWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        User user = result.user!;

        return _userfromFireUser(user);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email" || e.code == "wrong-password") {
        errorCode.value = "Invalid credentials";
      } else if (e.code == "user-disabled") {
        errorCode.value = "This email is blocked!";
      } else if (e.code == "user-not-found") {
        errorCode.value = "you need to register first";
      } else if (e.code == "network-request-failed") {
        errorCode.value = "Check your network connection \n & try again!";
      } else {
        errorCode.value = "Try again!";
      }

      return null;
    }
  }

  //sign out
  Future signOut() async {
    await _instance.signOut();
  }
}
