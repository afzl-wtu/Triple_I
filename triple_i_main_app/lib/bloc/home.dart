import 'package:meta/meta.dart';

import 'package:bloc/bloc.dart';

import '../repository/indexes_client.dart';
import '../models/profile/market_index.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _repository = IndexClient();
  HomeBloc() : super(HomeInitial());

  @override
  Stream<HomeState> mapEventToState(event) async* {
    if (event is FetchHomeData) {
      yield HomeLoading();
      yield* _loadContent();
    }
  }

  Stream<HomeState> _loadContent() async* {
    var indexes;
    try {
      print('In try Block of _loadContent;');
      indexes = await _repository.fetchIndexes();
      yield HomeLoaded(indexes: indexes);
    } catch (e, _) {
      print(
          'In _loadContent in HomeBloc: Error value of e: $e and value of indexes is: $indexes');
    }
  }
}

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeError extends HomeState {
  final String message;
  HomeError({@required this.message});
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<MarketIndexModel> indexes;
  HomeLoaded({@required this.indexes});
}

// class HomeLoaded extends HomeState {
//   final List<MarketIndexModel> indexes;
//   final List<Article> articles;
//   HomeLoaded({@required this.indexes, @required this.articles});
// }

@immutable
abstract class HomeEvent {}

class FetchHomeData extends HomeEvent {}
