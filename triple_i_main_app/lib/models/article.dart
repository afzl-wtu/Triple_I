class Article {
  final String? id;
  final String? description;
  final DateTime? time;
  final String? image;
  final Language? language;
  final String? title;
  final List<String>? images;
  bool? isFavourite;
  String? link;

  Article(
      {this.image,
      this.images,
      this.id,
      this.description,
      this.time,
      this.language,
      this.title,
      this.isFavourite,
      this.link});
  //static List<Article> fromJson() {}
}

enum Language { English, Hebrew }
