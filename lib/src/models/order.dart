import 'dart:convert';

import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/user.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  String? id;
  String? idClient;
  String? idDelivery;
  String? idAddress;
  String? status;
  double? lat;
  double? lng;
  int? timestamp;
  List<Product> products = [];
  List<Order> toList = [];
 late User client;
late  User? delivery ;
late  Address address;
  String? restaurantId;
  String? features;
late  Product? restaurant;
  double? distance;
  double? restaurantTime;
  String? acepted;
  String? tarjeta;
  double? totalCliente;

  Order(
      {this.id,
      this.idClient,
      this.idDelivery,
      this.idAddress,
      this.status,
      this.lat,
      this.lng,
      this.timestamp,
   required   this.products,
    required  this.client,
   this.delivery,
   required   this.address,
      this.restaurantId,
      this.features,
      this.restaurant,
      this.distance,
      this.restaurantTime,
      this.acepted,
      this.tarjeta,
      this.totalCliente});

  factory Order.fromJson(Map<String, dynamic> json) => Order(
      id: json["id"] is int ? json["id"].toString() : json['id'],
      idClient: json["id_client"],
      idDelivery: json["id_delivery"],
      idAddress: json["id_address"],
      status: json["status"],
      lat: json["lat"] is String ? double.parse(json["lat"]) : json["lat"],
      lng: json["lng"] is String ? double.parse(json["lng"]) : json["lng"],
      timestamp: json["timestamp"] is String
          ? int.parse(json["timestamp"])
          : json["timestamp"],
      products: json["products"] != null
          ? List<Product>.from(json["products"].map((model) =>
                  model is Product ? model : Product.fromJson(model)))
          : [],
      client: json['client'] is String
          ? userFromJson(json['client'])
          : json['client'] is User
              ? json['client']
              : User.fromJson(json['client'] ?? {}),
      delivery: json['delivery'] != null? (json['delivery'] is String
          ? userFromJson(json['delivery'])
          : json['delivery'] is User
              ? json['delivery']
              : User.fromJson(json['delivery'] ?? {})) : {},
      address: json['address'] is String
          ? addressFromJson(json['address'])
          : json['address'] is Address
              ? json['address']
              : Address.fromJson(json['address'] ?? {}),
      restaurantId: json["restaurant_id"],
      features: json["features"] ?? '',
      restaurant: json["restaurant"] is String
          ? productFromJson(json['restaurant'])
          : json['restaurant'] is Product
              ? json['restaurant']
              : Product.fromJson(json['restaurant'] ?? {}),
      distance: json["distance"] is String
          ? double.parse(json["distance"])
          : json["distance"],
      restaurantTime: (json["time_order"] is String
              ? double.parse(json["time_order"])
              : json["time_order"]) ??
          0.0,
      acepted: json["acepted"] ?? 'no',
      tarjeta: json["tarjeta"] ?? 'no',
      totalCliente: (json["total_cliente"] is String
              ? double.parse(json["total_cliente"])
              : json["total_cliente"]) ??
          0.0);

   Order.fromJsonList(List<dynamic> jsonList) {
    // ignore: unnecessary_null_comparison
    if (jsonList == null) return;
    jsonList.forEach((item) {
      Order order = Order.fromJson(item);
      toList.add(order);
    });
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_client": idClient,
        "id_delivery": idDelivery,
        "id_address": idAddress,
        "status": status,
        "lat": lat,
        "lng": lng,
        "timestamp": timestamp,
        "products": products,
        "client": client,
        "delivery": delivery,
        "address": address,
        "restaurant_id": restaurantId,
        "features": features,
        "restaurant": restaurant,
        "distance": distance,
        "time_order": restaurantTime,
        "acepted": acepted,
        "tarjeta": tarjeta,
        "total_cliente": totalCliente
      };
}
