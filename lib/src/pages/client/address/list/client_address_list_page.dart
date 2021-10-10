import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/address/list/client_address_list_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';

class ClientAddressListPage extends StatefulWidget {
  Product restaurant;
  ClientAddressListPage({Key key, this.restaurant}) : super(key: key);

  @override
  _ClientAddressListPageState createState() => _ClientAddressListPageState();
}

class _ClientAddressListPageState extends State<ClientAddressListPage> {
  ClientAddressListController _con = new ClientAddressListController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   backgroundColor: C,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Direcciones',
          style: TextStyle(color: Colors.white),
        ),
        actions: [FadeIn(child: _iconAdd())],
      ),
      body: Stack(
        children: [
          Positioned(top: 0, child: FadeIn(child: _textSelectAddress())),
          Container(
              margin: EdgeInsets.only(top: 50),
              child: FadeIn(
                  duration: Duration(milliseconds: 700), child: _listAddress()))
        ],
      ),
      bottomNavigationBar: _buttonAccept(),
    );
  }

  Widget _noAddress() {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 30),
            child: NoDataWidget(
                text: 'No tienes ninguna direccion agrega una nueva')),
        _buttonNewAddress()
      ],
    );
  }

  Widget _buttonNewAddress() {
    return Container(
      height: 40,
      child: ElevatedButton(
        onPressed: _con.goToNewAddress,
        child: Text('Nueva direccion'),
        style: ElevatedButton.styleFrom(primary: Colors.blue),
      ),
    );
  }

  Widget _buttonAccept() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, 'client/restaurants');
          //  _con.createOrder(widget.restaurant?.id ?? "");
        },
        child: Text('Confirmar'),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            primary: MyColors.primaryColor),
      ),
    );
  }

  Widget _listAddress() {
    return FutureBuilder(
        future: _con.getAddress(),
        builder: (context, AsyncSnapshot<List<Address>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return FadeIn(
                duration: Duration(seconds: 1),
                child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (_, index) {
                      return _radioSelectorAddress(snapshot.data[index], index);
                    }),
              );
            } else {
              return FadeIn(
                  duration: Duration(seconds: 1), child: _noAddress());
            }
          } else {
            return Container();
            // FadeIn(duration: Duration(seconds: 3), child: _noAddress()

          }
        });
  }

  Widget _radioSelectorAddress(Address address, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Radio(
                value: index,
                groupValue: _con.radioValue,
                onChanged: _con.handleRadioValueChange,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address?.address ?? '',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    address?.neighborhood ?? '',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ],
          ),
          Divider(
            color: Colors.grey[400],
          )
        ],
      ),
    );
  }

  Widget _textSelectAddress() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Text(
        'Elige donde recibir tus compras',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _iconAdd() {
    return IconButton(
        onPressed: _con.goToNewAddress,
        icon: Icon(Icons.add, color: Colors.white));
  }

  void refresh() {
    setState(() {});
  }
}
