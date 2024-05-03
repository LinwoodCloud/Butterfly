part of 'renderer.dart';

class UtilitiesRenderer extends Renderer<UtilitiesState> {
  final ViewOption option;

  UtilitiesRenderer(
      [super.element = const UtilitiesState(),
      this.option = const ViewOption()]);

  Rect getRulerRect(Size size) {
    const rulerSize = 100.0;
    return Rect.fromLTWH(
      -size.width,
      -rulerSize / 2,
      size.width * 2,
      rulerSize,
    );
  }

  bool hitRuler(Offset position, Size size) {
    if (!element.rulerEnabled) return false;
    final rulerRect = getRulerRect(size).translate(
        size.width / 2 + element.rulerPosition.x,
        size.height / 2 + element.rulerPosition.y);
    return rulerRect.contains(position.rotate(
        element.rulerPosition
            .toOffset()
            .translate(size.width / 2, size.height / 2),
        -element.rulerAngle * pi / 180));
  }

  @override
  void build(Canvas canvas, Size size, NoteData document, DocumentPage page,
      DocumentInfo info, CameraTransform transform,
      [ColorScheme? colorScheme, bool foreground = false]) {
    if (element.gridEnabled) {
      if (option.gridXSize > 0) {
        double x = 0;
        while (x < size.width) {
          final localX = x / transform.size;
          canvas.drawLine(
            Offset(localX + transform.position.dx, transform.position.dy),
            Offset(localX + transform.position.dx,
                size.height / transform.size + transform.position.dy),
            Paint()
              ..strokeWidth = 1 / transform.size
              ..color = Color(option.gridColor),
          );
          x += option.gridXSize;
        }
      }
      if (option.gridYSize > 0) {
        double y = 0;
        while (y < size.height) {
          final localY = y / transform.size;
          canvas.drawLine(
            Offset(transform.position.dx, transform.position.dy + localY),
            Offset(transform.position.dx + size.width / transform.size,
                transform.position.dy + localY),
            Paint()
              ..strokeWidth = 1 / transform.size
              ..color = Color(option.gridColor),
          );
          y += option.gridYSize;
        }
      }
    }
    if (element.rulerEnabled) {
      final rulerColor = colorScheme?.primary ?? Colors.grey;
      final rulerBackgroundColor =
          (colorScheme?.primaryContainer ?? Colors.grey).withAlpha(200);
      final rulerForegroundColor = colorScheme?.onPrimary ?? Colors.white;
      final rulerPaint = Paint()
        ..color = rulerColor
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      final rulerBackgroundPaint = Paint()
        ..color = rulerBackgroundColor
        ..style = PaintingStyle.fill;
      final rulerForegroundPaint = Paint()..color = rulerForegroundColor;
      final rulerRect = getRulerRect(size);

      // Calculate steps based on zoom level
      var steps = 10;

      // Paint ruler background
      canvas.save();
      canvas.translate(-transform.position.dx, -transform.position.dy);
      canvas.scale(1 / transform.size, 1 / transform.size);
      canvas.translate(size.width / 2 + element.rulerPosition.x,
          size.height / 2 + element.rulerPosition.y);
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
      while (x < size.width * 2) {
        // Disable text for now
        //final realX = x - (size.width / 2 ~/ steps) * steps;
        final posX =
            x + (transform.position.dx * transform.size) % steps - size.width;
        canvas.drawLine(
          Offset(posX, rulerRect.top),
          Offset(
              posX,
              rulerRect.top +
                  (placeTextBottom
                      ? rulerRect.height / 8
                      : rulerRect.height / 4)),
          rulerForegroundPaint,
        );
        /*if (realX >= 0 && realX < size.width) {
          final textPainter = TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            text: TextSpan(
              text: realX.toString(),
              style: TextStyle(color: colorScheme?.onPrimary ?? Colors.white),
            ),
          );
          textPainter.layout();
          textPainter.paint(
              canvas,
              Offset(
                  posX - textPainter.width / 2,
                  rulerRect.top +
                      10 +
                      (placeTextBottom
                          ? rulerRect.height / 8
                          : rulerRect.height / 4)));
        }*/
        placeTextBottom = !placeTextBottom;
        x += steps;
      }
      canvas.restore();
    }
  }

  Offset getPointerPosition(Offset position, CurrentIndexCubit cubit) {
    if (!element.rulerEnabled) return position;
    final size = cubit.state.cameraViewport.toSize();
    final rulerRect = getRulerRect(size).translate(
        size.width / 2 + element.rulerPosition.x,
        size.height / 2 + element.rulerPosition.y);
    final pivot = element.rulerPosition
        .toOffset()
        .translate(size.width / 2, size.height / 2);
    final angle = element.rulerAngle * pi / 180;

    final rotatedPosition = position.rotate(pivot, -angle);
    final firstHalf =
        rulerRect.topLeft & Size(rulerRect.width, rulerRect.height / 2);
    final secondHalf = firstHalf.translate(0, rulerRect.height / 2);
    final firstHalfHit = firstHalf.contains(rotatedPosition);
    final secondHalfHit = secondHalf.contains(rotatedPosition);
    // If the pointer is in the first half of the ruler, set the y to the top
    // If the pointer is in the second half of the ruler, set the y to the bottom

    if (firstHalfHit) {
      return Offset(rotatedPosition.dx, rulerRect.top).rotate(pivot, angle);
    } else if (secondHalfHit) {
      return Offset(rotatedPosition.dx, rulerRect.bottom).rotate(pivot, angle);
    }
    return position;
  }

  Offset getGridPosition(Offset position, DocumentPage page, DocumentInfo info,
      CurrentIndexCubit cubit) {
    if (!element.gridEnabled) return position;
    final transform = cubit.state.transformCubit.state;
    final localPosition = transform.globalToLocal(position);
    final option = info.view;
    final x = (localPosition.dx ~/ option.gridXSize) * option.gridXSize;
    final y = (localPosition.dy ~/ option.gridYSize) * option.gridYSize;
    return transform.localToGlobal(Offset(x, y));
  }
}
