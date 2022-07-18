import 'dart:convert';

import 'package:jcn_delivery/src/models/user.dart';

Message userFromJson(String str) => Message.fromJson(json.decode(str));

String userToJson(Message data) => json.encode(data.toJson());

class Message {
  int? from;
  String? message;
  int? to;
  String? type;
  String? open;
  List<Message> toList = [];
  User? client;
  User? receiver;
  DateTime? created;
  DateTime? updated;
  //MESSAGES

  Message(
      {this.from,
      this.to,
      this.message,
      this.client,
      this.receiver,
      this.type,
      this.open,
      this.created,
      this.updated});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        from: json["from_id"] is int
            ? json['from_id']
            : int.parse(json['from_id']),
        message: json["message_data"] ?? "",
        type: json["type"] ?? "",
        open: json["id_open"] ?? "",
        to: json['to_id'] is int ? json['to_id'] : int.parse(json['to_id']),
        client: json['client'] is String
            ? userFromJson(json['client'])
            : json['client'] is User
                ? json['client']
                : User.fromJson(json['client'] ?? {}),
        receiver: json['receiver'] is String
            ? userFromJson(json['receiver'])
            : json['receiver'] is User
                ? json['receiver']
                : User.fromJson(json['receiver'] ?? {}),
        created: json["created_at"] is String
            ? DateTime.parse(json["created_at"])
            : json["created_at"],
        updated: json["updated_at"] is String
            ? DateTime.parse(json["updated_at"])
            : json["updated_at"],
      );

  Message.fromJsonList(List<dynamic> jsonList) {
    // ignore: unnecessary_null_comparison
    if (jsonList == null) return;
    jsonList.forEach((item) {
      Message user = Message.fromJson(item);
      toList.add(user);
    });
  }

  Map<String, dynamic> toJson() => {
        "from": from,
        "to": to,
        "message": message,
        "type": type,
        "client": client,
        "receiver": receiver,
        "created_at": created,
        "updated_at": updated,
        "open": open
      };
}
