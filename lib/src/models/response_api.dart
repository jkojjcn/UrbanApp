import 'dart:convert';

ResponseApi responseApiFromJson(String str) =>
    ResponseApi.fromJson(json.decode(str));

String responseApiToJson(ResponseApi data) => json.encode(data.toJson());

class ResponseApi {
  String? message;
  bool? success;
  dynamic data;

  ResponseApi({
    this.message,
    this.data,
    this.success,
  });

  factory ResponseApi.fromJson(Map<String, dynamic> json) => ResponseApi(
        success: json["success"],
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
      };
}
