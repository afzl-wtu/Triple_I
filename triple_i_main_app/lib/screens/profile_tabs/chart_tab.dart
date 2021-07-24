import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';
import 'package:main/helpers/http_helper.dart';
import 'package:main/keys/api_keys.dart';
import 'package:main/repository/profile/client.dart';
import 'package:main/screens/profile_tabs/technical_chart_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:main/widgets/backgroundGrad.dart';
import 'package:main/widgets/loading_indicator.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

import '../../../helpers/color_helper.dart';
import '../../../helpers/text_helper.dart';
import '../../../models/profile/stock_chart.dart';
import '../../../models/profile/stock_profile.dart';
import '../../../models/profile/stock_quote.dart';

class ChartTab extends StatefulWidget {
  final Color color;
  final StockQuote stockQuote;
  final StockProfile stockProfile;
  //final List<StockChart> stockChart;

  ChartTab({
    @required this.color,
    @required this.stockProfile,
    @required this.stockQuote,
    // @required this.stockChart,
  });

  @override
  _ChartTabState createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  bool _isLoading;
  Map<String, List<KLineEntity>> _durationCharts = {};
  String _currentDuration = '1day';
  DateTime _from;
  DateTime _to;
  bool _isMovingToNextScreen = false;

  MainState _mainState = MainState.NONE;

  SecondaryState _secondaryState = SecondaryState.NONE;

  bool isLine = false;

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
  Future<void> _durationController(String duration,
      {DateTime from, DateTime to, bool nextScreen = false}) async {
    if (nextScreen) _isMovingToNextScreen = false;
    _isNextScreen = nextScreen;
    if (duration != null) _currentDuration = duration;
    _from = from;
    _to = to;
    print('PP: in _durationController before await _getData');
    await _getData();
    print(
        'PP: in _durationController before setState and after await _getData');
    if (_isNextScreen) _jumpToScreen();
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
                return KChartWidget(
                  _durationCharts['$_currentDuration'],
                  isLine: isLine,
                  mainState: _mainState,
                  secondaryState: _secondaryState,
                  fixedLength: 1,
                  timeFormat: TimeFormat.YEAR_MONTH_DAY,
                  isChinese: false,
                  bgColor: [
                    Color(0xFF121128),
                    Color(0xFF121128),
                    Color(0xFF121128)
                  ],
                );
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

  Widget button(String text, {VoidCallback onPressed, bool selected = false}) {
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

  Widget _buildPrice() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('\$${formatText(widget.stockQuote.price)}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
              '${determineTextBasedOnChange(widget.stockQuote.change)}  (${determineTextPercentageBasedOnChange(widget.stockQuote.changesPercentage)})',
              style: determineTextStyleBasedOnChange(widget.stockQuote.change))
        ],
      ),
    );
  }
}

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<StockChart> chart;

  final Color color;

  SimpleTimeSeriesChart({@required this.chart, @required this.color});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      [
        charts.Series<RowData, DateTime>(
          id: 'Cost',
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(color),
          domainFn: (RowData row, _) => row.timeStamp,
          measureFn: (RowData row, _) => row.cost,
          data: this
              .chart
              .map((item) => RowData(
                  timeStamp: DateTime.parse(item.date), cost: item.close))
              .toList(),
        ),
      ],
      animate: false,
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(desiredTickCount: 1),
          renderSpec: charts.NoneRenderSpec()),
    );
  }
}

/// Sample time series data type.
class RowData {
  final DateTime timeStamp;
  final double cost;
  RowData({this.timeStamp, this.cost});
}
