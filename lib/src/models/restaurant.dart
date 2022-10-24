import 'dart:convert';
import 'dart:developer';

Restaurant restaurantFromJson(String str) =>
    Restaurant.fromJson(json.decode(str));

String restaurantToJson(Restaurant data) => json.encode(data.toJson());

class Restaurant {
  String? id;
  String? name;
  String? description;
  String? image1;
  String? image2;
  String? image3;
  String? image4;
  double? price;
  int? idCategory;
  List<Restaurant> toList = [];
  double? lat;
  double? lng;
  String? notificationTokenR;
  String? masterNotificationToken;

  Restaurant(
      {this.id,
      this.name,
      this.description,
      this.image1,
      this.image2,
      this.image3,
      this.image4,
      this.price,
      this.idCategory,
      this.lat,
      this.lng,
      this.notificationTokenR,
      this.masterNotificationToken});

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
      id: json["id"] is int ? json["id"].toString() : json['id'],
      name: json["name"],
      description: json["description"],
      image1: json["image1"],
      image2: json["image2"],
      image3: json["image3"] ?? '',
      image4: json["image4"],
      price: json['price'] != null
          ? json['price'] is String
              ? double.parse(json["price"])
              : isInteger(json["price"])
                  ? json["price"].toDouble()
                  : json['price']
          : 0.0,
      idCategory: json["id_category"] is String
          ? int.parse(json["id_category"])
          : json["id_category"],
      lat: json['lat'] != null
          ? (json['lat'] is String
              ? double.parse(json["lat"])
              : isInteger(json["lat"])
                  ? json["lat"].toDouble()
                  : json['lat'])
          : 0.0,
      lng: json['lng'] != null
          ? (json['lng'] is String
              ? double.parse(json["lng"])
              : isInteger(json["lng"])
                  ? json["lng"].toDouble()
                  : json['lng'])
          : 0.0,
      notificationTokenR:
          json['notification_token'] != null ? json['notification_token'] : '',
      masterNotificationToken: json['master_notification_token'] != null
          ? json['master_notification_token']
          : '');

  Restaurant.fromJsonList(List<dynamic>? jsonList) {
    // ignore: unnecessary_null_comparison
    if (jsonList == null) return;
    try {
      jsonList.forEach((item) {
        if (item is Restaurant) {
          log('Regreso en Restaurant');

          toList.add(item);
        } else {
          log('Regreso en Json');
          Restaurant product = Restaurant.fromJson(item);
          toList.add(product);
        }
      });
    } catch (e) {
      log('No se ha decodificado');

      log(e.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "image1": image1,
        "image2": image2,
        "image3": image3,
        "image4": image4,
        "price": price,
        "id_category": idCategory,
        "lat": lat,
        "lng": lng,
        'notification_token': notificationTokenR,
        'master_notification_token': masterNotificationToken
      };

  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();
}
