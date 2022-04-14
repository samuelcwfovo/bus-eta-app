import 'package:bus_eta/TapPageWidget/MtrPage/mtr_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bus_eta/TapPageWidget/MtrDetailPage/mtr_detail.dart';
import 'dart:developer';

import 'package:bus_eta/TapPageWidget/lrtDetailPage/lrt_detail.dart';
import 'package:touchable/touchable.dart';

class MTR extends StatelessWidget {
  MTR({Key? key}) : super(key: key);

  final MTRController mtrController = Get.put(MTRController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TabBar(
              tabs: [
                Tab(text: 'mtr'.tr),
                Tab(text: 'lrt'.tr),
              ],
              controller: mtrController.tabController,
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: mtrController.tabController,
        children: [MTRTAB(), LRTTAB()],
      ),
    );
  }
}

class MTRTAB extends StatelessWidget {
  MTRTAB({Key? key}) : super(key: key);

  final MTRController mtrController = Get.find<MTRController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                "ETAprovide".tr,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            ...mtrController.MTRETAList.map((dynamic e) => ListTile(
                  leading: Material(
                    color: Colors.white,
                    shape: const CircleBorder(
                        side: BorderSide(color: Colors.white)),
                    child: Icon(Icons.train, color: e['color'] as Color),
                  ),
                  title: Text(e['name'][Get.locale!.languageCode] as String),
                  trailing:
                      Icon(Icons.circle, color: e['status_color'] as Color),
                  onTap: () => Get.to(MTRDetailPage(), arguments: [
                    e['name'][Get.locale!.languageCode],
                    e['line_code']
                  ]),
                )),
            ...[
              Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "noETAprovide".tr,
                    style: Theme.of(context).textTheme.caption,
                  ))
            ],
            ...mtrController.MTRNoETAList.map((dynamic e) => ListTile(
                  leading: Material(
                    color: Colors.white,
                    shape: const CircleBorder(
                        side: BorderSide(color: Colors.white)),
                    child: Icon(Icons.train, color: e['color'] as Color),
                  ),
                  title: Text(e['name'][Get.locale!.languageCode] as String),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: mtrController.MTRTimeTable.value[e['line_code']]!
                        .map((element) {
                      log("element" + element.toString());
                      if (element['freq'] == null) {
                        return Container();
                      }
                      return Container(
                        padding: EdgeInsets.only(top: 10, bottom: 5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                element['title'],
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
                              ),
                              Text(
                                "currentTrain".tr + element['freq'],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                              ...(element['remarks'] as List).isNotEmpty
                                  ? [
                                      Text(
                                        "備註:",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: (element['remarks'] as List)
                                            .map((remark) => Text(
                                                remark[0] + ": " + remark[1],
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)))
                                            .toList(),
                                      ),
                                    ]
                                  : [],
                            ]),
                      );
                    }).toList(),
                  ),
                  trailing:
                      Icon(Icons.circle, color: e['status_color'] as Color),
                )),
            ...[Padding(padding: EdgeInsets.only(bottom: 30))]
          ],
        ));
  }
}

class LRTTAB extends StatelessWidget {
  LRTTAB({Key? key}) : super(key: key);

  final MTRController mtrController = Get.find<MTRController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/resources/LTR/LightRail_Cover_" +
                  Get.locale!.languageCode +
                  ".png"),
              fit: BoxFit.fill)),
      child: CanvasTouchDetector(
        builder: (context) {
          return CustomPaint(
            painter: LRTPaint(context),
          );
        },
      ),
    );
  }
}

class LRTPaint extends CustomPainter {
  var paintData = [
    {
      'off_w': 15.0,
      'off_h': 460.0,
      'w': 85.0,
      'h': 105.0,
      'id': 0,
    },
    {
      'off_w': 49.0,
      'off_h': 360.0,
      'w': 74.0,
      'h': 97.0,
      'id': 1,
    },
    {
      'off_w': 100.0,
      'off_h': 250.0,
      'w': 90.0,
      'h': 105.0,
      'id': 2,
    },
    {
      'off_w': 170.0,
      'off_h': 167.0,
      'w': 210.0,
      'h': 80.0,
      'id': 3,
    },
    {
      'off_w': 170.0,
      'off_h': 25.0,
      'w': 100.0,
      'h': 137.0,
      'id': 4,
    },
  ];

  final BuildContext context;
  LRTPaint(this.context); // context from CanvasTouchDetector

  @override
  void paint(Canvas canvas, Size size) {
    var myCanvas = TouchyCanvas(context, canvas);
    for (var data in paintData) {
      myCanvas.drawRect(
          Offset(data['off_w']! as double, data['off_h']! as double) &
              Size(data['w']! as double, data['h']! as double),
          Paint()..color = Color.fromARGB(0, 255, 255, 255),
          onTapDown: (tapDetail) {
        // log(data['id']! as String);
        Get.to(() => LRTDetailPage(), arguments: data['id']);
      });
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
