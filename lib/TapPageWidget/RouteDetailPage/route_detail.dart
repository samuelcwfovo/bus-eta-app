import 'dart:developer';

import 'package:bus_eta/TapPageWidget/RouteDetailPage/route_detail_controller.dart';
import 'package:bus_eta/main_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:collection/collection.dart';

class RouteDeatailPage extends StatelessWidget {
  RouteDeatailPage({Key? key}) : super(key: key);

  final RouteDetailController detailController =
      Get.put(RouteDetailController());

  final MainController mainController = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    log('build ' + Get.arguments.toString());
    var routeData = mainController.DB['routeList'][Get.arguments];

    if (Get.arguments != null) {
      detailController.setRouteData(Get.arguments);
    } else {
      return const SizedBox.shrink();
    }

    return WillPopScope(
      onWillPop: detailController.onDetailPagePop,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                ),
                onPressed: () {
                  // do something
                },
              )
            ],
            title: Column(
              children: [
                Text(routeData['route'].toString()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'to'.tr,
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(routeData['dest'][Get.locale!.languageCode],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                        )),
                  ],
                ),
              ],
            ),
            backgroundColor: Colors.black45,
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarBrightness: Brightness.light),
          ),
          body: SizedBox.expand(
            child: Column(
              children: [
                Container(
                    height: context.height * 0.4,
                    child: Obx(
                      () => GoogleMap(
                        initialCameraPosition: const CameraPosition(
                            target: LatLng(22.327157, 114.122836), zoom: 10.5),
                        markers: detailController.finalMarkers.value,
                        polylines: detailController.polyLines.value,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        trafficEnabled: false,
                        onMapCreated: (GoogleMapController controller) =>
                            detailController.onMapCreated(controller, context),
                        onCameraMove:
                            detailController.clusterManager.value!.onCameraMove,
                        onCameraIdle:
                            detailController.clusterManager.value!.updateMap,
                      ),
                    )),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: ExpansionPanelList.radio(
                        key: UniqueKey(),
                        expandedHeaderPadding: EdgeInsets.zero,
                        animationDuration: const Duration(milliseconds: 300),
                        expansionCallback: detailController.onExpansionChanged,
                        elevation: 0,
                        dividerColor: Colors.grey[850],
                        children: (detailController.getRouteStopList())
                            .mapIndexed<ExpansionPanelRadio>((index, stopID) {
                          return ExpansionPanelRadio(
                              canTapOnHeader: true,
                              backgroundColor: Colors.grey[850],
                              value: index,
                              headerBuilder:
                                  (BuildContext context, bool isExpanded) {
                                return ListTile(
                                  title: Text(
                                      "${index + 1}. ${mainController.DB.value['stopList'][stopID]['name'][Get.locale!.languageCode]}"),
                                  subtitle: (routeData['fares'] != null &&
                                          index <
                                              (routeData['fares'] as List)
                                                  .length)
                                      ? Text(
                                          "${'fare'.tr}: \$${routeData['fares'][index].toString()}")
                                      : null,
                                );
                              },
                              body: Container(
                                padding: const EdgeInsets.only(
                                    left: 20, top: 10, bottom: 10),
                                color: Colors.grey[800],
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Obx(() => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: detailController
                                                            .etaList
                                                            .value[index] ==
                                                        null
                                                    ? [Text("loadingETA".tr)]
                                                    : [
                                                        Text(
                                                            "${detailController.getETATime(detailController.etaList.value[index], 0)} ${detailController.getDistance(index, 0)}"),
                                                        Text(
                                                            "${detailController.getETATime(detailController.etaList.value[index], 1)} ${detailController.getDistance(index, 1)}"),
                                                        Text(
                                                            "${detailController.getETATime(detailController.etaList.value[index], 2)} ${detailController.getDistance(index, 2)}"),
                                                      ],
                                              ),
                                              detailController
                                                          .getRouteStopList()
                                                          .length ==
                                                      index + 1
                                                  ? Container() // show null item
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: detailController
                                                                          .durationData
                                                                          .value[
                                                                      index] ==
                                                                  null
                                                              ? [
                                                                  Text(
                                                                      "loadingDuration"
                                                                          .tr)
                                                                ]
                                                              : [
                                                                  Text(
                                                                      "${"nextStopDistance".tr} : ${detailController.durationData.value[index]['distance']['text'].toString()}"),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                          "${'estimatedTraveltime'.tr} : ${detailController.durationData.value[index]['duration_in_traffic']['text'].toString()}"),
                                                                      detailController.durationData.value[index]['duration_in_traffic']['value'] - detailController.durationData.value[index]['duration']['value'] >
                                                                              60
                                                                          ? Text(
                                                                              "  (${'normalTraveltime'.tr} : ${detailController.durationData.value[index]['duration']['text'].toString()})")
                                                                          : Container()
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                      "${'trafficCondition'.tr} : ${detailController.getRouteTrafficStatus(detailController.durationData.value[index])}")
                                                                ]),
                                                    ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    padding: EdgeInsets.zero,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    iconSize: 20,
                                                    icon: Obx(() => Icon(
                                                          mainController
                                                                  .favouriteStopList
                                                                  .value
                                                                  .any((element) =>
                                                                      element.routeKey ==
                                                                          Get
                                                                              .arguments &&
                                                                      element.stopID ==
                                                                          stopID)
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          color: Colors.red,
                                                        )),
                                                    onPressed: () {
                                                      detailController
                                                          .onFavouriteListClick(
                                                              Get.arguments,
                                                              stopID,
                                                              index);
                                                    },
                                                  ),
                                                  IconButton(
                                                    padding: EdgeInsets.zero,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    iconSize: 20,
                                                    icon: const Icon(
                                                      Icons.access_time,
                                                      color: Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      // do something
                                                    },
                                                  )
                                                ],
                                              )
                                            ]))),
                              ));
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
