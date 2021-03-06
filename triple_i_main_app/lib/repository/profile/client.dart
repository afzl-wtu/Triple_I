import 'package:dio/dio.dart';
import 'package:main/models/profile/stock_chart.dart';
import 'package:main/repository/k_chart/flutter_k_chart.dart';
// import 'package:main/packages/flutter_k_chart.dart';

import '../../helpers/http_helper.dart';
import '../../keys/api_keys.dart';

import '../../models/profile/profile.dart';

import '../../models/profile/stock_profile.dart';
import '../../models/profile/stock_quote.dart';

class ProfileClient extends FetchClient {
  Future<StockQuote> fetchProfileChanges({String? symbol}) async {
    final Uri uri =
        Uri.https('financialmodelingprep.com', '/api/v3/quote/$symbol');
    final Response<dynamic> response = await FetchClient().fetchData(uri: uri);

    return StockQuote.fromJson(response.data[0]);
  }

  Future<ProfileModel> fetchStockData({String? symbol}) async {
    final Response<dynamic> stockProfile =
        await super.financialModelRequest('/api/v3/company/profile/$symbol');
    final Response<dynamic> stockQuote =
        await super.financialModelRequest('/api/v3/quote/$symbol');

    return ProfileModel(
      stockQuote: StockQuote.fromJson(stockQuote.data[0]),
      stockProfile: StockProfile.fromJson(stockProfile.data['profile']),
    );
  }

  static Future<List<KLineEntity>> getApiChart(
      String currentDuration, String symbol,
      [DateTime? from, DateTime? to]) async {
    Uri url;
    if (currentDuration != '1day') {
      url = Uri.https(
          'financialmodelingprep.com',
          '/api/v3/historical-chart/$currentDuration/$symbol',
          {'apikey': kFinancialModelingPrepApi});
    } else {
      if (from == null) from = DateTime.now().subtract(Duration(days: 60));

      if (to == null) to = DateTime.now();

      url = Uri.https('financialmodelingprep.com',
          '/api/v3/historical-price-full/$symbol', {
        'from': '${from.year}-${from.month}-${from.day}',
        'to': '${to.year}-${to.month}-${to.day}',
        'apikey': kFinancialModelingPrepApi,
      });
    }
    final response = await FetchClient().fetchData(uri: url);
    final datas = StockChart.toList(currentDuration != '1day'
            ? response.data
            : response.data['historical'])
        .map((a) => KLineEntity.fromCustom(
              time: DateTime.parse(a.date!).millisecondsSinceEpoch,
              open: a.open!,
              close: a.close!,
              change: a.change,
              high: a.high!,
              low: a.low!,
              vol: a.volume,
              amount: 123,
            ))
        .toList()
        .reversed
        .toList()
        .cast<KLineEntity>();
    return datas;
  }
}
