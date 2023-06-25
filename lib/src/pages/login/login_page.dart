import 'dart:developer';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/pages/login/login_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _formKey = GlobalKey<FormState>();

  TextEditingController _mobileController = new TextEditingController();
  OtpFieldController otpController = OtpFieldController();
  LoginController _con = LoginController();
  GeneralActions generalActions = Get.put(GeneralActions());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String smsCode = '';
  bool blockButttom = false;
  String otpCodeSent = '';

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  bool _validateText() {
    if (_mobileController.text.length == 10 &&
        _mobileController.text.isPhoneNumber) {
      return true;
    } else {
      return false;
    }
  }

  _reloadButtonConfirmDelay() {
    Future.delayed(Duration(seconds: 35), () {
      setState(() {
        blockButttom = false;
      });
    });
  }

  _reloadButtonConfirm() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        blockButttom = false;
      });
    });
  }

  _signInWithMobileNumber() async {
    UserCredential _credential;
    //var valid = _formKey.currentState.validate();
    User user;
    if (_validateText()) {
      try {
        setState(() {
          blockButttom = true;
        });
        _reloadButtonConfirmDelay();
        Get.snackbar('Enviando..', 'Al número: ${_mobileController.text}',
            backgroundColor: Color.fromARGB(255, 68, 87, 96),
            colorText: Colors.white);
        log('Intentando logear');

        await _auth.verifyPhoneNumber(
          phoneNumber: '+593' + _mobileController.text.trim(),
          verificationCompleted: (PhoneAuthCredential authCredential) async {
            print('AUTH CREDENTIAL');
            log(authCredential.toString());

            await _auth.signInWithCredential(authCredential).then((value) {
              log(value.toString());
              //  Navigator.pushNamed(context, LandingPage.routeName);
            });
          },
          verificationFailed: ((error) {
            Get.snackbar(
                'Error', 'No tenemos idea de lo que está pasando.. Reintente',
                backgroundColor: Colors.red, colorText: Colors.white);
            log(error.toString());
            setState(() {
              blockButttom = false;
            });
          }),
          codeSent: (String verificationId, forceResendingToken) {
            Get.snackbar('Enviado Correctamente', 'Quizá tarde unos segundos',
                backgroundColor: Color.fromARGB(255, 68, 87, 96),
                colorText: Colors.white);
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return AlertDialog(
                    insetPadding: EdgeInsets.symmetric(horizontal: 20),
                    title: Text("Ingresa el código recibido"),
                    content: Container(
                      // height: MediaQuery.of(context).size.height * 0.3,
                      //     width: MediaQuery.of(context).size.width * 0.8,
                      child: Material(
                        child: OTPTextField(
                            controller: otpController,
                            length: 6,
                            width: MediaQuery.of(context).size.width,
                            textFieldAlignment: MainAxisAlignment.spaceAround,
                            fieldWidth: 45,
                            fieldStyle: FieldStyle.box,
                            outlineBorderRadius: 15,
                            style: TextStyle(fontSize: 17),
                            onChanged: (pin) {
                              smsCode = pin;
                            },
                            onCompleted: (pin) {
                              smsCode = pin;
                            }),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                          child: Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _reloadButtonConfirm();
                          }),
                      TextButton(
                          child: Text("Confirmar"),
                          onPressed: () {
                            FirebaseAuth auth = FirebaseAuth.instance;

                            PhoneAuthCredential _credential =
                                PhoneAuthProvider.credential(
                              verificationId: verificationId,
                              smsCode: smsCode,
                            );
                            auth
                                .signInWithCredential(_credential)
                                .then((result) {
                              if (result != null) {
                                log(result.user!.phoneNumber!);
                                generalActions.userUid.value.password =
                                    result.user!.uid;
                                generalActions.userUid.value.phone =
                                    result.user!.phoneNumber!;
                                log(result.user!.phoneNumber!);
                                log(result.user!.uid);
                                _con.loginPhone(result.user!.uid,
                                    result.user!.phoneNumber!);
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
            seconds: 35,
          ),
        );
      } catch (e) {
        print('Error al enviar el código : ' + "$e");
      }
    } else {
      Get.snackbar('Error', 'Revisa el número de teléfono');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 1,
          width: MediaQuery.of(context).size.width * 1,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                      ),
                      Text(
                        'Pedidos bien puestitos!',
                        style:
                            TextStyle(color: Colors.deepOrange, fontSize: 20),
                      ),
                      Stack(
                        children: [
                          FadeInDown(
                            delay: Duration(milliseconds: 500),
                            duration: Duration(seconds: 1),
                            child: ClipRect(
                                child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 5.0, sigmaY: 5.0),
                                    child: Image.asset(
                                      'assets/urban/corceltransparent.png',
                                    ))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                FadeInUp(
                  delay: Duration(milliseconds: 500),
                  duration: Duration(seconds: 1),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                        topLeft: Radius.circular(50),
                      ),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(255, 68, 87, 96),
                            Color.fromARGB(255, 0, 30, 48),
                            Color.fromARGB(255, 0, 0, 0)
                          ]),
                    ),
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          delay: Duration(seconds: 1),
                          duration: Duration(seconds: 1),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
                                color: Colors.white),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  label: Text(
                                    'Número de celular',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  //  hintText: 'Correo electronico',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(15),
                                  hintStyle: TextStyle(
                                      color:
                                          Color.fromARGB(221, 190, 190, 190)),
                                  hintText: 'Ej. 0987654321',
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
                        ),
                        FadeIn(
                          delay: Duration(milliseconds: 1300),
                          duration: Duration(seconds: 1),
                          child: Text(
                            'Verificaremos enviando un código de confirmación ',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        FadeInDown(
                            delay: Duration(milliseconds: 1400),
                            duration: Duration(seconds: 1),
                            child: _buttonLogin()),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: ((context) {
                                  return AlertDialog(
                                    title: Text("Términos y Condiciones"),
                                    content: SingleChildScrollView(
                                      child: Text(
                                          'CORCEL DELIVERY \n Cuentas de Usuario. \n Con el fin de usar la mayor parte de las características de los Servicios, usted debe registrarse y mantener activa una cuenta personal de los Servicios como Usuario (“Cuenta”). Para obtener una Cuenta debe tener como mínimo 18 años, o tener la mayoría de edad legal que resulte aplicable conforme a ley. El registro de la cuenta requiere que usted le comunique a CORCEL DELIVERY determinada información personal, como su nombre, dirección, número de teléfono móvil y correo electrónico, así como disponer de la posibilidad de pago en efectivo o tarjeta. Usted se compromete a mantener la información en su Cuenta de forma exacta y completa. Si no mantiene la información de Cuenta, podrá resultar en su imposibilidad para acceder y utilizar los Servicios o en la resolución por parte de CORCEL DELIVERY de estas condiciones celebradas con usted. Usted es responsable de toda la actividad que ocurre en su Cuenta y se compromete a mantener en todo momento de forma segura y secreta el número de contacto de su Cuenta. Usted solo puede poseer una Cuenta. \n Requisitos y conducta. \n El Servicio no está disponible para el uso de personas menores de 18 años y/o menor a la edad legal. Usted no podrá autorizar a terceros a utilizar su Cuenta, asimismo no podrá permitir a personas menores de 18 años y/o menor a la edad legal. que participen en la ejecución de solicitudes de servicios en CORCEL DELIVERY, a menos que aquellos sean acompañados por un adulto, según corresponda. No podrá ceder o transferir de otro modo su Cuenta a cualquier otra persona o entidad. Usted acuerda cumplir con todas las leyes aplicables al utilizar los Servicios y solo podrá utilizar los Servicios con fines legítimos. En el uso de los Servicios, no causará estorbos, molestias, incomodidades o daños a la propiedad de terceros. En algunos casos, se le podrá requerir que facilite un documento de identidad u otro elemento de verificación de identidad para el acceso o uso de los Servicios, y usted acepta que se le podrá denegar el acceso o uso de los Servicios si se niega a facilitar el documento de identidad o el elemento de verificación de identidad. \n Mensajes de texto. \n Al crear una Cuenta, usted acepta que los Servicios le puedan enviar mensajes de texto informativos (SMS), correo electrónico y notificaciones como parte de la actividad comercial normal de su uso de los Servicios. Usted podrá solicitar la no recepción de mensajes de texto informativos (SMS), correo electrónico y notificaciones de CORCEL DELIVERY en cualquier momento enviando un correo electrónico a corceldelivery@gmail.com indicando que no desea recibir más dichos mensajes, junto con el número de teléfono del dispositivo móvil que recibe los mensajes. Usted reconoce que solicitar la no recepción de mensajes de texto informativos (SMS) podrá afectar al uso que usted haga de los Servicios. \n Acceso a la red y dispositivos. \n Usted es responsable de obtener el acceso a la red de datos necesario para utilizar los Servicios. Podrán aplicarse las tarifas y tasas de datos y mensajes de su red móvil si usted accede o utiliza los Servicios desde un dispositivo inalámbrico y usted será responsable de dichas tarifas y tasas. Usted es responsable de adquirir y actualizar el hardware compatible o los dispositivos necesarios para acceder y utilizar los Servicios y Aplicaciones y cualquier actualización de estos. CORCEL DELIVERY no garantiza que los Servicios, o cualquier parte de estos, funcionen en cualquier hardware o dispositivo particular. Además, los Servicios podrán ser objeto de disfunciones o retrasos inherentes al uso de Internet y de las comunicaciones electrónicas. \n Audiovisuales. \n Corcel Delivery puede afirmar la propiedad de cualquier contenido publicado en la plataforma y puede tener derecho de uso de dicho material. Está completamente restringido cualquier tipo de contenido fraudulento, engañoso o sexualmente explícito. \n Para obtener información más detallada, contacte a soporte al correo: corceldelivery@gmail.com "'),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Aceptar',
                                            style: TextStyle(
                                                color: Colors.deepOrange),
                                          ))
                                    ],
                                  );
                                }));
                          },
                          child: Text(
                            'Al iniciar acepta los TÉRMINOS Y CONDICIONES',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonLogin() {
    return !blockButttom
        ? Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
            child: FloatingActionButton.extended(
              backgroundColor: !blockButttom ? Colors.white : Colors.black,
              label: Text(
                'ENVIAR CÓDIGO DE VERIFICACIÓN',
                style: TextStyle(
                    color: blockButttom ? Colors.blue[900] : Colors.black,
                    fontFamily: 'MontserratSemiBold'),
              ),
              focusColor: Color.fromARGB(255, 255, 255, 255),
              onPressed: !blockButttom ? _signInWithMobileNumber : null,
            ),
          )
        : Container(
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
          );
  }
}
