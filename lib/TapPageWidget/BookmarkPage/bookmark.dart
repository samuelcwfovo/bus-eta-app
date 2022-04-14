import 'package:flutter/material.dart';
import 'package:bus_eta/TapPageWidget/BookmarkPage/bookmark_controller.dart';
import 'package:get/get.dart';
import 'package:bus_eta/main_controller.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

class Bookmark extends StatelessWidget {
  Bookmark({Key? key}) : super(key: key);

  final BookmarkController bookmarkController = Get.put(BookmarkController());
  final MainController mainController = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    bookmarkController.buildContext = context;

    return Column(
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(top: 8, right: 20),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       ElevatedButton(
        //         child: Text('add'),
        //         onPressed: () {},
        //       )
        //     ],
        //   ),
        // ),
        Expanded(
          child: Obx(() => DragAndDropLists(
                children: bookmarkController.contents.value,
                onItemReorder: bookmarkController.onItemReorder,
                onListReorder: bookmarkController.onListReorder,
                listPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                itemDivider: Divider(
                  thickness: 2,
                  height: 2,
                  color: Theme.of(context).canvasColor,
                ),
                itemDecorationWhileDragging: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.05),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                // listDecoration: BoxDecoration(
                //   color: Theme.of(context).cardColor,
                //   borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                // ),
                listInnerDecoration: BoxDecoration(
                  color: Theme.of(context).hoverColor,
                ),
                lastItemTargetHeight: 8,
                addLastItemTargetHeightToTop: true,
                lastListTargetSize: 40,
                listDragHandle: const DragHandle(
                  verticalAlignment: DragHandleVerticalAlignment.top,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10, top: 8),
                    child: Icon(
                      Icons.menu,
                      color: Colors.white24,
                    ),
                  ),
                ),
                itemDragHandle: DragHandle(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.menu,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
