import 'dart:async' show StreamSink;

import 'package:flutter/material.dart';
import 'package:k_chart/utils/number_util.dart';

import '../chart_style.dart';
import '../entity/info_window_entity.dart';
import '../entity/k_line_entity.dart';
import '../formatter.dart';
import '../utils/date_format_util.dart';
import 'base_chart_painter.dart';
import 'base_chart_renderer.dart';
import 'main_renderer.dart';
import 'secondary_renderer.dart';
import 'vol_renderer.dart';

const _sideBadgePaddingY = 1.5;

class ChartPainter extends BaseChartPainter {
  //
  static get maxScrollX => BaseChartPainter.maxScrollX;
  BaseChartRenderer mMainRenderer;
  BaseChartRenderer mVolRenderer;
  BaseChartRenderer mSecondaryRenderer;
  StreamSink<InfoWindowEntity> sink;
  Color upColor, dnColor;
  Color ma5Color, ma10Color, ma30Color;
  Color volColor;
  Color macdColor, difColor, deaColor, jColor;
  List<Color> bgColor;
  int fixedLength;
  List<int> maDayList;

  /// Used to draw a shortened int in the right text of the [VolRenderer]
  /// like 100K instead of 100,000
  final Formatter shortFormatter;

  /// Used to write a word 'Volume' in the [VolRenderer] in a different languages
  /// Should be sent from the parent project
  final String wordVolume;

  Paint selectPointPaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.5
    ..color = ChartColors.selectFillColor;

  Paint selectorBorderPaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke
    ..color = ChartColors.selectBorderColor;

  Paint lastPriceBackgroundPaintUp = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = ChartColors.upColor;

  Paint lastPriceBackgroundPaintDown = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = ChartColors.dnColor;

  Paint lastPriceBackgroundPaintNeutral = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = Colors.white.withOpacity(0.8);

  ChartPainter({
    @required datas,
    @required scaleX,
    @required scrollX,
    @required isLongPass,
    @required selectX,
    mainState,
    secondaryState,
    this.sink,
    bool isLine,
    this.bgColor,
    this.fixedLength,
    this.maDayList,
    @required this.shortFormatter,
    @required this.wordVolume,
    String fontFamily,
    int macdShortPeriod,
    int macdLongPeriod,
    int macdMaPeriod,
    int rsiPeriod,
    int wrPeriod,
    int kdjCalcPeriod,
    int kdjMaPeriod1,
    int kdjMaPeriod2,
    int pricePrecision,
    int amountPrecision,
  })  : assert(bgColor == null || bgColor.length >= 2),
        super(
          datas: datas,
          scaleX: scaleX,
          scrollX: scrollX,
          isLongPress: isLongPass,
          selectX: selectX,
          mainState: mainState,
          secondaryState: secondaryState,
          isLine: isLine,
          fontFamily: fontFamily,
          macdShortPeriod: macdShortPeriod,
          macdLongPeriod: macdLongPeriod,
          macdMaPeriod: macdMaPeriod,
          rsiPeriod: rsiPeriod,
          wrPeriod: wrPeriod,
          kdjCalcPeriod: kdjCalcPeriod,
          kdjMaPeriod1: kdjMaPeriod1,
          kdjMaPeriod2: kdjMaPeriod2,
          pricePrecision: pricePrecision,
          amountPrecision: amountPrecision
        );

  @override
  void initChartRenderer() {
    if (fixedLength == null) {
      if (datas == null || datas.isEmpty) {
        fixedLength = 2;
      } else {
        var t = datas[0];
        fixedLength = NumberUtil.getMaxDecimalLength(
          t.open,
          t.close,
          t.high,
          t.low,
        );
      }
    }
    mMainRenderer ??= MainRenderer(
      mMainRect,
      mMainMaxValue,
      mMainMinValue,
      mTopPadding,
      mainState,
      isLine,
      fixedLength,
      maDayList: maDayList,
      fontFamily: fontFamily,
      bgColor: bgColor,
      pricePrecision: pricePrecision,
    );
    mVolRenderer ??= VolRenderer(
      mVolRect,
      mVolMaxValue,
      mVolMinValue,
      mChildPadding,
      fixedLength,
      shortFormatter: shortFormatter,
      wordVolume: wordVolume,
      fontFamily: fontFamily,
      bgColor: bgColor,
      pricePrecision: pricePrecision,
      amountPrecision: amountPrecision
    );
    if (mSecondaryRect != null)
      mSecondaryRenderer ??= SecondaryRenderer(
        mSecondaryRect,
        mSecondaryMaxValue,
        mSecondaryMinValue,
        mChildPadding,
        secondaryState,
        fixedLength,
        fontFamily: fontFamily,
        bgColor: bgColor,
        macdShortPeriod: macdShortPeriod,
        macdLongPeriod: macdLongPeriod,
        macdMaPeriod: macdMaPeriod,
        rsiPeriod: rsiPeriod,
        wrPeriod: wrPeriod,
        kdjCalcPeriod: kdjCalcPeriod,
        kdjMaPeriod1: kdjMaPeriod1,
        kdjMaPeriod2: kdjMaPeriod2,
        pricePrecision: pricePrecision,
      );
  }

  @override
  void drawBg(Canvas canvas, Size size) {
    Paint mBgPaint = Paint();
    Gradient mBgGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: bgColor ?? [ChartColors.background, ChartColors.background],
    );
    if (mMainRect != null) {
      Rect mainRect =
          Rect.fromLTRB(0, 0, mMainRect.width, mMainRect.height + mTopPadding);
      canvas.drawRect(
          mainRect, mBgPaint..shader = mBgGradient.createShader(mainRect));
    }

    if (mVolRect != null) {
      Rect volRect = Rect.fromLTRB(
          0, mVolRect.top - mChildPadding, mVolRect.width, mVolRect.bottom);
      canvas.drawRect(
          volRect, mBgPaint..shader = mBgGradient.createShader(volRect));
    }

    if (mSecondaryRect != null) {
      Rect secondaryRect = Rect.fromLTRB(0, mSecondaryRect.top - mChildPadding,
          mSecondaryRect.width, mSecondaryRect.bottom);
      canvas.drawRect(secondaryRect,
          mBgPaint..shader = mBgGradient.createShader(secondaryRect));
    }
    Rect dateRect =
        Rect.fromLTRB(0, size.height - mBottomPadding, size.width, size.height);
    canvas.drawRect(
        dateRect, mBgPaint..shader = mBgGradient.createShader(dateRect));
  }

  @override
  void drawGrid(canvas) {
    mMainRenderer?.drawGrid(canvas, mGridRows, mGridColumns);
    mVolRenderer?.drawGrid(canvas, mGridRows, mGridColumns);
    mSecondaryRenderer?.drawGrid(canvas, mGridRows, mGridColumns);
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(mTranslateX * scaleX - rightCoverWidth, 0.0);
    canvas.scale(scaleX, 1.0);
    for (int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
      KLineEntity curPoint = datas[i];
      if (curPoint == null) continue;
      KLineEntity lastPoint = i == 0 ? curPoint : datas[i - 1];
      double curX = getX(i);
      double lastX = i == 0 ? curX : getX(i - 1);

      mMainRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      mVolRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      mSecondaryRenderer?.drawChart(
        lastPoint,
        curPoint,
        lastX,
        curX,
        size,
        canvas,
      );
    }

    if (isLongPress == true) {
      drawCrossLine(canvas, size);
    }

    canvas.restore();
  }

  @override
  void drawRightText(Canvas canvas, Size size) {
    var textStyle = getTextStyle(ChartColors.defaultTextColor);
    mMainRenderer?.drawRightText(canvas, size, textStyle, mGridRows);
    mVolRenderer?.drawRightText(canvas, size, textStyle, mGridRows);
    mSecondaryRenderer?.drawRightText(canvas, size, textStyle, mGridRows);
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    double columnSpace = size.width / mGridColumns;
    double startX = getX(mStartIndex) - mPointWidth / 2;
    double stopX = getX(mStopIndex) + mPointWidth / 2;
    double y = 0.0;
    for (var i = 0; i <= mGridColumns; ++i) {
      double translateX = xToTranslateX(columnSpace * i);
      if (translateX >= startX && translateX <= stopX) {
        int index = indexOfTranslateX(translateX);
        if (datas[index] == null) continue;
        TextPainter tp =
            getTextPainter(getDate(datas[index].time).toUpperCase());
        y = size.height - (mBottomPadding - tp.height) / 2 - tp.height;
        tp.paint(canvas, Offset(columnSpace * i - tp.width / 2, y));
      }
    }

//    double translateX = xToTranslateX(0);
//    if (translateX >= startX && translateX <= stopX) {
//      TextPainter tp = getTextPainter(getDate(datas[mStartIndex].id));
//      tp.paint(canvas, Offset(0, y));
//    }
//    translateX = xToTranslateX(size.width);
//    if (translateX >= startX && translateX <= stopX) {
//      TextPainter tp = getTextPainter(getDate(datas[mStopIndex].id));
//      tp.paint(canvas, Offset(size.width - tp.width, y));
//    }
  }

  @override
  void drawCrossLineText(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);

    TextPainter tp = getTextPainter(
      ChartFormats.money[pricePrecision].format(point.close),
      bgColor?.elementAt(0) ?? Colors.black,
      true,
    );
    double textHeight = tp.height;
    double textWidth = tp.width;

    double paddingXScreenSide = 3;
    double paddingXNearPeak = 1;
    double paddingXPeak = 6;
    double paddingY = _sideBadgePaddingY;
    double verticalDiff = textHeight / 2 + paddingY;
    double peakX;
    double y = getMainY(point.close);

    bool isLeft = false;
    if (translateXtoX(getX(index)) < mWidth / 2) {
      isLeft = false;

      peakX =
          textWidth + (paddingXScreenSide + paddingXNearPeak) + paddingXPeak;

      canvas.drawPath(
        Path()
          ..moveTo(peakX, y)
          ..lineTo(peakX - paddingXPeak, y + verticalDiff)
          ..lineTo(0, y + verticalDiff)
          ..lineTo(0, y - verticalDiff)
          ..lineTo(peakX - paddingXPeak, y - verticalDiff)
          ..close(),
        lastPriceBackgroundPaintNeutral,
      );

      tp.paint(
        canvas,
        Offset(paddingXScreenSide, y - textHeight / 2),
      );
    } else {
      isLeft = true;

      peakX = mWidth -
          textWidth -
          (paddingXScreenSide + paddingXNearPeak) -
          paddingXPeak;

      canvas.drawPath(
        Path()
          ..moveTo(peakX, y)
          ..lineTo(peakX + paddingXPeak, y + verticalDiff)
          ..lineTo(mWidth, y + verticalDiff)
          ..lineTo(mWidth, y - verticalDiff)
          ..lineTo(peakX + paddingXPeak, y - verticalDiff)
          ..close(),
        lastPriceBackgroundPaintNeutral,
      );
      tp.paint(
        canvas,
        Offset(mWidth - tp.width - paddingXScreenSide, y - textHeight / 2),
      );
    }

    final datePaddingX = 5;
    TextPainter dateTp = getTextPainter(
      ChartFormats.dateWithTime
          .format(DateTime.fromMillisecondsSinceEpoch(point.time)),
      bgColor.elementAt(0) ?? Colors.black,
      true,
    );
    textWidth = dateTp.width;
    textHeight = dateTp.height;

    // X center of the badge
    var x = translateXtoX(getX(index));
    // Y center of the badge
    final badgeHeight = dateTp.height + paddingY * 2;
    y = size.height - badgeHeight / 2 - (mBottomPadding - badgeHeight) / 2;

    if (x < textWidth + 2 * datePaddingX) {
      x = 1 + textWidth / 2 + datePaddingX;
    } else if (mWidth - x < textWidth + 2 * datePaddingX) {
      x = mWidth - 1 - textWidth / 2 - datePaddingX;
    }
    //double baseLine = textHeight / 2;
    canvas.drawRect(
      Rect.fromLTRB(
        x - textWidth / 2 - datePaddingX,
        y - textHeight / 2 - paddingY,
        x + textWidth / 2 + datePaddingX,
        y + textHeight / 2 + paddingY,
      ),
      lastPriceBackgroundPaintNeutral,
    );

    dateTp.paint(canvas, Offset(x - textWidth / 2, y - textHeight / 2));

    //长按显示这条数据详情
    sink?.add(InfoWindowEntity(point, isLeft));
  }

  @override
  void drawText(Canvas canvas, KLineEntity data, double x) {
    //长按显示按中的数据
    if (isLongPress) {
      var index = calculateSelectedX(selectX);
      data = getItem(index);
    }
    //松开显示最后一条数据
    mMainRenderer?.drawText(canvas, data, x);
    mVolRenderer?.drawText(canvas, data, x);
    mSecondaryRenderer?.drawText(canvas, data, x);
  }

  @override
  void drawMaxAndMin(Canvas canvas) {
    if (isLine == true) return;
    //绘制最大值和最小值
    double x = translateXtoX(getX(mMainMinIndex));
    double y = getMainY(mMainLowMinValue);
    if (x < mWidth / 2) {
      //画右边
      TextPainter tp = getTextPainter(
          "── " + mMainLowMinValue.toStringAsFixed(fixedLength), Colors.white);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      TextPainter tp = getTextPainter(
          mMainLowMinValue.toStringAsFixed(fixedLength) + " ──", Colors.white);
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
    x = translateXtoX(getX(mMainMaxIndex));
    y = getMainY(mMainHighMaxValue);
    if (x < mWidth / 2) {
      //画右边
      TextPainter tp = getTextPainter(
          "── " + mMainHighMaxValue.toStringAsFixed(fixedLength), Colors.white);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      TextPainter tp = getTextPainter(
          mMainHighMaxValue.toStringAsFixed(fixedLength) + " ──", Colors.white);
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
  }

  @override
  void drawLastPriceLineText(Canvas canvas, Size size, KLineEntity point) {
    double y = getMainY(point.close);

    // don't render it out of the main rect
    if (y < mMainRect.top || y > mMainRect.bottom) {
      return;
    }

    TextPainter textPaint = getTextPainter(
      ChartFormats.money[pricePrecision].format(point.close),
      bgColor?.elementAt(0) ?? Colors.black,
      true,
    );

    double textHeight = textPaint.height;
    double textWidth = textPaint.width;

    double paddingXRight = 3;
    double paddingXLeft = 1;
    double paddingY = _sideBadgePaddingY;
    double peakPaddingX = 6;
    double r = textHeight / 2 + paddingY;
    double peakX;

    peakX = mWidth - textWidth - (paddingXRight + paddingXLeft) - peakPaddingX;
    Path path = new Path();
    path.moveTo(peakX, y);
    path.lineTo(peakX + peakPaddingX, y + r);
    path.lineTo(mWidth, y + r);
    path.lineTo(mWidth, y - r);
    path.lineTo(peakX + peakPaddingX, y - r);
    path.close();
    canvas.drawPath(
        path,
        point.open > point.close
            ? lastPriceBackgroundPaintDown
            : lastPriceBackgroundPaintUp);
    textPaint.paint(
      canvas,
      Offset(mWidth - textPaint.width - paddingXRight, y - textHeight / 2),
    );
  }

  //
  void drawCrossLine(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);
    Paint paintY = Paint()
      ..color = Colors.white54
      ..strokeWidth = ChartStyle.vCrossWidth
      ..isAntiAlias = true;
    double x = getX(index);
    double y = getMainY(point.close);
    // Vertical line
    canvas.drawLine(
      Offset(x, mTopPadding),
      Offset(x, size.height - mBottomPadding),
      paintY,
    );

    Paint paintX = Paint()
      ..color = Colors.white54
      ..strokeWidth = ChartStyle.hCrossWidth
      ..isAntiAlias = true;
    // Horizontal line
    canvas.drawLine(
      Offset(-mTranslateX, y),
      Offset(-mTranslateX + mWidth / scaleX, y),
      paintX,
    );
    canvas.drawCircle(Offset(x, y), 2.0, paintX);
  }

  void drawLastPriceLine(Canvas canvas, Size size, KLineEntity point) {
    double y = getMainY(point.close);

    // don't render it out of the main rect
    if (y < mMainRect.top || y > mMainRect.bottom) {
      return;
    }

    // Horizontal line
    Paint paintX = Paint()
      ..color =
          point.open > point.close ? ChartColors.dnColor : ChartColors.upColor
      ..strokeWidth = ChartStyle.hCrossWidth
      ..isAntiAlias = true;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paintX,
    );
  }

  TextPainter getTextPainter(
    text, [
    color = ChartColors.defaultTextColor,
    bool bold = false,
  ]) {
    TextSpan span = TextSpan(
      text: "$text",
      style: getTextStyle(
        color,
        bold: bold,
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp;
  }

  String getDate(int date) {
    return dateFormat(DateTime.fromMillisecondsSinceEpoch(date), mFormats);
  }

  double getMainY(double y) => mMainRenderer?.getY(y) ?? 0.0;
}
