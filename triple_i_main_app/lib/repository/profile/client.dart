import 'package:dio/dio.dart';

import '../../helpers/http_helper.dart';
import '../../keys/api_keys.dart';

import '../../models/profile/profile.dart';
import '../../models/profile/stock_chart.dart';

import '../../models/profile/stock_profile.dart';
import '../../models/profile/stock_quote.dart';

class ProfileClient extends FetchClient {
  Future<StockQuote> fetchProfileChanges({String symbol}) async {
    final Uri uri =
        Uri.https('financialmodelingprep.com', '/api/v3/quote/$symbol');
    final Response<dynamic> response = await FetchClient().fetchData(uri: uri);

    return StockQuote.fromJson(response.data[0]);
  }

  Future<ProfileModel> fetchStockData({String symbol}) async {
    final Response<dynamic> stockProfile =
        await super.financialModelRequest('/api/v3/company/profile/$symbol');
    final Response<dynamic> stockQuote =
        await super.financialModelRequest('/api/v3/quote/$symbol');
    final Response<dynamic> stockChart = await _fetchChart(symbol: symbol);

    return ProfileModel(
      stockQuote: StockQuote.fromJson(stockQuote.data[0]),
      stockProfile: StockProfile.fromJson(stockProfile.data['profile']),
      stockChart: StockChart.toList(stockChart.data['historical']),
    );
  }

  static Future<Response> _fetchChart({String symbol}) async {
    final DateTime date = DateTime.now();
    final Uri uri = Uri.https(
        'financialmodelingprep.com', '/api/v3/historical-price-full/$symbol', {
      'from': '${date.year - 1}-${date.month}-${date.day}',
      'to': '${date.year}-${date.month}-${date.day - 1}',
      'apikey': kFinancialModelingPrepApi
    });

    return await FetchClient().fetchData(uri: uri);
  }
}
