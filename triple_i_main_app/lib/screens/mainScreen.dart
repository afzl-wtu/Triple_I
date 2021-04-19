import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:main/widgets/backgroundGrad.dart';

import './components/search.dart';
import './components/drawer.dart';
import './tabs/home.dart';
import 'tabs/us_market.dart';
import './tabs/notification.dart';
import './tabs/search.dart';
import './tabs/world.dart';

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
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTapBottomBar,
        activeColor: Color.fromRGBO(65, 190, 186, 1),
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.suitcase),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.workspaces_filled),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
          ),
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
          World(),
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
