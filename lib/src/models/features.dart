import 'dart:convert';
import 'package:jcn_delivery/src/models/sabores.dart';

Features featureFromJson(String str) => Features.fromJson(json.decode(str));

String productToJson(Features data) => json.encode(data.toJson());

class Features {
  String? id;
  String? name;
  String? description;
  int? max;
  int? min;
  bool? addInProduct = false;
  List<Sabores>? content;

  List<Features> toListFeatures = [];

  Features(
      {this.id,
      this.name,
      this.description,
      this.content,
      this.max,
      this.min,
      this.addInProduct});

  factory Features.fromJson(Map<String, dynamic> json) => Features(
      id: json["id"],
      name: (json["name"]) ?? "...",
      description: (json["description"]) ?? "....",
      content: json["content"] != null
          ? List<Sabores>.from(Sabores.fromJsonList(json["content"]).toList)
          : [],
      max: json["max"],
      min: json["min"]);

  Features.fromJsonList(List<dynamic> json) {
    // ignore: unnecessary_null_comparison
    if (json == null) return;
    json.forEach((item) {
      Features features = Features.fromJson(item);
      toListFeatures.add(features);
    });
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "content": content,
        "max": max,
        "min": min,
        "addInProduct": addInProduct
      };

  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}
