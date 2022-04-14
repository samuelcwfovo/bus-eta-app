import 'dart:developer';
import 'package:bus_eta/localization_service.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log(Get.locale!.toLanguageTag());
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "language".tr + ":",
            style: TextStyle(fontSize: 18),
          ),
          DropdownButton(
            value: Get.locale!.toLanguageTag() == "zh-HK" ? "繁體中文" : "English",
            underline: Container(
              height: 2,
              color: Colors.grey[500],
            ),
            onChanged: (String? value) {
              LocalizationService.changeLocale(value!);
            },
            items: const [
              DropdownMenuItem(
                value: "繁體中文",
                child: Text("繁體中文"),
              ),
              DropdownMenuItem(
                value: "English",
                child: Text("English"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
