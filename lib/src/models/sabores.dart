import 'dart:convert';

Sabores saboresFromJson(String str) => Sabores.fromJson(json.decode(str));

String saboresToJson(Sabores data) => json.encode(data.toJson());

class Sabores {
  String? id;
  String? name;
  String? description;
  List<Sabores>? content;
  bool? addInProduct;
  int? max;
  int? min;
  List<Sabores> toList = [];

  Sabores(
      {this.id, this.name, this.description, this.content, this.max, this.min});

  factory Sabores.fromJson(Map<String, dynamic> json) => Sabores(
      id: json["id"],
      name: (json["name"]) ?? "...",
      description: (json["description"]) ?? "....",
      content: json["content"] != null
          ? List<Sabores>.from(Sabores.fromJsonList(json["content"]).toList)
          : [],
      max: json["max"],
      min: json["min"]);

  Sabores.fromJsonList(List<dynamic> jsonList) {
    // ignore: unnecessary_null_comparison
    if (jsonList == null) return;
    jsonList.forEach((item) {
      Sabores sabores = Sabores.fromJson(item);
      toList.add(sabores);
    });
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
      };
}
