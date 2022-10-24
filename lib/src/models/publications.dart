import 'dart:convert';
import 'dart:developer';

import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/restaurant.dart';

Publications publicationsFromJson(String str) =>
    Publications.fromJson(json.decode(str));

// user , {
// id
// title
// subtitle
// restaurant
// type
// createdAt
// image1
// image2
// image3
// approved
// }

class Publications {
  // String? id;
  String? title;
  String? subtitle;
  String? fire;
  String? image;
  int? restaurantId;

  Restaurant? restaurant;
  List<Publications> toList = [];
  //MESSAGES

  Publications(
      { //this.id,
      this.title,
      this.subtitle,
      this.restaurant,
      this.image,
      this.fire,
      this.restaurantId});

  factory Publications.fromJson(Map<String, dynamic> json) => Publications(
      //  id: json["id"] is int ? json['id'].toString() : json["id"],
      title: json["title"],
      subtitle: json["subtitle"],
      restaurant: json["restaurant"] is String
          ? productFromJson(json['restaurant'])
          : json['restaurant'] is Restaurant
              ? json['restaurant']
              : Restaurant.fromJson(json['restaurant'] ?? {}),
      image: json["image"],
      fire: json["fire"],
      restaurantId: json["restaurant_id"]);

  Publications.fromJsonList(List<dynamic> jsonList) {
    log("ENTRó en el decode de publications");
    // ignore: unnecessary_null_comparison
    if (jsonList == null) return;
    jsonList.forEach((item) {
      Publications user = Publications.fromJson(item);
      toList.add(user);
    });
  }
}
