import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chats/chats_page.dart';

class ChatMainPage extends StatefulWidget {
  @override
  State<ChatMainPage> createState() => _ChatMainPageState();
}

class _ChatMainPageState extends State<ChatMainPage> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // bottomNavigationBar: _bottomNavigationBar(context),
        body: ChatsPage());
  }
}
