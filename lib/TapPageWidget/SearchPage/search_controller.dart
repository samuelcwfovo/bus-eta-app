import 'dart:developer';

import 'package:bus_eta/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  final MainController mainController = Get.find<MainController>();

  var displayRoutes = [].obs;
  var searchWords = "".obs;

  @override
  void onInit() {
    loadRouteToList();
    log(Get.locale!.languageCode);
    super.onInit();
  }

  void loadRouteToList() {
    if (!mainController.loadingDB.value) {
      displayRoutes.value = [];
      mainController.DB.value['routeList'].forEach((key, value) {
        if (value['route'].toLowerCase().contains(searchWords.toLowerCase())) {
          value['key'] = key;
          displayRoutes.value.add(value);
        }
      });
      displayRoutes.refresh();
    }
  }

  void onInput(str) {
    searchWords.value = str;
    loadRouteToList();
  }

  String getCompanyName(List co) {
    var x = {
      'gmb': {'zh': "九巴", 'en': "KMB"}, // data crash
      'kmb': {'zh': "九巴", 'en': "KMB"},
      'ctb': {'zh': "城巴", 'en': "CTB"},
      'nwfb': {'zh': "新巴", 'en': "NWFB"},
      'nlb': {'zh': "嶼巴", 'en': "NLB"},
      'lrtfeeder': {'zh': "港鐵巴士", 'en': "MTR Bus"}
    };

    if (co.length > 1) {
      return "${x[co[0]]![Get.locale!.languageCode]} + ${x[co[1]]![Get.locale!.languageCode]}";
    }
    return x[co[0]]![Get.locale!.languageCode]!;
  }

  bool isSpecialRoute(dynamic serviceType) {
    if (serviceType is int) {
      return serviceType > 1;
    }

    return int.parse(serviceType) > 1;
  }
}
