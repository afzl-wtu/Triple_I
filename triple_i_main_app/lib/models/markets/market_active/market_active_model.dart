import './market_active.dart';

class MarketMoversModelData {
  final List<MarketActiveModel> marketActiveModelData;

  MarketMoversModelData({required this.marketActiveModelData});

  static List<MarketActiveModel> toList(List<dynamic> items) {
    return items.map((item) => MarketActiveModel.fromJson(item)).toList();
  }
}
