import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_page.dart';

// ignore: must_be_immutable
class CardsView extends StatefulWidget {
  Product? product;

  CardsView({Key? key, this.product}) : super(key: key);
  @override
  _CardsViewState createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ClientProductsListPage(
                        restaurantId: widget.product?.id ?? "",
                        restaurant: widget.product,
                        panelState: true,
                      )));
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(7, 2, 7, 2),
          height: 200,
          width: 140,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Stack(
            children: <Widget>[
              Container(
                  height: 200,
                  width: 140,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 31, 31, 31),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 9,
                            offset: Offset(2, 2))
                      ]),
                  //s color: Colors.black,
                  child: widget.product?.image4 != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.product?.image4 ?? "",
                            fit: BoxFit.fill,
                          ),
                        )
                      : Image.asset('assets/iconApp/2xvsf.png')),
              Positioned(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: RichText(
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(children: [
                            TextSpan(
                                text: "${widget.product?.name} \n",
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold)),
                            /*  TextSpan(
                                text: "${product?.description ?? ''} \n",
                                style: TextStyle(fontSize: 13)),*/
                          ], style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ));
  }
}
