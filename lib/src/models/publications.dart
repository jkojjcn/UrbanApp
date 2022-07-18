import 'dart:convert';


Publications userFromJson(String str) => Publications.fromJson(json.decode(str));

String userToJson(Publications data) => json.encode(data.toJson());

class Publications {
  String? id;
  String? name;
  String? lastname;
  String? email;
  String? phone;
  String? comment;
  String? notificationToken;
  String? image;
  String? picture;
  String? approved;
  List<Publications> toList = [];
  //MESSAGES

  Publications(
      {this.id,
      this.name,
      this.lastname,
      this.email,
      this.phone,
      this.comment,
     //  this.sessionToken,
     this.notificationToken,
     this.image, 
     this.approved,
     this.picture,
     });

  factory Publications.fromJson(Map<String, dynamic> json) => Publications(
        id: json["id"] is int ? json['id'].toString() : json["id"],
        name: json["name"],
        lastname: json["lastname"],
        email: json["email"],
        phone: json["phone"],
        comment: json["comment"],
      //    sessionToken: json["session_token"],
      notificationToken: json["notification_token"],
        image: json["image"],
        approved: json["approved"],
        picture: json["picture"]
      );

  Publications.fromJsonList(List<dynamic> jsonList) {
    // ignore: unnecessary_null_comparison
    if (jsonList == null) return;
    jsonList.forEach((item) {
      Publications user = Publications.fromJson(item);
      toList.add(user);
    });
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "lastname": lastname,
        "email": email,
        "phone": phone,
        "comment": comment,
       "notification_token": notificationToken,
        "image": image,
        "approved": approved,
        "picture" : picture
      };
}
