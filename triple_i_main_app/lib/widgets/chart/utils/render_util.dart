import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class RenderUtil {
  static void drawDashedLine(
    Canvas canvas,
    Offset pointFrom,
    Offset pointTo,
    Paint paint,
  ) {
    canvas.drawPath(
      dashPath(
        Path()
          ..moveTo(pointFrom.dx, pointFrom.dy)
          ..lineTo(pointTo.dx, pointTo.dy),
        dashArray: CircularIntervalList<double>([3.0, 3.0]),
      ),
      paint,
    );
  }
}
