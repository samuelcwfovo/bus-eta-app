import 'dart:developer';
import 'package:uuid/uuid.dart';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:bus_eta/TapPageWidget/BookmarkPage/bookmark_controller.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class FavouriteItem {
  String routeKey;
  String stopID;
  int seq = 0;
  String uniqueKey = const Uuid().v1();
  String displayGroup;

  FavouriteItem(
      {required this.routeKey,
      required this.stopID,
      this.displayGroup = 'default',
      required this.seq});

  FavouriteItem.fromJson(Map<String, dynamic> json)
      : routeKey = json['routeKey'],
        stopID = json['stopID'],
        displayGroup = json['displayGroup'],
        seq = json['seq'];

  Map<String, dynamic> toJson() => {
        'routeKey': routeKey,
        'stopID': stopID,
        'displayGroup': displayGroup,
        'seq': seq,
      };
}

class FavouriteGroup {
  String name;
  List<dynamic> weekdays = [true, true, true, true, true, true, true];
  int startHour = 0;
  int startMin = 0;
  int endHour = 23;
  int endMin = 59;

  FavouriteGroup({
    required this.name,
  });

  FavouriteGroup.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        weekdays = jsonDecode(json['weekdays']),
        startHour = json['startHour'],
        startMin = json['startMin'],
        endHour = json['endHour'],
        endMin = json['endMin'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'weekdays': jsonEncode(weekdays),
        'startHour': startHour,
        'startMin': startMin,
        'endHour': endHour,
        'endMin': endMin,
      };
}

class MainController extends GetxController {
  var appTitle = "HK BUS ETA".obs;
  var selectedTabIndex = 1.obs;
  var DB = RxMap<String, dynamic>();
  var polyLineDB = RxMap<String, dynamic>();
  var polyLineNameDB = RxMap<String, dynamic>();
  var cameraDB = [].obs;
  var favouriteStopList = <FavouriteItem>[].obs;
  var favouriteListGroup2 = <FavouriteGroup>[].obs;
  // var favouriteListGroup = <String>[].obs;
  late BuildContext buildContext;

  var loadingDB = true.obs;

  StreamController<void> onDBLoadedStream = StreamController<void>.broadcast();
  StreamController<void> onLanuageChangeStream =
      StreamController<void>.broadcast();

  var bookmarkController;

  @override
  onInit() {
    fetchDB();
    loadPolyLineJson();
    loadCameraJson();
    loadFavourite();
    super.onInit();
  }

  void fetchDB() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File dbFile = File('${directory.path}/DB.json');
    final File md5File = File('${directory.path}/md5.json');

    String md5URL =
        'https://raw.githubusercontent.com/hkbus/hk-bus-crawling/gh-pages/routeFareList.md5';

    var md5Result = Dio().get(md5URL);
    var md5Data = (await md5Result).data;

    void saveDB() async {
      await dbFile.writeAsString(json.encode(DB.value));
      await md5File.writeAsString(md5Data);

      log('db saved');
    }

    void downloadDB() async {
      String finalDbURL =
          'https://raw.githubusercontent.com/hkbus/hk-bus-crawling/gh-pages/routeFareList.json';

      var finalDbResult = Dio().get(finalDbURL);

      Map<String, dynamic> data = jsonDecode((await finalDbResult).data);

      DB.value = data;
      loadingDB.value = false;

      onDBLoadedStream.sink.add(null);
      onDBLoadedStream.sink.close();

      saveDB();
    }

    if (dbFile.existsSync()) {
      //check md5
      var localMd5Result = await md5File.readAsString();

      if (md5Data == localMd5Result) {
        Map<String, dynamic> data =
            await jsonDecode(await dbFile.readAsString());
        DB.value = data;
        loadingDB.value = false;

        onDBLoadedStream.sink.add(null);
        onDBLoadedStream.sink.close();
      } else {
        downloadDB();
      }
    } else {
      downloadDB();
    }
  }

  void loadPolyLineJson() async {
    polyLineDB.value = json.decode(
        await rootBundle.loadString(('lib/resources/kmb_poly_line.json')));

    polyLineNameDB.value = json.decode(await rootBundle
        .loadString(('lib/resources/kmb_poly_line_name_result.json')));
  }

  void loadCameraJson() async {
    cameraDB.value = json.decode(
        await rootBundle.loadString(('lib/resources/camera_data.json')));

    log('camerajson');
  }

  void loadFavourite() async {
    final prefs = await SharedPreferences.getInstance();
    // saveFavouriteList();
    final String? favouriteListString = prefs.getString('favouriteList');
    final String? favouriteGroupString = prefs.getString('favouriteGroup');

    // if (favouriteGroupString != null) {
    //   favouriteListGroup.value = [...jsonDecode(favouriteGroupString)];
    // } else {
    //   favouriteListGroup.add('default');
    //   favouriteListGroup.add('test');
    //   favouriteListGroup.add('test2');
    // }

    if (favouriteGroupString != null) {
      List<dynamic> favouriteGroups = jsonDecode(favouriteGroupString);

      for (var json in favouriteGroups) {
        favouriteListGroup2.value.add(FavouriteGroup.fromJson(json));
      }
      favouriteListGroup2.refresh();
    } else {
      favouriteListGroup2.add(FavouriteGroup(name: 'default'));
      favouriteListGroup2.add(FavouriteGroup(name: '返工'));
      favouriteListGroup2.add(FavouriteGroup(name: '回家'));
    }

    if (favouriteListString != null) {
      List<dynamic> favouriteList = jsonDecode(favouriteListString);
      for (var json in favouriteList) {
        favouriteStopList.value.add(FavouriteItem.fromJson(json));
      }
      favouriteStopList.refresh();
    }

    BookmarkController bookmarkController = Get.find<BookmarkController>();

    onDBLoadedStream.stream.listen((_) {
      bookmarkController.setDisplayContent();
      bookmarkController.fetchAllStopsETA();
    });
  }

  void onFavouriteItemReorder(String id, int newgroupIndex) {
    // favouriteStopList[itemOldRealIndex].displayGroup =
    //     favouriteListGroup[newgroupIndex];

    // var movedItem = favouriteStopList.value.removeAt(itemOldRealIndex);
    // favouriteStopList.value.insert(itemNewRealIndex, movedItem);
    // favouriteStopList.refresh();

    // log(favouriteStopList[itemNewRealIndex].stopID);

    // BookmarkController bookmarkController = Get.find<BookmarkController>();
    // bookmarkController.setDisplayContent();

    var stop = favouriteStopList.firstWhere((e) => e.uniqueKey == id);
    stop.displayGroup = favouriteListGroup2[newgroupIndex].name;
    saveFavouriteList();
  }

  void onFavouriteGroupReorder(int oldListIndex, int newListIndex) {
    var movedList = favouriteListGroup2.removeAt(oldListIndex);
    favouriteListGroup2.insert(newListIndex, movedList);
    saveFavouriteGroup();
  }

  void onFavouriteListClick(
      String routeKey, String stopID, String group, int seq) {
    final int index = favouriteStopList.value.indexWhere(
        (element) => element.routeKey == routeKey && element.stopID == stopID);

    if (index == -1) {
      log("mainseq " + seq.toString());
      favouriteStopList.value.add(FavouriteItem(
          routeKey: routeKey, stopID: stopID, displayGroup: group, seq: seq));
    } else {
      favouriteStopList.value.removeAt(index);
    }

    favouriteStopList.refresh();

    log(favouriteStopList.value.length.toString());

    BookmarkController bookmarkController = Get.find<BookmarkController>();

    bookmarkController.setDisplayContent();
    bookmarkController.fetchAllStopsETA();
    saveFavouriteList();
  }

  void removeFavouriteListItem(String uuid) {
    final int index = favouriteStopList.value
        .indexWhere((element) => element.uniqueKey == uuid);
    favouriteStopList.value.removeAt(index);

    saveFavouriteList();
  }

  void removeFavouriteGroup(String name) {
    favouriteListGroup2.removeWhere((element) => element.name == name);

    favouriteStopList.value.forEach((element) {
      if (element.displayGroup == name) {
        element.displayGroup = 'default';
      }
    });

    favouriteStopList.refresh();
    saveFavouriteList();
    saveFavouriteGroup();
  }

  Future<void> onAddFavouriteGroupTap() async {
    TextEditingController _textFieldController = TextEditingController();

    return await showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("newBookMarkGroup".tr),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "bookMarkGroupName".tr),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  if (favouriteListGroup2.indexWhere((element) =>
                          element.name == _textFieldController.text) !=
                      -1) {
                    Get.snackbar("bookmarkNameExist".tr, "");
                    return;
                  }

                  favouriteListGroup2
                      .add(FavouriteGroup(name: _textFieldController.text));
                  favouriteStopList.refresh();
                  saveFavouriteGroup();
                  BookmarkController bookmarkController =
                      Get.find<BookmarkController>();

                  bookmarkController.setDisplayContent();
                  Navigator.of(context).pop();
                  Get.snackbar(_textFieldController.text + "added".tr, "");
                },
                child: Text("Confirm".tr)),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel".tr),
            ),
          ],
        );
      },
    );
  }

  void saveFavouriteList() async {
    final prefs = await SharedPreferences.getInstance();
    var json = jsonEncode(favouriteStopList.map((e) => e.toJson()).toList());
    await prefs.setString('favouriteList', json);
  }

  void saveFavouriteGroup() async {
    final prefs = await SharedPreferences.getInstance();

    var json = jsonEncode(favouriteListGroup2.map((e) => e.toJson()).toList());
    await prefs.setString('favouriteGroup', json);
  }

  onTabclick(int index) => selectedTabIndex.value = index;
}
