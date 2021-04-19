import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../models/profile/profile.dart';
import '../../../models/storage.dart';
import './profile.dart';

class ProfileScreen extends StatelessWidget {
  final bool isSaved;
  final Color color;
  final ProfileModel profile;

  ProfileScreen({
    @required this.isSaved,
    @required this.profile,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: color,
          centerTitle: true,
          title: Text(this.profile.stockQuote.symbol),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            WatchlistButtonWidget(
              storageModel: StorageModel(
                  symbol: profile.stockQuote.symbol,
                  companyName: profile.stockQuote.name),
              isSaved: isSaved,
              color: Colors.white,
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Profile(
            color: color,
            stockProfile: profile.stockProfile,
            stockChart: profile.stockChart,
            stockQuote: profile.stockQuote,
          ),
          // ProfileNewsScreen(news: profile.stockNews,),
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
