import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String? email;
  String? id;
  String? name;
  String? login;
  String? password;

  UserModel({this.email, this.id, this.login, this.password, this.name});

  Map toMap(UserModel user) {
    var data = Map<String, dynamic>();

    data["id"] = user.id;
    data["login"] = user.login;
    data["email"] = user.email;
    data["name"] = user.name;
    data["password"] = user.password;

    return data;
  }

  UserModel.fromMap(Map<String, dynamic> mapData) {
    this.id = mapData["id"];
    this.login = mapData["login"];
    this.email = mapData["email"];
    this.name = mapData["name"];
    this.password = mapData["password"];
  }
}
