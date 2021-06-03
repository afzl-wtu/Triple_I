import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart' as el;

import 'package:main/models/article.dart';

class ArticleView extends StatelessWidget {
  final Article data;
  ArticleView(this.data);

  @override
  Widget build(BuildContext context) {
    print('Article View: ${data.images.length}');
    return Scaffold(
      appBar: AppBar(
        title: Text(data.title),
        backgroundColor: Color.fromRGBO(65, 190, 186, 1),
      ),
      body: data.images.isEmpty ? _buildTextArticle() : _buildImagesArticles(),
    );
  }

  _buildImagesArticles() {
    print(data.images.length);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: data.images.length,
            itemBuilder: (_, i) => CachedNetworkImage(
              placeholder: (_, txt) => Text('Loading...'.tr()),
              fit: BoxFit.fitWidth,
              imageUrl: data.images[i],
            ),
          ),
        ),
      ],
    );
  }

  _buildTextArticle() {
    return SingleChildScrollView(
        child: Text(
      data.description,
      textDirection: data.language == Language.Hebrew
          ? TextDirection.rtl
          : TextDirection.ltr,
    ));
  }
}
