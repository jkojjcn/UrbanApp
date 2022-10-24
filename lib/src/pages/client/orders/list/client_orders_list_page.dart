import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/pages/client/orders/list/client_orders_list_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/utils/relative_time_util.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';
import 'package:timer_builder/timer_builder.dart';

class ClientOrdersListPage extends StatefulWidget {
  const ClientOrdersListPage({Key? key}) : super(key: key);

  @override
  _ClientOrdersListPageState createState() => _ClientOrdersListPageState();
}

class _ClientOrdersListPageState extends State<ClientOrdersListPage> {
  ClientOrdersListController _con = new ClientOrdersListController();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
      //     _actualizar();
    });
  }

  _actualizar() {
    Future.delayed(Duration(seconds: 10), () {
      _con.init(context, refresh);

      _actualizar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _con.status.length,
      child: SafeArea(
        child: Scaffold(
          key: _con.key,
          // backgroundColor: Colors.black,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: AppBar(
              title: Text('Mis pedidos'),
              backgroundColor: Colors.black,
              actions: [
                IconButton(
                    onPressed: () {
                      Get.toNamed('/centralChat');
                    },
                    icon: Icon(Icons.help)),
              ],
              leading: IconButton(
                  onPressed: () {
                    Get.offNamedUntil('/client/restaurants', (route) => false);
                  },
                  icon: Icon(Icons.arrow_back_ios_new_sharp)),
              bottom: TabBar(
                indicatorColor: MyColors.primaryColor,
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.grey[400],
                isScrollable: true,
                tabs: List<Widget>.generate(_con.status.length, (index) {
                  return Tab(
                    child: Text(
                      _con.status[index] == 'PAGADO'
                          ? 'VERIFICANDO'
                          : _con.status[index] == 'DESPACHADO'
                              ? 'PREPARANDO'
                              : _con.status[index],
                      style: TextStyle(
                          fontFamily: 'MontserratRegular', fontSize: 12),
                    ),
                  );
                }),
              ),
            ),
          ),
          body: TabBarView(
            children: _con.status.map((String status) {
              print(status);
              return TimerBuilder.periodic(Duration(seconds: 20),
                  builder: (context) {
                return FutureBuilder(
                    future: _con.getOrders(status),
                    builder: (context, AsyncSnapshot<List<Order>> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.length != null) {
                          return ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              itemCount: snapshot.data?.length ?? 0,
                              itemBuilder: (_, index) {
                                return _cardOrder(snapshot.data![index]);
                              });
                        } else {
                          return NoDataWidget(text: 'No hay ordenes');
                        }
                      } else {
                        return NoDataWidget(text: 'No hay ordenes');
                      }
                    });
              });
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _cardOrder(Order order) {
    String _tiempoDeOrden =
        RelativeTimeUtil.getRelativeTime(order.timestamp ?? 0);
    int? _tiempoDistancia;

    try {
      if ((order.distance! / 1000) <= 2) {
        _tiempoDistancia = 10;
      } else if ((order.distance! / 1000) > 2 &&
          (order.distance! / 1000) <= 4) {
        _tiempoDistancia = 20;
      } else if ((order.distance! / 1000) > 4) {
        _tiempoDistancia = 30;
      } else {
        _tiempoDistancia = 40;
      }
    } catch (e) {
      print(e);
    }

    return FadeInDown(
      from: 20,
      duration: Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          _con.openBottomSheet(order);
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Card(
            elevation: 3.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Stack(
              children: [
                Positioned(
                    child: Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                      color: MyColors.primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'Orden #${order.id}',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontFamily: 'NimbusSans'),
                    ),
                  ),
                )),
                Container(
                  margin: EdgeInsets.only(top: 30, left: 20, right: 20),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        width: double.infinity,
                        child: Text(
                          order.restaurant!.name!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      ((_tiempoDistancia! + order.restaurantTime!) -
                                  double.parse(_tiempoDeOrden)) >=
                              -30
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.delivery_dining_outlined,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    (order.restaurantTime != 0.0
                                        ? 'Llegada estimada en: ' +
                                            ((_tiempoDistancia +
                                                        order.restaurantTime!) -
                                                    double.parse(
                                                        _tiempoDeOrden))
                                                .toStringAsFixed(0) +
                                            ' minutos'
                                        : 'Esperando tiempo de preparación'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      Container(
                        alignment: Alignment.centerLeft,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Repartidor: ${order.delivery?.name ?? 'Asignando..'} ${order.delivery?.lastname ?? ''}',
                          style: TextStyle(fontSize: 13),
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Entregar en: ${order.address.address ?? ''}',
                          style: TextStyle(fontSize: 13),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {}); // CTRL + S
  }
}
