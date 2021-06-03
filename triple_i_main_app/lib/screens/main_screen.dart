import 'package:flutter/material.dart';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:easy_localization/easy_localization.dart';

import '../widgets/backgroundGrad.dart';
import './components/search.dart';
import './components/drawer.dart';
import './tabs/articles_tab.dart';
import './tabs/community_tab.dart';
import './tabs/markets_tab.dart';
import './tabs/news_tab.dart';
import './tabs/watchlist_tab.dart';

//flutter pub run easy_localization:generate -S "assets/translations/" -O "lib/"

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final pageController = PageController(initialPage: 2);
  final GlobalKey<SliderMenuContainerState> _drawerKey =
      GlobalKey<SliderMenuContainerState>();

  int pageIndex = 2;

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

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SliderMenuContainer(
        slideDirection:
            EasyLocalization.of(context).currentLocale == Locale('he')
                ? SlideDirection.RIGHT_TO_LEFT
                : SlideDirection.LEFT_TO_RIGHT,
        key: _drawerKey,
        hasAppBar: false,
        sliderMenu: CustomDrawer(_drawerKey),
        sliderMain: Scaffold(
          backgroundColor: Colors.black,
          body: buildStack(context),
          bottomNavigationBar: BottomNavyBar(
            selectedIndex: pageIndex,
            onItemSelected: onTapBottomBar,
            //color: Color.fromRGBO(65, 190, 186, 1),
            backgroundColor: Colors.white,
            items: [
              BottomNavyBarItem(
                  inactiveColor: Colors.black54,
                  icon: Icon(Icons.domain),
                  title: Text('News'.tr()),
                  activeColor: Color.fromRGBO(65, 190, 186, 1)),
              BottomNavyBarItem(
                  inactiveColor: Colors.black54,
                  icon: Icon(Icons.backup_table),
                  title: Text('Watchlist'.tr()),
                  activeColor: Color.fromRGBO(65, 190, 186, 1)),
              BottomNavyBarItem(
                  inactiveColor: Colors.black54,
                  icon: Icon(Icons.insert_chart),
                  title: Text('US Markets').tr(),
                  activeColor: Color.fromRGBO(65, 190, 186, 1)),
              BottomNavyBarItem(
                  inactiveColor: Colors.black54,
                  icon: Icon(
                    Icons.dashboard,
                  ),
                  title: Text('Articles'.tr()),
                  activeColor: Color.fromRGBO(65, 190, 186, 1)),
              BottomNavyBarItem(
                  inactiveColor: Colors.black54,
                  icon: Icon(Icons.people),
                  title: Text('Community'.tr()),
                  activeColor: Color.fromRGBO(65, 190, 186, 1)),
            ],
          ),
        ),
      ),
    );
  }

  Stack buildStack(BuildContext context) {
    return Stack(children: [
      BackgroundImage(),
      PageView(
        children: [
          NewsTab(),
          WatchlistTab(),
          MarketsTab(),
          ArticlesTab(),
          CommunityTab(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      buildFloatingSearchBar(context, _drawerKey),
    ]);
  }
}
