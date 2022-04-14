import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bus_eta/TapPageWidget/lrtDetailPage/lrt_detail_controller.dart';
import 'dart:developer';
import 'package:touchable/touchable.dart';
import 'package:bus_eta/TapPageWidget/lrtDetailPage/lrt_detail_eta.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LRTDetailPage extends StatelessWidget {
  LRTDetailPage({Key? key}) : super(key: key);

  final LRTDetailController lrtDetailController =
      Get.put(LRTDetailController());

  @override
  Widget build(BuildContext context) {
    //Get.arguments
    final PageController pageController =
        PageController(initialPage: Get.arguments is int ? Get.arguments : 0);
    log(Get.locale!.languageCode);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Obx(() => Text(lrtDetailController.title.value)),
      ),
      body: Center(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: PageView(
              reverse: true,
              scrollDirection: Axis.vertical,
              controller: pageController,
              onPageChanged: lrtDetailController.onPageChange,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "lib/resources/LTR/LightRail_TuenMunSouth_" +
                              Get.locale!.languageCode +
                              '.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: CanvasTouchDetector(builder: (context) {
                    return CustomPaint(
                      painter: Zone(context, 0),
                    );
                  }),
                ),
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "lib/resources/LTR/LightRail_TuenMunNorth_" +
                              Get.locale!.languageCode +
                              '.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: CanvasTouchDetector(builder: (context) {
                    return CustomPaint(
                      painter: Zone(context, 1),
                    );
                  }),
                ),
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("lib/resources/LTR/LightRail_LamTei_" +
                          Get.locale!.languageCode +
                          '.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: CanvasTouchDetector(builder: (context) {
                    return CustomPaint(
                      painter: Zone(context, 2),
                    );
                  }),
                ),
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "lib/resources/LTR/LightRail_YuenLong_HungShuiKiu_" +
                              Get.locale!.languageCode +
                              '.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: CanvasTouchDetector(builder: (context) {
                    return CustomPaint(
                      painter: Zone(context, 3),
                    );
                  }),
                ),
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "lib/resources/LTR/LightRail_TinShuiWai_" +
                              Get.locale!.languageCode +
                              '.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: CanvasTouchDetector(builder: (context) {
                    return CustomPaint(
                      painter: Zone(context, 4),
                    );
                  }),
                ),
              ],
            )),
      ),
    ));
  }
}

class Zone extends CustomPainter {
  var stopData = [
    [
      {
        'off_w': 100.0,
        'off_h': 615.0,
        'w': 70.0,
        'h': 40.0,
        'id': "1",
      },
      {
        'off_w': 15.0,
        'off_h': 552.0,
        'w': 60.0,
        'h': 25.0,
        'id': "10",
      },
      {
        'off_w': 140.0,
        'off_h': 552.0,
        'w': 60.0,
        'h': 25.0,
        'id': "240",
      },
      {
        'off_w': 35.0,
        'off_h': 487.0,
        'w': 55.0,
        'h': 25.0,
        'id': "15",
      },
      {
        'off_w': 70.0,
        'off_h': 400.0,
        'w': 90.0,
        'h': 25.0,
        'id': "20",
      },
      {
        'off_w': 217.0,
        'off_h': 410.0,
        'w': 90.0,
        'h': 25.0,
        'id': "250",
      },
      {
        'off_w': 60.0,
        'off_h': 305.0,
        'w': 70.0,
        'h': 25.0,
        'id': "30",
      },
      {
        'off_w': 250.0,
        'off_h': 337.0,
        'w': 55.0,
        'h': 42.0,
        'id': "260",
      },
      {
        'off_w': 350.0,
        'off_h': 365.0,
        'w': 40.0,
        'h': 45.0,
        'id': "920",
      },
      {
        'off_w': 311.0,
        'off_h': 327.0,
        'w': 55.0,
        'h': 25.0,
        'id': "265",
      },
      {
        'off_w': 311.0,
        'off_h': 247.0,
        'w': 55.0,
        'h': 25.0,
        'id': "270",
      },
      {
        'off_w': 275.0,
        'off_h': 277.0,
        'w': 37.0,
        'h': 40.0,
        'id': "275",
      },
      {
        'off_w': 311.0,
        'off_h': 157.0,
        'w': 69.0,
        'h': 25.0,
        'id': "280",
      },
      {
        'off_w': 333.0,
        'off_h': 85.0,
        'w': 40.0,
        'h': 45.0,
        'id': "300",
      },
      {
        'off_w': 268.0,
        'off_h': 95.0,
        'w': 38.0,
        'h': 43.0,
        'id': "295",
      },
      {
        'off_w': 187.0,
        'off_h': 70.0,
        'w': 38.0,
        'h': 43.0,
        'id': "60",
      },
      {
        'off_w': 120.0,
        'off_h': 88.0,
        'w': 55.0,
        'h': 25.0,
        'id': "50",
      },
      {
        'off_w': 95.0,
        'off_h': 167.0,
        'w': 80.0,
        'h': 25.0,
        'id': "40",
      }
    ],
    [
      {
        'off_w': 330.0,
        'off_h': 70.0,
        'w': 55.0,
        'h': 25.0,
        'id': "100",
      },
      {
        'off_w': 250.0,
        'off_h': 80.0,
        'w': 55.0,
        'h': 25.0,
        'id': "110",
      },
      {
        'off_w': 197.0,
        'off_h': 170.0,
        'w': 38.0,
        'h': 45.0,
        'id': "120",
      },
      {
        'off_w': 133.0,
        'off_h': 180.0,
        'w': 38.0,
        'h': 45.0,
        'id': "130",
      },
      {
        'off_w': 77.0,
        'off_h': 160.0,
        'w': 38.0,
        'h': 42.0,
        'id': "140",
      },
      {
        'off_w': 25.0,
        'off_h': 205.0,
        'w': 55.0,
        'h': 25.0,
        'id': "150",
      },
      {
        'off_w': 30.0,
        'off_h': 240.0,
        'w': 38.0,
        'h': 45.0,
        'id': "160",
      },
      {
        'off_w': 70.0,
        'off_h': 329.0,
        'w': 55.0,
        'h': 25.0,
        'id': "170",
      },
      {
        'off_w': 22.0,
        'off_h': 392.0,
        'w': 85.0,
        'h': 25.0,
        'id': "180",
      },
      {
        'off_w': 9.0,
        'off_h': 450.0,
        'w': 85.0,
        'h': 25.0,
        'id': "190",
      },
      {
        'off_w': 105.0,
        'off_h': 440.0,
        'w': 55.0,
        'h': 25.0,
        'id': "200",
      },
      {
        'off_w': 138.0,
        'off_h': 237.0,
        'w': 70.0,
        'h': 40.0,
        'id': "212",
      },
      {
        'off_w': 168.0,
        'off_h': 300.0,
        'w': 70.0,
        'h': 42.0,
        'id': "220",
      },
      {
        'off_w': 240.0,
        'off_h': 307.0,
        'w': 38.0,
        'h': 40.0,
        'id': "230",
      },
      {
        'off_w': 45.0,
        'off_h': 587.0,
        'w': 70.0,
        'h': 25.0,
        'id': "40",
      },
      {
        'off_w': 70.0,
        'off_h': 502.0,
        'w': 55.0,
        'h': 25.0,
        'id': "50",
      },
      {
        'off_w': 135.0,
        'off_h': 492.0,
        'w': 38.0,
        'h': 45.0,
        'id': "60",
      },
      {
        'off_w': 187.0,
        'off_h': 425.0,
        'w': 55.0,
        'h': 25.0,
        'id': "70",
      },
      {
        'off_w': 190.0,
        'off_h': 365.0,
        'w': 70.0,
        'h': 25.0,
        'id': "75",
      },
      {
        'off_w': 248.0,
        'off_h': 270.0,
        'w': 55.0,
        'h': 25.0,
        'id': "80",
      },
      {
        'off_w': 236.0,
        'off_h': 180.0,
        'w': 88.0,
        'h': 35.0,
        'id': "90",
      },
      {
        'off_w': 260.0,
        'off_h': 580.0,
        'w': 70.0,
        'h': 25.0,
        'id': "280",
      },
      {
        'off_w': 208.0,
        'off_h': 515.0,
        'w': 38.0,
        'h': 42.0,
        'id': "295",
      },
      {
        'off_w': 280.0,
        'off_h': 505.0,
        'w': 38.0,
        'h': 45.0,
        'id': "300",
      },
      {
        'off_w': 310.0,
        'off_h': 430.0,
        'w': 70.0,
        'h': 25.0,
        'id': "310",
      },
      {
        'off_w': 320.0,
        'off_h': 365.0,
        'w': 55.0,
        'h': 25.0,
        'id': "320",
      },
      {
        'off_w': 315.0,
        'off_h': 290.0,
        'w': 55.0,
        'h': 25.0,
        'id': "330",
      },
      {
        'off_w': 340.0,
        'off_h': 195.0,
        'w': 55.0,
        'h': 25.0,
        'id': "340",
      }
    ],
    [
      {
        'off_w': 13.0,
        'off_h': 555.0,
        'w': 55.0,
        'h': 25.0,
        'id': "100",
      },
      {
        'off_w': 70.0,
        'off_h': 425.0,
        'w': 55.0,
        'h': 25.0,
        'id': "350",
      },
      {
        'off_w': 190.0,
        'off_h': 250.0,
        'w': 55.0,
        'h': 25.0,
        'id': "360",
      },
      {
        'off_w': 300.0,
        'off_h': 116.0,
        'w': 70.0,
        'h': 25.0,
        'id': "370",
      }
    ],
    [
      {
        'off_w': 50.0,
        'off_h': 428.0,
        'w': 40.0,
        'h': 30.0,
        'id': "380",
      },
      {
        'off_w': 135.0,
        'off_h': 271.0,
        'w': 40.0,
        'h': 30.0,
        'id': "390",
      },
      {
        'off_w': 170.0,
        'off_h': 208.0,
        'w': 30.0,
        'h': 40.0,
        'id': "400",
      },
      {
        'off_w': 125.0,
        'off_h': 138.0,
        'w': 40.0,
        'h': 30.0,
        'id': "425",
      },
      {
        'off_w': 245.0,
        'off_h': 142.0,
        'w': 27.0,
        'h': 40.0,
        'id': "560",
      },
      {
        'off_w': 277.0,
        'off_h': 162.0,
        'w': 27.0,
        'h': 40.0,
        'id': "570",
      },
      {
        'off_w': 307.0,
        'off_h': 142.0,
        'w': 25.0,
        'h': 20.0,
        'id': "580",
      },
      {
        'off_w': 322.0,
        'off_h': 182.0,
        'w': 25.0,
        'h': 20.0,
        'id': "590",
      },
      {
        'off_w': 375.0,
        'off_h': 125.0,
        'w': 20.0,
        'h': 40.0,
        'id': "600",
      }
    ],
    [
      {
        'off_w': 260.0,
        'off_h': 550.0,
        'w': 85.0,
        'h': 25.0,
        'id': "430",
      },
      {
        'off_w': 285.0,
        'off_h': 447.0,
        'w': 60.0,
        'h': 25.0,
        'id': "435",
      },
      {
        'off_w': 165.0,
        'off_h': 507.0,
        'w': 60.0,
        'h': 25.0,
        'id': "445",
      },
      {
        'off_w': 137.0,
        'off_h': 447.0,
        'w': 60.0,
        'h': 25.0,
        'id': "448",
      },
      {
        'off_w': 275.0,
        'off_h': 392.0,
        'w': 60.0,
        'h': 25.0,
        'id': "450",
      },
      {
        'off_w': 260.0,
        'off_h': 320.0,
        'w': 60.0,
        'h': 35.0,
        'id': "455",
      },
      {
        'off_w': 93.0,
        'off_h': 370.0,
        'w': 60.0,
        'h': 25.0,
        'id': "460",
      },
      {
        'off_w': 37.0,
        'off_h': 220.0,
        'w': 60.0,
        'h': 25.0,
        'id': "468",
      },
      {
        'off_w': 48.0,
        'off_h': 153.0,
        'w': 60.0,
        'h': 25.0,
        'id': "480",
      },
      {
        'off_w': 125.0,
        'off_h': 257.0,
        'w': 40.0,
        'h': 45.0,
        'id': "490",
      },
      {
        'off_w': 210.0,
        'off_h': 275.0,
        'w': 60.0,
        'h': 30.0,
        'id': "500",
      },
      {
        'off_w': 185.0,
        'off_h': 200.0,
        'w': 60.0,
        'h': 25.0,
        'id': "510",
      },
      {
        'off_w': 210.0,
        'off_h': 135.0,
        'w': 60.0,
        'h': 25.0,
        'id': "520",
      },
      {
        'off_w': 200.0,
        'off_h': 32.0,
        'w': 100.0,
        'h': 25.0,
        'id': "530",
      },
      {
        'off_w': 122.0,
        'off_h': 24.0,
        'w': 60.0,
        'h': 25.0,
        'id': "540",
      },
      {
        'off_w': 75.0,
        'off_h': 92.0,
        'w': 60.0,
        'h': 25.0,
        'id': "550",
      }
    ]
  ];

  final BuildContext context;
  final int pointer;
  Zone(this.context, this.pointer); // context from CanvasTouchDetector

  @override
  void paint(Canvas canvas, Size size) {
    var myCanvas = TouchyCanvas(context, canvas);

    for (var data in stopData[pointer]) {
      myCanvas.drawRect(
          Offset(data['off_w']! as double, data['off_h']! as double) &
              Size(data['w']! as double, data['h']! as double),
          Paint()..color = Color.fromARGB(0, 255, 255, 255),
          onTapDown: (tapDetail) {
        log("onTapDown");
        log(data['id']! as String);
        Get.to(() => LRTETAPage(), arguments: data['id']);
      });
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
