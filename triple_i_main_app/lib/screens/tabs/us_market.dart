import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:main/bloc/profile.dart';
import 'package:main/bloc/sectorperformance.dart';
import 'package:main/helpers/color_helper.dart';
import 'package:main/models/markets/market_active/market_active.dart';
import 'package:main/models/markets/market_active/market_active_model.dart';
import 'package:main/models/markets/sector_performance/sector_performance_model.dart';
import 'package:main/screens/profile.dart';
import 'package:main/widgets/empty_screen.dart';
import 'package:main/widgets/loading_indicator.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class USMarket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
        ),
        Expanded(child: SingleChildScrollView(child: MarketsPerformance()))
      ],
    );
  }
}

class MarketsPerformance extends StatelessWidget {
  get kSubtitleStyling =>
      TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SectorPerformanceBloc, SectorPerformanceState>(
        builder: (BuildContext context, SectorPerformanceState state) {
      if (state is SectorPerformanceInitial) {
        BlocProvider.of<SectorPerformanceBloc>(context)
            .add(FetchSectorPerformance());
      }

      if (state is SectorPerformanceError) {
        return Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
          child: EmptyScreen(message: state.message),
        );
      }

      if (state is SectorPerformanceLoaded) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Divider(height: 2),

          // Section title.
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 8, left: 10),
            child: Text('Most Active'.tr(), style: kSubtitleStyling),
          ),
          _buildMarketMovers(
              stonks: state.marketActive, color: Color(0xFF263497)),

          // Section title
          Padding(
            padding: EdgeInsets.only(bottom: 8, left: 10),
            child: Text('Top Gainers'.tr(), style: kSubtitleStyling),
          ),
          _buildMarketMovers(stonks: state.marketGainer, color: Colors.green),

          Padding(
            padding: EdgeInsets.only(left: 10, bottom: 8),
            child: Text('Top Losers'.tr(), style: kSubtitleStyling),
          ),
          _buildMarketMovers(stonks: state.marketLoser, color: Colors.red),
          SectorPerformance(performanceData: state.sectorPerformance),
        ]);
      }

      return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
        child: LoadingIndicatorWidget(),
      );
    });
  }

  Widget _buildMarketMovers({MarketMoversModelData stonks, Color color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Container(
        height: 80,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: stonks.marketActiveModelData.length,
            itemBuilder: (BuildContext context, int index) => MarketMovers(
                  data: stonks.marketActiveModelData[index],
                  color: color,
                )),
      ),
    );
  }
}

class MarketMovers extends StatelessWidget {
  final MarketActiveModel data;
  final Color color;

  MarketMovers({
    @required this.data,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 14),
        child: Container(
          child: _buildContent(context),
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
          ),
        ));
  }

  Widget _buildContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Trigger fetch event.
        BlocProvider.of<ProfileBloc>(context)
            .add(FetchProfileData(symbol: data.ticker));

        // Send to Profile.
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => Profile(symbol: data.ticker)));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Ticker Symbol.
          Text(data.ticker,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: Colors.white70)),

          // Change percentage.
          SizedBox(height: 5),
          Text(
            data.changesPercentage,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class SectorPerformance extends StatefulWidget {
  final SectorPerformanceModel performanceData;

  SectorPerformance({@required this.performanceData});

  @override
  _SectorPerformanceState createState() => _SectorPerformanceState();
}

class _SectorPerformanceState extends State<SectorPerformance> {
  var _value = 0.0;
  List<SingleSectorPerformance> get _sectors {
    List<SingleSectorPerformance> a;
    if (_value == 0.0) a = widget.performanceData.realTime.sectors;
    if (_value == 1.0) a = widget.performanceData.oneDay.sectors;
    if (_value == 2.0) a = widget.performanceData.fiveDays.sectors;
    if (_value == 3.0) a = widget.performanceData.oneMonth.sectors;
    if (_value == 4.0) a = widget.performanceData.oneYear.sectors;
    if (_value == 5.0) a = widget.performanceData.tenYears.sectors;
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Card(
            color: Colors.white70,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SfSlider(
                activeColor: Color.fromRGBO(65, 190, 186, 1),
                min: 0.0,
                stepSize: 1.0,
                max: 5.0,
                value: _value,
                labelFormatterCallback: (val, text) {
                  return val == 0.0
                      ? 'Now'
                      : val == 1.0
                          ? '1 D'
                          : val == 2.0
                              ? '5 D'
                              : val == 3.0
                                  ? '1 M'
                                  : val == 4.0
                                      ? '1 Y'
                                      : '10 Y';
                },
                interval: 1,
                showTicks: true,
                showLabels: true,
                onChanged: (dynamic value) {
                  setState(() {
                    _value = value;
                  });
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: ListView.builder(
              shrinkWrap: true,
              addAutomaticKeepAlives: false,
              padding: EdgeInsets.only(top: 10),
              physics: NeverScrollableScrollPhysics(),
              itemCount: _sectors.length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildListTile(sectorPerformance: _sectors[index])),
        ),
      ],
    );
  }

  Widget _buildListTile({SingleSectorPerformance sectorPerformance}) {
    final changeString = sectorPerformance.change.replaceFirst(RegExp('%'), '');
    final change = double.parse(changeString);
    final width = change > 9.99 ? null : 75.5;

    return Column(
      children: <Widget>[
        Card(
          color: Colors.white54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(sectorPerformance.name,
                  style: TextStyle(color: Colors.black)),
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: determineColorBasedOnChange(change),
                ),
                width: width,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  sectorPerformance.change,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
