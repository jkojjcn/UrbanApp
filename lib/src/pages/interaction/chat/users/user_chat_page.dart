import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/users/user_chat_controller.dart';

class UserChatPage extends StatelessWidget {
  UserController con = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
      ),
      body: FutureBuilder(
          future: con.getUsers(),
          builder: (context, AsyncSnapshot<List<User>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data?.isNotEmpty == true) {
                return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (_, index) {
                      return cardUser(snapshot.data?[index]);
                    });
              } else {
                Container();
              }
            } else {
              Container();
            }
            return Container();
          }),
    );
  }

  Widget cardUser(User? user) {
    return ListTile(
      onTap: () => con.goToChat(user!),
      title: Text(user?.name ?? ''),
      subtitle: Text(user?.email ?? ''),
      leading: AspectRatio(
        aspectRatio: 1,
        child: ClipOval(
          child: user?.image != '' && user?.image != 'null'
              ? FadeInImage.assetNetwork(
                  fit: BoxFit.cover,
                  placeholder: 'assets/urban/logoWhiteBackground.png',
                  image: user?.image ??
                      'https://i.ibb.co/55h301K/logo-White-Background.png',
                )
              : FadeInImage.assetNetwork(
                  fit: BoxFit.cover,
                  placeholder: 'assets/urban/logoWhiteBackground.png',
                  image: 'https://i.ibb.co/55h301K/logo-White-Background.png',
                ),
        ),
      ),
    );
  }
}
