import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k_chart/constants.dart';
import 'package:k_chart/flutter_k_chart.dart';

import 'chart_style.dart';
import 'entity/info_window_entity.dart';
import 'entity/k_line_entity.dart';
import 'formatter.dart';
import 'renderer/chart_painter.dart';
import 'utils/date_format_util.dart';

enum MainState { MA, BOLL, NONE }
enum SecondaryState { MACD, KDJ, RSI, WR, NONE }

class TimeFormat {
  static const List<String> MONTH_DATE_COMMA_YEAR = [M, ' ', dd, ', ', yyyy];
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

/// The offset which chart will do when user dragging to the right
/// That mean when user drag to the very first value, it will allow
/// graph to move a little bit more to make the first value be not
/// at the very right. So we have space between right end and the last value
/// This is more readable.
const _rightScrollingOffset = -10.0;

class KChartWidget extends StatefulWidget {
  final List<KLineEntity> datas;
  final MainState mainState;
  final SecondaryState secondaryState;
  final bool isLine;
  final bool isChinese;
  final List<String> timeFormat;
  final DateFormat dateFormat;

  /// Called when the screen is scrolled to the end,
  /// returns TRUE if the right side, returns FALSE if the left side
  final Function(bool) onLoadMore;
  final List<Color> bgColor;
  final int fixedLength;
  final List<int> maDayList;
  final int rsiPeriod;
  final int wrPeriod;
  final int macdShortPeriod;
  final int macdLongPeriod;
  final int macdMaPeriod;
  final int kdjCalcPeriod;
  final int kdjMaPeriod1;
  final int kdjMaPeriod2;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool) isOnDrag;

  /// Used to draw a shortened int in difference places
  /// like 100K instead of 100,000
  final Formatter shortFormatter;

  final String fontFamily;
  final String wordVolume;
  final String wordDate;
  final String wordOpen;
  final String wordHigh;
  final String wordLow;
  final String wordClose;
  final String wordChange;
  final String wordAmount;

  /// Used to format prices in different places.
  /// For example at the right side of K-Chart
  final int pricePrecision;
  final int amountPrecision;

  KChartWidget(
    this.datas, {
    this.mainState = MainState.MA,
    this.secondaryState = SecondaryState.MACD,
    this.isLine,
    this.isChinese = true,
    this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
    this.dateFormat,
    this.onLoadMore,
    this.bgColor,
    this.fixedLength,
    this.maDayList = const [5, 10, 20],
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
    this.shortFormatter,
    this.fontFamily,
    this.wordVolume = 'Volume',
    this.wordDate = 'Date',
    this.wordOpen = 'Open',
    this.wordHigh = 'High',
    this.wordLow = 'Low',
    this.wordClose = 'Close',
    this.wordChange = 'Change',
    this.wordAmount = 'Amount',
    this.rsiPeriod = 6,
    this.wrPeriod = 14,
    this.macdShortPeriod = 12,
    this.macdLongPeriod = 26,
    this.macdMaPeriod = 9,
    this.kdjCalcPeriod = 9,
    this.kdjMaPeriod1 = 3,
    this.kdjMaPeriod2 = 3,
    this.pricePrecision = defaultPricePrecision,
    this.amountPrecision = defaultAmountPrecision
  }) : assert(maDayList != null);

  @override
  _KChartWidgetState createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  //
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;
  StreamController<InfoWindowEntity> mInfoWindowStream;
  double mWidth = 0;
  AnimationController _controller;
  Animation<double> aniX;
  double _lastScale = 1.0;
  bool isScale = false, isDrag = false, isLongPress = false;
  final List<String> infoNamesCN = [
    "时间",
    "开",
    "高",
    "低",
    "收",
    "涨跌额",
    "涨跌幅",
    "成交额"
  ];
  final List<String> infoNamesEN = [
    "Date",
    "Open",
    "High",
    "Low",
    "Close",
    "Change",
    "Change%",
    "Amount"
  ];
  List<String> infos;

  //
  @override
  void initState() {
    super.initState();
    mInfoWindowStream = StreamController<InfoWindowEntity>();
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
    if (widget.datas == null || widget.datas.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }
    return GestureDetector(
      onHorizontalDragDown: (details) {
        _stopAnimation();
        _onDragChanged(true);
      },
      onHorizontalDragUpdate: (details) {
        if (isScale || isLongPress) return;
        mScrollX = (details.primaryDelta / mScaleX + mScrollX)
            .clamp(_rightScrollingOffset, ChartPainter.maxScrollX);
        notifyChanged();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        var velocity = details.velocity.pixelsPerSecond.dx;
        _onFling(velocity);
      },
      onHorizontalDragCancel: () {
        _onDragChanged(false);
      },
      onScaleStart: (_) {
        isScale = true;
      },
      onScaleUpdate: (details) {
        if (isDrag || isLongPress) return;
        mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
        notifyChanged();
      },
      onScaleEnd: (_) {
        isScale = false;
        _lastScale = mScaleX;
      },
      onLongPressStart: (details) {
        isLongPress = true;
        if (mSelectX != details.globalPosition.dx) {
          mSelectX = details.globalPosition.dx + 40;
          notifyChanged();
        }
      },
      onLongPressMoveUpdate: (details) {
        if (mSelectX != details.globalPosition.dx) {
          mSelectX = details.globalPosition.dx + 40;
          notifyChanged();
        }
      },
      onLongPressEnd: (details) {
        isLongPress = false;
        mInfoWindowStream?.sink?.add(null);
        notifyChanged();
      },
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: ChartPainter(
              datas: widget.datas,
              scaleX: mScaleX,
              scrollX: mScrollX,
              selectX: mSelectX,
              isLongPass: isLongPress,
              mainState: widget.mainState,
              secondaryState: widget.secondaryState,
              isLine: widget.isLine,
              sink: mInfoWindowStream?.sink,
              bgColor: widget.bgColor,
              fixedLength: widget.fixedLength,
              maDayList: widget.maDayList,
              shortFormatter: widget.shortFormatter,
              fontFamily: widget.fontFamily,
              wordVolume: widget.wordVolume,
              rsiPeriod: widget.rsiPeriod,
              wrPeriod: widget.wrPeriod,
              macdShortPeriod: widget.macdShortPeriod,
              macdLongPeriod: widget.macdLongPeriod,
              macdMaPeriod: widget.macdMaPeriod,
              kdjCalcPeriod: widget.kdjCalcPeriod,
              kdjMaPeriod1: widget.kdjMaPeriod1,
              kdjMaPeriod2: widget.kdjMaPeriod2,
              pricePrecision: widget.pricePrecision,
              amountPrecision: widget.amountPrecision
            ),
          ),
          _buildInfoDialog()
        ],
      ),
    );
  }

  //
  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller.isAnimating) {
      _controller.stop();
      _onDragChanged(false);
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  void _onDragChanged(bool isOnDrag) {
    isDrag = isOnDrag;
    if (widget.isOnDrag != null) {
      widget.isOnDrag(isDrag);
    }
  }

  void _onFling(double x) {
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.flingTime),
      vsync: this,
    );
    aniX = null;
    aniX = Tween<double>(
      begin: mScrollX,
      end: x * widget.flingRatio + mScrollX,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.flingCurve,
    ));
    aniX.addListener(() {
      mScrollX = aniX.value;
      if (mScrollX <= _rightScrollingOffset) {
        mScrollX = _rightScrollingOffset;
        if (widget.onLoadMore != null) {
          widget.onLoadMore(true);
        }
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore(false);
        }
        _stopAnimation();
      }
      notifyChanged();
    });
    aniX.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    _controller.forward();
  }

  void notifyChanged() => setState(() {});

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity>(
      stream: mInfoWindowStream?.stream,
      builder: (context, snapshot) {
        if (!isLongPress ||
            widget.isLine == true ||
            !snapshot.hasData ||
            snapshot.data.kLineEntity == null) {
          return Container();
        }

        KLineEntity entity = snapshot.data.kLineEntity;
        double change = entity.close - entity.open;
        double changePercent = (change / entity.open) * 100;

        infos = [
          _getDate(entity.time),
          ChartFormats.money[widget.pricePrecision].format(entity.open),
          ChartFormats.money[widget.pricePrecision].format(entity.high),
          ChartFormats.money[widget.pricePrecision].format(entity.low),
          ChartFormats.money[widget.pricePrecision].format(entity.close),
          ChartFormats.money[widget.amountPrecision].format(entity.vol),
          // widget.shortFormatter != null
          //     ? widget.shortFormatter(entity.vol.toInt())
          //     : ChartFormats.numberShort.format(entity.vol),
          '${change > 0 ? '+' : ''}${change.toStringAsFixed(widget.pricePrecision)}',
          '${changePercent > 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
        ];

        final infoNames = [
          widget.wordDate,
          widget.wordOpen,
          widget.wordHigh,
          widget.wordLow,
          widget.wordClose,
          widget.wordVolume,
          widget.wordChange,
          widget.wordChange + ', %',
        ];

        return Positioned(
          top: 10.0,
          right: snapshot.data.isLeft ? null : 10.0,
          left: snapshot.data.isLeft ? 10.0 : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 3.0,
            ),
            width: mWidth / 3,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                color: Theme.of(context).hintColor.withOpacity(0.05),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: ListView.builder(
              padding: EdgeInsets.all(4),
              itemCount: infos.length,
              itemExtent: 14.0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _buildItem(
                  infos[index],
                  infoNames[index],
                  //widget.isChinese ? infoNamesCN[index] : infoNamesEN[index],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(String info, String infoName) {
    Color color = Color(0xFF8D9192);
    if (info.startsWith("+")) {
      color = ChartColors.upColor;
    } else if (info.startsWith("-")) {
      color = ChartColors.dnColor;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            "$infoName",
            style: const TextStyle(
              color: Color(0xFF8D9192),
              fontSize: 9.0,
            ),
          ),
        ),
        Text(
          info,
          style: TextStyle(
            color: color,
            fontSize: 9.0,
          ),
        ),
      ],
    );
  }

  String _getDate(int date) {
    return dateFormat(
      DateTime.fromMillisecondsSinceEpoch(date),
      widget.timeFormat,
    );
  }

  double getMinScrollX() {
    return mScaleX;
  }
}
