import 'package:flutter/material.dart';
import 'package:main/helpers/gradient_helper.dart';

class BackgroundImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        gradContainer(
          90,
          ['#1d6d6a', '#3caaa6', '#41beba'],
        ),
        gradContainer(
          186,
          ['#a6a6a6a', '#a6a6a6a 5%', '#d2d2d2a 0%', '#d2d2d2a'],
        ),
        gradContainer(
          304,
          ['#a2a2a212', '#a2a2a212 27%', '#18181812 0%', '#18181812'],
        ),
        gradContainer(
          200,
          ['#cecece17', '#cecece17 58%', '#06060617 0%', '#06060617'],
        ),
        gradContainer(
          3,
          ['#141414f', '#141414f 62%', '#888888f 0%', '#888888f'],
        ),
        gradContainer(
          183,
          ['#dfdfdf3', '#dfdfdf3 82%', '#1c1c1c3 0%', '#1c1c1c3'],
        ),
        gradContainer(
          326,
          ['#d5d5d5a', '#d5d5d5a 45%', '#424242a 0%', '#424242a'],
        ),
        gradContainer(
          76,
          ['#a9a9a9f', '#a9a9a9f 89%', '#bdbdbdf 0%', '#bdbdbdf'],
        ),
        gradContainer(
          194,
          ['#6666665', '#6666665 60%', '#4343435 0%', '#4343435'],
        ),
        gradContainer(
          56,
          ['#fefefed', '#fefefed 69%', '#a0a0a0d 0%', '#a0a0a0d'],
        ),
      ],
    );
  }

  Container gradContainer(int degree, List<String> colors) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration:
          BoxDecoration(gradient: CssLike.linearGradient(degree, colors)),
    );
  }
}
