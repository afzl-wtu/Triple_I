import 'package:dio/dio.dart';

import '../helpers/http_helper.dart';
import '../models/profile/market_index.dart';

class IndexClient extends FetchClient {
  Future<List<MarketIndexModel>> fetchIndexes() async {
    final Response<dynamic> response1 =
        await super.financialModelRequest('/api/v3/quote/^DJI');
    final Response<dynamic> response2 =
        await super.financialModelRequest('/api/v3/quote/^GSPC');
    final Response<dynamic> response3 =
        await super.financialModelRequest('/api/v3/quote/^IXIC');
    final Response<dynamic> response4 =
        await super.financialModelRequest('/api/v3/quote/^RUT');
    final Response<dynamic> response5 =
        await super.financialModelRequest('/api/v3/quote/^VIX');
    final response = [
      response1.data[0],
      response2.data[0],
      response3.data[0],
      response4.data[0],
      response5.data[0],
    ];

    return MarketIndexModel.toList(response);
  }
}
