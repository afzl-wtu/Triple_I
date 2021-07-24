import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../models/search.dart';
import './search_history.dart';
import './search_results.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets//message.dart';
import '../../bloc/search.dart';

Widget buildFloatingSearchBar(
    context, GlobalKey<SliderMenuContainerState> key) {
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

  return BlocBuilder<SearchBloc, SearchState>(
    builder: (_, state) => FloatingSearchBar(
      leadingActions: [
        IconButton(
          icon: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: key.currentState!.animation as Animation<double>),
          onPressed: key.currentState!.toggle,
        )
      ],
      hint: 'Search a Stock...'.tr(),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (value) {
        // Call your model, bloc, controller here.

        if (value.isNotEmpty) {
          BlocProvider.of<SearchBloc>(context)
              .add(FetchSearchResults(symbol: value.toUpperCase()));
        } else {
          BlocProvider.of<SearchBloc>(context).add(FetchSearchHistory());
        }
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: OfflineBuilder(
                child: Text('I am a Hero of Connectivity Builder'),
                connectivityBuilder: (ctx, isConnected, child) => Icon(
                    isConnected == ConnectivityResult.none
                        ? Icons.airplanemode_active
                        : Icons.signal_cellular_alt)),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: searchWindow(context, state),
          ),
        );
      },
    ),
  );
}

Widget searchWindow(context, state) {
  if (state is SearchInitial) {
    BlocProvider.of<SearchBloc>(context).add(FetchSearchHistory());
  }

  if (state is SearchResultsLoadingError) {
    return MessageScreen(message: state.message, action: Container());
  }

  if (state is SearchData) {
    return _buildWrapper(data: state.data, listType: state.listType);
  }

  return Padding(
    padding: EdgeInsets.all(MediaQuery.of(context).size.height / 12),
    child: LoadingIndicatorWidget(),
  );
}

Widget _buildWrapper({required List<StockSearch> data, ListType? listType}) {
  return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (BuildContext ctx, int i) {
        return listType == ListType.searchHistory
            ? SearchHistoryWidget(search: data[i])
            : SearchResultsWidget(search: data[i]);
      });
}
