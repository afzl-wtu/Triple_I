import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:meta/meta.dart';
import 'package:easy_localization/easy_localization.dart';

import '../helpers/sentry_helper.dart';
import '../models/search.dart';
import '../repository/search_client.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final _client = SearchClient();

  SearchBloc() : super(SearchInitial()); //SearchBloc(SearchState initialState)

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is FetchSearchHistory) {
      yield SearchLoading();
      yield* _fetchSavedSearches();
    }

    if (event is SaveSearch) {
      await _client.save(symbol: event.symbol);
      yield* _fetchSavedSearches();
    }

    if (event is DeleteSearch) {
      await this._client.delete(symbol: event.symbol);
      yield* _fetchSavedSearches();
    }

    if (event is FetchSearchResults) {
      yield SearchLoading();

      final hasConnection = await DataConnectionChecker().hasConnection;

      if (hasConnection) {
        yield* _fetchSearchResults(symbol: event.symbol);
      } else {
        yield SearchResultsLoadingError(message: 'No internet connection');
      }
    }
  }

  Stream<SearchState> _fetchSavedSearches() async* {
    yield SearchLoading();

    final data = await this._client.fetch();

    yield data.isEmpty
        ? SearchResultsLoadingError(message: 'No recent searches'.tr())
        : SearchData(data: data, listType: ListType.searchHistory);
  }

  Stream<SearchState> _fetchSearchResults({String symbol}) async* {
    try {
      final data = await this._client.searchStock(symbol: symbol);

      yield data.isEmpty
          ? SearchResultsLoadingError(message: 'No results were found')
          : SearchData(data: data, listType: ListType.searchResults);
    } catch (e, stack) {
      yield SearchResultsLoadingError(message: 'There was an error loading');
      await SentryHelper(exception: e, stackTrace: stack).report();
    }
  }
}

@immutable
abstract class SearchEvent {}

class SearchNoConnection extends SearchEvent {}

class FetchSearchHistory extends SearchEvent {}

class FetchSearchResults extends SearchEvent {
  final String symbol;

  FetchSearchResults({@required this.symbol});
}

class SaveSearch extends SearchEvent {
  final String symbol;

  SaveSearch({@required this.symbol});
}

class DeleteSearch extends SearchEvent {
  final String symbol;

  DeleteSearch({@required this.symbol});
}

@immutable
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchData extends SearchState {
  final List<StockSearch> data;
  final ListType listType;

  SearchData({@required this.data, @required this.listType});
}

class SearchResultsLoadingError extends SearchState {
  final String message;

  SearchResultsLoadingError({@required this.message});
}
