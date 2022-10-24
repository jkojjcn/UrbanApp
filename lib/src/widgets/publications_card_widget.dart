import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/models/publications.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_page.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class PublicationsCardWidget extends StatelessWidget {
  Publications publications;

  PublicationsCardWidget({Key? key, required this.publications})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ClientProductsListPage(
              restaurantId: publications.restaurantId.toString(),
              restaurant: publications.restaurant,
              panelState: true,
            ));
      },
      child: Container(
          margin: EdgeInsets.only(top: 15, bottom: 15),
          height: MediaQuery.of(context).size.height * 0.32,
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 97, 97, 97),
              boxShadow: [
                BoxShadow(
                    blurRadius: 4,
                    offset: Offset(1, 1),
                    color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.7),
                    spreadRadius: 2)
              ],
              borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.32,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 4,
                        offset: Offset(1, 1),
                        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.7),
                        spreadRadius: 2)
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl: publications.image!,
                  placeholder: (context, url) => Shimmer(
                      child: Container(
                    color: Colors.black,
                  )),
                  imageBuilder: (context, image) => Image(
                    image: image,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.32,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        end: Alignment.bottomCenter,
                        begin: Alignment.topCenter,
                        colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.8),
                      Colors.black,
                    ])),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    //   padding: EdgeInsets.only(bottom: 150),
                    height: MediaQuery.of(context).size.height * 0.075,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5))),
                    child: ListTile(
                      //contentPadding: EdgeInsets.only(bottom: 14),
                      leading: AspectRatio(
                        aspectRatio: 1,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: publications.restaurant!.image3!,
                            placeholder: (context, url) => Shimmer(
                                child: Container(
                              color: Colors.black,
                            )),
                            imageBuilder: (context, image) => Image(
                              image: image,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        publications.title!,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'MontSerratSemiBold'),
                      ),
                      subtitle: Text(
                        publications.subtitle!,
                        maxLines: 2,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_fire_department_outlined,
                                    color: Colors.white),
                                Text(
                                  publications.fire ?? '',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
