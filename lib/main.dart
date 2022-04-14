import 'package:bus_eta/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bus_eta/main_controller.dart';

import 'package:bus_eta/TapPageWidget/NearByPage/near_by.dart';
import 'package:bus_eta/TapPageWidget/SearchPage/search_page.dart';
import 'package:bus_eta/TapPageWidget/BookmarkPage/bookmark.dart';
import 'package:bus_eta/TapPageWidget/MtrPage/mtr.dart';
import 'package:bus_eta/TapPageWidget/SettingPage/setting_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MainLayout(),
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.fallbackLocale,
      translations: LocalizationService(),
      theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.black),
    );
  }
}

class MainLayout extends StatelessWidget {
  MainLayout({Key? key}) : super(key: key);

  final MainController mainController = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    mainController.buildContext = context;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => mainController.selectedTabIndex.value != 0
            ? const Text('HK BUS')
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('HK BUS'),
                  GestureDetector(
                      onTap: mainController.onAddFavouriteGroupTap,
                      child: const Icon(Icons.post_add_outlined))
                ],
              )),
        backgroundColor: Colors.black26,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black26,
            statusBarBrightness: Brightness.light),
      ),
      body: TabPage(),
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: 'search'.tr,
        color: Colors.grey,
        selectedColor: Colors.red,
        notchedShape: const CircularNotchedRectangle(),
        onTabSelected: mainController.onTabclick,
        items: [
          FABBottomAppBarItem(iconData: Icons.bookmarks, text: 'bookmark'.tr),
          FABBottomAppBarItem(iconData: Icons.location_on, text: 'nearby'.tr),
          FABBottomAppBarItem(iconData: Icons.train, text: 'mtr'.tr),
          FABBottomAppBarItem(iconData: Icons.settings, text: 'setting'.tr),
        ],
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => SearchPage()),
        child: const Icon(Icons.search),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class FABBottomAppBarItem {
  FABBottomAppBarItem({required this.iconData, required this.text});
  IconData iconData;
  String text;
}

class FABBottomAppBar extends StatefulWidget {
  FABBottomAppBar({
    Key? key,
    required this.items,
    required this.centerItemText,
    this.height = 60.0,
    this.iconSize = 24.0,
    required this.backgroundColor,
    required this.color,
    required this.selectedColor,
    required this.notchedShape,
    required this.onTabSelected,
  }) : super(key: key) {
    assert(items.length == 2 || items.length == 4);
  }
  final List<FABBottomAppBarItem> items;
  final String centerItemText;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  _updateIndex(int index) {
    widget.onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });
    items.insert(items.length >> 1, _buildMiddleTabItem());

    return BottomAppBar(
      shape: widget.notchedShape,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
      color: widget.backgroundColor,
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: widget.iconSize),
            Text(
              widget.centerItemText,
              style: TextStyle(color: widget.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required FABBottomAppBarItem item,
    required int index,
    required ValueChanged<int> onPressed,
  }) {
    final MainController mainController = Get.find<MainController>();

    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Obx(() => Icon(item.iconData,
                    color: mainController.selectedTabIndex.value == index
                        ? widget.selectedColor
                        : widget.color,
                    size: widget.iconSize)),
                Obx(() => Text(
                      item.text,
                      style: TextStyle(
                          color: mainController.selectedTabIndex.value == index
                              ? widget.selectedColor
                              : widget.color),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabPage extends StatelessWidget {
  TabPage({Key? key}) : super(key: key);

  // final MainController mainController = Get.put(MainController());
  final MainController mainController = Get.find<MainController>();

  List<Widget> tabPageWidgetList() {
    return [
      Bookmark(),
      NearBy(),
      MTR(),
      SettingPage(),
    ];
  }

  @override
  Widget build(context) {
    return Obx(
        () => tabPageWidgetList()[mainController.selectedTabIndex.value]);
  }
}
