import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:main/screens/articleview.dart';

import '../../bloc/home.dart';
import '../../helpers/color_helper.dart';
import '../../helpers/marquee_helper.dart';
import '../../helpers/text_helper.dart';
import '../../models/article.dart';
import '../../models/profile/market_index.dart';
import '../../widgets/loading_indicator.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    return BlocBuilder<HomeBloc, HomeState>(builder: (_, state) {
      print('PP in Bloc Builder, state is: $state');
      if (state is HomeInitial) {
        BlocProvider.of<HomeBloc>(context).add(FetchHomeData());
      }
      if (state is HomeLoaded) {
        return Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: marqueeGen(state.indexes, true),
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
                            : _buildGrid(snap.data);
                  }),
            )
          ],
        );
      }
      return Center(
        child: LoadingIndicatorWidget(),
      );
    });
  }

  Widget marqueeGen(List<MarketIndexModel> indexes, bool play) {
    return play
        ? Marquee(
            backwardAnimation: Curves.linear,
            forwardAnimation: Curves.linear,
            // directionMarguee: DirectionMarguee.oneDirection,
            child: Row(
              children: indexes
                  .map((indexData) => _buildIndexTile(indexData))
                  .toList(),
            ),
          )
        : Container(height: 30, width: 40, color: Colors.white);
  }

  Widget _buildIndexTile(MarketIndexModel index) {
    String name;
    if (index.name == 'Dow Jones Industrial Average') name = 'Dow Jones';
    if (index.name == 'NASDAQ Composite') name = 'NASDAQ';
    if (index.name == 'CBOE Volatility Index') name = 'CBOE';
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              //mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${name ?? index.name}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${index.price}',
                  style: TextStyle(fontSize: 16),
                ),
                Card(
                  color: determineColorBasedOnChange(index.change),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      '${determineTextBasedOnChange(index.change / index.price * 100)}%',
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildGrid(List<Article> data) {
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
