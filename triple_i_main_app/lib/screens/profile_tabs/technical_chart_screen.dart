import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main/repository/k_chart/chart_translations.dart';
import 'package:main/repository/k_chart/flutter_k_chart.dart';
import 'package:main/widgets/backgroundGrad.dart';
import 'package:main/widgets/loading_indicator.dart';

class TechnicalChartScreen extends StatefulWidget {
  final Map<String, List<KLineEntity>> durationChart;
  final Function durationController;
  final String currentDuration;
  TechnicalChartScreen(
      this.durationChart, this.durationController, this.currentDuration);

  @override
  _TechnicalChartScreenState createState() => _TechnicalChartScreenState();
}

class _TechnicalChartScreenState extends State<TechnicalChartScreen> {
  MainState _mainState = MainState.MA;
  ChartStyle chartStyle = ChartStyle();
  ChartColors chartColors = ChartColors();
  bool _hideGrid = false;
  bool _showNowPrice = true;
  bool isChangeUI = false;
  bool _volHidden = false;

  SecondaryState _secondaryState = SecondaryState.MACD;

  bool isLine = false;
  bool _isLoading = true;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    print('PP: in chart screen initState');
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    print('PP in chart screen dispose method');
    super.dispose();
  }

  bool _isJumpingback = false;
  Future<void> _jumpBack() async {
    print('PP: in _jumpBack start');
    _isLoading = true;
    bool _isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    if (_isPortrait) {
      _isJumpingback = true;
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.pop(context);
    } else
      _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    print('PP: in chartscreen build method');
    if (!_isJumpingback) _jumpBack();
    if (widget.durationChart['${widget.currentDuration}'] == null)
      widget.durationController('1day', nextScreen: true);
    return Scaffold(
      body: (_isLoading)
          ? Stack(children: [
              BackgroundImage(),
              Center(
                child: LoadingIndicatorWidget(),
              )
            ])
          : Stack(children: [
              Row(
                children: [
                  buildDummyColumn(),
                  Expanded(
                      child: KChartWidget(
                    widget.durationChart['${widget.currentDuration}'],
                    chartStyle,
                    chartColors,
                    isTrendLine: false,
                    isLine: isLine,
                    mainState: _mainState,
                    volHidden: _volHidden,
                    secondaryState: _secondaryState,
                    fixedLength: 2,
                    timeFormat: TimeFormat.YEAR_MONTH_DAY,
                    translations: kChartTranslations,
                    showNowPrice: _showNowPrice,
                    //`isChinese` is Deprecated, Use `translations` instead.
                    isChinese: false,
                    hideGrid: _hideGrid,
                    maDayList: [1, 100, 1000],
                  )
                      // KChartWidget(
                      //   widget.durationChart['${widget.currentDuration}'],
                      //   isLine: isLine,
                      //   mainState: _mainState,
                      //   secondaryState: _secondaryState,
                      //   fixedLength: 2,
                      //   timeFormat: TimeFormat.YEAR_MONTH_DAY,
                      //   isChinese: false,
                      //   bgColor: [
                      //     Color(0xFF121128),
                      //     Color(0xFF121128),
                      //     Color(0xFF121128)
                      //   ],
                      // ),
                      ),
                ],
              ),
              Row(
                children: [buildButtons(), Spacer()],
              ),
            ]),
    );
  }

  Widget buildDummyColumn() {
    return Column(
      children: [
        button(
          "Line",
          onPressed: null,
          selected: isLine,
        ),
      ],
    );
  }

  Widget buildButtons() {
    return Container(
      color: Color(0xFF121128),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            button("Candl",
                onPressed: () => isLine = !isLine, selected: !isLine),
            button("MA",
                onPressed: () => _mainState =
                    _mainState == MainState.MA ? MainState.NONE : MainState.MA,
                selected: _mainState == MainState.MA),
            button(
              "BOLL",
              onPressed: () => _mainState = _mainState == MainState.BOLL
                  ? MainState.NONE
                  : MainState.BOLL,
              selected: _mainState == MainState.BOLL,
            ),
            button("Vol",
                onPressed: () => _volHidden = !_volHidden,
                selected: !_volHidden),
            button("Grid",
                onPressed: () => _hideGrid = !_hideGrid, selected: !_hideGrid),
            button("Price",
                onPressed: () => _showNowPrice = !_showNowPrice,
                selected: _showNowPrice),
            SizedBox(
              height: 6,
            ),
            button("MACD",
                onPressed: () => _secondaryState =
                    _secondaryState == SecondaryState.MACD
                        ? SecondaryState.NONE
                        : SecondaryState.MACD,
                selected: _secondaryState == SecondaryState.MACD),
            button("KDJ",
                onPressed: () => _secondaryState =
                    _secondaryState == SecondaryState.KDJ
                        ? SecondaryState.NONE
                        : SecondaryState.KDJ,
                selected: _secondaryState == SecondaryState.KDJ),
            button("RSI",
                onPressed: () => _secondaryState =
                    _secondaryState == SecondaryState.RSI
                        ? SecondaryState.NONE
                        : SecondaryState.RSI,
                selected: _secondaryState == SecondaryState.RSI),
            button("WR",
                onPressed: () => _secondaryState =
                    _secondaryState == SecondaryState.WR
                        ? SecondaryState.NONE
                        : SecondaryState.WR,
                selected: _secondaryState == SecondaryState.WR),
            button("CCI",
                onPressed: () => _secondaryState =
                    _secondaryState == SecondaryState.CCI
                        ? SecondaryState.NONE
                        : SecondaryState.CCI,
                selected: _secondaryState == SecondaryState.CCI),
            SizedBox(
              height: 6,
            ),
            // button("Customize UI", onPressed: () {
            //   setState(() {
            //     this.isChangeUI = !this.isChangeUI;
            //     if (this.isChangeUI) {
            //       chartColors.selectBorderColor = Colors.red;
            //       chartColors.selectFillColor = Colors.red;
            //       chartColors.lineFillColor = Colors.red;
            //       chartColors.kLineColor = Colors.yellow;
            //     } else {
            //       chartColors.selectBorderColor = Color(0xff6C7A86);
            //       chartColors.selectFillColor = Color(0xff0D1722);
            //       chartColors.lineFillColor = Color(0x554C86CD);
            //       chartColors.kLineColor = Color(0xff4C86CD);
            //     }
            //   });
            // }),
            button(
              "1m",
              onPressed: () => widget.durationController('1min'),
              selected: widget.currentDuration == '1min',
            ),
            button(
              "5m",
              onPressed: () => widget.durationController('5min'),
              selected: widget.currentDuration == '5min',
            ),
            button(
              "30m",
              onPressed: () => widget.durationController('30min'),
              selected: widget.currentDuration == '30min',
            ),
            button(
              "1h",
              onPressed: () => widget.durationController('1hour'),
              selected: widget.currentDuration == '1hour',
            ),
            button(
              "1D",
              onPressed: () => widget.durationController('1day'),
              selected: widget.currentDuration == '1day',
            ),
            button(
              "⏱️",
              onPressed: _showRangePicker,
              selected: widget.currentDuration == '1day',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRangePicker() async {
    final _response = await showDateRangePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.input,
        initialDateRange: DateTimeRange(
            start: DateTime.now().subtract(Duration(days: 120)),
            end: DateTime.now()),
        firstDate: DateTime.now().subtract(Duration(days: 3650)),
        lastDate: DateTime.now());
    if (_response == null) return;
    widget.durationController('1day',
        from: _response.start, to: _response.end, nextScreen: true);
  }

  Widget button(String text, {VoidCallback? onPressed, bool selected = false}) {
    return SizedBox(
      width: 50.0,
      height: 30.0,
      child: TextButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed();
            setState(() {});
          }
        },
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.0,
          ),
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith(
              (states) => selected
                  ? Color.fromRGBO(65, 190, 186, 1)
                  : Color.fromRGBO(65, 190, 186, 1).withOpacity(0.6),
            ),
            foregroundColor:
                MaterialStateColor.resolveWith((states) => Colors.black)),
      ),
    );
  }
}
