part of 'handler.dart';

class PenHandler extends Handler<PenPainter> {
  Map<int, PenElement> elements = {};

  Map<int, Offset> lastPosition = {};

  PenHandler(super.data);

  @override
  List<Renderer> createForegrounds(
      CurrentIndexCubit currentIndexCubit, AppDocument document,
      [Area? currentArea]) {
    return elements.values
        .map((e) {
          if (e.points.length > 1) return PenRenderer(e);
          return null;
        })
        .whereType<Renderer>()
        .toList();
  }

  @override
  void resetInput(DocumentBloc bloc) {
    elements.clear();
    lastPosition.clear();
  }

  @override
  void onPointerUp(PointerUpEvent event, EventContext context) {
    print(_detectShape(elements[event.pointer]?.points ?? []));
    addPoint(context.buildContext, event.pointer, event.localPosition,
        _getPressure(event), event.kind,
        refresh: false);
    submitElement(context.viewportSize, context.buildContext, event.pointer);
  }

  Future<void> submitElement(
      Size viewportSize, BuildContext context, int index) async {
    final bloc = context.read<DocumentBloc>();
    var element = elements.remove(index);
    if (element == null) return;
    lastPosition.remove(index);
    bloc.add(ElementsCreated([element]));
    bloc.refresh();
    await bloc.bake();
  }

  void addPoint(BuildContext context, int pointer, Offset localPosition,
      double pressure, PointerDeviceKind kind,
      {bool refresh = true, bool shouldCreate = false}) {
    final bloc = context.read<DocumentBloc>();
    final currentIndexCubit = context.read<CurrentIndexCubit>();
    final viewport = currentIndexCubit.state.cameraViewport;
    final transform = context.read<TransformCubit>().state;
    final state = bloc.state as DocumentLoadSuccess;
    final settings = context.read<SettingsCubit>().state;
    final penOnlyInput = settings.penOnlyInput;
    localPosition =
        viewport.tool?.getPointerPosition(localPosition, currentIndexCubit) ??
            localPosition;
    if (lastPosition[pointer] == localPosition) return;
    lastPosition[pointer] = localPosition;
    if (penOnlyInput && kind != PointerDeviceKind.stylus) {
      return;
    }
    double zoom = data.zoomDependent ? transform.size : 1;

    final createNew = !elements.containsKey(pointer);

    if (createNew && !shouldCreate) return;

    final element = elements[pointer] ??
        PenElement(
          zoom: transform.size,
          layer: state.currentLayer,
          property: data.property
              .copyWith(strokeWidth: data.property.strokeWidth / zoom),
        );
    elements[pointer] = element.copyWith(
        points: List<PathPoint>.from(element.points)
          ..add(PathPoint.fromPoint(
              transform.localToGlobal(localPosition).toPoint(),
              (createNew ? 0 : pressure) / zoom)));
    if (refresh) bloc.refresh();
  }

  @override
  void onTapDown(TapDownDetails details, EventContext context) {}

  @override
  void onPointerDown(PointerDownEvent event, EventContext context) {
    final currentIndex = context.getCurrentIndex();
    if (currentIndex.moveEnabled && event.kind != PointerDeviceKind.stylus) {
      elements.clear();
      context.refresh();
      return;
    }
    elements.remove(event.pointer);
    addPoint(context.buildContext, event.pointer, event.localPosition,
        _getPressure(event), event.kind,
        shouldCreate: true);
  }

  double _getPressure(PointerEvent event) =>
      event.kind == PointerDeviceKind.stylus
          ? (event.pressure - event.pressureMin) /
              (event.pressureMax - event.pressureMin)
          : 0.5;

  @override
  void onPointerMove(PointerMoveEvent event, EventContext context) {
    addPoint(context.buildContext, event.pointer, event.localPosition,
        _getPressure(event), event.kind);
  }

  @override
  Widget getToolbar(DocumentBloc bloc) => ColorToolbarView(
        color: data.property.color,
        onChanged: (value) {
          bloc.add(PaintersChanged({
            data: data.copyWith(
                property: data.property.copyWith(
                    color: convertOldColor(value, data.property.color))),
          }));
        },
      );

  bool _isLine(List<PathPoint> points, [double tolerance = 10]) {
    if (points.length < 2) return false;
    final firstPoint = points.first;
    final secondPoint = points.last;
    for (final point in points.sublist(1, points.length - 1)) {
      if (point
              .toPoint()
              .distanceToLine(firstPoint.toPoint(), secondPoint.toPoint()) >
          tolerance) {
        return false;
      }
    }
    return true;
  }

  bool _isCircle(List<PathPoint> points, [double tolerance = 10]) {
    if (points.length < 2) return false;
    // Find center of all points
    final center = points
            .map((e) => e.toPoint())
            .reduce((value, element) => value + element) /
        points.length.toDouble();
    final radius = center.distanceTo(points.first.toPoint());
    for (final point in points.sublist(1, points.length - 1)) {
      if ((point.toPoint().distanceTo(center) - radius).abs() > tolerance * 2) {
        return false;
      }
    }
    return true;
  }

  bool _isRectangle(List<PathPoint> points, [double tolerance = 10]) {
    if (points.length < 4) return false;
    Point<double> topLeft = points.first.toPoint(),
        topRight = points.first.toPoint(),
        bottomLeft = points.first.toPoint(),
        bottomRight = points.first.toPoint();
    for (final point in points.sublist(1, points.length - 1)) {
      final p = point.toPoint();
      if (p.x < topLeft.x && p.y < topLeft.y) {
        topLeft = p;
      } else if (p.x > topRight.x && p.y < topRight.y) {
        topRight = p;
      } else if (p.x < bottomLeft.x && p.y > bottomLeft.y) {
        bottomLeft = p;
      } else if (p.x > bottomRight.x && p.y > bottomRight.y) {
        bottomRight = p;
      }
    }
    if ((topLeft.x - bottomLeft.x).abs() > tolerance * 2 ||
        (topRight.x - bottomRight.x).abs() > tolerance * 2 ||
        (topLeft.y - topRight.y).abs() > tolerance * 2 ||
        (bottomLeft.y - bottomRight.y).abs() > tolerance * 2) {
      return false;
    }
    // Put all points together to calculate center
    final center = points
            .map((e) => e.toPoint())
            .reduce((value, element) => value + element) /
        points.length.toDouble();

    for (final p in points) {
      final point = p.toPoint();
      if ((point.distanceToLine(topLeft, topRight) > tolerance &&
              point.distanceToLine(topLeft, bottomLeft) > tolerance &&
              point.distanceToLine(bottomLeft, bottomRight) > tolerance &&
              point.distanceToLine(topRight, bottomRight) > tolerance) ||
          point.distanceTo(center) < tolerance) {
        return false;
      }
    }
    return true;
  }

  PathShape? _detectShape(List<PathPoint> points, [double tolerance = 10]) {
    if (points.length < 2) return null;
    final size = (points
                .map((e) => e.toPoint())
                .reduce((value, element) => value + element) /
            points.length.toDouble())
        .distanceTo(points.first.toPoint());
    if (size < tolerance * 2) return null;
    if (_isLine(points, tolerance)) {
      return const PathShape.line();
    } else if (_isRectangle(points, tolerance * 2)) {
      return const PathShape.rectangle();
    } else if (_isCircle(points, tolerance * 2)) {
      return const PathShape.circle();
    }
    return null;
  }
}
