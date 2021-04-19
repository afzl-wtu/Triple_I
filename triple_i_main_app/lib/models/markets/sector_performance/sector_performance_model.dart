import 'package:meta/meta.dart';

// This is the main model.
class SectorPerformanceModel {
  final SectorPerformanceDataModel oneDay;
  final SectorPerformanceDataModel fiveDays;
  final SectorPerformanceDataModel oneMonth;
  final SectorPerformanceDataModel oneYear;
  final SectorPerformanceDataModel tenYears;
  final SectorPerformanceDataModel realTime;

  SectorPerformanceModel({
    @required this.realTime,
    @required this.oneDay,
    @required this.fiveDays,
    @required this.oneMonth,
    @required this.oneYear,
    @required this.tenYears,
  });
}

class SectorPerformanceDataModel {
  final List<SingleSectorPerformance> sectors;

  SectorPerformanceDataModel({@required this.sectors});

  factory SectorPerformanceDataModel.fromJson(Map<String, dynamic> json) {
    return SectorPerformanceDataModel(
        sectors: json.entries
            .map((entry) =>
                SingleSectorPerformance(change: entry.value, name: entry.key))
            .toList());
  }
}

class SingleSectorPerformance {
  final String name;
  final String change;

  SingleSectorPerformance({@required this.name, @required this.change});
}
