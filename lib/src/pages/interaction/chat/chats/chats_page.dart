import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chats/chats_controller.dart';
import 'package:jcn_delivery/src/utils/relative_time_util_chat.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  ChatsController con = Get.put(ChatsController());
  GeneralActions generalActions = Get.find();

  String urlRushImage = "https://i.ibb.co/55h301K/logo-White-Background.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        leading: Container(),
        centerTitle: true,
        actions: [
          FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.black,
              onPressed: () => Get.back(),
              heroTag: 'messageButton',
              child: Icon(Icons.close)),
        ],
      ),
      body: Obx(() => SafeArea(
            child: ListView(
              children: generalActions.chats.map((e) {
                return Container(
                    color: e.idUser1 == '1' || e.idUser2 == '1'
                        ? Color.fromARGB(255, 228, 228, 228)
                        : Colors.white,
                    child: e.id != null ? cardChat(e) : Container());
              }).toList(),
            ),
          )),
    );
  }

  Widget cardChat(Chat? chat) {
    return ListTile(
      onTap: () => con.goToChat(chat!),
      title: FadeIn(
        delay: Duration(milliseconds: 300),
        duration: Duration(milliseconds: 300),
        child: Text(chat?.idUser1 == con.myUser.id
            ? chat?.nameUser2 ?? ''
            : chat?.nameUser1 ?? ''),
      ),
      subtitle: FadeIn(
          delay: Duration(milliseconds: 300),
          duration: Duration(milliseconds: 300),
          child: Text(chat!.lastMessage ?? '')),
      trailing: FadeIn(
        delay: Duration(milliseconds: 300),
        duration: Duration(milliseconds: 300),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                chat.lastMessageTimestamp != 0
                    ? RelativeTimeUtil.getRelativeTime(
                        chat.lastMessageTimestamp!)
                    : '',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            chat.unreadMessage! > 0
                ? circleMessageUnread(chat.unreadMessage ?? 0)
                : SizedBox(),
          ],
        ),
      ),
      leading: FadeIn(
        delay: Duration(milliseconds: 300),
        duration: Duration(milliseconds: 300),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: chat.idUser1 == con.myUser.id
                  ? chat.imageUser2! == ""
                      ? urlRushImage
                      : chat.imageUser2!
                  : chat.imageUser1 ?? urlRushImage,
              placeholder: (context, url) => Shimmer(
                  child: Container(
                color: Colors.black,
              )),
              imageBuilder: (context, image) => Image(
                image: image,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget circleMessageUnread(int number) {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 10, right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 25,
          width: 25,
          color: Colors.red,
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
