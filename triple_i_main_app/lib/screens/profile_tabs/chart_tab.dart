import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main/repository/k_chart/flutter_k_chart.dart';
//import 'package:main/packages/chart_translations.dart';
//import 'package:main/packages/flutter_k_chart.dart';
import 'package:main/repository/profile/client.dart';
import 'package:main/screens/profile_tabs/technical_chart_screen.dart';
import 'package:main/widgets/loading_indicator.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

import '../../../helpers/color_helper.dart';
import '../../../helpers/text_helper.dart';
import '../../../models/profile/stock_profile.dart';
import '../../../models/profile/stock_quote.dart';

class ChartTab extends StatefulWidget {
  final Color color;
  final StockQuote stockQuote;
  final StockProfile? stockProfile;
  //final List<StockChart> stockChart;

  ChartTab({
    required this.color,
    required this.stockProfile,
    required this.stockQuote,
    // @required this.stockChart,
  });

  @override
  _ChartTabState createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  bool? _isLoading;
  Map<String, List<KLineEntity>> _durationCharts = {};
  String _currentDuration = '1day';
  DateTime? _from;
  DateTime? _to;
  bool _isMovingToNextScreen = false;
  MainState _mainState = MainState.MA;
  bool _volHidden = false;
  SecondaryState _secondaryState = SecondaryState.MACD;
  bool isLine = true;
  bool isChinese = false;
  bool _hideGrid = false;
  bool _showNowPrice = true;
  bool isChangeUI = false;

  ChartStyle chartStyle = ChartStyle();
  ChartColors chartColors = ChartColors();

  @override
  void initState() {
    print('PP: in chart_tab initstate');
    SystemChrome.setPreferredOrientations([]);

    print(
        'PP: in chart_tab initstate but after calling _durationController(null)');
    super.initState();
  }

  Future<void> _getData() async {
    if (_durationCharts.containsKey(_currentDuration) && _from == null) return;

    final datas = await ProfileClient.getApiChart(
        _currentDuration, widget.stockQuote.symbol, _from, _to);
    print(
        'PP: in chart_tab _getdata: value of datas before DataUtil.calculate= $datas');

    _durationCharts.update(_currentDuration, (value) => datas,
        ifAbsent: () => datas);

    print('PP: in _getData(last line) after data loaded');
  }

  bool _isNextScreen = false;
  Future<void> _durationController(String? duration,
      {DateTime? from, DateTime? to, bool nextScreen = false}) async {
    if (nextScreen) _isMovingToNextScreen = false;
    _isNextScreen = nextScreen;
    if (duration != null) _currentDuration = duration;
    _from = from;
    _to = to;
    print('PP: in _durationController before await _getData');
    await _getData();

    DataUtil.calculate(_durationCharts['$_currentDuration']!);
    print(
        'PP: in _durationController before setState and after await _getData');
    if (_isNextScreen)
      _jumpToScreen();
    else
      setState(() {});
  }

  Future<void> _jumpToScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TechnicalChartScreen(
          _durationCharts,
          _durationController,
          _currentDuration,
        ),
      ),
    );
    _isMovingToNextScreen = false;
    _isNextScreen = false;
  }

  Future<void> _jumper() async {
    print('PP: in  _jumper() start');
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      print(
          'PP: in  _jumper() if condition of OrientationLandscape if true and before Futur.delay');

      _isMovingToNextScreen = true;
      await Future.delayed(Duration(milliseconds: 0));

      print('PP: in  _jumper() if true, after future.delay');

      await _jumpToScreen();
    } else {
      print('PP: in  _jumper() else part before setting _isloading=false');

      _isLoading = false;
    }
  }

  @override
  void dispose() {
    print('PP: in dispose method');
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('PP: in build method setting _isLoading true');
    //_isLoading = true;
    //

    print(
        'PP: in _builder method after calling _jumper(), value of _isloading=$_isLoading');
    return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.8,
          width: double.infinity,
          child: FutureBuilder(
            future: (_durationCharts['$_currentDuration'] != null)
                ? null
                : _durationController(null),
            builder: (_, future) {
              if (future.connectionState == ConnectionState.waiting)
                return LoadingIndicatorWidget();
              else {
                if (!_isMovingToNextScreen) _jumper();
                return Container()
                    // KChartWidget(
                    //   _durationCharts['$_currentDuration'],
                    //   chartStyle,
                    //   chartColors,
                    //   isLine: isLine,
                    //   mainState: _mainState,
                    //   volHidden: _volHidden,
                    //   secondaryState: _secondaryState,
                    //   fixedLength: 2,
                    //   timeFormat: TimeFormat.YEAR_MONTH_DAY,
                    //   translations: kChartTranslations,
                    //   showNowPrice: _showNowPrice,
                    //   //`isChinese` is Deprecated, Use `translations` instead.
                    //   isChinese: false,
                    //   hideGrid: _hideGrid,
                    //   maDayList: [1, 100, 1000],
                    // )
                    // KChartWidget(
                    //   _durationCharts['$_currentDuration'],
                    //   isLine: isLine,
                    //   mainState: _mainState,
                    //   secondaryState: _secondaryState,
                    //   fixedLength: 1,
                    //   timeFormat: TimeFormat.YEAR_MONTH_DAY,
                    //   isChinese: false,
                    //   bgColor: [
                    //     Color(0xFF121128),
                    //     Color(0xFF121128),
                    //     Color(0xFF121128)
                    //   ],
                    // )
                    ;
              }
            },
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Center(child: Wrap(children: buildButtons())),
      ],
    );
  }

  List<Widget> buildButtons() {
    return [
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
      button("Time Mode", onPressed: () => isLine = true),
      button("K Line Mode", onPressed: () => isLine = false),
      button("Line:MA", onPressed: () => _mainState = MainState.MA),
      button("Line:BOLL", onPressed: () => _mainState = MainState.BOLL),
      button("Hide Line", onPressed: () => _mainState = MainState.NONE),
      button("Secondary Chart:MACD",
          onPressed: () => _secondaryState = SecondaryState.MACD),
      button("Secondary Chart:KDJ",
          onPressed: () => _secondaryState = SecondaryState.KDJ),
      button("Secondary Chart:RSI",
          onPressed: () => _secondaryState = SecondaryState.RSI),
      button("Secondary Chart:WR",
          onPressed: () => _secondaryState = SecondaryState.WR),
      button("Secondary Chart:CCI",
          onPressed: () => _secondaryState = SecondaryState.CCI),
      button("Secondary Chart:Hide",
          onPressed: () => _secondaryState = SecondaryState.NONE),
      button(_volHidden ? "Show Vol" : "Hide Vol",
          onPressed: () => _volHidden = !_volHidden),
      button("Change Language", onPressed: () => isChinese = !isChinese),
      button(_hideGrid ? "Show Grid" : "Hide Grid",
          onPressed: () => _hideGrid = !_hideGrid),
      button(_showNowPrice ? "Hide Now Price" : "Show Now Price",
          onPressed: () => _showNowPrice = !_showNowPrice),
      button("Customize UI", onPressed: () {
        setState(() {
          this.isChangeUI = !this.isChangeUI;
          if (this.isChangeUI) {
            chartColors.selectBorderColor = Colors.red;
            chartColors.selectFillColor = Colors.red;
            chartColors.lineFillColor = Colors.red;
            chartColors.kLineColor = Colors.yellow;
          } else {
            chartColors.selectBorderColor = Color(0xff6C7A86);
            chartColors.selectFillColor = Color(0xff0D1722);
            chartColors.lineFillColor = Color(0x554C86CD);
            chartColors.kLineColor = Color(0xff4C86CD);
          }
        });
      }),
      button(
        "1m",
        onPressed: () => _durationController('1min'),
        selected: _currentDuration == '1min',
      ),
      button(
        "5m",
        onPressed: () => _durationController('5min'),
        selected: _currentDuration == '5min',
      ),
      button(
        "30m",
        onPressed: () => _durationController('30min'),
        selected: _currentDuration == '30min',
      ),
      button(
        "1h",
        onPressed: () => _durationController('1hour'),
        selected: _currentDuration == '1hour',
      ),
      button(
        "1D",
        onPressed: () => _durationController('1day'),
        selected: _currentDuration == '1day',
      ),
      button(
        "?",
        onPressed: _showRangePicker,
        selected: _currentDuration == '1day',
      ),
    ];
  }

  Widget button(String text, {VoidCallback? onPressed, bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
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
                (states) =>
                    selected ? widget.color : widget.color.withOpacity(0.2),
              ),
              foregroundColor:
                  MaterialStateColor.resolveWith((states) => Colors.black)),
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
    _durationController('1day', from: _response[0], to: _response[1]);
  }
}
