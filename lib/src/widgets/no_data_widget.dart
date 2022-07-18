import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NoDataWidget extends StatelessWidget {
  String text;

  NoDataWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      delay: Duration(seconds: 1),
      duration: Duration(seconds: 2),
      child: Container(
        // margin: EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_food_outlined,
              color: Colors.orange,
              size: 30,
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ))
          ],
        ),
      ),
    );
  }
}
