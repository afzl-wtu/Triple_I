import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:k_chart/formatter.dart';
import 'package:k_chart/utils/render_util.dart';

import '../chart_style.dart';
import '../entity/volume_entity.dart';
import '../renderer/base_chart_renderer.dart';
import 'base_chart_renderer.dart';

class VolRenderer extends BaseChartRenderer<VolumeEntity> {
  double mVolWidth = ChartStyle.volWidth;

  /// Used to draw a shortened int in the right text
  /// like 100K instead of 100,000
  final Formatter shortFormatter;
  final String wordVolume;

  //
  Paint _volumeBadgeBackgroundPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..style = PaintingStyle.fill
    ..color = Colors.white10;

  VolRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    int fixedLength, {
    @required this.shortFormatter,
    @required this.wordVolume,
    String fontFamily,
    List<Color> bgColor,
    int pricePrecision,
    int amountPrecision,
  }) : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          fixedLength: fixedLength,
          fontFamily: fontFamily,
          bgColor: bgColor,
          pricePrecision: pricePrecision,
          amountPrecision: amountPrecision
        );

  @override
  void drawChart(
    VolumeEntity lastPoint,
    VolumeEntity curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    double r = mVolWidth / 2;
    double top = getVolY(curPoint.vol);
    double bottom = chartRect.bottom;
    if (curPoint.vol != 0) {
      canvas.drawRect(
          Rect.fromLTRB(curX - r, top, curX + r, bottom),
          chartPaint
            ..color = curPoint.close > curPoint.open
                ? ChartColors.upColor
                : ChartColors.dnColor);
    }

    if (lastPoint.MA5Volume != 0) {
      drawLine(lastPoint.MA5Volume, curPoint.MA5Volume, canvas, lastX, curX,
          ChartColors.ma5Color);
    }

    if (lastPoint.MA10Volume != 0) {
      drawLine(lastPoint.MA10Volume, curPoint.MA10Volume, canvas, lastX, curX,
          ChartColors.ma10Color);
    }
  }

  double getVolY(double value) =>
      (maxValue - value) * (chartRect.height / maxValue) + chartRect.top;

  @override
  void drawText(Canvas canvas, VolumeEntity data, double x) {
    /*TextSpan span = TextSpan(
      children: [
        TextSpan(
            text: "VOL:${NumberUtil.format(data.vol)}    ",
            style: getTextStyle(ChartColors.volColor)),
        if (NumberUtil.checkNotNullOrZero(data.MA5Volume))
          TextSpan(
              text: "MA5:${NumberUtil.format(data.MA5Volume)}    ",
              style: getTextStyle(ChartColors.ma5Color)),
        if (NumberUtil.checkNotNullOrZero(data.MA10Volume))
          TextSpan(
              text: "MA10:${NumberUtil.format(data.MA10Volume)}    ",
              style: getTextStyle(ChartColors.ma10Color)),
      ],
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
    */

    TextSpan span = TextSpan(
      text: wordVolume,
      style: TextStyle(
        fontSize: ChartStyle.fontSize,
        color: Colors.white.withOpacity(0.5),
        fontWeight: FontWeight.bold,
      ),
    );
    TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    // Volume badge
    final yLinePlusPadding =
        chartRect.top - topPadding + rightTextAxisLinePadding;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          x,
          yLinePlusPadding,
          x + tp.width + 12,
          yLinePlusPadding + tp.height + 8,
        ),
        Radius.circular(3.0),
      ),
      _volumeBadgeBackgroundPaint,
    );
    tp.paint(
      canvas,
      Offset(
        x + 6,
        yLinePlusPadding + 4,
      ),
    );
  }

  @override
  void drawRightText(Canvas canvas, Size size, textStyle, int gridRows) {
    final values = [maxValue, maxValue / 2];

    values.forEach((v) {
      TextSpan span = TextSpan(
        text: ChartFormats.money[amountPrecision].format(v),
        style: textStyle,
      );
      TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      var lineY =
          chartRect.top + chartRect.height * (1 - v / maxValue) - topPadding;
      tp.paint(
        canvas,
        Offset(
          chartRect.width - tp.width - rightTextScreenSidePadding,
          lineY + rightTextAxisLinePadding,
        ),
      );
      if (v == maxValue ~/ 2) {
        RenderUtil.drawDashedLine(
          canvas,
          Offset(chartRect.width - rightCoverWidth, lineY),
          Offset(chartRect.width, lineY),
          gridPaint,
        );
      }
    });

    RenderUtil.drawDashedLine(
      canvas,
      Offset(chartRect.width - rightCoverWidth, chartRect.top),
      Offset(chartRect.width - rightCoverWidth, chartRect.bottom),
      gridPaint,
    );

    RenderUtil.drawDashedLine(
      canvas,
      Offset(chartRect.width - gridPaint.strokeWidth / 2, chartRect.top),
      Offset(chartRect.width - gridPaint.strokeWidth / 2, chartRect.bottom),
      gridPaint,
    );

    RenderUtil.drawDashedLine(
      canvas,
      Offset(chartRect.width - gridPaint.strokeWidth / 2 - rightCoverWidth,
          chartRect.bottom),
      Offset(chartRect.width - gridPaint.strokeWidth / 2, chartRect.bottom),
      gridPaint,
    );
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    final bottom = chartRect.bottom;
    final top = chartRect.top;
    final height = chartRect.height;
    final width = chartRect.width;

    RenderUtil.drawDashedLine(
      canvas,
      Offset(0, bottom),
      Offset(width, bottom),
      gridPaint,
    );

    RenderUtil.drawDashedLine(
      canvas,
      Offset(0, bottom - height / 2),
      Offset(width, bottom - height / 2),
      gridPaint,
    );

    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      // shift to make very left vertical line fully visible
      final shift = i == 0 ? gridPaint.strokeWidth / 2 : 0.0;
      RenderUtil.drawDashedLine(
        canvas,
        Offset(columnSpace * i + shift, top - topPadding),
        Offset(columnSpace * i + shift, bottom),
        gridPaint,
      );
    }
  }
}
