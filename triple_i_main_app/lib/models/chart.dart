//Map<String, Map<Map<String,Map<String,DateTime>>, List<KLineEntity>>>
import 'package:main/repository/k_chart/flutter_k_chart.dart';

class ChartModel {
  final String symbol;
  List<SingleChart> charts;

  ChartModel(this.symbol, this.charts);
}

class SingleChart {
  final DurationModel duration;
  final List<KLineEntity> datas;

  SingleChart(
    this.duration,
    this.datas,
  );
}

class DurationModel {
  final String duration;
  final FromTo fromTo;

  DurationModel(this.duration, this.fromTo);
}

class FromTo {
  final DateTime? from;
  final DateTime? to;

  FromTo([this.from, this.to]);
}
