import 'dart:math';

import 'package:k_chart/utils/number_util.dart';

import '../entity/k_line_entity.dart';

// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import,camel_case_types
class DataUtil {
  static List<KLineEntity> calculate(
    List<KLineEntity> data, {
    List<int> maDayList = const [5, 10, 20],
    int bollCalcPeriod = 20,
    int bollBandwidth = 2,
    int macdShortPeriod = 12,
    int macdLongPeriod = 26,
    int macdMaPeriod = 9,
    int kdjCalcPeriod = 9,
    int kdjMaPeriod1 = 3,
    int kdjMaPeriod2 = 3,
    int rsiPeriod = 6, // 12 / 24
    int wrPeriod = 14, // 20
  }) {
    final dataInner = [...data];
    // todo make below methods all return data instead of changing given one.
    _calcMA(dataInner, maDayList);
    _calcBOLL(dataInner, bollCalcPeriod, bollBandwidth);
    _calcVolumeMA(dataInner);
    _calcKDJ(dataInner, kdjCalcPeriod, kdjMaPeriod1, kdjMaPeriod2);
    _calcMACD(dataInner, macdShortPeriod, macdLongPeriod, macdMaPeriod);
    _calcRSI(dataInner, rsiPeriod);
    _calcWR(dataInner, wrPeriod);
    return dataInner;
  }

  static _calcMA(List<KLineEntity> dataList, List<int> maDayList) {
    if (dataList == null || dataList.isEmpty) {
      return;
    }

    List<double> ma = List<double>.filled(maDayList.length, 0);

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      entity.maValueList = List<double>(maDayList.length);

      for (int j = 0; j < maDayList.length; j++) {
        ma[j] += closePrice;
        if (i == maDayList[j] - 1) {
          entity.maValueList[j] = ma[j] / maDayList[j];
        } else if (i >= maDayList[j]) {
          ma[j] -= dataList[i - maDayList[j]].close;
          entity.maValueList[j] = ma[j] / maDayList[j];
        } else {
          entity.maValueList[j] = 0;
        }
      }
    }
  }

  static void _calcBOLL(
    List<KLineEntity> dataList,
    int calcPeriod,
    int bandwidth,
  ) {
    _calcBOLLMA(calcPeriod, dataList);
    for (int i = 0; i < dataList.length; i++) {
      final e = dataList[i];
      if (i >= calcPeriod) {
        double md = 0;
        for (int j = i - calcPeriod + 1; j <= i; j++) {
          double c = dataList[j].close;
          double m = e.bollMa;
          double value = c - m;
          md += value * value;
        }
        md = md / (calcPeriod - 1);
        md = sqrt(md);
        e.bollMiddle = e.bollMa;
        e.bollUp = e.bollMiddle + bandwidth * md;
        e.bollDown = e.bollMiddle - bandwidth * md;
      }
    }
  }

  static void _calcBOLLMA(int day, List<KLineEntity> dataList) {
    if (dataList == null) {
      return;
    }

    double ma = 0;
    for (int i = 0; i < dataList.length; i++) {
      final e = dataList[i];
      ma += e.close;
      if (i == day - 1) {
        e.bollMa = ma / day;
      } else if (i >= day) {
        ma -= dataList[i - day].close;
        e.bollMa = ma / day;
      } else {
        e.bollMa = null;
      }
    }
  }

  static void _calcMACD(
    List<KLineEntity> dataList,
    int shortPeriod, // 12
    int longPeriod, // 26
    int maPeriod, // 9
  ) {
    double emaShort = 0;
    double emaLong = 0;
    double dif = 0;
    double dea = 0;
    double macd = 0;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      if (i == 0) {
        emaShort = closePrice;
        emaLong = closePrice;
      } else {
        // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
        emaShort = emaShort * (shortPeriod - 1) / (shortPeriod + 1) +
            closePrice * 2 / (shortPeriod + 1);
        // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
        emaLong = emaLong * (longPeriod - 1) / (longPeriod + 1) +
            closePrice * 2 / (longPeriod + 1);
      }
      // DIF = EMA（12） - EMA（26） 。
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      // 用（DIF-DEA）*2即为MACD柱状图。
      dif = emaShort - emaLong;
      dea = dea * (maPeriod - 1) / (maPeriod + 1) + dif * 2 / (maPeriod + 1);
      macd = (dif - dea) * 2;
      entity.dif = dif;
      entity.dea = dea;
      entity.macd = macd;
    }
  }

  static void _calcVolumeMA(List<KLineEntity> dataList) {
    double volumeMa5 = 0;
    double volumeMa10 = 0;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entry = dataList[i];

      volumeMa5 += entry.vol;
      volumeMa10 += entry.vol;

      if (i == 4) {
        entry.MA5Volume = (volumeMa5 / 5);
      } else if (i > 4) {
        volumeMa5 -= dataList[i - 5].vol;
        entry.MA5Volume = volumeMa5 / 5;
      } else {
        entry.MA5Volume = 0;
      }

      if (i == 9) {
        entry.MA10Volume = volumeMa10 / 10;
      } else if (i > 9) {
        volumeMa10 -= dataList[i - 10].vol;
        entry.MA10Volume = volumeMa10 / 10;
      } else {
        entry.MA10Volume = 0;
      }
    }
  }

  static void _calcRSI(List<KLineEntity> dataList, int period) {
    double rsi;
    double rsiAbsEma = 0;
    double rsiMaxEma = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      if (i == 0) {
        rsi = 0;
        rsiAbsEma = 0;
        rsiMaxEma = 0;
      } else {
        double rMax = max(0, closePrice - dataList[i - 1].close);
        double rAbs = (closePrice - dataList[i - 1].close).abs();

        rsiMaxEma = (rMax + (period - 1) * rsiMaxEma) / period;
        rsiAbsEma = (rAbs + (period - 1) * rsiAbsEma) / period;
        rsi = (rsiMaxEma / rsiAbsEma) * 100;
      }
      if (i < (period - 1)) {
        rsi = null;
      }
      if (rsi != null && rsi.isNaN) {
        rsi = null;
      }
      entity.rsi = rsi;
    }
  }

  static void _calcKDJ(
    List<KLineEntity> dataList,
    int calcPeriod,
    int maPeriod1,
    int maPeriod2,
  ) {
    double k = 0;
    double d = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      int startIndex = i - (calcPeriod - 1);
      if (startIndex < 0) {
        startIndex = 0;
      }
      double maxCalcPeriod = double.minPositive;
      double minCalcPeriod = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        maxCalcPeriod = max(maxCalcPeriod, dataList[index].high);
        minCalcPeriod = min(minCalcPeriod, dataList[index].low);
      }
      double rsv =
          100 * (closePrice - minCalcPeriod) / (maxCalcPeriod - minCalcPeriod);
      if (rsv.isNaN) {
        rsv = 0;
      }
      if (i == 0) {
        k = 50;
        d = 50;
      } else {
        k = (rsv + 2 * k) / 3;
        d = (k + 2 * d) / 3;
      }
      if (i < calcPeriod - 1) {
        entity.k = null;
        entity.d = null;
        entity.j = null;
      } else if (i == calcPeriod - 1 || i == calcPeriod) {
        entity.k = k;
        entity.d = null;
        entity.j = null;
      } else {
        entity.k = k;
        entity.d = d;
        entity.j = 3 * k - 2 * d;
      }
    }
  }

  static void _calcWR(List<KLineEntity> dataList, int period) {
    double r;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      int startIndex = i - period;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double maxPeriod = double.minPositive;
      double minPeriod = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        maxPeriod = max(maxPeriod, dataList[index].high);
        minPeriod = min(minPeriod, dataList[index].low);
      }
      if (i < period - 1) {
        entity.r = -10;
      } else {
        r = -100 * (maxPeriod - dataList[i].close) / (maxPeriod - minPeriod);
        if (r.isNaN) {
          entity.r = null;
        } else {
          entity.r = r;
        }
      }
    }
  }
}
