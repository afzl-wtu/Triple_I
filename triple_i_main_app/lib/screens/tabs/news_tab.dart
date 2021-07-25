import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../bloc/news/news_bloc.dart';
import '../../helpers/url.dart';
import '../../models/news/single_new_model.dart';
import '../../widgets/empty_screen.dart';
import '../../bloc/home.dart';
import '../../helpers/color_helper.dart';
import '../../helpers/marquee_helper.dart';
import '../../helpers/text_helper.dart';
import '../../models/profile/market_index.dart';
import '../../widgets/loading_indicator.dart';

class NewsTab extends StatefulWidget {
  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    marqueeGen(state.indexes!),
                    Expanded(
                        child:
                            SingleChildScrollView(child: NewsSectionWidget())),
                  ],
                ),
              ),
            ),
          ],
        );
      }
      return Center(
        child: LoadingIndicatorWidget(),
      );
    });
  }

  Widget marqueeGen(List<MarketIndexModel> indexes) {
    return //Todo: Duration Change before production

        Marquee(
      pauseDuration: Duration(hours: 1),
      backwardAnimation: Curves.linear,
      forwardAnimation: Curves.linear,
      // directionMarguee: DirectionMarguee.oneDirection,
      child: Row(
        children:
            indexes.map((indexData) => _buildIndexTile(indexData)).toList(),
      ),
    );
  }

  Widget _buildIndexTile(MarketIndexModel index) {
    String? name;
    if (index.name == 'Dow Jones Industrial Average') name = 'Dow Jones'.tr();
    if (index.name == 'NASDAQ Composite') name = 'NASDAQ'.tr();
    if (index.name == 'CBOE Volatility Index') name = 'CBOE'.tr();
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
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
                color: determineColorBasedOnChange(index.change!),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    '${determineTextBasedOnChange(index.change! / index.price! * 100)}%',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsSectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsBloc, NewsState>(
        builder: (BuildContext context, NewsState state) {
      if (state is NewsInitial) {
        BlocProvider.of<NewsBloc>(context).add(FetchNews());
      }

      if (state is NewsError) {
        return Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
          child: EmptyScreen(message: state.message),
        );
      }

      if (state is NewsLoaded) {
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: state.news.length,
          itemBuilder: (BuildContext context, int index) {
            // Ensure that we don't have empty headlines.
            if (state.news[index].news.isEmpty) {
              return EmptyScreen(
                  message:
                      'There are no news related to ${state.news[index].keyWord}.');
            }

            return NewsCardWidget(
              title: state.news[index].keyWord,
              news: state.news[index].news,
            );
          },
        );
      }

      return Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 3, left: 4, right: 4),
        child: LoadingIndicatorWidget(),
      );
    });
  }
}

class NewsCardWidget extends StatelessWidget {
  final String? title;
  final List<SingleNewModel> news;

  NewsCardWidget({required this.title, required this.news})
      // ignore: unnecessary_null_comparison
      : assert(news != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(this.title!.tr(),
              style: TextStyle(fontSize: 36, color: Colors.white)),
        ),
        Container(
          height: 225,
          child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: news.length,
              itemBuilder: (BuildContext context, int i) => Padding(
                  padding: EdgeInsets.only(top: 8, right: 24),
                  child: _renderNewsArticle(news[i]))),
        )
      ],
    );
  }

  Widget _renderNewsArticle(SingleNewModel singleNew) {
    print(singleNew.urlToImage);
    return InkWell(
      onTap: () {
        print('PP in Inkwell');
        launchUrl(singleNew.url!);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        child: Container(
          color: Colors.white54,
          child: Container(
            width: 200,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 8, left: 3, right: 2),
                  child: Text(
                    singleNew.title!,
                    style: TextStyle(
                        height: 1.6,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: singleNew.urlToImage == null
                      ? Icon(
                          Icons.photo_size_select_actual_rounded,
                          size: 120,
                          color: Color.fromRGBO(65, 190, 186, 1),
                        )
                      : CachedNetworkImage(
                          imageUrl: singleNew.urlToImage!,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
