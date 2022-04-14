import 'dart:async';
import 'dart:convert' hide Codec;
import 'dart:developer';
// import 'dart:js';
import 'dart:typed_data';
import 'dart:ui';
import "dart:math" show pi, cos, sin;

import 'package:bus_eta/main_controller.dart';
import 'package:bus_eta/util/get_eta.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

class Place with ClusterItem {
  final LatLng latLng;
  final String url;
  final double degree;

  Place({required this.latLng, required this.url, required this.degree});

  @override
  LatLng get location => latLng;
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

class RouteDetailController extends GetxController {
  var routeData = RxMap<String, dynamic>();
  var markers = <Marker>{};
  var busIcon = Rxn<BitmapDescriptor>();
  var busHereIcon = Rxn<BitmapDescriptor>();
  var mapController = Rxn<GoogleMapController>();
  var etaList = <int, List>{}.obs;
  var polyLines = <Polyline>{}.obs;
  var routeKey = "".obs;
  var durationData = {}.obs;
  var busDistanceData = [].obs;
  var buildContext = Rxn<BuildContext>();
  var cameraIcon = Rxn<BitmapDescriptor>();

  var finalMarkers = <Marker>{}.obs;
  var cameraMarkers = <Marker>{};
  var busMarkers = <Marker>{};

  var clusterManager = Rxn<ClusterManager>();
  // var placeItems = <Place>[].obs;

  var stillInDetailPage = false;

  var fetchBusDistanceTimer =
      Timer.periodic(const Duration(seconds: 1), (timer) => {});
  var updateBusPositionTimer =
      Timer.periodic(const Duration(seconds: 1), (timer) => {});

  int lastExpandTime = 0;

  final MainController mainController = Get.find<MainController>();

  @override
  void onInit() {
    log("route detail init");
    loadMapIcon();
    initMarkerCLuster();
    super.onInit();
  }

  void setRouteData(arguments) {
    routeKey.value = arguments;
    routeData.value = mainController.DB['routeList'][arguments];
  }

  void loadMapIcon() async {
    cameraIcon.value = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('lib/resources/camera_icon.png', 27));

    busIcon.value = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('lib/resources/bus_icon.jpg', 60));
    busHereIcon.value = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('lib/resources/bus_here_icon.jpg', 80));
  }

  void onMapCreated(GoogleMapController controller, BuildContext contex) {
    stillInDetailPage = true;
    mapController.value = controller;
    buildContext.value = contex;
    log('onmapc');

    markers.clear();
    meargeMarker();
    Timer(const Duration(milliseconds: 50), () => setupMarker());

    setupPolyLine();
    fetchDuration();
    fetchBusDistance();
    fetchTrafficJam();

    updateBusPositionTimer.cancel();

    clusterManager.value!.setMapId(controller.mapId);
  }

  void setupMarker() {
    var stopList = getRouteStopList();
    int index = 0;
    for (var stopID in stopList) {
      var stopData = mainController.DB['stopList'][stopID];

      Marker marker = Marker(
          markerId: MarkerId(index.toString()),
          icon: busIcon.value!,
          infoWindow: InfoWindow(
              title:
                  "${(index + 1).toString()}: ${stopData['name'][Get.locale!.languageCode]}"),
          position:
              LatLng(stopData['location']['lat'], stopData['location']['lng']));

      markers.add(marker);

      index++;
    }

    meargeMarker();

    //bounds
    final highestLat = stopList
        .map((e) => mainController.DB['stopList'][e]['location']['lat'])
        .reduce((value, element) => value > element ? value : element);
    final highestLong = stopList
        .map((e) => mainController.DB['stopList'][e]['location']['lng'])
        .reduce((value, element) => value > element ? value : element);
    final lowestLat = stopList
        .map((e) => mainController.DB['stopList'][e]['location']['lat'])
        .reduce((value, element) => value < element ? value : element);
    final lowestLong = stopList
        .map((e) => mainController.DB['stopList'][e]['location']['lng'])
        .reduce((value, element) => value < element ? value : element);

    final lowestLatLowestLong = LatLng(lowestLat, lowestLong);
    final highestLatHighestLong = LatLng(highestLat, highestLong);
    final cameraUpdate = CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: lowestLatLowestLong, northeast: highestLatHighestLong),
        30);

    mapController.value!.moveCamera(cameraUpdate);
  }

  void setupPolyLine() {
    polyLines.value = {};
    if (routeData.value['stops']['kmb'] != null) {
      var dbPolylines = mainController.polyLineDB.value[routeKey.value];

      int index = 0;
      for (var stopPolyLine in dbPolylines) {
        List<LatLng> latlngSegment = [];
        index++;

        for (var point in stopPolyLine) {
          latlngSegment.add(LatLng(point[0], point[1]));
        }

        polyLines.value.add(Polyline(
            startCap: Cap.roundCap,
            polylineId: PolylineId(UniqueKey().toString()),
            visible: true,
            points: latlngSegment,
            width: 3,
            zIndex: index,
            color: Colors.blueAccent));
      }
    }

    polyLines.refresh();
  }

  void onExpansionChanged(int index, bool isExpanded) {
    if (!isExpanded &&
        DateTime.now().millisecondsSinceEpoch > lastExpandTime + 50) {
      lastExpandTime = DateTime.now().millisecondsSinceEpoch;
      mapController.value!.showMarkerInfoWindow(MarkerId(index.toString()));

      var stopID = getRouteStopList()[index];
      var stopData = mainController.DB['stopList'][stopID];

      mapController.value!.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(stopData['location']['lat'], stopData['location']['lng']),
          14.8));

      fetchETA(routeData.value, index);

      updateBusPositionTimer.cancel();

      updateBusPositionTimer = Timer.periodic(
          const Duration(seconds: 1), (timer) => updateBusPosition(index));
    }
  }

  List getRouteStopList() {
    return routeData.value['stops'][routeData.value['co'][0]] ??
        routeData.value['stops'][routeData.value['co'][1]];
  }

  void fetchTrafficJam() async {
    if (!mainController.polyLineNameDB.value.containsKey(routeKey.value)) {
      return;
    }

    var result =
        await Dio().get("https://www.881903.com/api/news/recent/traffic");

    var dbPolylinesName = mainController.polyLineNameDB.value[routeKey.value];

    var displayList = [];

    if (result.data['response_code'] == 200) {
      log(result.data['response']['content'].toString());

      for (var element in (result.data['response']['content'] as List)) {
        var dateTime =
            DateTime.fromMillisecondsSinceEpoch(element['display_ts'] * 1000);

        if (DateTime.now().difference(dateTime).inHours < 24) {
          for (var polyline in dbPolylinesName) {
            for (var roadName in polyline) {
              if ((element["title"] as String).contains(roadName)) {
                displayList.add([
                  element["title"],
                  (element["preview_content"] as String)
                      .replaceAll(" ", "")
                      .replaceAll("\t", ""),
                  DateTime.now().difference(dateTime).inHours > 0
                      ? DateTime.now().difference(dateTime).inHours.toString() +
                          "小時前"
                      : DateTime.now()
                              .difference(dateTime)
                              .inMinutes
                              .toString() +
                          "分鐘前"
                ]);
              }
            }
          }
        }
      }

      if (displayList.isNotEmpty) {
        if (stillInDetailPage) {
          Widget okButton = TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(buildContext.value!, 'OK'),
          );

          // set up the AlertDialog
          AlertDialog alert = AlertDialog(
            title: Text(
              "tafficJamDetect".tr,
              style: const TextStyle(fontSize: 16),
            ),
            content: ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: buildContext.value!.height / 2),
              child: Container(
                height: 300.0, // Change as per your requirement
                width: 300.0,
                child: ListView(
                  children: displayList
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    e[0],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                Text("${e[2]}: ${e[1]}",
                                    style: TextStyle(fontSize: 10))
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            actions: [
              okButton,
            ],
          );

          showDialog(
            context: buildContext.value!,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
      }
    }
  }

  void fetchDuration() async {
    durationData.value = {};
    var stopList = getRouteStopList();

    var asyncCallList = <Future>[];

    for (var i = 0; i < stopList.length - 1; i++) {
      var stopData = mainController.DB['stopList'][stopList[i]];
      var nextStopData = mainController.DB['stopList'][stopList[i + 1]];

      Map<String, String> parms = {
        'language': Get.locale!.toLanguageTag(),
        'departure_time': 'now',
        'key': 'AIzaSyCEmBt-keCQm9W3WJkBAMQtlb8H5msU_Vk',
        'origins':
            "${stopData['location']['lat']},${stopData['location']['lng']}",
        'destinations':
            "${nextStopData['location']['lat']},${nextStopData['location']['lng']}"
      };

      asyncCallList.add(Dio().get(
          "https://maps.googleapis.com/maps/api/distancematrix/json",
          queryParameters: parms));
    }

    var results = await Future.wait(asyncCallList);

    for (var i = 0; i < results.length; i++) {
      var result = results[i];
      if (!result.data['rows'].isEmpty) {
        //"{distance: {text: 0.4 km, value: 429}, duration: {text: 1 min, value: 87}, duration_in_traffic: {text: 1 min, value: 84}, status: OK}"
        durationData.value[i] = result.data['rows'][0]['elements'][0];
      }
    }

    showAlertDialog();
  }

  void fetchBusDistance() async {
    busDistanceData.value = [];

    if (routeData.value['stops']['kmb'] != null) {
      String url =
          "https://bus-server-45vvcjqjd-samuelcwfovo.vercel.app/kmbETA";

      Map<String, String> parms = {
        'route': routeData.value['route'],
        'bound': routeData.value['bound']['kmb'] == "O" ? '1' : '2',
        'serviceType': routeData.value['serviceType']
      };

      var result = await Dio().get(url, queryParameters: parms);

      busDistanceData.value = result.data;
    }
    busDistanceData.refresh();

    fetchBusDistanceTimer.cancel();
    fetchBusDistanceTimer = Timer.periodic(
        const Duration(seconds: 30), (timer) => fetchBusDistance());
  }

  String getDistance(index, order) {
    if (busDistanceData.value.isNotEmpty &&
        busDistanceData.value[index].length > order) {
      var distance = busDistanceData.value[index][order]['distance'];

      if (distance != null) {
        String displayValue = ((distance / 10).ceil() / 100).toString();

        return ("$displayValue ${'km'.tr}");
      }
    }

    return "";
  }

  void fetchETA(route, seq) async {
    etaList.value = {};
    etaList.refresh();

    var result = await Eta.fetchEta(route, seq);

    etaList.value[seq] = result;
    etaList.refresh();
  }

  String getETATime(List? etaData, int order) {
    if (etaData == null) {
      return "loadingETA".tr;
    }

    if (etaData.length <= order) {
      return "${"noETA".tr} ";
    }

    if (etaData.length <= order ||
        etaData[order]['eta'] == null ||
        etaData[order]['eta'] == "") {
      return "${"noETA".tr}  ${etaData[order]['remark'][Get.locale!.languageCode]}";
    }

    var different =
        DateTime.parse(etaData[order]['eta']).difference(DateTime.now());

    if (different.inSeconds < 0) {
      return "leave".tr;
    }

    String eta =
        "${different.inMinutes} ${'min'.tr} ${(different.inSeconds % 60).toString().padLeft(2, '0')} ${'s'.tr}";

    return "${eta.padRight(10, '  ')}    ${(etaData[order]['co'] as String).tr}    ${etaData[order]['remark'][Get.locale!.languageCode]}";
  }

  String getRouteTrafficStatus(durationData) {
    int different = durationData['duration_in_traffic']['value'] -
        durationData['duration']['value'];
    if (different < 60) {
      return 'normal'.tr;
    }

    return "${'delay'.tr} ${(different / 60).ceil()} ${'min'.tr}";
  }

  void updateBusPosition(index) {
    if (busDistanceData.value.isNotEmpty) {
      var distance = busDistanceData.value[index][0]['distance'];
      if (distance != null) {
        if (routeData.value['stops']['kmb'] != null) {
          var dbPolylines = mainController.polyLineDB.value[routeKey.value];
          var totalDt = 0;

          for (var i = index - 1; i >= 0; i--) {
            var stopPolylines = dbPolylines[i];

            for (var j = stopPolylines.length - 1; j > 0; j--) {
              var currentPoint = stopPolylines[j];
              var previousPoint = stopPolylines[j - 1];

              var currentLatLng = mp.LatLng(currentPoint[0], currentPoint[1]);
              var previousLatLng =
                  mp.LatLng(previousPoint[0], previousPoint[1]);

              totalDt += mp.SphericalUtil.computeDistanceBetween(
                      currentLatLng, previousLatLng)
                  .toInt();

              if (totalDt > distance) {
                var heading = mp.SphericalUtil.computeHeading(
                    previousLatLng, currentLatLng);

                var offset = mp.SphericalUtil.computeOffset(
                    previousLatLng, totalDt - distance, heading);

                Marker marker = Marker(
                    markerId: const MarkerId("bus_position"),
                    icon: busHereIcon.value!,
                    position: LatLng(offset.latitude, offset.longitude));

                busMarkers.clear();
                busMarkers.add(marker);
                meargeMarker();
                log('add bus marker');
                return;
              }
            }
          }
        }
      }
    }
  }

  void onFavouriteListClick(routeIndex, stopID, index) {
    log("seq onFavouriteListClick " + index.toString());
    var favGroup = "default".obs;

    bool isFavour = mainController.favouriteStopList.value.any((element) =>
        element.routeKey == Get.arguments && element.stopID == stopID);

    if (isFavour) {
      mainController.onFavouriteListClick(
          routeIndex, stopID, favGroup.value, index);
      return;
    }

    showDialog(
        context: buildContext.value!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Please select bookmark group"),
            content: Obx(() => DropdownButton(
                  value: favGroup.value,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: mainController.favouriteListGroup2
                      .map((element) => DropdownMenuItem(
                            value: element.name,
                            child: Text(element.name),
                          ))
                      .toList(),
                  onChanged: (String? value) {
                    favGroup.value = value ?? "default";
                    favGroup.refresh();
                  },
                )),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    log(favGroup.value);
                    mainController.onFavouriteListClick(
                        routeIndex, stopID, favGroup.value, index);
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Comfirm")),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              )
            ],
          );
        });
  }

  void showAlertDialog() {
    // show the dialog
    if (getRouteDelayAlertText().isNotEmpty && stillInDetailPage) {
      // set up the button
      Widget okButton = TextButton(
        child: Text("OK"),
        onPressed: () => Navigator.pop(buildContext.value!, 'OK'),
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text(
          "routeDelay".tr,
          style: const TextStyle(fontSize: 16),
        ),
        content: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: buildContext.value!.height / 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: getRouteDelayAlertText(),
          ),
        ),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: buildContext.value!,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  List<Widget> getRouteDelayAlertText() {
    var stopList = getRouteStopList();

    List<Widget> weightData = [];

    durationData.value.entries.map((entry) {
      var different = entry.value['duration_in_traffic']['value'] -
          entry.value['duration']['value'];
      if (different > 60) {
        var origStopID = stopList[entry.key];
        var origStopData = mainController.DB['stopList'][origStopID];
        var origStopName = origStopData['name'][Get.locale!.languageCode];

        var destStopID = stopList[entry.key + 1];
        var destStopData = mainController.DB['stopList'][destStopID];
        var destStopName = destStopData['name'][Get.locale!.languageCode];

        weightData.add(Text(
          "${entry.key + 1}. [$origStopName] - [$destStopName]    :  ${(different / 60).toStringAsFixed(2)} ${'min'.tr}",
          style: const TextStyle(fontSize: 12),
        ));
      }
    }).toList();

    return weightData;
  }

  Future<bool> onDetailPagePop() {
    updateBusPositionTimer.cancel();
    busMarkers.clear();
    stillInDetailPage = false;
    meargeMarker();
    return Future.value(true);
  }

  void meargeMarker() {
    finalMarkers.clear();
    finalMarkers.addAll(cameraMarkers);
    finalMarkers.addAll(busMarkers);
    finalMarkers.addAll(markers);

    finalMarkers.refresh();
  }

  void initMarkerCLuster() {
    var _placeItems = <Place>[];

    for (var cameraData in mainController.cameraDB.value) {
      _placeItems.add(Place(
          latLng: LatLng(cameraData['latitude'], cameraData['longitude']),
          url: cameraData['url'],
          degree: cameraData['Deg'].runtimeType == String
              ? -1
              : cameraData['Deg'].toDouble()));
    }

    void updateMarkers(Set<Marker> _markers) {
      cameraMarkers = _markers;
      meargeMarker();
    }

    Future<BitmapDescriptor> _getMarkerBitmap(int size, String text) async {
      final PictureRecorder pictureRecorder = PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final Paint paint1 = Paint()..color = Colors.green;
      final Paint paint2 = Paint()..color = Colors.white;

      canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);

      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );

      final img = await pictureRecorder.endRecording().toImage(size, size);
      final data =
          await img.toByteData(format: ImageByteFormat.png) as ByteData;

      return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    }

    Future<BitmapDescriptor> getMarker(int size, double degree) async {
      final PictureRecorder pictureRecorder = PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final Paint paint2 = Paint()..color = Colors.green;

      canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint2);

      if (degree == -1) {
        final img = await pictureRecorder.endRecording().toImage(size, size);
        final data =
            await img.toByteData(format: ImageByteFormat.png) as ByteData;

        return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
      }

      var paintArrow = Paint();
      paintArrow.style = PaintingStyle.stroke;
      paintArrow.strokeWidth = 4;
      paintArrow.color = Colors.black;

      var length = 10;
      var x = 0;
      var y = length;
      var angle = degree - 180;

      double rad = angle * pi / 180;

      var newX = x * cos(rad) - y * sin(rad);
      var newY = y * cos(rad) + x * sin(rad);

      var pointUp = Offset(newX + size / 2, newY + size / 2);

      var angle1 = degree;

      var rad1 = angle1 * pi / 180;
      var newX1 = x * cos(rad1) - y * sin(rad1);
      var newY1 = y * cos(rad1) + x * sin(rad1);

      var pointdown = Offset(newX1 + size / 2, newY1 + size / 2);

      angle = degree - 180 + 70;

      rad = angle * pi / 180;

      newX = x * cos(rad) - y * sin(rad);
      newY = y * cos(rad) + x * sin(rad);

      var pointright = Offset(newX + size / 2, newY + size / 2);

      angle = degree - 180 - 70;

      rad = angle * pi / 180;

      newX = x * cos(rad) - y * sin(rad);
      newY = y * cos(rad) + x * sin(rad);

      var pointleft = Offset(newX + size / 2, newY + size / 2);

      canvas.drawLine(Offset(size / 2, size / 2), pointdown, paintArrow);
      canvas.drawLine(Offset(size / 2, size / 2), pointUp, paintArrow);

      canvas.drawLine(pointUp, pointright, paintArrow);

      canvas.drawLine(pointUp, pointleft, paintArrow);

      final img = await pictureRecorder.endRecording().toImage(size, size);
      final data =
          await img.toByteData(format: ImageByteFormat.png) as ByteData;

      return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    }

    Future<Marker> _markerBuilder(Cluster<Place> cluster) async {
      return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          icon: cluster.isMultiple
              ? await _getMarkerBitmap(75, cluster.count.toString())
              : await getMarker(35, cluster.items.first.degree),
          onTap: () async {
            if (!cluster.isMultiple) {
              await showDialog(
                  context: buildContext.value!,
                  builder: (_) {
                    return Dialog(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(cluster.items.first.url))),
                      ),
                    );
                  });
            }
          });
    }

    clusterManager.value = ClusterManager<Place>(_placeItems, updateMarkers,
        markerBuilder: _markerBuilder,
        levels: [1, 4.25, 11.5, 11.5, 11.5, 14.5, 16.0, 16.5, 20.0],
        extraPercent: 0.1,
        stopClusteringZoom: 13);
  }
}
