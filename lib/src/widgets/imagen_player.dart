import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class ImagenPlayerPage extends StatefulWidget {
  final String image1;
  final String image2;

  const ImagenPlayerPage({Key? key, required this.image1, required this.image2})
      : super(key: key);

  @override
  _ImagenPlayerPageState createState() => _ImagenPlayerPageState();
}

class _ImagenPlayerPageState extends State<ImagenPlayerPage>
    with SingleTickerProviderStateMixin {
  double nextImage = 0;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 700), () {
      setState(() {
        nextImage = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 1,
      width: MediaQuery.of(context).size.width * 1,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black])),
      child: Stack(children: [
        ImageSlideshow(
            isLoop: true,
            height: MediaQuery.of(context).size.height * 1,
            width: MediaQuery.of(context).size.width * 1,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 1,
                width: MediaQuery.of(context).size.width * 1,
                child: Image.network(
                  widget.image1,
                  //  width: 400,
                  // color: Colors.white,
                  // height: 400,
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 1,
                width: MediaQuery.of(context).size.width * 1,
                child: Image.network(
                  widget.image2,
                  //  width: 400,
                  // color: Colors.white,
                  // height: 400,
                  fit: BoxFit.fill,
                  scale: 2,
                ),
              ),
            ]),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                Colors.black,
                Colors.black.withOpacity(0.5),
                Colors.transparent,
                Colors.transparent,
                Colors.transparent,
                Colors.transparent,
                Colors.transparent,
                Colors.transparent,
                Colors.transparent,
              ])),
        ),
      ]),
    );
  }
}
