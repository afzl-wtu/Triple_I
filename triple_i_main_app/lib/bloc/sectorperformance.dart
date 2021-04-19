import 'dart:async';
import 'package:main/helpers/sentry_helper.dart';
import 'package:main/models/markets/market_active/market_active_model.dart';
import 'package:main/models/markets/sector_performance/sector_performance_model.dart';
import 'package:main/repository/market_client.dart';
import 'package:meta/meta.dart';

import 'package:bloc/bloc.dart';

class SectorPerformanceBloc
    extends Bloc<SectorPerformanceEvent, SectorPerformanceState> {
  SectorPerformanceBloc() : super(SectorPerformanceInitial());

  @override
  Stream<SectorPerformanceState> mapEventToState(
      SectorPerformanceEvent event) async* {
    if (event is FetchSectorPerformance) {
      yield SectorPerformanceLoading();
      yield* _fetchData();
    }
  }

  Stream<SectorPerformanceState> _fetchData() async* {
    try {
      final client = MarketClient();

      yield SectorPerformanceLoaded(
          sectorPerformance: await client.fetchSectorPerformance(),
          marketActive: await client.fetchMarketActive(),
          marketGainer: await client.fetchMarketGainers(),
          marketLoser: await client.fetchMarketLosers());
    } catch (e, stack) {
      await SentryHelper(exception: e, stackTrace: stack).report();
      yield SectorPerformanceError(message: 'There was an unkwon error');
    }
  }
}

@immutable
abstract class SectorPerformanceEvent {}

class FetchSectorPerformance extends SectorPerformanceEvent {}

@immutable
abstract class SectorPerformanceState {}

class SectorPerformanceInitial extends SectorPerformanceState {}

class SectorPerformanceError extends SectorPerformanceState {
  final String message;

  SectorPerformanceError({
    @required this.message,
  });
}

class SectorPerformanceLoading extends SectorPerformanceState {}

class SectorPerformanceLoaded extends SectorPerformanceState {
  final SectorPerformanceModel sectorPerformance;
  final MarketMoversModelData marketActive;
  final MarketMoversModelData marketGainer;
  final MarketMoversModelData marketLoser;

  SectorPerformanceLoaded({
    @required this.sectorPerformance,
    @required this.marketActive,
    @required this.marketGainer,
    @required this.marketLoser,
  });
}
