import 'package:get/get.dart';
import 'dart:developer';
import 'package:dio/dio.dart';

// stores ExpansionPanel state information
class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

class MTRDetailController extends GetxController {
  var ETAData = <String, dynamic>{}.obs;

  var mtrStops = {
    'AEL': [
      {
        'en': "Airport",
        'zh': "機場",
        'code': "AIR",
      },
      {
        'en': "AsiaWorld Expo",
        'zh': "亞洲博覽館",
        'code': "AWE",
      },
      {
        'en': "Tsing Yi",
        'zh': "青衣",
        'code': "TSY",
      },
      {
        'en': "Kowloon",
        'zh': "九龍",
        'code': "KOW",
      },
      {
        'en': "Hong Kong",
        'zh': "香港",
        'code': "HOK",
      },
    ],
    'TCL': [
      {
        'en': "Tung Chung",
        'zh': "東涌",
        'code': "TUC",
      },
      {
        'en': "Sunny Bay",
        'zh': "欣澳",
        'code': "SUN",
      },
      {
        'en': "Tsing Yi",
        'zh': "青衣",
        'code': "TSY",
      },
      {
        'en': "Lai King",
        'zh': "荔景",
        'code': "LAK",
      },
      {
        'en': "Nam Cheong",
        'zh': "南昌",
        'code': "NAC",
      },
      {
        'en': "Olympic",
        'zh': "奧運",
        'code': "OLY",
      },
      {
        'en': "Kowloon",
        'zh': "九龍",
        'code': "KOW",
      },
      {
        'en': "Hong Kong",
        'zh': "香港",
        'code': "HOK",
      },
    ],
    'TML': [
      {
        'en': "Tuen Mun",
        'zh': "屯門",
        'code': "TUM",
      },
      {
        'en': "Siu Hong",
        'zh': "兆康",
        'code': "SIH",
      },
      {
        'en': "Tin Shui Wai",
        'zh': "天水圍",
        'code': "TIS",
      },
      {
        'en': "Long Ping",
        'zh': "朗屏",
        'code': "LOP",
      },
      {
        'en': "Yuen Long",
        'zh': "元朗",
        'code': "YUL",
      },
      {
        'en': "Kam Sheung Road",
        'zh': "錦上路",
        'code': "KSR",
      },
      {
        'en': "Tsuen Wan West",
        'zh': "荃灣西",
        'code': "TWW",
      },
      {
        'en': "Mei Foo",
        'zh': "美孚",
        'code': "MEF",
      },
      {
        'en': "Nam Cheong",
        'zh': "南昌",
        'code': "NAC",
      },
      {
        'en': "Austin",
        'zh': "柯士甸",
        'code': "AUS",
      },
      {
        'en': "East Tsim Sha Tsui",
        'zh': "尖東",
        'code': "ETS",
      },
      {
        'en': "Hung Hom",
        'zh': "紅磡",
        'code': "HUH",
      },
      {
        'en': "Ho Man Tin",
        'zh': "何文田",
        'code': "HOM",
      },
      {
        'en': "To Kwa Wan",
        'zh': "土瓜灣",
        'code': "TKW",
      },
      {
        'en': "Sung Wong Toi",
        'zh': "宋皇臺",
        'code': "SUW",
      },
      {
        'en': "Kai Tak",
        'zh': "啟德",
        'code': "KAT",
      },
      {
        'en': "Diamond Hill",
        'zh': "鑽石山",
        'code': "DIH",
      },
      {
        'en': "Hin Keng",
        'zh': "顯徑",
        'code': "HIK",
      },
      {
        'en': "Tai Wai",
        'zh': "大圍",
        'code': "TAW",
      },
      {
        'en': "Che Kung Temple",
        'zh': "車公廟",
        'code': "CKT",
      },
      {
        'en': "Sha Tin Wai",
        'zh': "沙田圍",
        'code': "STW",
      },
      {
        'en': "City One",
        'zh': "沙田第一城",
        'code': "CIO",
      },
      {
        'en': "Shek Mun",
        'zh': "石門",
        'code': "SHM",
      },
      {
        'en': "Tai Shui Hang",
        'zh': "大水坑",
        'code': "TSH",
      },
      {
        'en': "Heng On",
        'zh': "恆安",
        'code': "HEO",
      },
      {
        'en': "Ma On Shan",
        'zh': "馬鞍山",
        'code': "MOS",
      },
      {
        'en': "Wu Kai Sha",
        'zh': "烏溪沙",
        'code': "WKS",
      },
    ],
    'TKL': [
      {
        'en': "Po Lam",
        'zh': "寶琳",
        'code': "POA",
      },
      {
        'en': "Hang Hau",
        'zh': "坑口",
        'code': "HAH",
      },
      {
        'en': "LOHAS Park",
        'zh': "康城",
        'code': "LHP",
      },
      {
        'en': "Tseung Kwan O",
        'zh': "將軍澳",
        'code': "TKO",
      },
      {
        'en': "Tiu Keng Leng",
        'zh': "調景嶺",
        'code': "TIK",
      },
      {
        'en': "Yau Tong",
        'zh': "油塘",
        'code': "YAT",
      },
      {
        'en': "Quarry Bay",
        'zh': "鰂魚涌",
        'code': "QUB",
      },
      {
        'en': "North Point",
        'zh': "北角",
        'code': "NOP",
      },
    ],
  };

  var connectedStopList = {
    'TSY': ['AEL', 'TCL'],
    'NAC': ['TML', 'TCL'],
    'KOW': ['AEL', 'TCL'],
    'HOK': ['AEL', 'TCL'],
  };

  List<String> getConnectedStop(line, code) {
    var connect = connectedStopList[code];

    if (connect != null) {
      if (connect.contains(line)) {
        var result = connect.where((element) => element != line).toList();

        return result;
      }
    }

    return [];
  }

  void fetchConnectedStop(line, code) {
    var connect = connectedStopList[code];
    if (connect != null) {
      if (connect.contains(line)) {
        var result = connect.where((element) => element != line).toList();
        fetchMTRETA(result[0], code);
      }
    }
  }

  String getStopNameByCode(line, code) {
    var result = mtrStops[line]!.firstWhere((e) => e['code'] == code);
    return result['zh']!;
  }

  void onExpansionChanged(int index, bool isExpanded, lineCode, bool reverse) {
    if (!isExpanded) {
      var stopData = mtrStops[lineCode]!;
      int stopListLength = stopData.length;
      var position = reverse ? stopListLength - index - 1 : index;

      fetchMTRETA(lineCode, stopData[position]['code']);
      fetchConnectedStop(lineCode, stopData[position]['code']);
    }
  }

  void fetchMTRETA(line, sta) async {
    String url =
        "https://rt.data.gov.hk/v1/transport/mtr/getSchedule.php?line=$line&sta=$sta";

    var result = await Dio().get(url);

    if (ETAData.value[line] == null) {
      ETAData.value[line] = {};
    }
    ETAData.value[line][sta] = result.data['data']["$line-$sta"];
    ETAData.refresh();
    // log(ETAData.toString());
  }
}
