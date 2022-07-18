import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/product.dart';

import 'package:jcn_delivery/src/pages/delivery/orders/detail/delivery_orders_detail_controller.dart';
import 'package:jcn_delivery/src/utils/relative_time_util.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';

// ignore: must_be_immutable
class DeliveryOrdersDetailPage extends StatefulWidget {
  Order order;
  double totalDelivery;

  DeliveryOrdersDetailPage(
      {Key? key, required this.order, required this.totalDelivery})
      : super(key: key);

  @override
  _DeliveryOrdersDetailPageState createState() =>
      _DeliveryOrdersDetailPageState();
}

class _DeliveryOrdersDetailPageState extends State<DeliveryOrdersDetailPage> {
  DeliveryOrdersDetailController _con = new DeliveryOrdersDetailController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.order);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #${widget.order.id ?? ''}'),
        actions: [
          Container(
            margin: EdgeInsets.only(top: 18, right: 15),
            height: 50,
            child: Text(
              'Local: ${_con.total.toStringAsFixed(2)}\$',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Divider(
                color: Colors.grey[400],
                endIndent: 30, // DERECHA
                indent: 30, //IZQUIERDA
              ),
              SizedBox(height: 10),
              _textData('Cliente:',
                  '${widget.order.client.name ?? ''} ${widget.order.client.lastname ?? ''}'),
              _textData(
                  'Entregar en:', '${widget.order.address.address ?? ''}'),
              _textData('Fecha de pedido:',
                  '${RelativeTimeUtil.getRelativeTime(widget.order.timestamp ?? 0)}'),
              //    widget.order.status != 'ENTREGADO'
              //        ? widget.order.status == 'DESPACHADO'
              //            ? _textFieldPrice()
              //            : Container()
              //        : Container(),
              widget.order.status != 'ENTREGADO' ? _buttonNext() : Container()
            ],
          ),
        ),
      ),
      body: widget.order.products.length != 0
          ? ListView(
              children: widget.order.products.map((Product product) {
                return _cardProduct(product);
              }).toList(),
            )
          : NoDataWidget(
              text: 'Ningun producto agregado',
            ),
    );
  }

  Widget _textData(String title, String content) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          content,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buttonNext() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 20),
      child: ElevatedButton(
        onPressed: () async {
          double priceTotal = _con.priceController.numberValue;
          double deliveryTotal = widget.totalDelivery;

          double newTotalClient = priceTotal + deliveryTotal;

          try {
            _con.updateOrder(newTotalClient);
            if (widget.order.status == 'DESPACHADO') {
              _con.createNotification();
            }
          } catch (e) {}
        },
        style: ElevatedButton.styleFrom(
            primary: widget.order.status == 'DESPACHADO'
                ? Colors.blue
                : Colors.green,
            padding: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  widget.order.status == 'DESPACHADO'
                      ? 'INICIAR ENTREGA'
                      : 'IR AL MAPA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 50, top: 4),
                height: 30,
                child: Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _cardProduct(Product product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _imageProduct(product),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Cantidad: ${product.quantity}',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageProduct(Product product) {
    return Container(
      width: 50,
      height: 50,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.grey[200]),
      child: FadeInImage(
        image: NetworkImage(product.image1!),
        fit: BoxFit.contain,
        fadeInDuration: Duration(milliseconds: 50),
        placeholder: AssetImage('assets/img/no-image.png'),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
