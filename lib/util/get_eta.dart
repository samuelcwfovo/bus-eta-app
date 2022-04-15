import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

class Eta {
  static Future kmb(stopId, route, seq, serviceType, bound) async {
    return Dio()
        .get(
            "https://data.etabus.gov.hk/v1/transport/kmb/eta/${stopId}/${route}/${serviceType}")
        .then((res) => res.data)
        .then((data) => data['data'])
        .then((datas) => datas
            .where((e) => e['dir'] == bound && e['seq'] == seq + 1)
            .toList())
        .then((datas) => datas
            .map((e) => {
                  'eta': e['eta'],
                  'remark': {'zh': e['rmk_tc'], 'en': e['rmk_en']},
                  'co': 'kmb'
                })
            .toList());
  }

  static Future ctb(stopId, route, bound) async {
    return Dio()
        .get(
            "https://rt.data.gov.hk//v1/transport/citybus-nwfb/eta/CTB/${stopId}/${route}")
        .then((res) => res.data)
        .then((data) => data['data'])
        .then((datas) => datas
            .where((e) => e.containsKey('eta') && e['dir'] == bound)
            .toList())
        .then((datas) => datas
            .map((e) => {
                  'eta': e['eta'],
                  'remark': {'zh': e['rmk_tc'], 'en': e['rmk_en']},
                  'co': 'ctb'
                })
            .toList());
  }

  static Future nwfb(stopId, route, bound) async {
    return Dio()
        .get(
            "https://rt.data.gov.hk//v1/transport/citybus-nwfb/eta/NWFB/${stopId}/${route}")
        .then((res) => res.data)
        .then((data) => data['data'])
        .then((datas) => datas
            .where((e) => e.containsKey('eta') && e['dir'] == bound)
            .toList())
        .then((datas) => datas
            .map((e) => {
                  'eta': e['eta'],
                  'remark': {'zh': e['rmk_tc'], 'en': e['rmk_en']},
                  'co': 'nwfb'
                })
            .toList());
  }

  static Future nlb(stopId, nlbId) async {
    var dio = Dio();

    return dio
        .post(
            "https://rt.data.gov.hk/v1/transport/nlb/stop.php?action=estimatedArrivals",
            data: jsonEncode(
                {'routeId': nlbId, 'stopId': stopId, 'language': 'zh'}),
            options: Options(contentType: Headers.textPlainContentType))
        .then((res) => res.data)
        .then((value) {
      if (!value.containsKey('estimatedArrivals')) return [];
      if (value['estimatedArrivals'].length == 0) return [];

      return value['estimatedArrivals']
          .where((e) => e.containsKey('estimatedArrivalTime') as bool)
          .toList()
          .map((e) => {
                'eta': e['estimatedArrivalTime'],
                'remark': {'zh': '', 'en': ''},
                'co': 'nlb'
              })
          .toList();
    });
  }

  static Future lrtfeeder(stopId, route) async {
    return Dio()
        .post("https://rt.data.gov.hk/v1/transport/mtr/bus/getSchedule",
            data: {'routeName': route, 'language': 'zh'},
            options: Options(
                headers: {Headers.contentTypeHeader: "application/json"}))
        .then((res) => res.data)
        .then((value) {
      log(value.toString());
      return value;
    }).then((value) {
      if (value["routeStatusRemarkContent"] == "停止服務") {
        return [
          {
            'eta': '',
            'remark': {'zh': '停止服務', 'en': 'stop service'},
            'co': 'lrtfeeder'
          }
        ];
      }
      return [];
    });
    // .then((value) => value['busStop'])
    // .then((value) => value.where((e) => e['busStopId'] == stopId));
  }

  static Future<List> fetchEta(Map<String, dynamic> route, int seq) async {
    List eta = [];

    for (var company in (route['co'] as List)) {
      if (company == 'kmb' && route['stops'].containsKey('kmb')) {
        List data = await kmb(route['stops']['kmb'][seq], route['route'], seq,
            route['serviceType'], route['bound']['kmb']);
        for (var element in data) {
          eta.add(element);
        }
      } else if (company == 'ctb' && route['stops'].containsKey('ctb')) {
        List data = await ctb(route['stops']['ctb'][seq], route['route'],
            route['bound'][company]);
        for (var element in data) {
          eta.add(element);
        }
      } else if (company == 'nwfb' && route['stops'].containsKey('nwfb')) {
        List data = await nwfb(route['stops']['nwfb'][seq], route['route'],
            route['bound'][company]);
        for (var element in data) {
          eta.add(element);
        }
      } else if (company == 'nlb' && route['stops'].containsKey('nlb')) {
        List data = await nlb(route['stops']['nlb'][seq], route['nlbId']);
        for (var element in data) {
          if ((element as Map).containsKey('eta')) {
            String time = element['eta'];
            if (time.contains(' ')) {
              time = time.replaceAll(' ', 'T') + '+08:00';
              element['eta'] = time;
            }
          }
          eta.add(element);
        }
      } else if (company == 'lrtfeeder' &&
          route['stops'].containsKey('lrtfeeder')) {
        List data =
            await lrtfeeder(route['stops']['lrtfeeder'][seq], route['route']);
        for (var element in data) {
          eta.add(element);
        }
      }
    }

    eta.sort((a, b) {
      if (a['eta'] == '' || a['eta'] == null) {
        return 1;
      } else if (b['eta'] == '' || b['eta'] == null) {
        return -1;
      }
      return a['eta'].compareTo(b['eta']);
    });

    return eta;
  }
}
