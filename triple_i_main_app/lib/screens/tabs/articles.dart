import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:main/models/article.dart';
import 'package:main/screens/articleview.dart';
import 'package:main/widgets/loading_indicator.dart';

class ArticlesTab extends StatelessWidget {
  Future<List<Article>> articleslist() async {
    print('Future Time: ${DateTime.now().toIso8601String()}');
    List<Article> articles = [];
    final _col = FirebaseFirestore.instance.collection('Articles');
    try {
      final _documents = await _col.get();
      final docs = _documents.docs;
      docs.forEach((element) {
        articles.add(
          Article(
            id: element.id,
            images: (element.get('images') as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
            title: element.get('title'),
            image: element.get('imageUrl'),
            description: element.get('description'),
            language: element.get('language') == 'Hebrew'
                ? Language.Hebrew
                : Language.English,
            time: DateTime.now(),
          ),
        );
      });
    } catch (error) {
      print(error);
    }
    print(articles);
    return articles;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
        ),
        Expanded(
          child: FutureBuilder(
              future: articleslist(),
              builder: (_, snap) {
                return snap.connectionState == ConnectionState.waiting
                    ? LoadingIndicatorWidget()
                    : snap.data.length == 0
                        ? Center(
                            child: Text('No Articles Currently'),
                          )
                        : _buildGrid(snap.data, context);
              }),
        )
      ],
    );
  }

  _buildGrid(List<Article> data, context) {
    return Card(
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                crossAxisCount: 2,
                childAspectRatio: 1 / 1.07),
            itemBuilder: (_, i) => InkWell(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ArticleView(data[i]))),
              child: GridTile(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: CachedNetworkImageProvider(
                                data[i].image.isNotEmpty
                                    ? data[i].image
                                    : data[i].images[0]),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white)),
                      child: GridTileBar(
                        backgroundColor: Colors.transparent,
                        title: Text(data[i].title),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
