import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/article.dart';

class ViewArticle extends StatefulWidget {
  @override
  _ViewArticleState createState() => _ViewArticleState();
}

class _ViewArticleState extends State<ViewArticle> {
  final _col = FirebaseFirestore.instance.collection('Articles');

  List<Article> articles = [];

  Future<void> setArticles() async {
    try {
      final _documents = await _col.get();
      final docs = _documents.docs;
      docs.forEach((element) {
        articles.add(
          Article(
            id: element.id,
            title: element.get('title'),
            images: (element.get('images') as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
            image: element.get('imageUrl'),
            description: element.get('description'),
            time: DateTime.now(),
          ),
        );
      });
      setState(() {
        firstTime = false;
      });
    } catch (error) {
      await _showError(error.toString());
    }
  }

  Future<void> _showError(String error, [String id]) async {
    return showDialog(
        context: context,
        builder: (_) {
          print('PP inshowDialog');
          return AlertDialog(
            // contentPadding: EdgeInsets.all(40),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            title: Text(error == 'Article will be removed!'
                ? 'Are you sure?'
                : 'OOPS...'),
            content: Text(error),
            actions: <Widget>[
              TextButton(
                onPressed: () => error == 'Article will be removed!'
                    ? deleteArticle(
                        id,
                      )
                    : Navigator.pop(context),
                child: Text('Okay'),
              )
            ],
          );
        });
  }

  Future<void> deleteArticle(String id) async {
    try {
      await _col.doc(id).delete();
      Navigator.pop(context);
      setState(() {
        firstTime = true;
        articles.clear();
      });
    } catch (error) {
      await _showError(error);
    }
  }

  bool firstTime = true;
  Widget build(BuildContext context) {
    if (firstTime) {
      setArticles();
    }
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        //backgroundColor: Colors.amber,
        centerTitle: true,
        elevation: .1,
        toolbarOpacity: .9,
        title: Text('Articles'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            // color: Colors.grey[300],
            child: Column(
              children: articles.map((e) {
                return Dismissible(
                  onDismissed: (_) {
                    deleteArticle(e.id);
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('Article deleted successfully!'),
                        action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              // Some code to undo the change.
                            })));
                  },
                  background: Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Icon(
                          Icons.delete_forever,
                          size: 38,
                        )
                      ],
                    ),
                    color: Colors.red,
                  ),
                  direction: DismissDirection.startToEnd,
                  key: GlobalKey(),
                  child: Card(
                    elevation: 1.0,
                    margin: new EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: ListTile(
                      title: Text(e.title),
                      leading: CircleAvatar(
                        backgroundImage: (e.image ?? '').isNotEmpty
                            ? CachedNetworkImageProvider(
                                e.image,
                              )
                            : e.images.isNotEmpty
                                ? CachedNetworkImageProvider(e.images[0])
                                : null,
                      ),
                      subtitle: Text(
                        '${e.description}',
                        maxLines: 1,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                              onPressed: () {}), //to do
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
