import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
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
  MainState _mainState = MainState.NONE;

  SecondaryState _secondaryState = SecondaryState.NONE;

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
                  Expanded(child: Container()
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
            button(
              "Line",
              onPressed: () => isLine = true,
              selected: isLine,
            ),
            button(
              "Bars",
              onPressed: () => isLine = false,
              selected: !isLine,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 6.0,
              ),
            ),
            button(
              "1m",
              onPressed: () =>
                  widget.durationController('1min', nextScreen: true),
              selected: widget.currentDuration == '1min',
            ),
            button(
              "5m",
              onPressed: () =>
                  widget.durationController('5min', nextScreen: true),
              selected: widget.currentDuration == '5min',
            ),
            button(
              "30m",
              onPressed: () =>
                  widget.durationController('30min', nextScreen: true),
              selected: widget.currentDuration == '30min',
            ),
            button(
              "1h",
              onPressed: () =>
                  widget.durationController('1hour', nextScreen: true),
              selected: widget.currentDuration == '1hour',
            ),
            button(
              "1D",
              onPressed: () =>
                  widget.durationController('1day', nextScreen: true),
              selected: widget.currentDuration == '1day',
            ),
            button(
              "?",
              onPressed: _showRangePicker,
              selected: widget.currentDuration == '1min',
            ),
            Padding(padding: EdgeInsets.only(top: 6)),
            button(
              "MACD",
              onPressed: () => _secondaryState = SecondaryState.MACD,
              selected: _mainState == MainState.MA,
            ),
            button(
              "KDJ",
              onPressed: () => _secondaryState = SecondaryState.KDJ,
              selected: _secondaryState == SecondaryState.KDJ,
            ),
            button(
              "RSI",
              onPressed: () => _secondaryState = SecondaryState.RSI,
              selected: _secondaryState == SecondaryState.RSI,
            ),
            button(
              "WR",
              onPressed: () => _secondaryState = SecondaryState.WR,
              selected: _secondaryState == SecondaryState.WR,
            ),
            button(
              "NONE",
              onPressed: () => _secondaryState = SecondaryState.NONE,
              selected: _secondaryState == SecondaryState.NONE,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 6.0,
              ),
            ),
            button(
              "MA",
              onPressed: () => _mainState = MainState.MA,
              selected: _mainState == MainState.MA,
            ),
            button(
              "BOLL",
              onPressed: () => _mainState = MainState.BOLL,
              selected: _mainState == MainState.BOLL,
            ),
            button(
              "NONE",
              onPressed: () => _mainState = MainState.NONE,
              selected: _mainState == MainState.NONE,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRangePicker() async {
    final _response = await DateRangePicker.showDatePicker(
        context: context,
        initialFirstDate: DateTime.now().subtract(Duration(days: 365)),
        initialLastDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 3650)),
        lastDate: DateTime.now());
    widget.durationController('1day',
        from: _response[0], to: _response[1], nextScreen: true);
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
              (states) => selected ? Colors.blue : Colors.blue.withOpacity(0.6),
            ),
            foregroundColor:
                MaterialStateColor.resolveWith((states) => Colors.black)),
      ),
    );
  }
}
