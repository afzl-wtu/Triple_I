import 'package:meta/meta.dart';

import './single_new_model.dart';

class NewsDataModel {
  final String keyWord;
  final List<SingleNewModel> news;

  NewsDataModel({@required this.keyWord, @required this.news});
}
