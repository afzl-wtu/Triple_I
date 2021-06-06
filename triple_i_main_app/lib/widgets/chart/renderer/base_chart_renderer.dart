import 'package:flutter/material.dart';

import '../chart_style.dart';

export '../chart_style.dart';

const rightTextAxisLinePadding = 5.0;
const rightTextScreenSidePadding = 4.0;
const rightCoverWidth = 40.0;

abstract class BaseChartRenderer<T> {
  double maxValue, minValue;
  double scaleY;
  double topPadding;
  Rect chartRect;
  int fixedLength;
  final String fontFamily;
  final List<Color> bgColor;

  // Price precision used to draw the right side text
  // (prices near the chart). Also can be used for any prices
  // on the chart.
  int pricePrecision;
  int amountPrecision;
  Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.5
    ..color = Colors.red;

  Paint gridPaint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0
    ..color = Color(0x06A86A9C1);

  Paint backgroundPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = ChartColors.background;

  BaseChartRenderer({
    @required this.chartRect,
    @required this.maxValue,
    @required this.minValue,
    @required this.topPadding,
    @required this.fixedLength,
    this.fontFamily,
    this.bgColor,
    this.pricePrecision,
    this.amountPrecision
  }) {
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = chartRect.height / (maxValue - minValue);
    // print("maxValue=====" + maxValue.toString() + "====minValue===" + minValue.toString() + "==scaleY==" + scaleY.toString());
  }

  double getY(double y) => (maxValue - y) * scaleY + chartRect.top;

  String format(double n) {
    if (n == null || n.isNaN) {
      return "0.00";
    } else {
      return n.toStringAsFixed(fixedLength);
    }
  }

  void drawGrid(Canvas canvas, int gridRows, int gridColumns);

  void drawText(Canvas canvas, T data, double x);

  void drawRightText(Canvas canvas, Size size, textStyle, int gridRows);

  void drawChart(
    T lastPoint,
    T curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  );

  void drawLine(
    double lastPrice,
    double curPrice,
    Canvas canvas,
    double lastX,
    double curX,
    Color color,
  ) {
    if (lastPrice == null || curPrice == null) {
      return;
    }
    double lastY = getY(lastPrice);
    double curY = getY(curPrice);
    canvas.drawLine(
      Offset(lastX, lastY),
      Offset(curX, curY),
      chartPaint..color = color,
    );
  }

  void drawPath(
    List<double> prices,
    List<double> xs,
    Canvas canvas,
    Color color,
  ) {
    if (prices == null ||
        prices.isEmpty ||
        prices.any((p) => p == null) ||
        xs == null ||
        xs.isEmpty ||
        xs.any((x) => x == null) ||
        xs.length != prices.length) {
      return;
    }

    final path = Path()..moveTo(xs.first, getY(prices.first));
    for (int i = 1; i < prices.length; i++) {
      path.lineTo(xs[i], getY(prices[i]));
    }

    canvas.drawPath(path, chartPaint..color = color);
  }

  TextStyle getTextStyle(Color color, {bool bold = false, bool light = false}) {
    FontWeight fontWeight;
    if (bold) {
      fontWeight = FontWeight.bold;
    }
    if (light) {
      fontWeight = FontWeight.w300;
    }
    return TextStyle(
      fontSize: 8.0,
      color: color,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
    );
  }

  TextStyle getTextStyleBold(Color color) {
    return getTextStyle(
      color,
      bold: true,
    );
  }

  TextStyle getTextStyleLight(Color color) {
    return getTextStyle(
      color,
      light: true,
    );
  }
}
