import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';

class ClientProductsListPage extends StatefulWidget {
  String restaurantId;
  Product restaurant;
  ClientProductsListPage({Key key, this.restaurantId, this.restaurant})
      : super(key: key);

  @override
  _ClientProductsListPageState createState() => _ClientProductsListPageState();
}

class _ClientProductsListPageState extends State<ClientProductsListPage> {
  ClientProductsListController _con = new ClientProductsListController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _con.categories?.length,
      child: Scaffold(
        key: _con.key,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(225),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black87,
            flexibleSpace: Column(
              children: [
                Stack(
                  children: [
                    // Text('data'),
                    Container(
                      height: 165,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50)),
                      child: FadeIn(
                        delay: Duration(seconds: 1),
                        child: ImageSlideshow(
                          width: double.infinity,
                          // height: 200,
                          initialPage: 0,
                          isLoop: true,
                          indicatorColor: MyColors.primaryColor,
                          indicatorBackgroundColor: Colors.grey,
                          children: [
                            FadeInImage(
                              image: widget.restaurant?.image1 != null
                                  ? NetworkImage(widget.restaurant.image1)
                                  : AssetImage('assets/img/no-image.png'),
                              fit: BoxFit.cover,
                              fadeInDuration: Duration(milliseconds: 50),
                              placeholder:
                                  AssetImage('assets/img/no-image.png'),
                            ),
                            FadeInImage(
                              image: widget.restaurant?.image2 != null
                                  ? NetworkImage(widget.restaurant.image2)
                                  : AssetImage('assets/img/no-image.png'),
                              fit: BoxFit.cover,
                              fadeInDuration: Duration(milliseconds: 50),
                              placeholder:
                                  AssetImage('assets/img/no-image.png'),
                            ),
                            FadeInImage(
                              image: widget.restaurant?.image3 != null
                                  ? NetworkImage(widget.restaurant.image3)
                                  : AssetImage('assets/img/no-image.png'),
                              fit: BoxFit.cover,
                              fadeInDuration: Duration(milliseconds: 50),
                              placeholder:
                                  AssetImage('assets/img/no-image.png'),
                            ),
                          ],
                          onPageChanged: (value) {
                            print('Page changed: $value');
                          },
                          autoPlayInterval: 30000,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      top: 25,
                      child: GestureDetector(
                        onTap: () {
                          _con.goToOrderCreatePage(widget.restaurant);
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
                          //  child:
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                        )),

                    Positioned(
                        left: 5,
                        top: 30,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          }, //_con.close,
                          icon: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
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
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey[200],
              isScrollable: true,
              tabs: List<Widget>.generate(_con.categories.length, (index) {
                return Tab(
                  child: Text(_con.categories[index].name ?? ''),
                );
              }),
            ),
          ),
        ),
        backgroundColor: Colors.black,
        drawer: _drawer(),
        body: TabBarView(
          children: _con.categories.map((Category category) {
            return FutureBuilder(
                future: _con.getProducts(
                    category.id, _con.productName, widget.restaurantId),
                builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length > 0) {
                      return GridView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, childAspectRatio: 0.74),
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (_, index) {
                            return FadeIn(
                                child: _cardProduct(snapshot.data[index]));
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
    );
  }

  Widget _cardProduct(Product product) {
    return GestureDetector(
      onTap: () {
        _con.openBottomSheet(product);
      },
      child: Container(
        height: 250,
        child: Card(
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 130,
                    margin: EdgeInsets.only(top: 5),
                    //  width: MediaQuery.of(context).size.width * 0.15,
                    padding: EdgeInsets.all(15),
                    child: FadeInImage(
                      image: product.image1 != null
                          ? NetworkImage(product.image1)
                          : AssetImage('assets/img/pizza2.png'),
                      fit: BoxFit.fill,
                      fadeInDuration: Duration(milliseconds: 50),
                      placeholder: AssetImage('assets/img/no-image.png'),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    height: 33,
                    child: Text(
                      product.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontFamily: 'NimbusSans'),
                    ),
                  ),
                  // Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Text(
                        '${product.price.toStringAsFixed(2) ?? 0}\$',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'NimbusSans'),
                      ),
                    ),
                  )
                ],
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
        decoration: InputDecoration(
            hintText: 'Buscar',
            suffixIcon: Icon(Icons.search, color: Colors.orange[300]),
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Colors.grey[400])),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Colors.grey[300])),
            contentPadding: EdgeInsets.all(15)),
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(color: MyColors.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_con.user?.name ?? ''} ${_con.user?.lastname ?? ''}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  Text(
                    _con.user?.email ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                    maxLines: 1,
                  ),
                  Text(
                    _con.user?.phone ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                    maxLines: 1,
                  ),
                  Container(
                    height: 60,
                    margin: EdgeInsets.only(top: 10),
                    child: FadeInImage(
                      image: _con.user?.image != null
                          ? NetworkImage(_con.user?.image)
                          : AssetImage('assets/img/no-image.png'),
                      fit: BoxFit.contain,
                      fadeInDuration: Duration(milliseconds: 50),
                      placeholder: AssetImage('assets/img/no-image.png'),
                    ),
                  )
                ],
              )),
          ListTile(
            onTap: _con.goToUpdatePage,
            title: Text('Editar perfil'),
            trailing: Icon(Icons.edit_outlined),
          ),
          ListTile(
            onTap: _con.goToOrdersList,
            title: Text('Mis pedidos'),
            trailing: Icon(Icons.shopping_cart_outlined),
          ),
          _con.user != null
              ? _con.user.roles.length > 1
                  ? ListTile(
                      onTap: _con.goToRoles,
                      title: Text('Seleccionar rol'),
                      trailing: Icon(Icons.person_outline),
                    )
                  : Container()
              : Container(),
          ListTile(
            onTap: _con.logout,
            title: Text('Cerrar sesion'),
            trailing: Icon(Icons.power_settings_new),
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {}); // CTRL + S
  }
}
