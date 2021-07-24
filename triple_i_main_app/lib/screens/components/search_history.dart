import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/profile.dart';
import '../../bloc/search.dart';
import '../../models/search.dart';
import '../profile_screen.dart';

class SearchHistoryWidget extends StatelessWidget {
  final StockSearch search;

  SearchHistoryWidget({required this.search});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(
          Icons.history,
          color: Colors.black,
        ),
        title: Text(
          search.symbol!,
          style: TextStyle(color: Colors.black),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProfileScreen(symbol: search.symbol)));

          BlocProvider.of<ProfileBloc>(context)
              .add(FetchProfileData(symbol: search.symbol));
        },
        trailing: IconButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            icon: Icon(
              Icons.clear,
              color: Colors.black,
            ),
            onPressed: () {
              BlocProvider.of<SearchBloc>(context)
                  .add(DeleteSearch(symbol: search.symbol));
            }));
  }
}
