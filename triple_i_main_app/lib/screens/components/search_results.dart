import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:main/screens/profile_screen.dart';

import '../../bloc/profile.dart';
import '../../bloc/search.dart';
import '../../models/search.dart';

class SearchResultsWidget extends StatelessWidget {
  final StockSearch search;

  SearchResultsWidget({@required this.search});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.search,
        color: Colors.black,
      ),
      title: Text(
        search.symbol,
        style: TextStyle(color: Colors.black),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProfileScreen(symbol: search.symbol)));

        // Save event.
        BlocProvider.of<SearchBloc>(context)
            .add(SaveSearch(symbol: search.symbol));

        // Fetch profile event.
        BlocProvider.of<ProfileBloc>(context)
            .add(FetchProfileData(symbol: search.symbol));
      },
    );
  }
}
