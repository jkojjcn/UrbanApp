import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class Bubble extends StatelessWidget {
  Bubble(
      {this.message = '',
      this.time = '',
      this.delivered,
      this.isMe,
      this.status = ''});

  final String message, time, status;
  final delivered, isMe;

  Uri? isUrlLink;

  @override
  Widget build(BuildContext context) {
    isUrlLink = Uri.tryParse(message);

    final bg = isMe ? Colors.white : Colors.deepOrange;
    final align = isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final icon = status == 'ENVIADO'
        ? Icons.done
        : status == 'RECIBIDO'
            ? Icons.done_all
            : Icons.done_all;
    final radius = isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(15.0),
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(15.0),
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          );
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              right: isMe == true ? 3 : 70,
              left: isMe == true ? 70 : 3,
              top: 5,
              bottom: 5),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: .5,
                  spreadRadius: 1.0,
                  color: Colors.black.withOpacity(.12))
            ],
            color: bg,
            borderRadius: radius,
          ),
          child: Stack(
            children: <Widget>[
              isUrlLink != null
                  ? Container(
                      padding: EdgeInsets.only(right: isMe == true ? 60 : 57),
                      child: Text(
                        message,
                        style: TextStyle(
                            color: isMe
                                ? Color.fromARGB(255, 43, 43, 43)
                                : Color.fromARGB(255, 255, 255, 255)),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        _launchUrl(Uri.parse(message));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromARGB(255, 136, 136, 136),
                        ),
                        padding: EdgeInsets.only(right: isMe == true ? 60 : 57),
                        child: Text(
                          "${"-- " + message}",
                          style: TextStyle(
                              color: isMe
                                  ? Color.fromARGB(255, 43, 43, 43)
                                  : Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                  children: <Widget>[
                    Text(time,
                        style: TextStyle(
                          color: isMe
                              ? Color.fromARGB(255, 197, 197, 197)
                              : Color.fromARGB(255, 230, 230, 230),
                          fontSize: 10.0,
                        )),
                    isMe == true
                        ? Icon(
                            icon,
                            size: 12.0,
                            color: status == 'VISTO'
                                ? Colors.blue
                                : Colors.black38,
                          )
                        : Container()
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Future<void> _launchUrl(_messageUrl) async {
    if (!await launchUrl(_messageUrl)) {
      throw 'Could not launch $_messageUrl';
    }
  }
}
