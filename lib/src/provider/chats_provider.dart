import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';

class ChatProvider extends GetConnect {
  String rutaNew = Environment.API_DELIVERY_NEW + '/api/chats';

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  Future<List<Chat>> getChats() async {
    Response response = await get('$rutaNew/findByIdUser/${userSession.id}',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken!
        });

    if (response.statusCode == 401) {
      Get.snackbar('Petición denegada',
          'Tu usuario no tiene permitido obtener esta información');
      return [];
    }

    List<Chat> chats = Chat.fromJsonList(response.body);
    return chats;
  }

  Future<ResponseApi> create(Chat chat) async {
    Response response = await post('$rutaNew/create', chat.toJson(), headers: {
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
}
