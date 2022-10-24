import 'dart:developer';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/pages/login/login_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _formKey = GlobalKey<FormState>();

  TextEditingController _mobileController = new TextEditingController();
  TextEditingController _codeController = new TextEditingController();
  LoginController _con = LoginController();
  GeneralActions generalActions = Get.put(GeneralActions());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String smsCode = '';

  @override
  void dispose() {
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  _signInWithMobileNumber() async {
    UserCredential _credential;
    //var valid = _formKey.currentState.validate();
    User user;

    try {
      log('Intentando logear');
      Get.snackbar('Un momento', 'El código está por llegar..',
          backgroundColor: Colors.white);

      await _auth.verifyPhoneNumber(
        phoneNumber: '+593' + _mobileController.text.trim(),
        verificationCompleted: (PhoneAuthCredential authCredential) async {
          print('AUTH CREDENTIAL');
          log(authCredential.toString());

          await _auth.signInWithCredential(authCredential).then((value) {
            log(value.toString());
            log(value.toString());
            log(value.toString());
            log(value.toString());

            //  Navigator.pushNamed(context, LandingPage.routeName);
          });
        },
        verificationFailed: ((error) {
          log(error.toString());
        }),
        codeSent: (String verificationId, forceResendingToken) {
          showDialog(
              context: context,
              builder: (_) {
                return CupertinoAlertDialog(
                  title: Text("Ingresa el código recibido"),
                  content: CupertinoTextField(
                    controller: _codeController,
                  ),
                  actions: <Widget>[
                    CupertinoButton(
                        child: Text("Confirmar"),
                        onPressed: () {
                          FirebaseAuth auth = FirebaseAuth.instance;
                          smsCode = _codeController.text.trim();
                          PhoneAuthCredential _credential =
                              PhoneAuthProvider.credential(
                            verificationId: verificationId,
                            smsCode: smsCode,
                          );
                          auth.signInWithCredential(_credential).then((result) {
                            if (result != null) {
                              log(result.user!.phoneNumber!);
                              generalActions.userUid.value.password =
                                  result.user!.uid;
                              generalActions.userUid.value.phone =
                                  result.user!.phoneNumber!;
                              log(result.user!.phoneNumber!);
                              log(result.user!.uid);
                              _con.loginPhone(
                                  result.user!.uid, result.user!.phoneNumber!);
                            }
                          }).catchError((e) {
                            print(e);
                          });
                        })
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print('AUTORETRIVAL SECTION');
          print(verificationId);
          print("Timout");
        },
        timeout: Duration(
          seconds: 45,
        ),
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Colors.white,

        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 1,
            width: MediaQuery.of(context).size.width * 1,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                  Color.fromARGB(255, 0, 0, 0),
                  Color.fromARGB(255, 65, 65, 65),
                  Color.fromARGB(255, 54, 54, 54),
                  Color.fromARGB(255, 0, 0, 0),
                ])),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Text(
                    'Las mejores promos con estilo!',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Stack(
                    children: [
                      Opacity(
                          child: Image.asset('assets/iconApp/logoflyicon.png',
                              color: Colors.black),
                          opacity: 0.2),
                      ClipRect(
                          child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                              child: Image.asset(
                                'assets/iconApp/logoflyicon.png',
                                color: Colors.white,
                              ))),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              blurRadius: 4,
                              offset: Offset(4, 4),
                              color:
                                  Color.fromARGB(255, 0, 0, 0).withOpacity(0.7),
                              spreadRadius: 2)
                        ],
                        color: Color.fromARGB(255, 255, 255, 255)),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          label: Text(
                            'Número de celular',
                            style:
                                TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                          //  hintText: 'Correo electronico',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(15),
                          hintStyle: TextStyle(
                              color: Color.fromARGB(221, 190, 190, 190)),
                          hintText: 'Ej. 0998041037',
                          prefixIcon: Icon(
                            Icons.email,
                            color: MyColors.primaryColor,
                          )),
                      controller: _mobileController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          Get.snackbar('Ingresa tu número',
                              'Ej. 0998041037 (es el número de soporte)');
                          //  return "Ingresa tu número de contacto";
                        }
                        if (!value.contains('@')) {
                          return "Invalid mobile number";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  _buttonLogin()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonLogin() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: FloatingActionButton.extended(
        label: Text('INGRESAR'),
        focusColor: Colors.red,
        onPressed: _signInWithMobileNumber,
      ),
    );
  }
}
