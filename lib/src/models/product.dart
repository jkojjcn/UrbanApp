import 'dart:convert';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
  String id;
  String name;
  String description;
  String image1;
  String image2;
  String image3;
  double price;
  double priceRestaurant;
  int available;
  int idCategory;
  int quantity;
  List<Product> toList = [];
  double lat;
  double lng;
  dynamic features;
  String sabores;

  Product(
      {this.id,
      this.name,
      this.description,
      this.image1,
      this.image2,
      this.image3,
      this.price,
      this.available,
      this.idCategory,
      this.quantity,
      this.lat,
      this.lng,
      this.features,
      this.sabores,
      this.priceRestaurant});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
      id: json["id"] is int ? json["id"].toString() : json['id'],
      name: json["name"],
      description: json["description"],
      image1: json["image1"],
      image2: json["image2"],
      image3: json["image3"],
      price: json['price'] != null
          ? json['price'] is String
              ? double.parse(json["price"])
              : isInteger(json["price"])
                  ? json["price"].toDouble()
                  : json['price']
          : 0.0,
      priceRestaurant: json['price_restaurant'] != null
          ? json['price_restaurant'] is String
              ? double.parse(json["price_restaurant"])
              : isInteger(json["price_restaurant"])
                  ? json["price_restaurant"].toDouble()
                  : json['price_restaurant']
          : 0.0,
      available: json["available"] is String
          ? int.parse(json["available"])
          : json["available"],
      idCategory: json["id_category"] is String
          ? int.parse(json["id_category"])
          : json["id_category"],
      quantity: json["quantity"],
      lat: json['lat'] != null
          ? (json['lat'] is String
              ? double.parse(json["lat"])
              : isInteger(json["lat"])
                  ? json["lat"].toDouble()
                  : json['lat'])
          : 0.0 ?? 0.0,
      lng: json['lng'] != null
          ? (json['lng'] is String
              ? double.parse(json["lng"])
              : isInteger(json["lng"])
                  ? json["lng"].toDouble()
                  : json['lng'])
          : 0.0 ?? 0.0,
      features: json['features'],
      sabores: json['sabores'] ?? '');

  Product.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;
    jsonList.forEach((item) {
      Product product = Product.fromJson(item);
      toList.add(product);
    });
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "image1": image1,
        "image2": image2,
        "image3": image3,
        "price": price,
        "available": available,
        "price_restaurant": priceRestaurant,
        "id_category": idCategory,
        "quantity": quantity,
        "lat": lat,
        "lng": lng,
        "features": features,
        'sabores': sabores
      };

  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}
