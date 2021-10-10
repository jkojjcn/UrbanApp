import 'dart:convert';

DropModel productFromJson(String str) => DropModel.fromJson(json.decode(str));

String productToJson(DropModel data) => json.encode(data.toJson());

class DropModel {
  

  String name;
  bool data;
  double price;
  String id;
  List<DropModel> toList = [];

  DropModel({this.id, this.name, this.price, this.data});

  factory DropModel.fromJson(Map<String, dynamic> json) => DropModel(
        id: json['id'],
        name: json['name'],
        data: json['data'],
        price: json['price']
      );

  DropModel.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;
    jsonList.forEach((item) {
      DropModel product = DropModel.fromJson(item);
      toList.add(product);
    });
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "neccesary": data,
        "price": price,
      };
}
