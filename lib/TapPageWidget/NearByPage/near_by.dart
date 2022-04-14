import 'package:bus_eta/TapPageWidget/NearByPage/near_by_controller.dart';
import 'package:bus_eta/TapPageWidget/RouteDetailPage/route_detail.dart';
import 'package:bus_eta/main_controller.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NearBy extends StatelessWidget {
  NearBy({Key? key}) : super(key: key);

  final NearByController nearByController = Get.put(NearByController());
  final MainController mainController = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => RefreshIndicator(
          onRefresh: () async => nearByController.fetchStopEta(),
          child: ListView.builder(
            itemCount: nearByController.nearByStops.value.length,
            itemBuilder: (context, index) {
              var routeId =
                  nearByController.nearByStops.value[index]['routeId'];
              var stop = nearByController.nearByStops.value[index]['stop'];

              return GestureDetector(
                onTap: () => Get.to(RouteDeatailPage(), arguments: routeId),
                child: Container(
                  height: 95,
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 0, left: 15, right: 10),
                  margin: EdgeInsets.only(
                      bottom:
                          index == nearByController.nearByStops.value.length - 1
                              ? 25
                              : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 65,
                            child: Text(
                              mainController.DB['routeList'][routeId]['route'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Text(
                                        'to'.tr,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        mainController.DB['routeList'][routeId]
                                            ['dest'][Get.locale!.languageCode],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Text(
                                        'from'.tr,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        mainController.DB['routeList'][routeId]
                                            ['orig'][Get.locale!.languageCode],
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white60),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          stop.name[Get.locale!.languageCode],
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70),
                                        ),
                                      ),
                                      Text(
                                        " - " +
                                            nearByController
                                                .getStopDistanceString(stop),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                                // Text(routeId)
                              ],
                            ),
                          ),
                        ],
                      ),
                      Obx(() => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(nearByController.getRouteEta(
                                  nearByController.nearByStopEta.value[index],
                                  0)),
                              Text(nearByController.getRouteEta(
                                  nearByController.nearByStopEta.value[index],
                                  1)),
                            ],
                          ))
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
