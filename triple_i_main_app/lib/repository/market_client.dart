import 'package:dio/dio.dart';
import 'package:main/helpers/http_helper.dart';
import 'package:main/models/markets/market_active/market_active_model.dart';
import 'package:main/models/markets/sector_performance/sector_performance_model.dart';

class MarketClient extends FetchClient {
  /// Fetches sector performance and returns [SectorPerformanceModel].
  Future<SectorPerformanceModel> fetchSectorPerformance() async {
    final Response<dynamic> response = await super.fetchData(
        uri: Uri.https('www.alphavantage.co', '/query',
            {'function': 'SECTOR', 'apikey': 'demo'}));

    return SectorPerformanceModel(
      realTime: SectorPerformanceDataModel.fromJson(
          response.data['Rank A: Real-Time Performance']),
      oneDay: SectorPerformanceDataModel.fromJson(
          response.data['Rank B: 1 Day Performance']),
      fiveDays: SectorPerformanceDataModel.fromJson(
          response.data['Rank C: 5 Day Performance']),
      oneMonth: SectorPerformanceDataModel.fromJson(
          response.data['Rank D: 1 Month Performance']),
      oneYear: SectorPerformanceDataModel.fromJson(
          response.data['Rank G: 1 Year Performance']),
      tenYears: SectorPerformanceDataModel.fromJson(
          response.data['Rank J: 10 Year Performance']),
    );
  }

  /// Fetches market most active stocks and retuns [MarketMoversModelData].
  Future<MarketMoversModelData> fetchMarketActive() async {
    final Response<dynamic> response =
        await super.financialModelRequest('/api/v3/stock/actives');
    return MarketMoversModelData(
        marketActiveModelData:
            MarketMoversModelData.toList(response.data['mostActiveStock']));
  }

  /// Fetches market most gainer stocks and retuns [MarketMoversModelData].
  Future<MarketMoversModelData> fetchMarketGainers() async {
    final Response<dynamic> response =
        await super.financialModelRequest('/api/v3/stock/gainers');
    return MarketMoversModelData(
        marketActiveModelData:
            MarketMoversModelData.toList(response.data['mostGainerStock']));
  }

  /// Fetches market most loser stocks and retuns [MarketMoversModelData].
  Future<MarketMoversModelData> fetchMarketLosers() async {
    final Response<dynamic> response =
        await super.financialModelRequest('/api/v3/stock/losers');
    return MarketMoversModelData(
        marketActiveModelData:
            MarketMoversModelData.toList(response.data['mostLoserStock']));
  }
}
