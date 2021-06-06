import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../../helpers/color_helper.dart';
import '../../../helpers/text_helper.dart';
import '../../../models/profile/stock_chart.dart';
import '../../../models/profile/stock_profile.dart';
import '../../../models/profile/stock_quote.dart';

class ChartTab extends StatelessWidget {
  final Color color;
  final StockQuote stockQuote;
  final StockProfile stockProfile;
  final List<StockChart> stockChart;

  ChartTab({
    @required this.color,
    @required this.stockProfile,
    @required this.stockQuote,
    @required this.stockChart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 26, right: 26, top: 26),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(this.stockQuote.name ?? '-',
                          style: TextStyle(fontSize: 25)),
                      _buildPrice(),
                      Container(
                          height: 250,
                          padding: EdgeInsets.only(top: 26),
                          child: SimpleTimeSeriesChart(
                              chart: this.stockChart, color: this.color)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<StockChart> chart;

  final Color color;

  SimpleTimeSeriesChart({@required this.chart, @required this.color});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      [
        charts.Series<RowData, DateTime>(
          id: 'Cost',
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(color),
          domainFn: (RowData row, _) => row.timeStamp,
          measureFn: (RowData row, _) => row.cost,
          data: this
              .chart
              .map((item) => RowData(
                  timeStamp: DateTime.parse(item.date), cost: item.close))
              .toList(),
        ),
      ],
      animate: false,
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(desiredTickCount: 1),
          renderSpec: charts.NoneRenderSpec()),
    );
  }
}

/// Sample time series data type.
class RowData {
  final DateTime timeStamp;
  final double cost;
  RowData({this.timeStamp, this.cost});
}
