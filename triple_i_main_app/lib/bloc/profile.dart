import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../helpers/sentry_helper.dart';
import '../models/profile/profile.dart';

import '../repository/profile/client.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final _httpClient = ProfileClient();
  //final _storageClient = PortfolioStorageClient();

  ProfileBloc() : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is FetchProfileData) {
      yield ProfileLoading();
      yield* _mapProfileState(symbol: event.symbol);
    }
  }

  Stream<ProfileState> _mapProfileState({String symbol}) async* {
    try {
      yield ProfileLoaded(
          profileModel: await this._httpClient.fetchStockData(symbol: symbol),
          isSymbolSaved: false
          //await this._storageClient.symbolExists(symbol: symbol)
          );
    } catch (e, stack) {
      yield ProfileLoadingError(error: 'Symbol not supported.');
      await SentryHelper(exception: e, stackTrace: stack).report();
    }
  }
}

@immutable
abstract class ProfileEvent {}

class FetchProfileData extends ProfileEvent {
  final String symbol;

  FetchProfileData({@required this.symbol});
}

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileNoConnection extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoadingError extends ProfileState {
  final dynamic error;

  ProfileLoadingError({@required this.error});
}

class ProfileLoaded extends ProfileState {
  final ProfileModel profileModel;
  final bool isSymbolSaved;

  ProfileLoaded({
    @required this.profileModel,
    @required this.isSymbolSaved,
  });
}
