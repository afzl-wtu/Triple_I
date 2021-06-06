mixin CandleEntity {
  double open;
  double high;
  double low;
  double close;

  // MA
  List<double> maValueList;

  // BOLL (upper, middle and bottom lines) and some bollMa parameter
  double bollUp;
  double bollMiddle;
  double bollDown;
  double bollMa;
}
