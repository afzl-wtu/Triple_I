import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:main/bloc/chart.dart';
import 'package:main/models/chart.dart';
import 'package:main/repository/k_chart/chart_translations.dart';
import 'package:main/repository/k_chart/flutter_k_chart.dart';
import 'package:main/widgets/loading_indicator.dart';
import '../../../models/profile/stock_profile.dart';
import '../../../models/profile/stock_quote.dart';

class ChartTab extends StatefulWidget {
  final Color color;
  final StockQuote stockQuote;
  final StockProfile? stockProfile;

  ChartTab({
    required this.color,
    required this.stockProfile,
    required this.stockQuote,
  });

  @override
  _ChartTabState createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  String _currentDuration = '1day';

  MainState _mainState = MainState.MA;
  bool _volHidden = false;
  SecondaryState _secondaryState = SecondaryState.MACD;
  bool isLine = true;
  bool isChinese = false;
  bool _hideGrid = false;
  bool _showNowPrice = true;
  bool isChangeUI = false;
  var _isTrendLine = false;
  ChartStyle chartStyle = ChartStyle();
  ChartColors chartColors = ChartColors();

  void _fetchChartData(String s, {DateTime? from, DateTime? to}) {
    _currentDuration = s;
    BlocProvider.of<ChartBloc>(context).add(
      FetchChartData(
        symbol: widget.stockQuote.symbol!,
        duration: DurationModel(_currentDuration, FromTo(from, to)),
      ),
    );
  }

  @override
  void initState() {
    BlocProvider.of<ChartBloc>(context).add(ResetChart());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.8,
          width: double.infinity,
          child: BlocBuilder<ChartBloc, ChartState>(
            builder: (_, state) {
              if (state is ChartInitial) {
                BlocProvider.of<ChartBloc>(context).add(
                  FetchChartData(
                    symbol: widget.stockQuote.symbol!,
                    duration: DurationModel(_currentDuration, FromTo()),
                  ),
                );
                return LoadingIndicatorWidget();
              } else if (state is ChartLoading)
                return CupertinoActivityIndicator();
              else if (state is ChartLoaded) {
                return KChartWidget(
                  state.datas,
                  chartStyle,
                  chartColors,
                  isLine: isLine,
                  mainState: _mainState,
                  isTrendLine: _isTrendLine,
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
                );
              } else //if (state is ChartError)
                return Center(
                    child: Wrap(
                  children: [Text((state as ChartError).error)],
                ));
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
      button("Candles", onPressed: () => isLine = !isLine, selected: !isLine),
      button("MA",
          onPressed: () => _mainState =
              _mainState == MainState.MA ? MainState.NONE : MainState.MA,
          selected: _mainState == MainState.MA),
      button(
        "BOLL",
        onPressed: () => _mainState =
            _mainState == MainState.BOLL ? MainState.NONE : MainState.BOLL,
        selected: _mainState == MainState.BOLL,
      ),
      button("Vol",
          onPressed: () => _volHidden = !_volHidden, selected: !_volHidden),
      button("Grid",
          onPressed: () => _hideGrid = !_hideGrid, selected: !_hideGrid),
      button("Price",
          onPressed: () => _showNowPrice = !_showNowPrice,
          selected: _showNowPrice),
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
      button(
        "1m",
        onPressed: () => _fetchChartData('1min'),
        selected: _currentDuration == '1min',
      ),
      button(
        "5m",
        onPressed: () => _fetchChartData('5min'),
        selected: _currentDuration == '5min',
      ),
      button(
        "30m",
        onPressed: () => _fetchChartData('30min'),
        selected: _currentDuration == '30min',
      ),
      button(
        "1h",
        onPressed: () => _fetchChartData('1hour'),
        selected: _currentDuration == '1hour',
      ),
      button(
        "1D",
        onPressed: () => _fetchChartData('1day'),
        selected: _currentDuration == '1day',
      ),
      button(
        "⏱️",
        onPressed: _showRangePicker,
        selected: _currentDuration == '1day',
      ),
      button(
        'Draw',
        onPressed: () => _isTrendLine = !_isTrendLine,
        selected: _isTrendLine,
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
    final _response = await showDateRangePicker(
        initialEntryMode: DatePickerEntryMode.input,
        context: context,
        initialDateRange: DateTimeRange(
            start: DateTime.now().subtract(
              Duration(days: 120),
            ),
            end: DateTime.now()),
        firstDate: DateTime.now().subtract(Duration(days: 50)),
        lastDate: DateTime.now());
    if (_response == null) return;
    _fetchChartData('1day', from: _response.start, to: _response.end);
    setState(() {});
  }
}
