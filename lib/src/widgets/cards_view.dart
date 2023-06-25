import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/restaurant.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_page.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

// ignore: must_be_immutable
class CardsView extends StatefulWidget {
  Restaurant? product;

  CardsView({Key? key, this.product}) : super(key: key);
  @override
  _CardsViewState createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Get.to(() => ClientProductsListPage(
                restaurantId: widget.product?.id ?? "",
                restaurant: widget.product,
                panelState: true,
              ));

          /*   Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ClientProductsListPage(
                        restaurantId: widget.product?.id ?? "",
                        restaurant: widget.product,
                        panelState: true,
                      )));*/
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(5, 4, 5, 2),
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.30,
          child: Stack(
            children: <Widget>[
              Container(
                  height: 150,
                  width: 120,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 2,
                            offset: Offset(2, 2))
                      ]),
                  //s color: Colors.black,
                  child: widget.product?.image4 != null
                      ? ClipRRect(
                          child: CachedNetworkImage(
                            imageUrl: widget.product!.image4!,
                            placeholder: (context, url) => Shimmer(
                                child: Container(
                              color: Colors.black,
                            )),
                            imageBuilder: (context, image) => Image(
                              image: image,
                              fit: BoxFit.fill,
                            ),
                          ),
                        )
                      : Image.asset('assets/iconApp/logoMoto.png')),
              widget.product!.image2 != null
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: !widget.product!.image2
                                    .toString()
                                    .contains('ABRE PRONTO')
                                ? !widget.product!.image2
                                        .toString()
                                        .contains('Promo')
                                    ? Colors.red
                                    : Colors.green
                                : Color.fromARGB(255, 199, 179, 0),
                            borderRadius: BorderRadius.circular(3)),
                        child: Text(
                          widget.product!.image2.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                  : Container(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "${widget.product?.name} \n",
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          ),
        ));
  }
}
