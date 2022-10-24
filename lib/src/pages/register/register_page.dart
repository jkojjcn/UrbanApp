import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/pages/register/register_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';

class RegisterPage extends StatelessWidget {
  RegisterController con = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blueGrey[900],
      body: Container(
        decoration: BoxDecoration(color: Color.fromARGB(255, 46, 46, 46)),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 1,
        child: Stack(
          children: [
            //  Positioned(top: -80, left: -100, child: _circle()),
            Positioned(
              child: _textRegister(),
              top: 65,
              left: 27,
            ),
            Positioned(
              child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white)),
              top: 51,
              left: 5,
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 120),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _imageUser(context),
                    SizedBox(height: 30),
                    _textFieldEmail(),
                    _textFieldName(),
                    _buttonLogin(context)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _imageUser(BuildContext context) {
    return GestureDetector(
      onTap: () => con.showAlertDialog(context),
      child: GetBuilder<RegisterController>(
        builder: (controller) => Column(
          children: [
            CircleAvatar(
              backgroundImage: con.imageFile != null
                  ? FileImage(con.imageFile!)
                  : AssetImage('assets/iconApp/fly.png') as ImageProvider,
              radius: 60,
              backgroundColor: Colors.grey[200],
            ),
            con.imageFile != null
                ? Text(
                    'Listo!',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontFamily: 'MontserratRegular'),
                  )
                : Text(
                    'Cambiar Imagen',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'MontserratRegular'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _textRegister() {
    return Text('   REGISTRO',
        style: TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'MontserratRegular'));
  }

  Widget _textFieldEmail() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: con.emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            hintText: 'Correo electronico',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(color: MyColors.primaryColorDark),
            prefixIcon: Icon(
              Icons.email,
              color: MyColors.primaryColor,
            )),
      ),
    );
  }

  Widget _textFieldName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: con.nameController,
        decoration: InputDecoration(
            hintText: 'Nombre y apellido',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(color: MyColors.primaryColorDark),
            prefixIcon: Icon(
              Icons.person,
              color: MyColors.primaryColor,
            )),
      ),
    );
  }

  Widget _buttonLogin(context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: ElevatedButton(
        onPressed: () {
          if (con.isEnable) {
            con.register(context);
          } else {
            null;
          }
        },
        child: Text('REGISTRARSE'),
        style: ElevatedButton.styleFrom(
            // ignore: deprecated_member_use
            primary: MyColors.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: EdgeInsets.symmetric(vertical: 15)),
      ),
    );
  }
}
