import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:main/repository/k_chart/flutter_k_chart.dart';
import 'package:main/screens/full_chart_screen.dart';
import '../../../models/profile/stock_profile.dart';
import '../../../models/profile/stock_quote.dart';

class ChartTab extends StatelessWidget {
  final Color color;
  final StockQuote stockQuote;
  final StockProfile? stockProfile;

  ChartTab({
    required this.color,
    required this.stockProfile,
    required this.stockQuote,
  });
  Future<void> _jumper(BuildContext ctx) async {
    if (MediaQuery.of(ctx).orientation == Orientation.landscape) {
      Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => FullChartScreen(stockQuote.symbol!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    _jumper(context);
    final _url =
        'https://www.tradingview.com/chart/?symbol=${stockQuote.symbol}';
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(_url)),
    );
  }
}
