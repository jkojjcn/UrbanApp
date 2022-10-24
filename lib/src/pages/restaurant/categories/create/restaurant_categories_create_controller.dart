import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/categories_provider.dart';
import 'package:jcn_delivery/src/utils/my_snackbar.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';

class RestaurantCategoriesCreateController {
  late BuildContext context;
  late Function refresh;

  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  CategoriesProvider _categoriesProvider = new CategoriesProvider();
  late User user;
  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(GetStorage().read('user'));
    _categoriesProvider.init(context, user);
  }

  void createCategory() async {
    String name = nameController.text;
    String description = descriptionController.text;

    if (name.isEmpty || description.isEmpty) {
      MySnackbar.show(context, 'Debe ingresar todos los campos');
      return;
    }

    Category category = new Category(name: name, description: description);

    ResponseApi responseApi = await _categoriesProvider.create(category);

    MySnackbar.show(context, responseApi.message!);

    if (responseApi.success!) {
      nameController.text = '';
      descriptionController.text = '';
    }
  }
}
