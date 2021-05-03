import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:main/widgets/backgroundGrad.dart';

import './components/search.dart';
import './components/drawer.dart';
import './tabs/home.dart';
import 'tabs/us_market.dart';
import './tabs/notification.dart';
import './tabs/search.dart';
import 'tabs/articles.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final pageController = PageController();
  var drawerStatus = FSBStatus.FSB_CLOSE;

  int pageIndex = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int abc) {
    setState(() {
      pageIndex = abc;
    });
  }

  void onTapBottomBar(int selectedTab) {
    print(selectedTab);
    pageController.jumpToPage(selectedTab);
  }

  void drawerToogle() {
    setState(() {
      drawerStatus = drawerStatus == FSBStatus.FSB_OPEN
          ? FSBStatus.FSB_CLOSE
          : FSBStatus.FSB_OPEN;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FoldableSidebarBuilder(
        drawerBackgroundColor: Color.fromRGBO(65, 190, 186, 1),
        status: drawerStatus,
        drawer: CustomDrawer(
          closeDrawer: drawerToogle,
        ),
        screenContents: buildStack(context, drawerToogle),
      ), //,
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: pageIndex,
        onItemSelected: onTapBottomBar,
        //color: Color.fromRGBO(65, 190, 186, 1),
        backgroundColor: Colors.white,
        items: [
          BottomNavyBarItem(
              inactiveColor: Colors.black54,
              icon: Icon(Icons.domain),
              title: Text('Home'),
              activeColor: Color.fromRGBO(65, 190, 186, 1)),
          BottomNavyBarItem(
              inactiveColor: Colors.black54,
              icon: Icon(Icons.insert_chart),
              title: Text('US Markets'),
              activeColor: Color.fromRGBO(65, 190, 186, 1)),
          BottomNavyBarItem(
              inactiveColor: Colors.black54,
              icon: Icon(Icons.backup_table),
              title: Text('Watchlist'),
              activeColor: Color.fromRGBO(65, 190, 186, 1)),
          BottomNavyBarItem(
              inactiveColor: Colors.black54,
              icon: Icon(
                Icons.dashboard,
              ),
              title: Text('Articles'),
              activeColor: Color.fromRGBO(65, 190, 186, 1)),
        ],
      ),
    );
  }

  Stack buildStack(BuildContext context, Function drawerToogle) {
    return Stack(children: [
      BackgroundImage(),
      PageView(
        children: [
          Home(),
          USMarket(),
          SSearch(),
          ArticlesTab(),
          NNotification(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      buildFloatingSearchBar(context, drawerToogle),
    ]);
  }
}
