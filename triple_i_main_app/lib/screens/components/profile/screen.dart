import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:main/models/news/news.dart';
import 'package:main/models/news/single_new_model.dart';
import 'package:main/repository/news/repository.dart';
import 'package:main/screens/components/news_tile.dart';
import 'package:main/widgets/backgroundGrad.dart';
import 'package:main/widgets/loading_indicator.dart';

import '../../../models/profile/profile.dart';
import '../../../models/storage.dart';
import './profile.dart';

class ProfileScreen extends StatefulWidget {
  final bool isSaved;
  final Color color;
  final ProfileModel profile;

  ProfileScreen({
    @required this.isSaved,
    @required this.profile,
    @required this.color,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
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
              Tab(text: 'Chart'),
              Tab(
                text: 'News',
              )
            ],
          ),
        ),
        body: Stack(
          children: [
            BackgroundImage(),
            TabBarView(controller: _tabController, children: [
              Profile(
                color: widget.color,
                stockProfile: widget.profile.stockProfile,
                stockChart: widget.profile.stockChart,
                stockQuote: widget.profile.stockQuote,
              ),
              NewsListTab(widget.profile.stockQuote.symbol)
            ])
          ],
        ));
  }
}

class NewsListTab extends StatelessWidget {
  final nc = NewsRepository();
  final String companySymbol;
  NewsListTab(this.companySymbol);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: nc.fetchNews(specificSymbol: companySymbol),
      builder: (_, data) {
        if (!(data.connectionState == ConnectionState.waiting)) {
          final newsList = (data.data as NewsDataModel).news;
          return ListView.builder(
              itemCount: newsList.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return NewsTile(
                  imgUrl: newsList[index].urlToImage ?? "",
                  title: newsList[index].title ?? "",
                  desc: newsList[index].description ?? "",
                  content: "Here is Content",
                  posturl: newsList[index].url ?? "",
                );
              });
        } else {
          return LoadingIndicatorWidget();
        }
      },
    );
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
