import 'dart:convert';

import 'package:jcn_delivery/src/models/rol.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String? id;
  String? name;
  String? lastname;
  String? email;
  String? phone;
  String? password;
  String? sessionToken;
  String? notificationToken;
  String? image;
  bool? isAvailable;
  List<Rol>? roles;
  List<User> toList = [];
  String? caja;

  //MESSAGES

  User(
      {this.id,
      this.name,
      this.lastname,
      this.email,
      this.phone,
      this.password,
      this.sessionToken,
      this.notificationToken,
      this.image,
      this.isAvailable,
      this.caja,
      this.roles});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json["id"] is int ? json['id'].toString() : json["id"],
      name: json["name"] ?? '',
      lastname: json["lastname"] ?? '',
      email: json["email"] ?? '',
      phone: json["phone"] ?? '',
      password: json["password"] ?? '',
      sessionToken: json["session_token"] ?? '',
      notificationToken: json["notification_token"] ?? '',
      image: json["image"] ?? '',
      isAvailable: json["is_available"] ?? false,
      caja: json["caja"].toString(),
      roles: json['roles'] != null && json['roles'] != 'null'
          ? json['roles'] is String
              ? List<Rol>.from(jsonDecode(json['roles'])
                  .map((model) => Rol.fromJson(model))
                  .toList())
              : List<Rol>.from(
                  json['roles'].map((model) => Rol.fromJson(model)).toList())
          : []);

  static List<User> fromJsonGetxList(List<dynamic> jsonList) {
    List<User> toListG = [];

    jsonList.forEach((item) {
      User user = User.fromJson(item);
      toListG.add(user);
    });
    return toListG;
  }

  User.fromJsonList(List<dynamic> jsonList) {
    // ignore: unnecessary_null_comparison
    if (jsonList == null) return;
    jsonList.forEach((item) {
      User user = User.fromJson(item);
      toList.add(user);
    });
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "lastname": lastname,
        "email": email,
        "phone": phone,
        "password": password,
        "session_token": sessionToken,
        "notification_token": notificationToken,
        "image": image,
        "is_available": isAvailable,
        "caja": caja,
        "roles": jsonEncode(roles)
      };
}
