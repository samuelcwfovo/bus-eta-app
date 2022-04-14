import 'dart:developer';

import 'package:bus_eta/TapPageWidget/RouteDetailPage/route_detail.dart';
import 'package:bus_eta/TapPageWidget/SearchPage/search_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SearchPage extends StatelessWidget {
  SearchPage({Key? key}) : super(key: key);

  final SearchController searchController = Get.put(SearchController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black45,
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarBrightness: Brightness.light),
            title: TextField(
              onChanged: (str) => searchController.onInput(str),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'search'.tr,
                  labelStyle:
                      const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ),
          body: Obx(
            () => Container(
              child: ListView.builder(
                itemCount: searchController.displayRoutes.value.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => Get.to(RouteDeatailPage(),
                        arguments: searchController.displayRoutes.value[index]
                            ['key']),
                    child: Container(
                        height: 95,
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 0, left: 15, right: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          searchController.displayRoutes
                                              .value[index]['route'],
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (searchController.isSpecialRoute(
                                            searchController.displayRoutes
                                                .value[index]['serviceType']))
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Text('special'.tr,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red)),
                                          )
                                      ],
                                    ),
                                  ),
                                  Text(searchController.getCompanyName(
                                      searchController
                                          .displayRoutes.value[index]['co']))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Container(
                                width: 240,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: Text(
                                            'to'.tr,
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            searchController.displayRoutes
                                                    .value[index]['dest']
                                                [Get.locale!.languageCode],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: Text(
                                            'from'.tr,
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            searchController.displayRoutes
                                                    .value[index]['orig']
                                                [Get.locale!.languageCode],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white60),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )),
                  );
                },
              ),
            ),
          )),
    );
  }
}
