import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/categories_provider.dart';
import 'package:jcn_delivery/src/provider/products_provider.dart';
import 'package:jcn_delivery/src/utils/my_snackbar.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:image_picker/image_picker.dart';

class RestaurantProductsCreateController {
  late BuildContext context;
  late Function refresh;

  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController establecimientoController = new TextEditingController();
  MoneyMaskedTextController priceController = new MoneyMaskedTextController();

  CategoriesProvider _categoriesProvider = new CategoriesProvider();
  ProductsProvider _productsProvider = new ProductsProvider();

  late User user;
  List<Category> categories = [];
  late String idCategory;

  // IMAGENES
  PickedFile? pickedFile;
  File? imageFile1;
  File? imageFile2;
  File? imageFile3;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    user = User.fromJson(GetStorage().read('user'));
    _categoriesProvider.init(context, user);
    _productsProvider.init(context, user);
    getCategories({});
  }

  void getCategories(restaurantId) async {
    categories = await _categoriesProvider.getAll(restaurantId);
    refresh();
  }

  void createProduct() async {
    String name = nameController.text;
    String description = descriptionController.text;
    String establecimiento = establecimientoController.text;
    double price = priceController.numberValue;

    if (name.isEmpty ||
        description.isEmpty ||
        price == 0 ||
        establecimiento.isEmpty) {
      MySnackbar.show(context, 'Debe ingresar todos los campos');
      return;
    }

    if (imageFile1 == null) {
      MySnackbar.show(context, 'Selecciona las tres imagenes');
      return;
    }

    Product product = new Product(
        name: name,
        description: description,
        price: price,
        idCategory: int.parse(idCategory));

    List<File> images = [];
    images.add(imageFile1!);
    images.add(imageFile2!);
    images.add(imageFile3!);

    print('Formulario Producto: ${product.toJson()}');
  }

  void resetValues() {
    nameController.text = '';
    descriptionController.text = '';
    establecimientoController.text = '';
    priceController.text = '0.0';
    // imageFile1 = null;
    // imageFile2 = null;
    // imageFile3 = null;
    // idCategory = null;
    refresh();
  }

  Future selectImage(ImageSource? imageSource, int numberFile) async {
    // ignore: deprecated_member_use
    pickedFile = await ImagePicker().getImage(source: imageSource!);
    if (pickedFile != null) {
      if (numberFile == 1) {
        imageFile1 = File(pickedFile!.path);
      } else if (numberFile == 2) {
        //    imageFile2 = File(pickedFile.path);
      } else if (numberFile == 3) {
        //    imageFile3 = File(pickedFile.path);
      }
    }
    Navigator.pop(context);
    refresh();
  }

  void showAlertDialog(int numberFile) {
    Widget galleryButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.gallery, numberFile);
        },
        child: Text('GALERIA'));

    Widget cameraButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.camera, numberFile);
        },
        child: Text('CAMARA'));

    AlertDialog alertDialog = AlertDialog(
      title: Text('Selecciona tu imagen'),
      actions: [galleryButton, cameraButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }
}
