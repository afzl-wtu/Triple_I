import 'package:flutter/material.dart';
import 'package:main/models/news/news.dart';
import 'package:main/repository/news/repository.dart';
import 'package:main/screens/components/news_tile.dart';
import 'package:main/widgets/loading_indicator.dart';

class NewsListTab extends StatefulWidget {
  final String? companySymbol;
  NewsListTab(this.companySymbol);

  @override
  State<NewsListTab> createState() => _NewsListTabState();
}

class _NewsListTabState extends State<NewsListTab>
    with AutomaticKeepAliveClientMixin {
  final nc = NewsRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: nc.fetchNews(specificSymbol: widget.companySymbol),
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
