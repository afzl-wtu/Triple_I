import 'dart:async';

import './chart_style.dart';
import './entity/k_line_entity.dart';
import './renderer/chart_painter.dart';
import './renderer/index.dart';
import './utils/date_format_util.dart';
import 'package:flutter/material.dart';

import './chart_translations.dart';
import './extension/map_ext.dart';
import 'entity/info_window_entity.dart';
//import './flutter_k_chart.dart';

enum MainState { MA, BOLL, NONE }
enum SecondaryState { MACD, KDJ, RSI, WR, CCI, NONE }

class TimeFormat {
  static const List<String> YEAR_MONTH_DAY = [yyyy, '-', mm, '-', dd];
  static const List<String> YEAR_MONTH_DAY_WITH_HOUR = [
    yyyy,
    '-',
    mm,
    '-',
    dd,
    ' ',
    HH,
    ':',
    nn
  ];
}

class KChartWidget extends StatefulWidget {
  final List<KLineEntity>? datas;
  final MainState mainState;
  final bool volHidden;
  final SecondaryState secondaryState;
  final Function()? onSecondaryTap;
  final bool isLine;
  final bool hideGrid;
  @Deprecated('Use `translations` instead.')
  final bool isChinese;
  final bool showNowPrice;
  final Map<String, ChartTranslations> translations;
  final List<String> timeFormat;

  //当屏幕滚动到尽头会调用，真为拉到屏幕右侧尽头，假为拉到屏幕左侧尽头
  final Function(bool)? onLoadMore;
  final List<Color>? bgColor;
  final int fixedLength;
  final List<int> maDayList;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool)? isOnDrag;
  final ChartColors chartColors;
  final ChartStyle chartStyle;
  final bool isTrendLine;

  KChartWidget(
    this.datas,
    this.chartStyle,
    this.chartColors, {
    required this.isTrendLine,
    this.mainState = MainState.MA,
    this.secondaryState = SecondaryState.MACD,
    this.onSecondaryTap,
    this.volHidden = false,
    this.isLine = false,
    this.hideGrid = false,
    this.isChinese = false,
    this.showNowPrice = true,
    this.translations = kChartTranslations,
    this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
    this.onLoadMore,
    this.bgColor,
    this.fixedLength = 2,
    this.maDayList = const [5, 10, 20],
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
  });

  @override
  _KChartWidgetState createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0, mSelectY = 0.0;
  StreamController<InfoWindowEntity?>? mInfoWindowStream;
  List<Line> lines = [];

  bool waitingForOtherPairofCords = false;
  bool enableCordRecord = false;
  double mWidth = 0;
  double? changeinXposition;
  double? changeinYposition;
  AnimationController? _controller;
  Animation<double>? aniX;

  double getMinScrollX() {
    return mScaleX;
  }

  double _lastScale = 1.0;
  bool isScale = false, isDrag = false, isLongPress = false;

  @override
  void initState() {
    super.initState();
    mInfoWindowStream = StreamController<InfoWindowEntity?>.broadcast();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mWidth = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    mInfoWindowStream?.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas != null && widget.datas!.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }
    final _painter = ChartPainter(
      widget.chartStyle,
      widget.chartColors,
      lines: lines,
      datas: widget.datas,
      isTrendLine: widget.isTrendLine,
      scaleX: mScaleX,
      scrollX: mScrollX,
      selectX: mSelectX,
      selectY: mSelectY,
      isLongPass: isLongPress,
      mainState: widget.mainState,
      volHidden: widget.volHidden,
      secondaryState: widget.secondaryState,
      isLine: widget.isLine,
      hideGrid: widget.hideGrid,
      showNowPrice: widget.showNowPrice,
      sink: mInfoWindowStream?.sink,
      bgColor: widget.bgColor,
      fixedLength: widget.fixedLength,
      maDayList: widget.maDayList,
    );
    return GestureDetector(
      onTapUp: (details) {
        // if (widget.onSecondaryTap != null &&
        //     _painter.isInSecondaryRect(details.localPosition)) {
        //   widget.onSecondaryTap!();
        // }
        if (widget.isTrendLine && !isLongPress && enableCordRecord) {
          enableCordRecord = false;
          Offset p1 = Offset(afzl()!, mSelectY);
          if (!waitingForOtherPairofCords)
            lines.add(Line(p1, Offset(-1, -1), afzalMax!, afzalScale!));

          if (waitingForOtherPairofCords) {
            var a = lines.last;
            lines.removeLast();
            lines.add(Line(a.p1, p1, afzalMax!, afzalScale!));
            waitingForOtherPairofCords = false;
          } else {
            waitingForOtherPairofCords = true;
          }

          notifyChanged();
        }
      },
      onHorizontalDragDown: (details) {
        print('PP: onHorizontalDragDown k_chart_widget, details: $details');
        _stopAnimation();
        _onDragChanged(true);
      },
      onHorizontalDragUpdate: (details) {
        //print('PP: onHorizontalDragUpdate k_chart_widget, details: $details');
        if (isScale || isLongPress) return;
        mScrollX = (details.primaryDelta! / mScaleX + mScrollX)
            .clamp(0.0, ChartPainter.maxScrollX)
            .toDouble();
        notifyChanged();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        print('PP: onHorizontalDragEnd k_chart_widget, details: $details');
        var velocity = details.velocity.pixelsPerSecond.dx;
        _onFling(velocity);
      },
      onHorizontalDragCancel: () {
        print('PP: onHorizontalDragCancel k_chart_widget');
        _onDragChanged(false);
      },
      onScaleStart: (_) {
        print('PP: onScaleStart k_chart_widget');
        isScale = true;
      },
      onScaleUpdate: (details) {
        print('PP: onScaleUpdatet k_chart_widget,details:$details');
        if (isDrag || isLongPress) return;
        mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
        notifyChanged();
      },
      onScaleEnd: (_) {
        print('PP: onScaleEnd k_chart_widget');
        isScale = false;
        _lastScale = mScaleX;
      },
      onLongPressStart: (details) {
        print(
            'PP: onLongPress Start k_chart_widget, globalxposition:${details.globalPosition.dx}, localXpostion: ${details.localPosition.dx}');
        isLongPress = true;
        if ((mSelectX != details.globalPosition.dx ||
                mSelectY != details.globalPosition.dy) &&
            !widget.isTrendLine) {
          changeinXposition = details.globalPosition.dx;

          notifyChanged();
        }
        if (widget.isTrendLine && changeinXposition == null) {
          mSelectX = changeinXposition = details.globalPosition.dx;
          mSelectY = changeinYposition = details.globalPosition.dy;
          notifyChanged();
        }
        if (widget.isTrendLine && changeinXposition != null) {
          changeinXposition = details.globalPosition.dx;
          changeinYposition = details.globalPosition.dy;
          notifyChanged();
        }
      },
      onLongPressMoveUpdate: (details) {
        print(
            'PP: onLongPressMoveUpdate Start k_chart_widget, details:X: ${details.globalPosition.dx}, distance: ${details.globalPosition.distance}');

        if ((mSelectX != details.globalPosition.dx ||
                mSelectY != details.globalPosition.dy) &&
            !widget.isTrendLine) {
          mSelectX = details.globalPosition.dx;
          mSelectY = details.localPosition.dy;

          notifyChanged();
        }
        if (widget.isTrendLine) {
          mSelectX =
              mSelectX + (details.globalPosition.dx - changeinXposition!);
          changeinXposition = details.globalPosition.dx;
          mSelectY =
              mSelectY + (details.globalPosition.dy - changeinYposition!);
          changeinYposition = details.globalPosition.dy;
          notifyChanged();
        }
      },
      onLongPressEnd: (details) {
        print('PP: onLongPressEnd k_chart_widget, details:$details');
        isLongPress = false;
        enableCordRecord = true;
        mInfoWindowStream?.sink.add(null);
        notifyChanged();
      },
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: _painter,
          ),
          if (!widget.isTrendLine) _buildInfoDialog()
        ],
      ),
    );
  }

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller!.isAnimating) {
      _controller!.stop();
      _onDragChanged(false);
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  void _onDragChanged(bool isOnDrag) {
    isDrag = isOnDrag;
    if (widget.isOnDrag != null) {
      widget.isOnDrag!(isDrag);
    }
  }

  void _onFling(double x) {
    _controller = AnimationController(
        duration: Duration(milliseconds: widget.flingTime), vsync: this);
    aniX = null;
    aniX = Tween<double>(begin: mScrollX, end: x * widget.flingRatio + mScrollX)
        .animate(CurvedAnimation(
            parent: _controller!.view, curve: widget.flingCurve));
    aniX!.addListener(() {
      mScrollX = aniX!.value;
      if (mScrollX <= 0) {
        mScrollX = 0;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(true);
        }
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(false);
        }
        _stopAnimation();
      }
      notifyChanged();
    });
    aniX!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    _controller!.forward();
  }

  void notifyChanged() => setState(() {});

  late List<String> infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity?>(
        stream: mInfoWindowStream?.stream,
        builder: (context, snapshot) {
          if (!isLongPress ||
              widget.isLine == true ||
              !snapshot.hasData ||
              snapshot.data?.kLineEntity == null) return Container();
          KLineEntity entity = snapshot.data!.kLineEntity;
          double upDown = entity.close - entity.open;
          double upDownPercent = entity.ratio ?? (upDown / entity.open) * 100;
          infos = [
            getDate(entity.time),
            entity.open.toStringAsFixed(widget.fixedLength),
            entity.high.toStringAsFixed(widget.fixedLength),
            entity.low.toStringAsFixed(widget.fixedLength),
            entity.close.toStringAsFixed(widget.fixedLength),
            "${upDown > 0 ? "+" : ""}${upDown.toStringAsFixed(widget.fixedLength)}",
            "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
            entity.amount.toInt().toString()
          ];
          return Container(
            margin: EdgeInsets.only(
                left: snapshot.data!.isLeft ? 4 : mWidth - mWidth / 3 - 4,
                top: 25),
            width: mWidth / 3,
            decoration: BoxDecoration(
                color: widget.chartColors.selectFillColor,
                border: Border.all(
                    color: widget.chartColors.selectBorderColor, width: 0.5)),
            child: ListView.builder(
              padding: EdgeInsets.all(4),
              itemCount: infos.length,
              itemExtent: 14.0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // ignore: deprecated_member_use_from_same_package
                final translations = widget.isChinese
                    ? kChartTranslations['zh_CN']!
                    : widget.translations.of(context);

                return _buildItem(
                  infos[index],
                  translations.byIndex(index),
                );
              },
            ),
          );
        });
  }

  Widget _buildItem(String info, String infoName) {
    Color color = widget.chartColors.infoWindowNormalColor;
    if (info.startsWith("+"))
      color = widget.chartColors.infoWindowUpColor;
    else if (info.startsWith("-")) color = widget.chartColors.infoWindowDnColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: Text("$infoName",
                style: TextStyle(
                    color: widget.chartColors.infoWindowTitleColor,
                    fontSize: 10.0))),
        Text(info, style: TextStyle(color: color, fontSize: 10.0)),
      ],
    );
  }

  String getDate(int? date) => dateFormat(
      DateTime.fromMillisecondsSinceEpoch(
          date ?? DateTime.now().millisecondsSinceEpoch),
      widget.timeFormat);
}
