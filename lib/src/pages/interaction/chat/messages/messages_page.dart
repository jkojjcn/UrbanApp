import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/messages/messages_controller.dart';
import 'package:jcn_delivery/src/utils/bubble.dart';
import 'package:jcn_delivery/src/utils/bubble_image.dart';
import 'package:jcn_delivery/src/utils/relative_time_util_chat.dart';

class MessagesPage extends StatelessWidget {
  MessagesController con = Get.put(MessagesController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 58, 58, 58),
        body: SafeArea(
          child: Obx(() => (Column(
                children: [
                  customAppBar(),
                  Expanded(
                      flex: 1,
                      child: Container(
                        //  margin: EdgeInsets.only(bottom: 20),
                        child: ListView(
                          reverse: false,
                          controller: con.scrollController,
                          children: getMessages(),
                        ),
                      )),
                  messageBox(context)
                ],
              ))),
        ));
  }

  List<Widget> getMessages() {
    // con.messages.sort((b, a) => b.timestamp!.compareTo(a.timestamp!));
    return con.messages.map((e) {
      return Container(
          alignment: e.idSender == con.myUser.id
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: FadeInUp(
              duration: Duration(milliseconds: 300),
              from: 50,
              child: bubbleMessage(e)),
          margin: EdgeInsets.symmetric(horizontal: 20));
    }).toList();
  }

  Widget bubbleMessage(Message message) {
    if (message.isImage == true) {
      return BubbleImage(
          message: message.message ?? '',
          delivered: true,
          isImage: true,
          url: message.url ??
              'https://i.ibb.co/55h301K/logo-White-Background.png',
          isMe: message.idSender == con.myUser.id ? true : false,
          status: message.status ?? 'ENVIADO',
          time: RelativeTimeUtil.getRelativeTime(message.timestamp ?? 0));
    }

    return Bubble(
        message: message.message.toString(),
        delivered: true,
        isMe: message.idSender == con.myUser.id ? true : false,
        status: message.status ?? 'ENVIADO',
        time: RelativeTimeUtil.getRelativeTime(message.timestamp ?? 0));
  }

  Widget messageBox(BuildContext context) {
    return FadeInDown(
      from: 50,
      duration: Duration(milliseconds: 300),
      child: Card(
        // margin: EdgeInsets.zero,
        elevation: 15,
        color: Color.fromARGB(255, 58, 58, 58),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: IconButton(
                    onPressed: () => con.showAlertDialog(context),
                    icon: Icon(
                      Icons.image_outlined,
                      color: Colors.white,
                    ))),
            Expanded(
                flex: 8,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.05,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color.fromARGB(255, 121, 121, 121),
                  ),
                  child: TextField(
                    key: _formKey,
                    onChanged: (value) {
                      con.emitWriting();
                    },
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.white),
                    controller: con.messageController,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        hintText: 'Escribe tu mensaje',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                  ),
                )),
            Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: CupertinoButton(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      color: Color.fromARGB(255, 224, 224, 224),
                      onPressed: () => con.sendMessage(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 6,
                              child: Text(
                                'Enviar',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontFamily: 'MontserratRegular'),
                              )),
                          Expanded(
                            flex: 4,
                            child: FadeIn(
                                child: Icon(
                              Icons.send_rounded,
                              color: Colors.black,
                            )),
                          ),
                        ],
                      )),
                ))
          ],
        ),
      ),
    );
  }

  Widget customAppBar() {
    return SafeArea(
      child: ListTile(
        contentPadding: EdgeInsets.only(top: 10, left: 10),
        title: Text(
          con.userChat.name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 240, 240, 240),
              fontWeight: FontWeight.bold),
        ),
        subtitle: con.isWriting.value == true
            ? Text(
                'Escribiendo',
                style: TextStyle(color: Colors.grey),
              )
            : Text(
                '',
                style: TextStyle(color: Colors.grey),
              ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () => Get.back(), icon: Icon(Icons.arrow_back_ios)),
            Container(
              margin: EdgeInsets.symmetric(vertical: 2),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipOval(
                  child: con.userChat.image != ''
                      ? FadeInImage.assetNetwork(
                          fit: BoxFit.cover,
                          placeholder: 'assets/urban/logoWhiteBackground.png',
                          image: con.userChat.image ??
                              'https://i.ibb.co/55h301K/logo-White-Background.png',
                        )
                      : FadeInImage.assetNetwork(
                          fit: BoxFit.cover,
                          placeholder: 'assets/urban/logoWhiteBackground.png',
                          image:
                              'https://i.ibb.co/55h301K/logo-White-Background.png',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
