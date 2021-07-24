import 'package:flutter/material.dart';
import 'package:main/models/news/news.dart';
import 'package:main/repository/news/repository.dart';
import 'package:main/screens/components/news_tile.dart';
import 'package:main/widgets/loading_indicator.dart';

class NewsListTab extends StatelessWidget {
  final nc = NewsRepository();
  final String? companySymbol;
  NewsListTab(this.companySymbol);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: nc.fetchNews(specificSymbol: companySymbol),
      builder: (_, data) {
        if (!(data.connectionState == ConnectionState.waiting)) {
          final newsList = (data.data as NewsDataModel).news;
          return ListView.builder(
              itemCount: newsList.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return NewsTile(
                  imgUrl: newsList[index].urlToImage ?? "",
                  title: newsList[index].title ?? "",
                  desc: newsList[index].description ?? "",
                  //Todo: May be translate it.
                  content: "Here is Content",
                  posturl: newsList[index].url ?? "",
                );
              });
        } else {
          return LoadingIndicatorWidget();
        }
      },
    );
  }
}
