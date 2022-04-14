import 'dart:async';

import 'package:get/get.dart';
import 'dart:developer';
import 'package:bus_eta/main_controller.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:bus_eta/util/get_eta.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:collection/collection.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();
}

class BookmarkController extends GetxController {
  var contents = <DragAndDropList>[].obs;
  late BuildContext buildContext;
  var nearByStopEta = <String, dynamic>{}.obs;

  final MainController mainController = Get.find<MainController>();

  late FlutterLocalNotificationsPlugin flutterNotificationPlugin;

  @override
  void onInit() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchAllStopsETA();
    });

    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   showNoti();
    // });

    setupNoti();
    super.onInit();
  }

  void onSelectNotification(String? payload) async {
    log("onSelectNotification");
  }

  void setupNoti() async {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('flutter');

    var initializationSettings =
        new InitializationSettings(android: initializationSettingsAndroid);

    flutterNotificationPlugin = FlutterLocalNotificationsPlugin();

    flutterNotificationPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    showNoti();
  }

  void showNoti() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        playSound: false,
        ticker: 'ticker',
        ongoing: true,
        autoCancel: false);

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    flutterNotificationPlugin.show(0, 'New Alert',
        'How to show Local Notification', platformChannelSpecifics,
        payload: 'No Sound');
  }

  void setDisplayContent() {
    // log("setDisplayContent");
    // if (nearByStopEta.isEmpty) {
    //   fetchAllStopsETA();
    // }

    contents.clear();
    mainController.favouriteListGroup2.forEach((e) {
      contents.add(DragAndDropList(
          header: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.only(right: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            var startHour = e.startHour.obs;
                            var startMin = e.startMin.obs;
                            var endHour = e.endHour.obs;
                            var endMin = e.endMin.obs;

                            var weekdays = e.weekdays.obs;

                            showDialog(
                                context: buildContext,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(e.name),
                                    content: Container(
                                        height: 350,
                                        child: Column(
                                          children: [
                                            // week

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                    width: 100,
                                                    child:
                                                        Text("StartTime".tr)),
                                                Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: GestureDetector(
                                                    child: Obx(() => Text(
                                                        "${startHour.value.toString().padLeft(2, '0')} : ${startMin.value.toString().padLeft(2, '0')}")),
                                                    onTap: () async {
                                                      var _pickedTime =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now());
                                                      if (_pickedTime != null) {
                                                        startHour.value =
                                                            _pickedTime.hour;
                                                        startMin.value =
                                                            _pickedTime.minute;
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  top: 15),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                      width: 100,
                                                      child:
                                                          Text("EndTime".tr)),
                                                  Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.white),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: GestureDetector(
                                                      child: Obx(() => Text(
                                                          "${endHour.value.toString().padLeft(2, '0')} : ${endMin.value.toString().padLeft(2, '0')}")),
                                                      onTap: () async {
                                                        var _pickedTime =
                                                            await showTimePicker(
                                                                context:
                                                                    context,
                                                                initialTime:
                                                                    TimeOfDay
                                                                        .now());
                                                        if (_pickedTime !=
                                                            null) {
                                                          endHour.value =
                                                              _pickedTime.hour;
                                                          endMin.value =
                                                              _pickedTime
                                                                  .minute;
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10)),
                                            ...[
                                              "monday".tr,
                                              "tuesday".tr,
                                              "wednesday".tr,
                                              "thursday".tr,
                                              "friday".tr,
                                              "saturday".tr,
                                              "sunday".tr,
                                            ].mapIndexed((i, e) => Obx(() =>
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(e),
                                                      SizedBox(
                                                        width: 36,
                                                        height: 36,
                                                        child: Checkbox(
                                                            activeColor:
                                                                Colors.grey,
                                                            checkColor:
                                                                Colors.white,
                                                            value: weekdays
                                                                .value[i],
                                                            onChanged:
                                                                (bool? value) {
                                                              weekdays.value[
                                                                  i] = value!;
                                                              weekdays
                                                                  .refresh();
                                                            }),
                                                      )
                                                    ],
                                                  ),
                                                )))
                                          ],
                                        )),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            e.startHour = startHour.value;
                                            e.startMin = startMin.value;
                                            e.endHour = endHour.value;
                                            e.endMin = endMin.value;
                                            e.weekdays = weekdays.value;

                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text("Comfirm")),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("Cancel"),
                                      )
                                    ],
                                  );
                                });
                          },
                          child: const Icon(Icons.access_time,
                              color: Colors.white60)),
                      e.name != "default"
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: GestureDetector(
                                  onTap: () {
                                    mainController.removeFavouriteGroup(e.name);
                                    setDisplayContent();
                                  },
                                  child: const Icon(Icons.delete,
                                      color: Colors.white60)),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          children: []));
    });

    // int i = 0;
    // var listGroupMap = Map.fromIterable(
    //     mainController.favouriteListGroup2.value,
    //     value: (_) => i++);

    mainController.favouriteStopList.forEach((e) {
      //default gp
      int index = mainController.favouriteListGroup2.value
          .indexWhere((element) => element.name == e.displayGroup);
      // int index = listGroupMap[e.displayGroup]!;

      contents.value[index].children.add(DragAndDropItem(
        feedbackWidget: Text(e.uniqueKey),
        child: Dismissible(
          key: UniqueKey(),
          confirmDismiss: onConfirmDismiss,
          onDismissed: (_) {
            for (var j = 0; j < contents.value.length; j++) {
              for (var k = 0; k < contents.value[j].children.length; k++) {
                if ((contents.value[j].children[k].feedbackWidget! as Text)
                        .data! ==
                    e.uniqueKey) {
                  contents.value[j].children.removeAt(k);
                  mainController.removeFavouriteListItem(e.uniqueKey);
                  contents.refresh();
                }
              }
            }
          },
          child: Container(
            padding:
                const EdgeInsets.only(top: 5, bottom: 7, left: 15, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 65,
                      child: Text(
                        mainController.DB['routeList'][e.routeKey]['route'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Text(
                                'to'.tr,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            Text(
                              mainController.DB['routeList'][e.routeKey]['dest']
                                  [Get.locale!.languageCode],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              mainController.DB['stopList'][e.stopID]['name']
                                  [Get.locale!.languageCode],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white60),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(getETATime(e.routeKey, e.seq, 0)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ));
    });

    contents.refresh();
  }

  void onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    var movedItem =
        contents.value[oldListIndex].children.removeAt(oldItemIndex);

    contents.value[newListIndex].children.insert(newItemIndex, movedItem);

    log((movedItem.feedbackWidget! as Text).data!);

    contents.refresh();
  }

  void onListReorder(int oldListIndex, int newListIndex) {
    var movedList = contents.value.removeAt(oldListIndex);
    contents.value.insert(newListIndex, movedList);
    contents.refresh();

    mainController.onFavouriteGroupReorder(oldListIndex, newListIndex);
    log(mainController.favouriteListGroup.toString());
  }

  void fetchAllStopsETA() async {
    var futures = <Future>[];

    for (var element in mainController.favouriteStopList) {
      futures.add(fetchEtaAction(
          mainController.DB['routeList'][element.routeKey],
          element.routeKey,
          element.seq));
    }

    await Future.wait(futures);
    log("finish");
    setDisplayContent();
  }

  Future<void> fetchEtaAction(
      Map<String, dynamic> route, String routeKey, int seq) async {
    log("seq" + seq.toString());
    var result = await Eta.fetchEta(route, seq);
    log("result" + seq.toString() + " " + result.toString());

    if (nearByStopEta.value[routeKey] == null) {
      nearByStopEta.value[routeKey] = {};
    }
    nearByStopEta.value[routeKey][seq] = result;
  }

  String getETATime(String routeKey, int seq, int index) {
    var etaData = nearByStopEta.value[routeKey];

    log("getETATime" + etaData.toString());
    if (etaData == null ||
        etaData[seq] == null ||
        etaData[seq].length <= index ||
        etaData[seq][index] == null ||
        etaData[seq][index]['eta'] == null) {
      return '-';
    }

    etaData = etaData[seq];
    String time = etaData[index]['eta'];
    // log(time);
    if (time.contains(' ')) {
      time = time.replaceAll(' ', 'T') + '+08:00';
    }
    var different = DateTime.parse(time).difference(DateTime.now());

    if (different.inSeconds < 0) {
      return "leave".tr;
    }

    if (different.inSeconds < 60) {
      return "> 1 ${'min'.tr}";
    }

    return different.inMinutes.toString() + " " + "min".tr;
  }

  Future<bool?> onConfirmDismiss(_) async {
    return await showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete")),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
