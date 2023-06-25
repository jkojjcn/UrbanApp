import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/profile/edit/profile_edit_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';

class ProfileEditPage extends StatelessWidget {
  ProfileEditController con = Get.put(ProfileEditController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Perfil de usuario'),
      ),
      bottomNavigationBar: _buttonLogin(context),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            _imageUser(context),
            _textFieldName(),
            _textFieldDescription(),
            _textFieldPhone()
          ],
        ),
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

  Widget _textFieldDescription() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: con.lastnameController,
        decoration: InputDecoration(
            hintText: 'Descripción',
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

  Widget _textFieldPhone() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: con.phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            hintText: 'Telefono',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(color: MyColors.primaryColorDark),
            prefixIcon: Icon(
              Icons.phone,
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
          con.updateUser(context);
        },
        child: Text('EDITAR PERFIL'),
        style: ElevatedButton.styleFrom(
            // ignore: deprecated_member_use
            primary: MyColors.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: EdgeInsets.symmetric(vertical: 15)),
      ),
    );
  }

  Widget _imageUser(BuildContext context) {
    return GestureDetector(
      onTap: () => con.showAlertDialog(context),
      child: GetBuilder<ProfileEditController>(
        builder: (controller) => CircleAvatar(
          backgroundImage: con.imageFile != null
              ? FileImage(con.imageFile!)
              : con.user.image != null
                  ? NetworkImage(con.user.image!)
                  : AssetImage(
                      'assets/urban/logoWhiteBackground.png',
                    ) as ImageProvider,
          radius: 60,
          backgroundColor: Colors.grey[200],
        ),
      ),
    );
  }
}
