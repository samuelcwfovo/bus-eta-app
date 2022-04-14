import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bus_eta/TapPageWidget/lrtDetailPage/lrt_eta_controller.dart';
import 'package:bus_eta/TapPageWidget/lrtDetailPage/lrt_detail_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:developer';

class LRTETAPage extends StatelessWidget {
  LRTETAPage({Key? key}) : super(key: key);

  final LRTETAController lrtETAController = Get.put(LRTETAController());
  final LRTDetailController lrtDetailController =
      Get.find<LRTDetailController>();

  @override
  Widget build(BuildContext context) {
    log(lrtETAController.languageCode);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(lrtDetailController.getStopNameByID(Get.arguments)),
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Obx(
            () => lrtETAController.lastUpdateTime.value != ""
                ? Column(
                    children: [
                      Obx(() => Column(
                            children: lrtETAController.ETAData.value
                                .map((e) => Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(
                                                bottom: 1),
                                            child: Text(
                                              e['platform_id'].toString() +
                                                  '號月台',
                                              style: TextStyle(
                                                  color: Colors.white70),
                                            ),
                                          ),
                                          Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: DataTable(
                                                  columnSpacing: 30,
                                                  horizontalMargin: 0,
                                                  // sortColumnIndex:
                                                  //     lrtETAController
                                                  //         .sortColumnIndex
                                                  //         .value,
                                                  // sortAscending:
                                                  //     lrtETAController
                                                  //         .sort.value,
                                                  columns: [
                                                    DataColumn(
                                                        onSort: (columnIndex,
                                                                ascending) =>
                                                            lrtETAController.onSort(
                                                                columnIndex,
                                                                ascending,
                                                                e[
                                                                    'route_list']),
                                                        label: const Text('路線',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                fontSize: 11))),
                                                    DataColumn(
                                                        onSort: (columnIndex,
                                                                ascending) =>
                                                            lrtETAController.onSort(
                                                                columnIndex,
                                                                ascending,
                                                                e[
                                                                    'route_list']),
                                                        label: Text('目的地',
                                                            style: TextStyle(
                                                                fontSize: 11))),
                                                    DataColumn(
                                                        onSort: (columnIndex,
                                                                ascending) =>
                                                            lrtETAController.onSort(
                                                                columnIndex,
                                                                ascending,
                                                                e[
                                                                    'route_list']),
                                                        label: Text('卡數',
                                                            style: TextStyle(
                                                                fontSize: 11))),
                                                    DataColumn(
                                                        onSort: (columnIndex,
                                                                ascending) =>
                                                            lrtETAController.onSort(
                                                                columnIndex,
                                                                ascending,
                                                                e[
                                                                    'route_list']),
                                                        label: Text('下一班車',
                                                            style: TextStyle(
                                                                fontSize: 11)))
                                                  ],
                                                  rows:
                                                      (e['route_list'] as List)
                                                          .map(
                                                              (data) => DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Container(
                                                                          width:
                                                                              40,
                                                                          child:
                                                                              Text(
                                                                            data['route_no'],
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                        )),
                                                                        DataCell(
                                                                            Container(
                                                                          width:
                                                                              140,
                                                                          child:
                                                                              Text(
                                                                            data['dest_' +
                                                                                lrtETAController.languageCode],
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                        )),
                                                                        DataCell(
                                                                            Text(
                                                                          data['train_length'].toString() +
                                                                              "卡",
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        )),
                                                                        DataCell(
                                                                            Text(
                                                                          data['time_' +
                                                                              lrtETAController.languageCode],
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        )),
                                                                      ]))
                                                          .toList())

                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment
                                              //           .spaceBetween,
                                              //   children: const [
                                              //     SizedBox(
                                              //       width: 50,
                                              //       child: Text(
                                              //         '路線',
                                              //         style:
                                              //             TextStyle(fontSize: 11),
                                              //       ),
                                              //     ),
                                              //     SizedBox(
                                              //       width: 100,
                                              //       child: Text('目的地',
                                              //           style: TextStyle(
                                              //               fontSize: 11)),
                                              //     ),
                                              //     SizedBox(
                                              //       width: 50,
                                              //       child: Text('卡數',
                                              //           style: TextStyle(
                                              //               fontSize: 11)),
                                              //     ),
                                              //     SizedBox(
                                              //       width: 60,
                                              //       child: Text(
                                              //         "下一班車",
                                              //         style:
                                              //             TextStyle(fontSize: 11),
                                              //         textAlign: TextAlign.end,
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                              ),
                                          // ...(e['route_list'] as List)
                                          //     .map((data) => Row(
                                          //           mainAxisAlignment:
                                          //               MainAxisAlignment
                                          //                   .spaceBetween,
                                          //           children: [
                                          //             SizedBox(
                                          //               width: 50,
                                          //               child: Text(
                                          //                 data['route_no'],
                                          //                 style: TextStyle(
                                          //                     fontWeight:
                                          //                         FontWeight
                                          //                             .bold),
                                          //               ),
                                          //             ),
                                          //             SizedBox(
                                          //               width: 100,
                                          //               child: Text(
                                          //                   data['dest_ch'],
                                          //                   style: TextStyle(
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w500)),
                                          //             ),
                                          //             SizedBox(
                                          //               width: 50,
                                          //               child: Text(
                                          //                   data['train_length']
                                          //                           .toString() +
                                          //                       "卡",
                                          //                   style: TextStyle(
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w500)),
                                          //             ),
                                          //             SizedBox(
                                          //               width: 60,
                                          //               child: Text(
                                          //                   data['time_ch'],
                                          //                   textAlign:
                                          //                       TextAlign.end,
                                          //                   style: TextStyle(
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w500)),
                                          //             ),
                                          //           ],
                                          //         ))
                                          //     .toList(),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          )),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: Obx(() => Text(
                              "最後更新時間: " +
                                  lrtETAController.lastUpdateTime.value,
                              style: TextStyle(fontSize: 11),
                            )),
                      )
                    ],
                  )
                : Container(
                    // constraints: BoxConstraints.expand(),
                    // child: LoadingIndicator(
                    //     indicatorType: Indicator.ballPulse,

                    //     /// Required, The loading type of the widget
                    //     colors: const [Colors.white],

                    //     /// Optional, The color collections
                    //     strokeWidth: 2,

                    //     /// Optional, The stroke of the line, only applicable to widget which contains line
                    //     backgroundColor: Colors.black,

                    //     /// Optional, Background of the widget
                    //     pathBackgroundColor: Colors.black

                    //     /// Optional, the stroke backgroundColor
                    ),
          ),
        )),
      ),
    );
  }
}
