import 'dart:convert';

OrderProductModel orderproductFromJson(String str) =>
    OrderProductModel.fromJson(json.decode(str));

class OrderProductModel {
  String? id;
  String? name;
  String? description;
  String? image1;
  String? features;
  double? price;
  double? priceRestaurant;
  List<OrderProductModel>? toList;

  OrderProductModel(
      {this.id,
      this.name,
      this.description,
      this.image1,
      this.features,
      this.price,
      this.priceRestaurant});

  factory OrderProductModel.fromJson(Map<String, dynamic> json) =>
      OrderProductModel(
          id: json["id"] is int ? json["id"].toString() : json['id'],
          name: json["name"],
          description: json["description"],
          image1: json["image1"],
          price: json["price"],
          priceRestaurant: json['price_restaurant'] != null
              ? json['price_restaurant'] is String
                  ? double.parse(json["price_restaurant"])
                  : isInteger(json["price_restaurant"])
                      ? json["price_restaurant"].toDouble()
                      : json['price_restaurant']
              : 0.0,
          features: json["features"]);

  OrderProductModel.fromJsonList(List<dynamic>? jsonList) {
    // ignore: unnecessary_null_comparison
    if (jsonList == null) return;
    try {
      jsonList.forEach((item) {
        if (item is OrderProductModel) {
          toList!.add(item);
        } else {
          OrderProductModel product = OrderProductModel.fromJson(item);
          toList!.add(product);
        }
      });
    } catch (e) {}
  }

  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}
