import 'package:meta/meta.dart';

class StockChart {
  final String date;
  final double open;
  final double high;
  final double low;
  final double adjClose;
  final double volume;
  final double unadjustedVolume;
  final double change;
  final double changePercent;
  final double vwap;
  final double changeOverTime;
  final double close;
  final String label;

  StockChart({
    @required this.open,
    @required this.high,
    @required this.low,
    @required this.adjClose,
    @required this.volume,
    @required this.unadjustedVolume,
    @required this.change,
    @required this.changePercent,
    @required this.vwap,
    @required this.changeOverTime,
    @required this.date,
    @required this.close,
    @required this.label,
  });

  static List<StockChart> toList(List<dynamic> items) {
    return items.map((item) => StockChart.fromJson(item)).toList();
  }

  factory StockChart.fromJson(Map<dynamic, dynamic> json) {
    return StockChart(
      date: json['date'],
      close: json['close'],
      label: json['label'],
      open: json['open'],
      high: json['high'],
      low: json['low'],
      adjClose: json['adjClose'],
      volume: (json['volume'] as num).toDouble(),
      unadjustedVolume: json['unadjustedVolume'],
      change: json['change'],
      changePercent: json['changePercent'],
      vwap: json['vwap'],
      changeOverTime: json['changeOverTime'],
    );
  }
}
