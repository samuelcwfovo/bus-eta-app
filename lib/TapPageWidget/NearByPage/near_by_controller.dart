import 'dart:async';
import 'dart:developer';

import 'package:bus_eta/main_controller.dart';
import 'package:bus_eta/util/get_eta.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class Stop {
  String id;
  double lat;
  double lng;
  Map<String, String> name;

  Stop(this.id, this.lat, this.lng, this.name);

  double getDistance(Position position) {
    return Geolocator.distanceBetween(
        position.latitude, position.longitude, lat, lng);
  }
}

class NearByController extends GetxController {
  final MainController mainController = Get.find<MainController>();

  var currentPosition = Rxn<Position>();
  var nearByStops = [].obs; //it shoult be route?
  var nearByStopEta = <int, List>{}.obs;

  @override
  void onInit() {
    initPositionListerner();
    updateNearByStopsOnDBLoad();
    initAutoRefresh();
    super.onInit();
  }

  void initPositionListerner() => {
        Geolocator.getPositionStream(distanceFilter: 200)
            .listen((Position position) {
          currentPosition.value = position;
          updateNearByStops();
        })
      };

  void updateNearByStopsOnDBLoad() => {
        mainController.onDBLoadedStream.stream.listen((_) {
          updateNearByStops();
        })
      };

  void initAutoRefresh() => {
        Timer.periodic(const Duration(seconds: 30), (timer) {
          fetchStopEta();
        })
      };

  void updateNearByStops() {
    if (!mainController.loadingDB.value) {
      List<Stop> stopList = [];

      (mainController.DB['stopList'] as Map<String, dynamic>)
          .forEach((key, value) {
        stopList
            .add(Stop(key, value['location']['lat'], value['location']['lng'], {
          'en': value['name']['en'],
          'zh': value['name']['zh'],
        }));
      });

      stopList.sort((a, b) => a
          .getDistance(currentPosition.value!)
          .compareTo(b.getDistance(currentPosition.value!)));

      stopList.take(6).forEach((stop) {
        (mainController.DB['routeList'] as Map<String, dynamic>)
            .forEach((key, route) {
          ["kmb", "nwfb", "ctb", "nlb", "lrtfeeder"].forEach((company) {
            if (route['stops'].containsKey(company) &&
                route['stops'][company].contains(stop.id)) {
              var data = {
                'routeId': key,
                'stopId': stop.id,
                'stop': stop,
                'company': company
              };

              bool contain = false;

              nearByStops.value.forEach((element) {
                if (element['routeId'] == key) {
                  contain = true;
                }
              });

              if (!contain) {
                nearByStops.value.add(data);
              }
            }
          });
        });
      });
    }

    nearByStops.value.sort((a, b) {
      var distance = a['stop']
          .getDistance(currentPosition.value!)
          .compareTo(b['stop'].getDistance(currentPosition.value!));

      if (distance != 0) return distance;

      return a['routeId'].compareTo(b['routeId']);
    });
    nearByStops.refresh();

    fetchStopEta();
  }

  void fetchStopEta() {
    nearByStopEta.value = {};
    nearByStopEta.refresh();

    nearByStops.asMap().forEach((index, stopData) {
      fetchEtaAction(
          index,
          mainController.DB['routeList'][stopData['routeId']],
          mainController.DB['routeList'][stopData['routeId']]['stops']
                  [stopData['company']]
              .indexOf(stopData['stopId']));
    });
  }

  void fetchEtaAction(int index, Map<String, dynamic> route, int seq) async {
    var result = await Eta.fetchEta(route, seq);

    nearByStopEta.value[index] = result;

    nearByStopEta.refresh();
  }

  String getStopDistanceString(Stop stop) {
    var distance = stop.getDistance(currentPosition.value!);
    if (distance / 1000 > 1) {
      return (distance / 1000).toStringAsFixed(2) + "km";
    }

    return distance.ceil().toString() + "m";
  }

  String getRouteEta(List? etaData, int index) {
    if (etaData == null ||
        etaData.length <= index ||
        etaData[index]['eta'] == null) {
      return '-';
    }

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
    // " " +
    // (different.inSeconds % 60).toString().padLeft(2, '0') +
    // " " +
    // "s".tr;
  }
}
