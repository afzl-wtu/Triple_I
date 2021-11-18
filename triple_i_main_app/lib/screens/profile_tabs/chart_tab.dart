import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:main/repository/k_chart/flutter_k_chart.dart';
import '../../../models/profile/stock_profile.dart';
import '../../../models/profile/stock_quote.dart';

class ChartTab extends StatefulWidget {
  final Color color;
  final StockQuote stockQuote;
  final StockProfile? stockProfile;

  ChartTab({
    required this.color,
    required this.stockProfile,
    required this.stockQuote,
  });

  @override
  State<ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final _url =
        'https://www.tradingview.com/chart/?symbol=${widget.stockQuote.symbol}';
    return InAppWebView(
      initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
              forceDark: AndroidForceDark.FORCE_DARK_ON)),
      initialUrlRequest: URLRequest(url: Uri.parse(_url)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
