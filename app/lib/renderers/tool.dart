part of 'renderer.dart';

class ToolRenderer extends Renderer<ToolState> {
  ToolRenderer(super.element);

  Rect getRulerRect(Size size) {
    const rulerSize = 100.0;
    return Rect.fromLTWH(
      -size.width / 2,
      0,
      size.width * 2,
      rulerSize,
    );
  }

  @override
  void build(
      Canvas canvas, Size size, AppDocument document, CameraTransform transform,
      [bool foreground = false]) {
    final option = document.tool;
    if (option.showGrid) {
      double x = 0;
      while (x < size.width / transform.size) {
        canvas.drawLine(
          Offset(x - transform.position.dx, -transform.position.dy),
          Offset(x - transform.position.dx,
              size.height / transform.size - transform.position.dy),
          Paint()
            ..strokeWidth = 1 / transform.size
            ..color = Color(option.gridColor),
        );
        x += option.gridXSize * transform.size;
      }
      double y = 0;
      while (y < size.height / transform.size) {
        canvas.drawLine(
          Offset(-transform.position.dx, -transform.position.dy + y),
          Offset(-transform.position.dx + size.width / transform.size,
              -transform.position.dy + y),
          Paint()
            ..strokeWidth = 1 / transform.size
            ..color = Color(option.gridColor),
        );
        y += option.gridYSize * transform.size;
      }
    }
    if (element.rulerEnabled) {
      const rulerColor = Colors.grey;
      final rulerBackgroundColor = Colors.grey.withAlpha(150);
      final rulerPaint = Paint()
        ..color = rulerColor
        ..strokeWidth = 1 / transform.size
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      final rulerBackgroundPaint = Paint()
        ..color = rulerBackgroundColor
        ..style = PaintingStyle.fill;
      final rulerRect = getRulerRect(size);

      var stepExp = 1, step = 1;
      while (step < 200 / transform.size) {
        stepExp += 1;
        step = pow(10, stepExp).toInt();
      }
      while (step > 200 / transform.size && stepExp > 1) {
        stepExp -= 1;
        step = pow(10, stepExp).toInt();
      }

      // Paint ruler background
      canvas.save();
      canvas.translate(-transform.position.dx, -transform.position.dy);
      canvas.scale(1 / transform.size, 1 / transform.size);
      canvas.translate(size.width / 2 + element.rulerPosition.dx,
          size.height / 2 + element.rulerPosition.dy);
      canvas.rotate(element.rulerAngle * pi / 180);
      canvas.drawRect(rulerRect, rulerBackgroundPaint);
      canvas.drawLine(
        Offset(rulerRect.left, rulerRect.top),
        Offset(rulerRect.right, rulerRect.top),
        rulerPaint,
      );
      canvas.drawLine(
        Offset(rulerRect.left, rulerRect.bottom),
        Offset(rulerRect.right, rulerRect.bottom),
        rulerPaint,
      );

      // Paint ruler lines
      int x = 0;
      var placeTextBottom = false;
      while (x < size.width) {
        final realX = x +
            (transform.position.dx * transform.size) % step -
            size.width / 2;
        canvas.drawLine(
          Offset(realX, rulerRect.top),
          Offset(
              realX,
              rulerRect.top +
                  (placeTextBottom
                      ? rulerRect.height / 8
                      : rulerRect.height / 4)),
          rulerPaint,
        );
        final textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          text: TextSpan(
              text: x.toString(), style: const TextStyle(color: Colors.white)),
        );
        textPainter.layout();
        textPainter.paint(
            canvas,
            Offset(
                realX - textPainter.width / 2,
                rulerRect.top +
                    10 / transform.size +
                    (placeTextBottom
                        ? rulerRect.height / 8
                        : rulerRect.height / 4)));
        placeTextBottom = !placeTextBottom;
        x += step;
      }
      canvas.restore();
    }
  }

  Offset getPointerPosition(Offset position, CurrentIndexCubit cubit) {
    return position;
  }
}
