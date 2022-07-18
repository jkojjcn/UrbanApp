import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/pages/chat/chat_controller.dart';
import 'package:jcn_delivery/src/pages/client/orders/list/client_orders_list_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

ChatController _con = new ChatController();

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(child: Text("Notificaciones")),
              Container(
                height: 25,
                width: 25,
                child: FloatingActionButton(
                    heroTag: "messageButton",
                    mini: true,
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
            ],
          ),
          backgroundColor: Colors.black,
        ),
        //   backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(color: Colors.black),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                      child: FutureBuilder(
                          future: _con.getMessages(),
                          builder:
                              (context, AsyncSnapshot<List<Message>> message) {
                            _con.messageListModel.clear();
                            message.data?.sort(
                                (b, a) => a.created!.compareTo(b.created!));
                            message.data?.forEach((element) {
                              if (!_con.messageListModel.contains(element)) {
                                _con.messageListModel.add(element);
                              }
                            });
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: ListView.builder(
                                  itemCount: _con.messageListModel.length,
                                  itemBuilder: (context, index) {
                                    DateTime createdTime =
                                        _con.messageListModel[index].created!;

                                    Duration diff =
                                        createdTime.difference(DateTime.now());

                                    var time = '';
                                    print(diff.inDays);

                                    if (diff.inSeconds >= -60) {
                                      // time = format.format(date);

                                      time = diff.inSeconds.toString() +
                                          "segundos";
                                    } else if (diff.inMinutes >= -60) {
                                      // time = format.format(date);

                                      time =
                                          diff.inMinutes.toString() + "minutos";
                                    } else if (diff.inHours >= -24) {
                                      time = diff.inHours.toString() + "horas";
                                    } else if (diff.inDays < 0 &&
                                        diff.inDays > -7) {
                                      time = diff.inDays.toString();
                                      if (diff.inDays == -1) {
                                        time = 'Hace ' +
                                            diff.inDays.toString() +
                                            ' dia';
                                      } else {
                                        time = 'Hace ' +
                                            diff.inDays.toString() +
                                            ' dias';
                                      }
                                    } else if (diff.inDays <= -7) {
                                      time =
                                          (diff.inDays / 7).toStringAsFixed(0) +
                                              " semanas";
                                    }
                                    time =
                                        time.replaceFirst(RegExp('-'), 'Hace ');

                                    return GestureDetector(
                                      onTap: () {
                                        if (_con.messageListModel[index].type ==
                                            'notification') {
                                          print("NOTOFICATION ");
                                          showDialog(
                                              context: context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title: Text(_con
                                                          .messageListModel[
                                                              index]
                                                          .client
                                                          ?.name ??
                                                      ""),
                                                  content: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                    child: Image.network(_con
                                                            .messageListModel[
                                                                index]
                                                            .message ??
                                                        ""),
                                                  ),
                                                );
                                              });
                                        } else if (_con
                                                .messageListModel[index].type ==
                                            'payment') {
                                          showDialog(
                                              context: context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title:
                                                      Text('Pago con Tarjeta'),
                                                  content: Text(
                                                      'Realice el pago, lo verificaremos en 2 minutos maximo.'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            Text('Cancelar')),
                                                    TextButton(
                                                        onPressed: () {
                                                          _con.launchURL(_con
                                                              .messageListModel[
                                                                  index]
                                                              .message);
                                                        },
                                                        child: Text(
                                                          'REALIZAR PAGO',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )),
                                                  ],
                                                );
                                              });
                                        } else if (_con
                                                .messageListModel[index].type ==
                                            'order') {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ClientOrdersListPage()));
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage:
                                                        NetworkImage(_con
                                                                .messageListModel[
                                                                    index]
                                                                .client
                                                                ?.image ??
                                                            ""),
                                                    foregroundImage: _con
                                                                .messageListModel[
                                                                    index]
                                                                .client
                                                                ?.image ==
                                                            null
                                                        ? AssetImage(
                                                            'assets/iconApp/2xvsf.png')
                                                        : null,
                                                  ),
                                                  content: Text(_con
                                                          .messageListModel[
                                                              index]
                                                          .message ??
                                                      ""),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('Cerrar')),
                                                  ],
                                                );
                                              });
                                        }
                                      },
                                      child: Card(
                                        margin: EdgeInsets.only(
                                            left: 15, right: 15, bottom: 10),
                                        color:
                                            _con.messageListModel[index].open !=
                                                    "Si"
                                                ? Colors.green
                                                : Colors.white,
                                        child: ListTile(
                                            trailing: Text(
                                              time,
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.024),
                                            ),
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              backgroundImage: NetworkImage(_con
                                                      .messageListModel[index]
                                                      .client
                                                      ?.image ??
                                                  ""),
                                              foregroundImage: _con
                                                          .messageListModel[
                                                              index]
                                                          .client
                                                          ?.image ==
                                                      null
                                                  ? AssetImage(
                                                      'assets/iconApp/2xvsf.png')
                                                  : null,
                                            ),
                                            subtitle: _subtitle(
                                                _con.messageListModel[index]
                                                        .type ??
                                                    "",
                                                _con.messageListModel[index]
                                                        .message ??
                                                    ""),
                                            title: Text(
                                              _con.messageListModel[index]
                                                      .client?.name ??
                                                  "..",
                                              style: TextStyle(fontSize: 13),
                                            )),
                                      ),
                                    );
                                  }),
                            );
                          })),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _subtitle(String type, String message) {
    if (type == 'notification') {
      return Container();
    } else if (type == 'payment') {
      return Text("Pago");
    } else if (type == 'order') {
      return Text(message);
    }
    return Text(message);
  }

  void refresh() {
    setState(() {}); // CTRL + S
  }
}
