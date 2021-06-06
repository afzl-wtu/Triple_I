import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:k_chart/utils/render_util.dart';

import '../entity/macd_entity.dart';
import '../k_chart_widget.dart' show SecondaryState;
import 'base_chart_renderer.dart';

class SecondaryRenderer extends BaseChartRenderer<MACDEntity> {
  double mMACDWidth = ChartStyle.macdWidth;
  SecondaryState state;
  final int macdShortPeriod;
  final int macdLongPeriod;
  final int macdMaPeriod;
  final int rsiPeriod;
  final int wrPeriod;
  final int kdjCalcPeriod;
  final int kdjMaPeriod1;
  final int kdjMaPeriod2;

  SecondaryRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    this.state,
    int fixedLength, {
    this.macdShortPeriod,
    this.macdLongPeriod,
    this.macdMaPeriod,
    this.rsiPeriod,
    this.wrPeriod,
    this.kdjCalcPeriod,
    this.kdjMaPeriod1,
    this.kdjMaPeriod2,
    String fontFamily,
    List<Color> bgColor,
    int pricePrecision,
  }) : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          fixedLength: fixedLength,
          fontFamily: fontFamily,
          bgColor: bgColor,
          pricePrecision: pricePrecision,
        );

  @override
  void drawChart(
    MACDEntity lastPoint,
    MACDEntity curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    switch (state) {
      case SecondaryState.MACD:
        drawMACD(curPoint, canvas, curX, lastPoint, lastX);
        break;
      case SecondaryState.KDJ:
        drawLine(
          lastPoint.k,
          curPoint.k,
          canvas,
          lastX,
          curX,
          ChartColors.kColor,
        );
        drawLine(
          lastPoint.d,
          curPoint.d,
          canvas,
          lastX,
          curX,
          ChartColors.dColor,
        );
        drawLine(
          lastPoint.j,
          curPoint.j,
          canvas,
          lastX,
          curX,
          ChartColors.jColor,
        );
        break;
      case SecondaryState.RSI:
        drawLine(
          lastPoint.rsi,
          curPoint.rsi,
          canvas,
          lastX,
          curX,
          ChartColors.rsiColor,
        );
        break;
      case SecondaryState.WR:
        drawLine(
          lastPoint.r,
          curPoint.r,
          canvas,
          lastX,
          curX,
          ChartColors.rsiColor,
        );
        break;
      default:
        break;
    }
  }

  void drawMACD(
    MACDEntity curPoint,
    Canvas canvas,
    double curX,
    MACDEntity lastPoint,
    double lastX,
  ) {
    double macdY = getY(curPoint.macd);
    double r = mMACDWidth / 2;
    double zeroy = getY(0);
    if (curPoint.macd > 0) {
      canvas.drawRect(Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
          chartPaint..color = ChartColors.upColor);
    } else {
      canvas.drawRect(Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
          chartPaint..color = ChartColors.dnColor);
    }
    if (lastPoint.dif != 0) {
      drawLine(lastPoint.dif, curPoint.dif, canvas, lastX, curX,
          ChartColors.difColor);
    }
    if (lastPoint.dea != 0) {
      drawLine(lastPoint.dea, curPoint.dea, canvas, lastX, curX,
          ChartColors.deaColor);
    }
  }

  @override
  void drawText(Canvas canvas, MACDEntity data, double x) {
    List<TextSpan> children;
    switch (state) {
      case SecondaryState.MACD:
        children = [
          TextSpan(
            text: 'MACD ',
            style: getTextStyleLight(ChartColors.defaultTextColor),
          ),
          TextSpan(
            text: "($macdShortPeriod, $macdLongPeriod, $macdMaPeriod)    ",
            style: getTextStyleBold(ChartColors.defaultTextColor),
          ),
          if (data.macd != 0)
            TextSpan(
              text: "MACD: ",
              style: getTextStyleLight(ChartColors.macdColorOpacity70),
            ),
          if (data.macd != 0)
            TextSpan(
              text: "${format(data.macd)}    ",
              style: getTextStyleBold(ChartColors.macdColor),
            ),
          if (data.dif != 0)
            TextSpan(
              text: "DIF: ",
              style: getTextStyleLight(ChartColors.difColorOpacity70),
            ),
          if (data.dif != 0)
            TextSpan(
              text: "${format(data.dif)}    ",
              style: getTextStyleBold(ChartColors.difColor),
            ),
          if (data.dea != 0)
            TextSpan(
              text: "DEA: ",
              style: getTextStyleLight(ChartColors.deaColorOpacity70),
            ),
          if (data.dea != 0)
            TextSpan(
              text: "${format(data.dea)}",
              style: getTextStyleBold(ChartColors.deaColor),
            ),
        ];
        break;
      case SecondaryState.KDJ:
        children = [
          TextSpan(
            text: "KDJ ",
            style: getTextStyleLight(ChartColors.defaultTextColor),
          ),
          TextSpan(
            text: '($kdjCalcPeriod, $kdjMaPeriod1, $kdjMaPeriod2)    ',
            style: getTextStyleBold(ChartColors.defaultTextColor),
          ),
          if (data.macd != 0)
            TextSpan(
              text: 'K: ',
              style: getTextStyleLight(ChartColors.kColorOpacity70),
            ),
          if (data.macd != 0)
            TextSpan(
              text: '${format(data.k)}    ',
              style: getTextStyleBold(ChartColors.kColor),
            ),
          if (data.dif != 0)
            TextSpan(
              text: 'D: ',
              style: getTextStyleBold(ChartColors.dColorOpacity70),
            ),
          if (data.dif != 0)
            TextSpan(
              text: '${format(data.d)}    ',
              style: getTextStyleBold(ChartColors.dColor),
            ),
          if (data.dea != 0)
            TextSpan(
              text: 'J: ',
              style: getTextStyleLight(ChartColors.jColorOpacity70),
            ),
          if (data.dea != 0)
            TextSpan(
              text: '${format(data.j)}',
              style: getTextStyleBold(ChartColors.jColor),
            ),
        ];
        break;
      case SecondaryState.RSI:
        children = [
          TextSpan(
            text: 'RSI $rsiPeriod: ',
            style: getTextStyleLight(ChartColors.rsiColorOpacity70),
          ),
          TextSpan(
            text: format(data.rsi),
            style: getTextStyleBold(ChartColors.rsiColor),
          ),
        ];
        break;
      case SecondaryState.WR:
        children = [
          TextSpan(
            text: 'WR $wrPeriod: ',
            style: getTextStyleLight(ChartColors.rsiColorOpacity70),
          ),
          TextSpan(
            text: format(data.r),
            style: getTextStyleBold(ChartColors.rsiColor),
          ),
        ];
        break;
      default:
        break;
    }
    TextPainter tp = TextPainter(
      text: TextSpan(children: children ?? []),
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
    tp.paint(
      canvas,
      Offset(x, chartRect.top - topPadding + rightTextAxisLinePadding),
    );
  }

  @override
  void drawRightText(Canvas canvas, Size size, textStyle, int gridRows) {
    final values = [
      maxValue,
      minValue + (maxValue - minValue) / 2,
      minValue,
    ];

    final ys = [
      chartRect.top,
      chartRect.top + (chartRect.bottom - chartRect.top) / 2,
      chartRect.bottom,
    ];

    for (int i = 0; i < values.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: format(values[i]),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      var y = ys[i] - topPadding + rightTextAxisLinePadding;
      // the latest number should be ABOVE hte line, not under it
      if (i == values.length - 1) {
        y = ys[i] - topPadding - rightTextAxisLinePadding - painter.height;
      }
      painter.paint(
        canvas,
        Offset(
          chartRect.width - painter.width - rightTextScreenSidePadding,
          y,
        ),
      );
      RenderUtil.drawDashedLine(
        canvas,
        Offset(chartRect.width - rightCoverWidth, ys[i] - topPadding),
        Offset(chartRect.width, ys[i] - topPadding),
        gridPaint,
      );
    }

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
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    final top = chartRect.top;
    final bottom = chartRect.bottom;
    final middle = top + (bottom - top) / 2;

    RenderUtil.drawDashedLine(
      canvas,
      Offset(0, top),
      Offset(chartRect.width, top),
      gridPaint,
    );
    RenderUtil.drawDashedLine(
      canvas,
      Offset(0, middle),
      Offset(chartRect.width, middle),
      gridPaint,
    );
    RenderUtil.drawDashedLine(
      canvas,
      Offset(0, bottom),
      Offset(chartRect.width, bottom),
      gridPaint,
    );
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      RenderUtil.drawDashedLine(
        canvas,
        Offset(columnSpace * i, chartRect.top - topPadding),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
      /*RenderUtil.drawDashedLine(
        canvas,
        Offset(columnSpace * i, (chartRect.top - topPadding) + 20),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
      RenderUtil.drawDashedLine(
        canvas,
        Offset(columnSpace * i, chartRect.top - topPadding),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );*/
    }
  }
}
