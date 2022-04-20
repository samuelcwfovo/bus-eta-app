import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'dart:async';

class LRTETAController extends GetxController {
  var ETAData = [].obs;
  var lastUpdateTime = "".obs;
  var timer;

  var sort = true.obs;
  var sortColumnIndex = 0.obs;

  var languageCode = Get.locale!.languageCode == "zh" ? "ch" : "en";

  @override
  onInit() {
    fetchLrtETA();
    timer = Timer.periodic(Duration(seconds: 15), (Timer t) => fetchLrtETA());

    super.onInit();
  }

  @override
  void onClose() {
    log('close');
    timer.cancel();
  }

  void fetchLrtETA() async {
    log(Get.arguments);

    String url =
        "https://rt.data.gov.hk/v1/transport/mtr/lrt/getSchedule?station_id=${Get.arguments}";

    var result = await Dio().get(url);

    log(result.data['platform_list'].toString());

    ETAData.value = result.data['platform_list'];
    lastUpdateTime.value = result.data['system_time'];
  }

  void onSort(columnIndex, ascending, List listdata) {
    sort.value = !sort.value;
    onSortColum(columnIndex, sort.value, listdata);
  }

  void onSortColum(columnIndex, ascending, List listdata) {
    if (columnIndex == 0) {
      if (ascending) {
        listdata.sort((a, b) => a['route_no'].compareTo(b['route_no']));
      } else {
        listdata.sort((a, b) => b['route_no'].compareTo(a['route_no']));
      }
    }
    if (columnIndex == 1) {
      var id = 'dest_' + languageCode;
      if (ascending) {
        listdata.sort((a, b) => a[id].compareTo(b[id]));
      } else {
        listdata.sort((a, b) => b[id].compareTo(a[id]));
      }
    }
    if (columnIndex == 2) {
      if (ascending) {
        listdata.sort((a, b) => a['train_length'].compareTo(b['train_length']));
      } else {
        listdata.sort((a, b) => b['train_length'].compareTo(a['train_length']));
      }
    }
    if (columnIndex == 3) {
      var id = 'time_' + languageCode;
      if (ascending) {
        listdata.sort((a, b) =>
            int.parse(a[id].replaceAll(RegExp('[^0-9]'), ''))
                .compareTo(int.parse(b[id].replaceAll(RegExp('[^0-9]'), ''))));
      } else {
        listdata.sort((a, b) =>
            int.parse(b[id].replaceAll(RegExp('[^0-9]'), ''))
                .compareTo(int.parse(a[id].replaceAll(RegExp('[^0-9]'), ''))));
      }
    }
    ETAData.refresh();
  }
}
