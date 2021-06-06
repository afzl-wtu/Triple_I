import 'package:flutter/material.dart';
import 'package:k_chart/utils/render_util.dart';
import 'package:path_drawing/path_drawing.dart';

import '../chart_style.dart';
import '../entity/candle_entity.dart';
import '../k_chart_widget.dart' show MainState;
import 'base_chart_renderer.dart';

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  double mCandleWidth = ChartStyle.candleWidth;
  double mCandleLineWidth = ChartStyle.candleLineWidth;
  MainState state;
  bool isLine;

  // Painted content area
  Rect _contentRect;
  double _contentPadding = 5.0;
  List<int> maDayList;
  Shader mLineFillShader;
  Path mLinePath, mLineFillPath;
  Paint mLinePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..color = ChartColors.kLineColor;
  Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  MainRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    this.state,
    this.isLine,
    int fixedLength, {
    this.maDayList = const [5, 10, 20],
    String fontFamily,
    List<Color> bgColor,
    pricePrecision,
  }) : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          fixedLength: fixedLength,
          fontFamily: fontFamily,
          bgColor: bgColor,
          pricePrecision: pricePrecision,
        ) {
    _contentRect = Rect.fromLTRB(
        chartRect.left,
        chartRect.top + _contentPadding,
        chartRect.right,
        chartRect.bottom - _contentPadding);
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = _contentRect.height / (maxValue - minValue);
  }

  @override
  void drawText(Canvas canvas, CandleEntity data, double x) {
    if (isLine == true || state == MainState.NONE) {
      return;
    }

    TextSpan span;
    switch (state) {
      case MainState.MA:
        span = TextSpan(
          children: _createMATextSpan(data),
        );
        break;
      case MainState.BOLL:
        final middle = data.bollMiddle != null && data.bollMiddle != 0;
        final up = data.bollUp != null && data.bollUp != 0;
        final down = data.bollDown != null && data.bollDown != 0;
        span = TextSpan(
          children: [
            if (middle)
              TextSpan(
                text: 'BOLL: ',
                style: getTextStyleLight(ChartColors.ma5Color),
              ),
            if (middle)
              TextSpan(
                text: ChartFormats.money[pricePrecision].format(data.bollMiddle) + '    ',
                style: getTextStyleBold(ChartColors.ma5Color),
              ),
            if (up)
              TextSpan(
                text: 'UB: ',
                style: getTextStyleLight(ChartColors.ma10Color),
              ),
            if (up)
              TextSpan(
                text: ChartFormats.money[pricePrecision].format(data.bollUp) + '    ',
                style: getTextStyleBold(ChartColors.ma10Color),
              ),
            if (down)
              TextSpan(
                text: 'LB: ',
                style: getTextStyleLight(ChartColors.ma20Color),
              ),
            if (down)
              TextSpan(
                text: ChartFormats.money[pricePrecision].format(data.bollDown),
                style: getTextStyleBold(ChartColors.ma20Color),
              ),
          ],
        );
        break;
      case MainState.NONE:
        // do nothing
        break;
    }

    TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    canvas.drawRect(
      Rect.fromLTRB(
        chartRect.left,
        chartRect.top,
        chartRect.left + tp.width + rightTextScreenSidePadding * 2,
        chartRect.top + tp.height + rightTextAxisLinePadding * 2,
      ),
      backgroundPaint
        ..color =
            bgColor?.elementAt(0)?.withOpacity(0.75) ?? ChartColors.background,
    );

    tp.paint(canvas, Offset(x, chartRect.top + rightTextAxisLinePadding));
  }

  @override
  void drawChart(
    CandleEntity lastPoint,
    CandleEntity curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    if (isLine != true) {
      drawCandle(curPoint, canvas, curX);
    }
    if (isLine == true) {
      drawPolyline(lastPoint.close, curPoint.close, canvas, lastX, curX);
    } else if (state == MainState.MA) {
      drawMaLine(lastPoint, curPoint, canvas, lastX, curX);
    } else if (state == MainState.BOLL) {
      drawBollLine(lastPoint, curPoint, canvas, lastX, curX);
    }
  }

  @override
  void drawRightText(Canvas canvas, Size size, textStyle, int gridRows) {
    double rowSpace = chartRect.height / gridRows;
    for (var i = 0; i <= gridRows; ++i) {
      double value = (gridRows - i) * rowSpace / scaleY + minValue;
      TextSpan span = TextSpan(
        text: ChartFormats.money[pricePrecision].format(value),
        style: textStyle,
      );
      TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      if (i == 0) {
        tp.paint(
          canvas,
          Offset(
            chartRect.width - tp.width - rightTextScreenSidePadding,
            topPadding + rightTextAxisLinePadding,
          ),
        );
        RenderUtil.drawDashedLine(
          canvas,
          Offset(chartRect.width - rightCoverWidth, topPadding),
          Offset(chartRect.width, topPadding),
          gridPaint,
        );
      } else {
        // the last number should be above the line
        tp.paint(
          canvas,
          Offset(
            chartRect.width - tp.width - rightTextScreenSidePadding,
            topPadding +
                rowSpace * i +
                rightTextAxisLinePadding -
                (i == gridRows ? tp.height + 10 : 0),
          ),
        );
        RenderUtil.drawDashedLine(
          canvas,
          Offset(chartRect.width - rightCoverWidth, topPadding + rowSpace * i),
          Offset(chartRect.width, topPadding + rowSpace * i),
          gridPaint,
        );
      }
    }

    RenderUtil.drawDashedLine(
      canvas,
      Offset(chartRect.width - rightCoverWidth, 0),
      Offset(chartRect.width - rightCoverWidth, chartRect.height),
      gridPaint,
    );

    RenderUtil.drawDashedLine(
      canvas,
      Offset(chartRect.width - gridPaint.strokeWidth / 2, 0),
      Offset(chartRect.width - gridPaint.strokeWidth / 2, chartRect.height),
      gridPaint,
    );
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawPath(
        dashPath(
          Path()
            ..moveTo(0, rowSpace * i + topPadding)
            ..lineTo(chartRect.width, rowSpace * i + topPadding),
          dashArray: CircularIntervalList<double>([3.0, 3.0]),
        ),
        gridPaint,
      );
    }

    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= gridColumns; i++) {
      // shift is for the last and first vertical lines to keep it's full
      // width inside the screen
      var shift = 0.0;
      if (i == 0) {
        shift = gridPaint.strokeWidth / 2;
      }

      if (i == gridColumns) {
        shift = -gridPaint.strokeWidth / 2;
      }

      RenderUtil.drawDashedLine(
        canvas,
        Offset(columnSpace * i + shift, topPadding / 3),
        Offset(columnSpace * i + shift, chartRect.bottom),
        gridPaint,
      );
    }
  }

  @override
  double getY(double y) {
    return (maxValue - y) * scaleY + _contentRect.top;
  }

  drawPolyline(
    double lastPrice,
    double curPrice,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
//    drawLine(lastPrice + 100, curPrice + 100, canvas, lastX, curX, ChartColors.kLineColor);
    mLinePath ??= Path();

//    if (lastX == curX) {
//      mLinePath.moveTo(lastX, getY(lastPrice));
//    } else {
////      mLinePath.lineTo(curX, getY(curPrice));
//      mLinePath.cubicTo(
//          (lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
//    }
    if (lastX == curX) lastX = 0; //起点位置填充
    mLinePath.moveTo(lastX, getY(lastPrice));
    mLinePath.cubicTo((lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2,
        getY(curPrice), curX, getY(curPrice));

//    //画阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: [ChartColors.lineFillColor, Colors.transparent],
    ).createShader(Rect.fromLTRB(
        chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath.lineTo(lastX, getY(lastPrice));
    mLineFillPath.cubicTo((lastX + curX) / 2, getY(lastPrice),
        (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    mLineFillPath.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath.close();

    canvas.drawPath(mLineFillPath, mLineFillPaint);
    mLineFillPath.reset();

    canvas.drawPath(mLinePath, mLinePaint);
    mLinePath.reset();
  }

  void drawMaLine(
    CandleEntity lastPoint,
    CandleEntity curPoint,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
    for (int i = 0; i < curPoint.maValueList.length; i++) {
      if (i == 3) {
        break;
      }
      if (lastPoint.maValueList[i] != 0) {
        drawLine(
          lastPoint.maValueList[i],
          curPoint.maValueList[i],
          canvas,
          lastX,
          curX,
          ChartColors.getMAColor(i),
        );
      }
    }
  }

  void drawBollLine(
    CandleEntity from,
    CandleEntity to,
    Canvas canvas,
    double fromX,
    double toX,
  ) {
    if (from.bollUp != null &&
        from.bollUp != 0 &&
        from.bollDown != null &&
        from.bollDown != 0) {
      drawPath(
        [from.bollUp, to.bollUp, to.bollDown, from.bollDown],
        [fromX, toX, toX, fromX],
        canvas,
        ChartColors.bollBackground,
      );
    }
    if (from.bollUp != null && from.bollUp != 0) {
      drawLine(
        from.bollUp,
        to.bollUp,
        canvas,
        fromX,
        toX,
        ChartColors.bollUp,
      );
    }

    if (from.bollDown != null && from.bollDown != 0) {
      drawLine(
        from.bollDown,
        to.bollDown,
        canvas,
        fromX,
        toX,
        ChartColors.bollDown,
      );
    }
    if (from.bollMiddle != null && from.bollMiddle != 0) {
      drawLine(
        from.bollMiddle,
        to.bollMiddle,
        canvas,
        fromX,
        toX,
        ChartColors.bollMiddle,
      );
    }
  }

  void drawCandle(CandleEntity curPoint, Canvas canvas, double curX) {
    var high = getY(curPoint.high);
    var low = getY(curPoint.low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;
    if (open > close) {
      chartPaint.color = ChartColors.upColor;
      canvas.drawRect(
        Rect.fromLTRB(curX - r, close, curX + r, open),
        chartPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(curX - lineR, high, curX + lineR, low),
        chartPaint,
      );
    } else if (close > open) {
      chartPaint.color = ChartColors.dnColor;
      canvas.drawRect(
        Rect.fromLTRB(curX - r, open, curX + r, close),
        chartPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(curX - lineR, high, curX + lineR, low),
        chartPaint,
      );
    } else {
      chartPaint.color = ChartColors.upColor;
      canvas.drawLine(
        Offset(curX - r, open),
        Offset(curX + r, open),
        chartPaint,
      );
      if (high != low) {
        canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low),
          chartPaint,
        );
      }
    }
  }

  List<InlineSpan> _createMATextSpan(CandleEntity data) {
    List<InlineSpan> result = [];
    for (int i = 0; i < data.maValueList.length; i++) {
      final color = ChartColors.getMAColor(i);
      final value = data.maValueList[i];
      if (value != 0) {
        result.add(
          TextSpan(
            text: 'MA${maDayList[i]}: ',
            style: getTextStyleLight(color.withOpacity(0.7)),
          ),
        );

        var text = '${ChartFormats.money[pricePrecision].format(value)}';
        if (i != data.maValueList.length - 1) {
          text += '    ';
        }

        result.add(
          TextSpan(
            text: text,
            style: getTextStyleBold(color),
          ),
        );
      }
    }
    return result;
  }
}
