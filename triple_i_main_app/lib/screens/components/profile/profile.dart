import 'package:flutter/material.dart';

import '../../../helpers/color_helper.dart';
import '../../../helpers/text_helper.dart';
import '../../../models/profile/stock_chart.dart';
import '../../../models/profile/stock_profile.dart';
import '../../../models/profile/stock_quote.dart';
import './profile_graph.dart';
import './profile_summary.dart';

class Profile extends StatelessWidget {
  final Color color;
  final StockQuote stockQuote;
  final StockProfile stockProfile;
  final List<StockChart> stockChart;

  Profile({
    @required this.color,
    @required this.stockProfile,
    @required this.stockQuote,
    @required this.stockChart,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(left: 26, right: 26, top: 26),
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.stockQuote.name ?? '-', style: TextStyle(fontSize: 25)),
            _buildPrice(),
            Container(
                height: 250,
                padding: EdgeInsets.only(top: 26),
                child: SimpleTimeSeriesChart(
                    chart: this.stockChart, color: this.color)),
            StatisticsWidget(
              quote: stockQuote,
              profile: stockProfile,
            )
          ],
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('\$${formatText(stockQuote.price)}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
              '${determineTextBasedOnChange(stockQuote.change)}  (${determineTextPercentageBasedOnChange(stockQuote.changesPercentage)})',
              style: determineTextStyleBasedOnChange(stockQuote.change))
        ],
      ),
    );
  }
}
