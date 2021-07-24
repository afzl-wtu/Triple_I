import 'package:meta/meta.dart';

class SingleNewModel {
  final String? source;
  final String? title;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? description;

  SingleNewModel(
      {required this.description,
      required this.source,
      required this.title,
      required this.url,
      required this.urlToImage,
      required this.publishedAt});

  factory SingleNewModel.fromJson(Map<String, dynamic> json) {
    return SingleNewModel(
      source: json['source']['name'],
      title: json['title'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      description: null,
    );
  }
  factory SingleNewModel.fromJsonFinnhub(Map<String, dynamic> json) {
    print('PP in fromJsonFinnhub: json: $json');
    return SingleNewModel(
      source: json['source'],
      title: json['headline'],
      url: json['url'],
      urlToImage: json['image'],
      publishedAt: json['datetime'].toString(),
      description: json['summary'],
    );
  }

  static List<SingleNewModel> toList(List<dynamic>? items,
      [bool finnhub = false]) {
    List<SingleNewModel> testList;
    finnhub == false
        ? testList = items!.map((item) => SingleNewModel.fromJson(item)).toList()
        : testList =
            items!.map((item) => SingleNewModel.fromJsonFinnhub(item)).toList();
    print('PP in toList method testList: $testList');
    return testList;
  }
}
