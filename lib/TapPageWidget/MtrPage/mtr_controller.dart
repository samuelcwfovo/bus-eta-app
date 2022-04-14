import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:xml/xml.dart' hide parse;

import 'package:bus_eta/main_controller.dart';

import 'package:html/dom.dart' as dom;
// import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';

class MTRController extends GetxController with SingleGetTickerProviderMixin {
  var MTRETAList = [
    {
      'name': {'zh': "機場快綫", 'en': "Airport Express"},
      'line_code': 'AEL',
      'status_color': Colors.green,
      'color': Color(int.parse("1c7670", radix: 16) | 0xFF000000)
    },
    {
      'name': {'zh': "東涌綫", 'en': "Tung Chung Line"},
      'line_code': 'TCL',
      'status_color': Colors.green,
      'color': Color(int.parse("fe7f1d", radix: 16) | 0xFF000000)
    },
    {
      'name': {'zh': "屯馬綫", 'en': "Tuen Ma Line"},
      'line_code': 'TML',
      'status_color': Colors.green,
      'color': Color(int.parse("9a3b26", radix: 16) | 0xFF000000)
    },
    {
      'name': {'zh': "將軍澳綫", 'en': "Tseung Kwan O Line"},
      'line_code': 'TKL',
      'status_color': Colors.green,
      'color': Color(int.parse("6b208b", radix: 16) | 0xFF000000)
    },
  ].obs;

  var MTRNoETAList = [
    {
      'name': {'zh': "迪士尼綫", 'en': "Disneyland Resort Line"},
      'line_code': 'DRL',
      'status_color': Colors.green,
      'color': Color(int.parse("f550a6", radix: 16) | 0xFF000000)
    },
    {
      'name': {'zh': "東鐵綫", 'en': "East Rail Line"},
      'line_code': 'EAL',
      'status_color': Colors.green,
      'color': Color(int.parse("5eb6e4", radix: 16) | 0xFF000000)
    },
    {
      'name': {'zh': "港島綫", 'en': "Island Line"},
      'line_code': 'ISL',
      'status_color': Colors.green,
      'color': Color(int.parse("0860a8", radix: 16) | 0xFF000000)
    },
    {
      'name': {'zh': "觀塘綫", 'en': "Kwun Tong Line"},
      'line_code': 'KTL',
      'status_color': Colors.green,
      'color': Color(int.parse("1a9437", radix: 16) | 0xFF000000)
    },
    {
      'name': {'zh': "南港島綫", 'en': "South Island Line"},
      'line_code': 'SIL',
      'status_color': Colors.green,
      'color': Color(int.parse("b5bd00", radix: 16) | 0xFF000000)
    },
    {
      'name': {'zh': "荃灣綫", 'en': "Tsuen Wan Line"},
      'line_code': 'TWL',
      'status_color': Colors.green,
      'color': Color(int.parse("ff0000", radix: 16) | 0xFF000000)
    },
  ].obs;

  var tabController;

  var MTRTimeTable = {
    'DRL': [],
    'EAL': [],
    'ISL': [],
    'KTL': [],
    'SIL': [],
    'TWL': [],
  }.obs;

  final MainController mainController = Get.find<MainController>();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);
    fetchStatus();
    fetchMTRtimeTable();

    mainController.onLanuageChangeStream.stream.listen((_) {
      fetchMTRtimeTable();
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  String getLineNameByLineCode(code) {
    dynamic e =
        MTRETAList.firstWhere((element) => element['line_code'] == code);

    if (e.isNotEmpty) {
      return e['name'][Get.locale!.languageCode] as String;
    }

    return "";
  }

  void fetchStatus() {
    Dio()
        .get("https://www.mtr.com.hk/alert/ryg_line_status.xml")
        .then((res) => res.data)
        .then((xml) {
      var doc = XmlDocument.parse(xml);

      doc.findAllElements('line').forEach((node) {
        var lineCode = node.findElements('line_code').single.text;
        var status = node.findElements('status').single.text;

        for (var element in [...MTRETAList, ...MTRNoETAList]) {
          if (element['line_code'] == lineCode) {
            element['status_color'] = status == 'red'
                ? Colors.red
                : status == 'yellow'
                    ? Colors.yellow
                    : status == 'grey'
                        ? Colors.grey
                        : Colors.green;
          }
        }

        MTRETAList.refresh();
        MTRNoETAList.refresh();
      });
    });
  }

  bool isValidTimeRange(startHour, startMin, endHour, endMin) {
    TimeOfDay now = TimeOfDay.now();

    return ((now.hour > startHour) ||
            (now.hour == startHour && now.minute >= startMin)) &&
        ((now.hour < endHour) || (now.hour == endHour && now.minute <= endMin));
  }

  void fetchMTRtimeTable() async {
    var result = await Dio().get(
        "https://checkfare.swiftzer.net/wp/TPHotm-${Get.locale!.languageCode}");
    var document = parse(result.data);

    MTRTimeTable.value = {
      'DRL': [],
      'EAL': [],
      'ISL': [],
      'KTL': [],
      'SIL': [],
      'TWL': [],
    };

    for (var k in MTRTimeTable.keys) {
      var linePage = document.getElementById("_page_" + k);

      var lineTable = linePage!.querySelectorAll('dl.headway');

      var directionTitles = linePage.querySelectorAll('h3');

      var weekDays = linePage.querySelectorAll('h4');
      var direction1;
      var direction2;
      var weekDay;

      if (DateTime.now().weekday == 7 || DateTime.now().weekday == 6) {
        direction1 = lineTable[1];
        direction2 = lineTable[3];
        weekDay = weekDays[1];
      } else {
        direction1 = lineTable[0];
        direction2 = lineTable[2];
        weekDay = weekDays[0];
      }

      MTRTimeTable[k]!.add({
        'title': "${directionTitles[0].text}  -  ${weekDay.text}",
        'remarks': []
      });
      MTRTimeTable[k]!.add({
        'title': "${directionTitles[1].text}  -  ${weekDay.text}",
        'remarks': []
      });

      var loopCount = 0;
      for (var element in [direction1, direction2]) {
        for (var i = 0; i + 2 < element.children.length; i += 2) {
          var timeStart = element.children[i].text.split(':');
          var timeEnd = element.children[i + 2].text.split(':');
          dom.Element text = element.children[i + 1];
          var remarks = [];

          TimeOfDay now = TimeOfDay.now();

          log("isValidTimeRange " +
              "now ${now.hour}:${now.minute} " +
              " startHour " +
              int.parse(timeStart[0]).toString() +
              " startMin " +
              int.parse(timeStart[1]).toString() +
              " endHour " +
              int.parse(timeEnd[0]).toString() +
              " endMin " +
              int.parse(timeEnd[1]).toString() +
              " " +
              isValidTimeRange(int.parse(timeStart[0]), int.parse(timeStart[1]),
                      int.parse(timeEnd[0]), int.parse(timeEnd[1]))
                  .toString());
          if (isValidTimeRange(int.parse(timeStart[0]), int.parse(timeStart[1]),
              int.parse(timeEnd[0]), int.parse(timeEnd[1]))) {
            //remarks
            if (text.children.length > 1) {
              var remarksElement = text.children[1];

              var plusList =
                  remarksElement.getElementsByClassName('icon-plus-2');
              if (plusList.isNotEmpty) {
                var stops = "";
                var isbusy = false;
                for (var plusE in plusList) {
                  for (var plusChild in plusE.children) {
                    if (plusChild.className == "icon-info") {
                      isbusy = true;
                    } else {
                      stops += plusChild.text + " ";
                    }
                  }
                }
                var topic = isbusy ? "[繁忙時間]部分列車由此站開始載客" : "部分列車由此站開始載客";
                remarks.add([topic, stops]);
              }

              var minusList =
                  remarksElement.getElementsByClassName('icon-minus-2');
              if (minusList.isNotEmpty) {
                var stops = "";
                var isbusy = false;

                for (var minusE in minusList) {
                  for (dom.Element minusChild in minusE.children) {
                    if (minusChild.className == "icon-info") {
                      isbusy = true;
                    } else {
                      log(minusChild.children.toString());
                      if (minusChild.children.isEmpty) {
                        stops += minusChild.text + " ";
                      }
                    }
                  }
                }
                var topic = isbusy ? "[繁忙時間]部分列車於此站停止服務" : "部分列車於此站停止服務";

                remarks.add([topic, stops]);
              }

              var shiftText = "隔班開出";
              if (remarksElement.children.length >= 3) {
                if (remarksElement.text.contains(shiftText)) {
                  remarks.add([
                    "列車由此站隔班開出",
                    remarksElement.children[0].text +
                        " " +
                        remarksElement.children[1].text
                  ]);
                }
              }
            }

            MTRTimeTable[k]![loopCount]['freq'] = text.children[0].text;
            if (MTRTimeTable[k]![loopCount]['freq'] == Null) {
              log("null");
            }
            log("MTRTimeTable[k]![loopCount]['freq']" +
                MTRTimeTable[k]![loopCount]['freq']);
            MTRTimeTable[k]![loopCount]['remarks'] = remarks;
          }
        }

        loopCount += 1;
      }
    }
    log("MTRTimeTable" + MTRTimeTable.toString());
    MTRTimeTable.refresh();
  }
}
