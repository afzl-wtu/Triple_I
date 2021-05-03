import '../../models/news/news.dart';
import './news_client.dart';

class NewsRepository extends NewsClient {
  Future<NewsDataModel> fetchNews({String title, String specificSymbol}) async {
    final a =
        await super.fetchNews(title: title, specificSymbol: specificSymbol);
    print('PP in NewsRepository class: response of fetch news: ${a}');
    return a;
  }
}
