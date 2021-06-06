import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:main/helpers/text_helper.dart';
import 'package:main/models/profile/stock_profile.dart';
import 'package:main/models/profile/stock_quote.dart';

class SummaryTab extends StatelessWidget {
  final StockQuote stockQuote;

  final StockProfile stockProfile;

  const SummaryTab({@required this.stockQuote, @required this.stockProfile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StatisticsWidget(
          quote: stockQuote,
          profile: stockProfile,
        ),
      ),
    );
  }
}

class StatisticsWidget extends StatelessWidget {
  final StockQuote quote;
  final StockProfile profile;

  StatisticsWidget({@required this.quote, @required this.profile});

  static Text _renderText(dynamic text) {
    return text != null ? Text(compactText(text)) : Text('-');
  }

  List<Widget> _leftColumn() {
    return [
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Open'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.open)),
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Prev close'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.previousClose)),
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Day High'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.dayHigh)),
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Day Low'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.dayLow)),
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('52 WK High'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.yearHigh)),
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('52 WK Low'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.dayLow)),
    ];
  }

  List<Widget> _rightColumn() {
    return [
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Outstanding Shares'.tr(),
              style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.sharesOutstanding)),
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Volume'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.volume)),
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Avg Vol'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.avgVolume)),
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('MKT Cap'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.marketCap)),
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('P/E Ratio'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.pe)),
      ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('EPS'.tr(), style: TextStyle(color: Colors.white)),
          trailing: _renderText(quote.eps)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 16),
        Text('Summary'.tr(), style: TextStyle(fontSize: 25)),
        SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(children: _leftColumn()),
            ),
            SizedBox(width: 40),
            Expanded(
              child: Column(children: _rightColumn()),
            )
          ],
        ),
        Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('CEO'.tr(), style: TextStyle(color: Colors.white)),
          trailing: Text(displayDefaultTextIfNull(profile.ceo)),
        ),
        Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Sector'.tr(), style: TextStyle(color: Colors.white)),
          trailing: Text(displayDefaultTextIfNull(profile.sector)),
        ),
        Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Exchange'.tr(), style: TextStyle(color: Colors.white)),
          trailing: Text('${profile.exchange}'),
        ),
        Divider(),
        Text('${'About'.tr()} ${profile.companyName ?? '-'} ',
            style: TextStyle(fontSize: 25)),
        SizedBox(height: 8),
        Text(
          profile.description ?? '-',
          style: TextStyle(fontSize: 16, color: Colors.white, height: 1.75),
        ),
        Divider(),
        SizedBox(height: 30),
      ],
    );
  }
}
