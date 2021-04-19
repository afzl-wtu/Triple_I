import 'package:dio/dio.dart';

import '../helpers/http_helper.dart';
import '../models/profile/market_index.dart';

class IndexClient extends FetchClient {
  Future<List<MarketIndexModel>> fetchIndexes() async {
    final Response<dynamic> response = await super
        .financialModelRequest('/api/v3/quote/^DJI,^GSPC,^IXIC,^RUT,^VIX');
    print(response);
    return MarketIndexModel.toList(response.data);
  }
}
