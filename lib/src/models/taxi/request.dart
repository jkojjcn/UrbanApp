import 'dart:convert';

import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/user.dart';

RequestTaxiModel addressFromJson(String str) =>
    RequestTaxiModel.fromJson(json.decode(str));

String addressToJson(RequestTaxiModel data) => json.encode(data.toJson());

class RequestTaxiModel {
  RequestTaxiModel(
      {this.id,
      this.requestStatus,
      this.idAddress,
      this.idClient,
      this.idTaxi,
      this.arrivedAt,
      this.createdAt,
      this.updatedAt,
      this.taxiUser,
      this.taxiClient,
      this.addressRequest,
      this.idTime,
      this.lat,
      this.lng});

  String? id;
  String? requestStatus;
  int? idClient;
  double? idAddress;
  int? idTaxi;
  User? taxiUser;
  User? taxiClient;
  double? idTime;
  Address? addressRequest;
  double? lat;
  double? lng;
  String? createdAt;
  String? updatedAt;
  String? arrivedAt;
  List<RequestTaxiModel> toList = [];

  factory RequestTaxiModel.fromJson(Map<String, dynamic> json) =>
      RequestTaxiModel(
          id: json["id"] is int ? json['id'].toString() : json['id'] ?? "",
          requestStatus: json["request_status"].toString(),
          idClient: json["id_client"] is String
              ? int.parse(json["id_client"])
              : json["id_client"],
          idAddress: json["id_address"] ?? 0.0,
          idTaxi: json["id_taxi"] is String
              ? int.parse(json["id_taxi"])
              : json["id_taxi"],
          taxiUser: json["taxi_user"] is String
              ? addressFromJson(json["taxi_user"])
              : json["taxi_user"] is User
                  ? json["taxi_user"]
                  : User.fromJson(json["taxi_user"] ?? {}),
          taxiClient: json["taxi_client"] is String
              ? addressFromJson(json["taxi_client"])
              : json["taxi_client"] is User
                  ? json["taxi_client"]
                  : User.fromJson(json["taxi_client"] ?? {}),
          idTime: json["id_time"] is String
              ? double.parse(json["id_time"])
              : json["id_time"],
          addressRequest: json["address_request"] is String
              ? addressFromJson(json["address_request"])
              : json["address_request"] is Address
                  ? json["address_request"]
                  : Address.fromJson(json["address_request"] ?? {}),
          lat: json["lat"] is String ? double.parse(json["lat"]) : json["lat"],
          lng: json["lng"] is String ? double.parse(json["lng"]) : json["lng"],
          createdAt: json["created_at"].toString(),
          updatedAt: json["updated_at"].toString(),
          arrivedAt: json["arrived_at"].toString());

  RequestTaxiModel.fromJsonList(List<dynamic> jsonList) {
    // ignore: unnecessary_null_comparison
    if (jsonList == null) return;
    jsonList.forEach((item) {
      RequestTaxiModel requestTaxi = RequestTaxiModel.fromJson(item);
      toList.add(requestTaxi);
    });
  }

  Map<String, dynamic> toJson() => {
        "id_client": idClient,
        "request_status": requestStatus,
        "id_taxi": idTaxi,
        "id_time": idTime,
        // "id_address": addressRequest!.id,
        "lat": lat,
        "lng": lng,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "arrived_at": arrivedAt
      };
}
