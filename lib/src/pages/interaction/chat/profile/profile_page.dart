import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/profile/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfileController con = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuario'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'a',
            onPressed: () {},
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            heroTag: '3',
            child: Icon(
              Icons.edit,
              color: Colors.deepOrange,
            ),
            onPressed: con.goToProfileEdit,
          ),
        ],
      ),
      body: Obx(() => SafeArea(
            child: ListView(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 30),
                    width: 200,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipOval(
                        child: con.user.value.image != null &&
                                con.user.value.image != "" &&
                                con.user.value.image != 'null'
                            ? FadeInImage.assetNetwork(
                                fit: BoxFit.cover,
                                placeholder:
                                    'assets/urban/logoWhiteBackground.png',
                                image: con.user.value.image ??
                                    'https://i.ibb.co/55h301K/logo-White-Background.png',
                              )
                            : Container(),
                      ),
                    ),
                  ),
                ),
                userInfo('Nombre ', con.user.value.name!, Icons.person),
                userInfo('Email ', con.user.value.email!, Icons.email),
                userInfo('Contacto ', con.user.value.phone!, Icons.phone)
              ],
            ),
          )),
    );
  }

  Widget userInfo(String title, String subtitle, IconData iconData) {
    return Container(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
      ),
    );
  }
}
