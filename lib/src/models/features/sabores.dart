import 'dart:convert';

FeaturesSabores productFromJson(String str) =>
    FeaturesSabores.fromJson(json.decode(str));

String productToJson(FeaturesSabores data) => json.encode(data.toJson());

class FeaturesSabores {
  String id;
  String name;
  String description;
  double price;
  int max;
  int min;
  bool necessary;
  List<FeaturesSabores> toListFeaturesSabores = [];

  FeaturesSabores(
      {this.id,
      this.name,
      this.description,
      this.price,
      this.max,
      this.min,
      this.necessary});

  factory FeaturesSabores.fromJson(Map<String, dynamic> json) =>
      FeaturesSabores(
        id: json['id'],
        name: (json["name"]) ?? "...",
        description: (json["description"]) ?? "....",
        price: json["price"],
        max: json["max"],
        min: json["min"],
        necessary: json["necessary"],
      );

  FeaturesSabores.fromJsonList(List<dynamic> json) {
    if (json == null) return;
    json.forEach((item) {
      FeaturesSabores features = FeaturesSabores.fromJson(item);
      toListFeaturesSabores.add(features);
    });
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
      };

  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}
