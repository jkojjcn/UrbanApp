import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';

// ignore: must_be_immutable
class ClientProductsListPage extends StatefulWidget {
  String? restaurantId;
  Product? restaurant;
  bool? panelState;
  ClientProductsListPage(
      {Key? key, this.restaurantId, this.restaurant, this.panelState})
      : super(key: key);

  @override
  _ClientProductsListPageState createState() => _ClientProductsListPageState();
}

class _ClientProductsListPageState extends State<ClientProductsListPage> {
  ClientProductsListController _con = new ClientProductsListController();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.restaurantId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _con.categories.length,
      child: SafeArea(
        child: Scaffold(
          key: _con.key,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(265),
            child: AppBar(
              automaticallyImplyLeading: false,
              //  backgroundColor: Colors.black,
              flexibleSpace: Column(
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: 'abrirRestaurante',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 165,
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50)),
                            child: FadeInImage(
                              image: NetworkImage(widget.restaurant!.image3!),
                              fit: BoxFit.fill,
                              fadeInDuration: Duration(milliseconds: 50),
                              placeholder:
                                  AssetImage('assets/img/no-image.png'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        top: 25,
                        child: GestureDetector(
                          onTap: () {
                            _con.goToOrderCreatePage(widget.restaurant!);
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white),
                            margin: EdgeInsets.only(left: 25, top: 13),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          right: 18,
                          top: 38,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                          )),
                      widget.panelState!
                          ? FadeIn(
                              child: Hero(
                              tag: 'abrirRestaurante',
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                }, //_con.close,
                                icon: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                          : Container(),
                      Positioned(
                          top: 140,
                          left: 10,
                          child: Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delivery_dining,
                                  color: Colors.amber,
                                ),
                                _con.restaurantDistance(
                                    widget.restaurant!.price!)
                              ],
                            ),
                          ))
                    ],
                  ),
                  SizedBox(height: 15),
                  _textFieldSearch()
                ],
              ),
              bottom: TabBar(
                indicatorColor: MyColors.primaryColor,
                labelColor: Colors.amber,
                unselectedLabelColor: Colors.grey[200],
                isScrollable: true,
                tabs: List<Widget>.generate(_con.categories.length, (index) {
                  return Tab(
                    child: Text(
                      _con.categories[index].name ?? '',
                      style: TextStyle(fontSize: 13),
                    ),
                  );
                }),
              ),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 7, 7, 7),
          // drawer: _drawer(),
          body: TabBarView(
            children: _con.categories.map((Category category) {
              return FutureBuilder(
                  future: _con.getProducts(
                      category.id!, _con.productName, widget.restaurantId!),
                  builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        snapshot.data
                            ?.sort(((a, b) => a.name!.compareTo(b.name!)));
                        return GridView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2, vertical: 1),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, childAspectRatio: 0.98),
                            itemCount: snapshot.data?.length ?? 0,
                            itemBuilder: (_, index) {
                              return Hero(
                                  tag: 'productImage',
                                  child: _cardProduct(snapshot.data![index]));
                            });
                      } else {
                        return FadeIn(
                            child: NoDataWidget(text: 'No hay productos'));
                      }
                    } else {
                      return FadeIn(
                          child: NoDataWidget(text: 'No hay productos'));
                    }
                  });
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _cardProduct(Product product) {
    return GestureDetector(
      onTap: () {
        product.available != 0
            ? _con.openBottomSheet(product, widget.restaurant!)
            : Fluttertoast.showToast(msg: 'Producto agotado por ahora..');
      },
      child: Container(
        height: 200,
        child: Card(
          color: Color.fromARGB(255, 39, 39, 39),
          //  elevation: 5.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(27)),
                      child: FadeInImage(
                        image: NetworkImage(product.image1!),
                        fit: BoxFit.contain,
                        fadeInDuration: Duration(milliseconds: 50),
                        placeholder: AssetImage('assets/img/no-image.png'),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 4, top: 6, right: 4),
                    // height: 33,
                    child: Text(
                      product.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'NimbusSans',
                          color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 4, top: 3, right: 4),
                    // height: 33,
                    child: Text(
                      product.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'MontserratRegular',
                          color: Colors.grey),
                    ),
                  ),
                  // Spacer(),
                ],
              ),
              product.available == 0
                  ? Container(
                      color: Colors.grey.withOpacity(0.7),
                      child: Center(
                        child: Text(
                          'Agotado',
                          style: TextStyle(
                              fontSize: 19,
                              color: Colors.white,
                              fontFamily: 'MontserratSemiBold'),
                        ),
                      ),
                    )
                  : Container(),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  //  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  child: Text(
                    '${product.price?.toStringAsFixed(2) ?? 0} \$',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'NimbusSans'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFieldSearch() {
    return Container(
      height: 35,
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        onChanged: _con.onChangeText,
        cursorColor: Colors.amber,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: 'Buscar',
            suffixIcon: Icon(Icons.search, color: Colors.amber),
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
            focusColor: Colors.white,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            contentPadding: EdgeInsets.all(15)),
      ),
    );
  }

  void refresh() {
    setState(() {}); // CTRL + S
  }

  @override
  void dispose() {
    super.dispose();
  }
}
