import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:main/bloc/profile.dart';
import 'package:main/helpers/color_helper.dart';
import 'package:main/screens/profile_tabs/forum_tab.dart';
import 'package:main/screens/profile_tabs/newslist_tab.dart';
import 'package:main/screens/profile_tabs/summary_tab.dart';
import 'package:main/widgets/backgroundGrad.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:main/widgets/empty_screen.dart';
import 'package:main/widgets/loading_indicator.dart';

import '../../models/profile/profile.dart';
import '../../models/storage.dart';
import 'profile_tabs/chart_tab.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  final String symbol;

  ProfileScreen({
    @required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
      if (state is ProfileLoadingError) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(65, 190, 186, 1),
              title: Text(':('),
            ),
            backgroundColor: Colors.black,
            body: Center(child: EmptyScreen(message: state.error)));
      }

      if (state is ProfileLoaded) {
        return ProfileScreen2(
            isSaved: state.isSymbolSaved,
            profile: state.profileModel,
            color: determineColorBasedOnChange(
                state.profileModel.stockProfile.changes));
      }

      return Scaffold(
          body: Stack(children: [
        BackgroundImage(),
        Center(child: LoadingIndicatorWidget())
      ]));
    });
  }
}

class ProfileScreen2 extends StatefulWidget {
  final bool isSaved;
  final Color color;
  final ProfileModel profile;

  ProfileScreen2({
    @required this.isSaved,
    @required this.profile,
    @required this.color,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen2>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: widget.color,
          centerTitle: true,
          title: Text(this.widget.profile.stockQuote.symbol),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            WatchlistButtonWidget(
              storageModel: StorageModel(
                  symbol: widget.profile.stockQuote.symbol,
                  companyName: widget.profile.stockQuote.name),
              isSaved: widget.isSaved,
              color: Colors.white,
            )
          ],
          bottom: TabBar(
            indicatorColor: Theme.of(context).scaffoldBackgroundColor,
            controller: _tabController,
            tabs: [
              Tab(text: 'Summary'.tr()),
              Tab(text: 'Chart'.tr()),
              Tab(
                text: 'News'.tr(),
              ),
              Tab(
                text: 'Forum'.tr(),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            BackgroundImage(),
            TabBarView(controller: _tabController, children: [
              SummaryTab(
                stockProfile: widget.profile.stockProfile,
                stockQuote: widget.profile.stockQuote,
              ),
              ChartTab(
                color: widget.color,
                stockProfile: null,
                stockChart: widget.profile.stockChart,
                stockQuote: widget.profile.stockQuote,
              ),
              NewsListTab(widget.profile.stockQuote.symbol),
              ForumTab(),
            ])
          ],
        ));
  }
}

class WatchlistButtonWidget extends StatefulWidget {
  final Color color;
  final bool isSaved;
  final StorageModel storageModel;

  WatchlistButtonWidget(
      {@required this.color,
      @required this.isSaved,
      @required this.storageModel});

  @override
  _WatchlistButtonWidgetState createState() => _WatchlistButtonWidgetState();
}

class _WatchlistButtonWidgetState extends State<WatchlistButtonWidget> {
  bool isSaved;
  Color color;

  @override
  void initState() {
    this.isSaved = this.widget.isSaved;
    this.color = this.isSaved ? this.widget.color : Color(0X88ffffff);

    super.initState();
  }

  @override
  void dispose() {
    this.isSaved = null;
    this.color = null;

    super.dispose();
  }

  void changeState({bool isSaved, Color color}) {
    setState(() {
      this.isSaved = isSaved;
      this.color = color;
    });
  }

  void onPressedHandler() {
    if (this.isSaved) {
      changeState(isSaved: false, color: Color(0X88ffffff));
//Todos
      //   BlocProvider.of<PortfolioBloc>(context)
      //       .add(DeleteProfile(symbol: this.widget.storageModel.symbol));
      // } else {
      //   changeState(isSaved: true, color: this.widget.color);

      //   BlocProvider.of<PortfolioBloc>(context)
      //       .add(SaveProfile(storageModel: this.widget.storageModel));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        icon: Icon(FontAwesomeIcons.solidBookmark, color: this.color),
        onPressed: () => onPressedHandler());
  }
}
