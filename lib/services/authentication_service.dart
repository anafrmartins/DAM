import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationService extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

  User? userAuth;

  bool isLoading = true;
  bool loading = false;

  AuthenticationService() {
    _authCheck();
  }

  _getUser() {
    userAuth = _auth.currentUser;
    notifyListeners();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      userAuth = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }

  register(String name, String email, String password) async {
    loading = true;
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      userAuth = userCredential.user;
      await userAuth!.updateDisplayName(name);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'A senha é muito fraca';
      } else if (e.code == 'email-already-in-use') {
        throw 'Este e-mail já existe';
      } else if (e.code == 'user-not-found') {
        throw 'Usuario Inesistente';
      }
    }
    loading = false;
  }

  login(String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      userAuth = userCredential.user;
      _getUser();
    } on FirebaseAuthException catch (e) {
      loading = false;
      notifyListeners();
      if (e.code == 'user-not-found') {
        throw 'E-mail não encontrado. Cadastra-se';
      } else if (e.code == 'wrong-password') {
        throw 'Password incorreta. Tenta outra password';
      }
    }
    loading = false;
    notifyListeners();
  }

  logout() async {
    await _auth.signOut();
    _getUser();
    notifyListeners();
  }
}
