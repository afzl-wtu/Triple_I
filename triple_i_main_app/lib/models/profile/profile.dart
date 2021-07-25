import './stock_profile.dart';
import './stock_quote.dart';
//import './stock_chart.dart';

class ProfileModel {
  final StockProfile stockProfile;
  final StockQuote stockQuote;
  //final List<StockChart> stockChart;

  ProfileModel({
    required this.stockProfile,
    required this.stockQuote,
    //@required this.stockChart,
  });
}
