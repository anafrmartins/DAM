import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogHelper {
  static void showLoading() {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: 8,
              ),
              Text(
                'Bom dia como estao??',
                style: Get.textTheme.headline6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen!) {}
    Get.back();
  }
}
