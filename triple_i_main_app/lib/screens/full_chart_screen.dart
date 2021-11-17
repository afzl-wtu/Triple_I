import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FullChartScreen extends StatelessWidget {
  final String symbol;

  FullChartScreen(this.symbol);

  Future<void> _jumper(BuildContext context) async {
    final _orientation = MediaQuery.of(context).orientation;
    if (_orientation == Orientation.portrait) {
      Navigator.pop(context);
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    } else {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    _jumper(context);
    final _url = 'https://www.tradingview.com/chart/?symbol=$symbol';
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(_url)),
      ),
    );
  }
}
