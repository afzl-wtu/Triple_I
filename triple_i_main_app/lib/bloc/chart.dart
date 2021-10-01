import 'package:bloc/bloc.dart';
import 'package:main/models/chart.dart';
import 'package:main/repository/k_chart/flutter_k_chart.dart';
import 'package:main/repository/profile/client.dart';
import 'package:meta/meta.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  ChartBloc() : super(ChartInitial());
  List<ChartModel> _charts = [];

  @override
  Stream<ChartState> mapEventToState(ChartEvent event) async* {
    _charts[0].charts.forEach((element) {
      print(
          'from: ${element.duration.fromTo.from} to: ${element.duration.fromTo.to}');
    });
    if (event is ResetChart) yield ChartInitial();
    if (event is FetchChartData) {
      yield ChartLoading();
      if (_charts.isNotEmpty) {
        try {
          final a =
              _charts.firstWhere((element) => element.symbol == event.symbol);
          final b = a.charts.firstWhere((element) =>
              element.duration.duration == event.duration.duration &&
              element.duration.fromTo.from == event.duration.fromTo.from &&
              element.duration.fromTo.to == event.duration.fromTo.to);

          yield ChartLoaded(b.datas);
        } catch (e, _) {
          print('PP: In ChartBloc, length of _charts : ${_charts.length}');
          yield* _loadContent(event);
        }
      } else
        yield* _loadContent(event);
    }
  }

  Stream<ChartState> _loadContent(FetchChartData event) async* {
    try {
      final datas = await ProfileClient.getApiChart(
        event.duration.duration,
        event.symbol,
        event.duration.fromTo.from,
        event.duration.fromTo.to,
      );
      try {
        final a =
            _charts.firstWhere((element) => element.symbol == event.symbol);
        try {
          a.charts.firstWhere(
            (element) =>
                element.duration.duration == event.duration.duration &&
                element.duration.fromTo.from == event.duration.fromTo.from &&
                element.duration.fromTo.to == event.duration.fromTo.to,
          );
        } catch (e, _) {
          var a =
              _charts.indexWhere((element) => element.symbol == event.symbol);
          _charts[a].charts.add(SingleChart(event.duration, datas));
        }
      } catch (e, _) {
        _charts.add(
            ChartModel(event.symbol, [SingleChart(event.duration, datas)]));
      }
      // }
      yield ChartLoaded(datas);
    } catch (e, _) {
      yield ChartError(e.toString());
    }
  }
}

@immutable
abstract class ChartState {}

class ChartInitial extends ChartState {}

class ChartLoading extends ChartState {}

class ChartError extends ChartState {
  final String error;

  ChartError(this.error);
}

class ChartLoaded extends ChartState {
  final List<KLineEntity> datas;
  ChartLoaded(this.datas);
}

@immutable
abstract class ChartEvent {}

class ResetChart extends ChartEvent {}

class FetchChartData extends ChartEvent {
  final DurationModel duration;
  final String symbol;

  FetchChartData({
    required this.symbol,
    required this.duration,
  });
}
