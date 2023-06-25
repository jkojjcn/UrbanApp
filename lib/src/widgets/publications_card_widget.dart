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
          //      margin: EdgeInsets.only(top: 10, bottom: 10, left: 4, right: 4),
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 32, 32, 32),
          ),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 1,
                child: CachedNetworkImage(
                  imageUrl: publications.image!,
                  placeholder: (context, url) => Shimmer(
                      child: Container(
                    color: Colors.black,
                  )),
                  imageBuilder: (context, image) => Image(
                    image: image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                //   padding: EdgeInsets.only(bottom: 150),
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5))),
                child: Center(
                  child: ListTile(
                    //contentPadding: EdgeInsets.only(bottom: 14),
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                      child: ClipOval(
                          child: Image.network(
                        publications.restaurant!.image3!,
                        fit: BoxFit.fitHeight,
                      )),
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.02,
                width: MediaQuery.of(context).size.width * 1,
                color: Color.fromARGB(255, 41, 41, 41),
              ),
            ],
          )),
    );
  }
}
