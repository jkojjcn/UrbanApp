import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class MessageProvider extends GetConnect {
  String rutaNew = Environment.API_DELIVERY_NEW + '/api/message';

  String ruta = Environment.API_DELIVERY;

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Future<List<Message>> getMessagesByChat(String idChat) async {
    Response response = await get('$rutaNew/findByChat/$idChat', headers: {
      'Content-Type': 'application/json',
      'Authorization': userSession.sessionToken!
    });

    if (response.statusCode == 401) {
      Get.snackbar('Petición denegada',
          'Tu usuario no tiene permitido obtener esta información');
      return [];
    }

    List<Message> messages = Message.fromJsonList(response.body);
    return messages;
  }

  Future<ResponseApi> create(Message message) async {
    Response response = await post('$rutaNew/create', message.toJson(),
        headers: {
          'Content-type': 'application/json',
          'Authorization': userSession.sessionToken!
        });

    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar su cuenta, reintente!');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<Stream> createWithImage(Message message, File image) async {
    Uri url = Uri.http('$ruta', '/api/message/createWithImage');
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = userSession.sessionToken!;

    request.files.add(http.MultipartFile(
        'image', http.ByteStream(image.openRead().cast()), await image.length(),
        filename: basename(image.path)));
    request.fields['message'] = json.encode(message);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  Future<ResponseApi> updateToSeen(String idMessage) async {
    Response response = await put('$rutaNew/updateToSeen', {
      'id': idMessage,
    }, headers: {
      'Content-type': 'application/json',
      'Authorization': userSession.sessionToken!
    });

    if (response.statusCode != 201) {
      Get.snackbar('Error', 'No se pudo actualizar a Visto!');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
}
