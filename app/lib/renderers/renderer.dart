import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:butterfly/api/image.dart';
import 'package:butterfly/bloc/document_bloc.dart';
import 'package:butterfly/helpers/element.dart';
import 'package:butterfly/helpers/rect.dart';
import 'package:butterfly/helpers/point.dart';
import 'package:butterfly/visualizer/element.dart';
import 'package:butterfly/visualizer/text.dart';
import 'package:butterfly_api/butterfly_api.dart';
import 'package:butterfly_api/butterfly_text.dart' as text;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import 'package:markdown/markdown.dart' as md;
import 'package:material_leap/material_leap.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as freehand;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:xml/xml.dart';

import '../cubits/current_index.dart';
import '../cubits/transform.dart';
import '../helpers/xml.dart';
import '../models/label.dart';
import '../services/asset.dart';
import 'textures/texture.dart';

part 'backgrounds/texture.dart';
part 'backgrounds/empty.dart';
part 'backgrounds/image.dart';
part 'elements/image.dart';
part 'elements/markdown.dart';
part 'elements/text.dart';
part 'elements/texture.dart';
part 'elements/path.dart';
part 'elements/pen.dart';
part 'elements/shape.dart';
part 'elements/svg.dart';
part 'utilities.dart';

class DefaultHitCalculator extends HitCalculator {
  final Rect? rect;
  final double rotation;

  DefaultHitCalculator(this.rect, this.rotation);

  @override
  bool hit(Rect rect, {bool full = false}) {
    final element = this.rect;
    if (element == null) return false;
    if (full) {
      return element.top >= rect.top &&
          element.left >= rect.left &&
          element.right <= rect.right &&
          element.bottom <= rect.bottom;
    }
    return element.overlaps(rect);
  }

  @override
  bool hitPolygon(List<ui.Offset> polygon, {bool full = false}) {
    if (rect == null) return false;
    final center = rect!.center;
    final isCenter = isPointInPolygon(polygon, center);
    final isTopLeft =
        isPointInPolygon(polygon, rect!.topLeft.rotate(center, rotation));
    final isTopRight =
        isPointInPolygon(polygon, rect!.topRight.rotate(center, rotation));
    final isBottomLeft =
        isPointInPolygon(polygon, rect!.bottomLeft.rotate(center, rotation));
    final isBottomRight =
        isPointInPolygon(polygon, rect!.bottomRight.rotate(center, rotation));
    if (full) {
      return isCenter &&
          isTopLeft &&
          isTopRight &&
          isBottomLeft &&
          isBottomRight;
    }
    return isCenter || isTopLeft || isTopRight || isBottomLeft || isBottomRight;
  }
}

abstract class HitCalculator {
  bool hit(Rect rect, {bool full = false});
  bool hitPolygon(List<Offset> polygon, {bool full = false});

  bool isPointInPolygon(List<Offset> polygon, Offset testPoint) {
    bool result = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].dy < testPoint.dy && polygon[j].dy >= testPoint.dy) ||
          (polygon[j].dy < testPoint.dy && polygon[i].dy >= testPoint.dy)) {
        if (polygon[i].dx +
                (testPoint.dy - polygon[i].dy) /
                    (polygon[j].dy - polygon[i].dy) *
                    (polygon[j].dx - polygon[i].dx) <
            testPoint.dx) {
          result = !result;
        }
      }
      j = i;
    }
    return result;
  }
}

enum RendererOperation {
  invert,
  background;

  String getLocalizedName(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return switch (this) {
      RendererOperation.invert => loc.invert,
      RendererOperation.background => loc.background,
    };
  }

  IconGetter get icon => switch (this) {
        RendererOperation.invert => PhosphorIcons.circleHalf,
        RendererOperation.background => PhosphorIcons.paintBucket,
      };
}

typedef RendererOperationCallback = void Function(
    DocumentBloc bloc, BuildContext context);

abstract class Renderer<T> {
  final T element;
  final String? layer;
  Area? area;

  Renderer(this.element, [this.layer]);

  factory Renderer.fromInstance(T element, [String? layer]) {
    // Elements
    if (element is PadElement) {
      return switch (element) {
        PenElement() => PenRenderer(element, layer),
        TextElement() => TextRenderer(element, layer),
        ImageElement() => ImageRenderer(element, layer),
        SvgElement() => SvgRenderer(element, layer),
        ShapeElement() => ShapeRenderer(element, layer),
        MarkdownElement() => MarkdownRenderer(element, layer),
        TextureElement() => TextureRenderer(element, layer),
      } as Renderer<T>;
    }

    // Backgrounds
    if (element is Background) {
      return switch (element) {
        TextureBackground() => TextureBackgroundRenderer(element),
        ImageBackground() => ImageBackgroundRenderer(element),
        SvgBackground() => EmptyBackgroundRenderer(element),
      } as Renderer<T>;
    }

    if (element is UtilitiesState) {
      return UtilitiesRenderer(element) as Renderer<T>;
    }

    throw Exception('Invalid instance type');
  }

  double get rotation =>
      element is PadElement ? (element as PadElement).rotation : 0.0;

  String get id =>
      (element is PadElement ? (element as PadElement).id : null) ?? '';

  @mustCallSuper
  FutureOr<void> setup(NoteData document, AssetService assetService,
          DocumentPage page) async =>
      _updateArea(page);

  void dispose() {}

  void _updateArea(DocumentPage page) => area = rect == null
      ? null
      : page.areas.firstWhereOrNull((area) => area.rect.overlaps(rect!));
  bool onAreaUpdate(NoteData document, DocumentPage page, Area? area) {
    if (area?.rect.overlaps(rect!) ?? false) {
      this.area = area;
    }
    return false;
  }

  bool onAssetUpdate(NoteData document, AssetService assetService,
          DocumentPage page, String path) =>
      false;

  Rect? get rect => null;

  Rect? get expandedRect {
    final current = rect;
    if (current == null) return null;
    final rotation = this.rotation * (pi / 180);
    if (rotation == 0) return current;
    final center = current.center;
    final topLeft = current.topLeft.rotate(center, rotation);
    final topRight = current.topRight.rotate(center, rotation);
    final bottomLeft = current.bottomLeft.rotate(center, rotation);
    final bottomRight = current.bottomRight.rotate(center, rotation);
    final all = [topLeft, topRight, bottomLeft, bottomRight];
    final xs = all.map((p) => p.dx);
    final ys = all.map((p) => p.dy);
    final left = xs.reduce(min);
    final right = xs.reduce(max);
    final top = ys.reduce(min);
    final bottom = ys.reduce(max);
    return Rect.fromLTRB(left, top, right, bottom);
  }

  void build(Canvas canvas, Size size, NoteData document, DocumentPage page,
      DocumentInfo info, CameraTransform transform,
      [ColorScheme? colorScheme, bool foreground = false]);

  HitCalculator getHitCalculator() =>
      DefaultHitCalculator(rect, this.rotation * (pi / 180));

  void buildSvg(XmlDocument xml, NoteData document, DocumentPage page,
      Rect viewportRect) {}

  Renderer<T>? transform({
    Offset? position,
    double scaleX = 1,
    double scaleY = 1,
    double? rotation,
    bool relative = true,
    bool rotatePosition = false,
  }) {
    final rect = this.rect ?? Rect.zero;
    rotation ??= relative ? 0 : this.rotation;
    final double nextRotation =
        (relative ? rotation + this.rotation : rotation) % 360;
    position ??= relative ? rect.topLeft : Offset.zero;
    var nextPosition = relative ? position + rect.topLeft : position;

    if (rotatePosition) {
      var relativePosition = nextPosition - rect.topLeft;
      relativePosition = relativePosition.rotate(rect.center, rotation);
      nextPosition = relativePosition + rect.topLeft;
    }

    final radians = this.rotation * (pi / 180);

    if (radians != 0) {
      final rotationCos = cos(radians);
      final rotationSin = sin(radians);
      final oldScaleX = scaleX;
      final oldScaleY = scaleY;

      scaleX = (oldScaleX * rotationCos - oldScaleY * rotationSin).abs();
      scaleY = (oldScaleX * rotationSin + oldScaleY * rotationCos).abs();
      final offsetX = (oldScaleX - scaleX) * rect.width / 2;
      final offsetY = (oldScaleY - scaleY) * rect.height / 2;
      nextPosition += Offset(offsetX, offsetY);
    }

    return _transform(
      position: nextPosition,
      rotation: nextRotation,
      scaleX: scaleX,
      scaleY: scaleY,
    );
  }

  Renderer<T>? _transform({
    required Offset position,
    required double rotation,
    double scaleX = 1,
    double scaleY = 1,
  }) =>
      null;

  Map<RendererOperation, RendererOperationCallback> getOperations() => {};
}
