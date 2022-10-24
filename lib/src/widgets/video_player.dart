import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/restaurant.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_page.dart';
import 'package:video_player/video_player.dart';
import 'package:animate_do/animate_do.dart';

// ignore: must_be_immutable
class VideoPlayerWidget extends StatefulWidget {
  Restaurant? restaurant;
  bool? interaction;

  VideoPlayerWidget({Key? key, required this.restaurant, this.interaction})
      : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.restaurant!.image1!,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.initialize();
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      delay: Duration(seconds: 1),
      child: Container(
        color: Color.fromARGB(255, 43, 43, 43),
        height: MediaQuery.of(context).size.height * 1,
        width: MediaQuery.of(context).size.width * 1,
        child: Stack(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 1,
                  width: MediaQuery.of(context).size.width * 1,
                  child: VideoPlayer(_controller),
                ),
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ])),
                  height: MediaQuery.of(context).size.height * 1,
                  width: MediaQuery.of(context).size.width * 1,
                  child: GestureDetector(
                    onTap: () {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    },
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: ClientProductsListPage(
                        restaurantId: widget.restaurant!.id,
                        restaurant: widget.restaurant,
                        panelState: true),
                  ),
                );
              },
              child: FadeInDown(
                duration: Duration(seconds: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: MediaQuery.of(context).size.width * 0.10,
                            backgroundImage:
                                NetworkImage(widget.restaurant!.image3!),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  widget.restaurant!.name ?? '..',
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 204, 204, 204),
                                      fontFamily: 'MontserratSemiBold',
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  widget.restaurant!.description ?? '..',
                                  maxLines: 2,
                                  softWrap: false,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 204, 204, 204),
                                      fontFamily: 'MontserratRegular',
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            widget.restaurant!.image2 != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.yellowAccent,
                                      ),
                                      Text(
                                        widget.restaurant!.image2 ?? '..',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 45,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
