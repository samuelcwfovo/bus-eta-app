import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:developer';

class LRTDetailController extends GetxController {
  var title = "".obs;
  var LTRZoneList = [
    {
      'zone': {'zh': "屯門南", 'en': "Tuen Mun South"}
    },
    {
      'zone': {'zh': "屯門北", 'en': "Tuen Mun North"}
    },
    {
      'zone': {'zh': "藍地", 'en': "Lam Tei"}
    },
    {
      'zone': {'zh': "元朗及洪水橋", 'en': "Yuen Long & Hung Shui Kiu"}
    },
    {
      'zone': {'zh': "天水圍", 'en': "Tin Shui Wai"}
    },
  ];

  var ltrStopData = {};

  @override
  onInit() {
    onPageChange(Get.arguments);
    loadStop();
    super.onInit();
  }

  void loadStop() async {
    ltrStopData = json
        .decode(await rootBundle.loadString(('lib/resources/ltr_data.json')));
  }

  String getStopNameByID(id) {
    return ltrStopData[id]['zh'];
  }

  void onPageChange(index) {
    title.value = LTRZoneList[index]['zone']![Get.locale!.languageCode]! + "";
  }
}
