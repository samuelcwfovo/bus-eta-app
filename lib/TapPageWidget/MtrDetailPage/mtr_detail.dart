import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bus_eta/TapPageWidget/MtrDetailPage/mtr_detail_controller.dart';
import 'package:bus_eta/TapPageWidget/MtrPage/mtr_controller.dart';

import 'dart:developer';

class MTRDetailPage extends StatelessWidget {
  MTRDetailPage({Key? key}) : super(key: key);

  final MTRDetailController mtrDetailController =
      Get.put(MTRDetailController());

  final MTRController mtrController = Get.find<MTRController>();

  List<Widget> _loadingDraw() {
    return [
      CircularProgressIndicator(
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation(Colors.blue),
      ),
    ];
  }

  List<Widget> _ETADraw(etaData, dir, stopCode) {
    var eta = [];

    if (etaData[dir] == null) {
      return [const Text('沒有預計到達時間')];
    }

    etaData[dir].forEach((element) {
      eta.add(Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 80,
                child: Text(mtrDetailController.getStopNameByCode(
                    Get.arguments[1], element['dest'])),
              ),
              SizedBox(
                width: 50,
                child: Text(element['plat']),
              ),
              SizedBox(
                  width: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Text(element['ttnt']), const Text('分鐘')],
                  ))
            ],
          )));
    });

    var extraData =
        mtrDetailController.getConnectedStop(Get.arguments[1], stopCode);

    var extraETA = [];
    if (extraData.isNotEmpty) {
      extraETA.add(Container(
          padding: const EdgeInsets.only(top: 25, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(mtrController.getLineNameByLineCode(extraData[0])),
              // +" -- " +
              //     mtrDetailController.getStopNameByCode(
              //         extraData[0], stopCode)),
            ],
          )));

      extraETA.add(
        Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("目的地"),
                Text('月台'),
                Text('下一班車'),
              ],
            )),
      );

      if (mtrDetailController.ETAData[extraData[0]] == null ||
          mtrDetailController.ETAData[extraData[0]][stopCode] == null) {
        extraETA.add(Text("loadingETA".tr));
      } else {
        var data = mtrDetailController.ETAData[extraData[0]][stopCode];
        // log('data ' + data.toString());
        // log('data down' + data["DOWN"].toString());

        data["UP"].forEach((e) {
          // log("e " + e.toString());

          extraETA.add(Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(mtrDetailController.getStopNameByCode(
                        extraData[0], e['dest'])),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(e['plat']),
                  ),
                  SizedBox(
                      width: 55,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Text(e['ttnt']), const Text('分鐘')],
                      ))
                ],
              )));
        });

        if (data["DOWN"] != null) {
          data["DOWN"].forEach((e) {
            extraETA.add(Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(mtrDetailController.getStopNameByCode(
                          extraData[0], e['dest'])),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(e['plat']),
                    ),
                    SizedBox(
                        width: 55,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text(e['ttnt']), const Text('分鐘')],
                        ))
                  ],
                )));
          });
        }
      }
    }
    return [
      Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("目的地"),
              Text('月台'),
              Text('下一班車'),
            ],
          )),
      ...eta,
      ...extraETA
    ];
  }

  @override
  Widget build(BuildContext context) {
    log('build ' + Get.arguments.toString());
    log(mtrDetailController.mtrStops[Get.arguments[1]]!.first['zh'].toString());
    return SafeArea(
        child: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(Get.arguments[0]),
          bottom: TabBar(tabs: [
            Tab(
                text: "往" +
                    mtrDetailController
                        .mtrStops[Get.arguments[1]]!.first['zh']!),
            Tab(
                text: "往" +
                    mtrDetailController.mtrStops[Get.arguments[1]]!.last['zh']!)
          ]),
        ),
        body: TabBarView(children: [
          SingleChildScrollView(
            child: Container(
                child: ExpansionPanelList.radio(
              key: UniqueKey(),
              expandedHeaderPadding: EdgeInsets.zero,
              animationDuration: const Duration(milliseconds: 300),
              expansionCallback: (index, isExpanded) =>
                  mtrDetailController.onExpansionChanged(
                      index, isExpanded, Get.arguments[1], true),
              elevation: 0,
              dividerColor: Colors.grey[850],
              children: mtrDetailController.mtrStops[Get.arguments[1]]!.reversed
                  .map((e) => ExpansionPanelRadio(
                      canTapOnHeader: true,
                      value: e['code']!,
                      backgroundColor: Colors.grey[850],
                      headerBuilder: (BuildContext context, bool isExpanded) =>
                          ListTile(
                            title: Text(e['zh']!),
                          ),
                      body: Container(
                          padding: const EdgeInsets.only(
                              left: 20, top: 10, bottom: 10, right: 20),
                          child: Obx(() => Column(
                              children: mtrDetailController
                                              .ETAData[Get.arguments[1]] ==
                                          null ||
                                      mtrDetailController
                                                  .ETAData[Get.arguments[1]]
                                              [e['code']] ==
                                          null
                                  ? [Text("loadingETA".tr)]
                                  : _ETADraw(
                                      mtrDetailController
                                          .ETAData[Get.arguments[1]][e['code']],
                                      "UP",
                                      e['code'])
                              // : _ETADraw(e['code']!, "UP"),
                              )))))
                  .toList(),
            )),
          ),
          SingleChildScrollView(
            child: Container(
                child: ExpansionPanelList.radio(
              key: UniqueKey(),
              expandedHeaderPadding: EdgeInsets.zero,
              animationDuration: const Duration(milliseconds: 300),
              expansionCallback: (index, isExpanded) =>
                  mtrDetailController.onExpansionChanged(
                      index, isExpanded, Get.arguments[1], false),
              elevation: 0,
              dividerColor: Colors.grey[850],
              children: mtrDetailController.mtrStops[Get.arguments[1]]!
                  .map((e) => ExpansionPanelRadio(
                      canTapOnHeader: true,
                      value: e['code']!,
                      backgroundColor: Colors.grey[850],
                      headerBuilder: (BuildContext context, bool isExpanded) =>
                          ListTile(
                            title: Text(e['zh']!),
                          ),
                      body: Container(
                          padding: const EdgeInsets.only(
                              left: 20, top: 10, bottom: 10, right: 20),
                          child: Obx(() => Column(
                              children: mtrDetailController
                                              .ETAData[Get.arguments[1]] ==
                                          null ||
                                      mtrDetailController
                                                  .ETAData[Get.arguments[1]]
                                              [e['code']] ==
                                          null
                                  ? [Text("loadingETA".tr)]
                                  : _ETADraw(
                                      mtrDetailController
                                          .ETAData[Get.arguments[1]][e['code']],
                                      "DOWN",
                                      e['code'],
                                    )
                              // : _ETADraw(e['code']!, "UP"),
                              )))))
                  .toList(),
            )),
          ),
        ]),
      ),
    ));
  }
}
