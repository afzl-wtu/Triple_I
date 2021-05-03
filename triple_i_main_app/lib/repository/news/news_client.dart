import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../helpers/http_helper.dart';
import '../../keys/api_keys.dart';
import '../../models/news/news.dart';
import '../../models/news/single_new_model.dart';

class NewsClient extends FetchClient {
  Future<NewsDataModel> fetchNews({String title, String specificSymbol}) async {
    final Uri newsUri = specificSymbol == null
        ? Uri.https('newsapi.org', '/v2/everything', {
            'q': '"$title"',
            'language': 'en',
            'sortBy': 'popularity',
            'pageSize': '10',
            'apikey': kNewsKey
          })
        : Uri.https('finnhub.io', '/api/v1/company-news', {
            'symbol': specificSymbol,
            'from': DateFormat('yyyy-MM-dd')
                .format(DateTime.now().subtract(Duration(days: 360))),
            'to': DateFormat('yyyy-MM-dd').format(DateTime.now()),
            'token': kFinnhubKey
          });

    final Response<dynamic> newsResponse = await super.fetchData(uri: newsUri);
    print(
        'PP in fetchNew super  method value of response:${newsResponse.data.toString()}');
    final List<SingleNewModel> newsOverviews = specificSymbol != null
        ? SingleNewModel.toList(newsResponse.data, true)
        : SingleNewModel.toList(
            newsResponse.data['articles'],
          );
    print('PPxxx: ${newsOverviews.length}');
    return NewsDataModel(
      keyWord: title ?? specificSymbol,
      news: newsOverviews,
    );
  }
}
