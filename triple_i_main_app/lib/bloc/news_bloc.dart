import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:main/repository/news/repository.dart';
import 'package:meta/meta.dart';

import '../helpers/sentry_helper.dart';

import '../models/news/news.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final _newsRepository = NewsRepository();
  //final _databaseRepository = HomeStorageClient();

  NewsBloc() : super(NewsInitial());

  @override
  Stream<NewsState> mapEventToState(NewsEvent event) async* {
    if (event is FetchNews) {
      yield NewsLoading();
      yield* _fetchNews();
    }
  }

  Stream<NewsState> _fetchNews() async* {
    try {
      final symbolsStored = []; //await this._databaseRepository.fetch();

      if (symbolsStored.isNotEmpty) {
        final news = await Future.wait(symbolsStored.map((symbol) async =>
            await _newsRepository.fetchNews(title: symbol.companyName)));

        yield NewsLoaded(news: news);
      } else {
        final news = await Future.wait(['Dow Jones', 'S&P 500', 'Nasdaq'].map(
            (symbol) async => await _newsRepository.fetchNews(title: symbol)));

        yield NewsLoaded(news: news);
      }
    } catch (e, stack) {
      yield NewsError(message: 'There was an error loading');
      await SentryHelper(exception: e, stackTrace: stack).report();
    }
  }
}

@immutable
abstract class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsError extends NewsState {
  final String message;

  NewsError({required this.message});
}

class NewsLoaded extends NewsState {
  final List<NewsDataModel> news;

  NewsLoaded({required this.news});
}

@immutable
abstract class NewsEvent {}

class FetchNews extends NewsEvent {}
