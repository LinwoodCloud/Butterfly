part of '../selection.dart';

class ElementSelection<T extends PadElement> extends Selection<Renderer<T>> {
  ElementSelection(super.selected);

  factory ElementSelection.from(Renderer<T> selected) {
    if (selected is Renderer<ImageElement>) {
      return ImageElementSelection([selected as Renderer<ImageElement>])
          as ElementSelection<T>;
    }
    if (selected is Renderer<ImageElement>) {
      return ImageElementSelection([selected as Renderer<ImageElement>])
          as ElementSelection<T>;
    }
    if (selected is Renderer<LabelElement>) {
      return LabelElementSelection([selected]) as ElementSelection<T>;
    }
    if (selected is Renderer<PenElement>) {
      return PenElementSelection([selected as Renderer<PenElement>])
          as ElementSelection<T>;
    }
    if (selected is Renderer<ShapeElement>) {
      return ShapeElementSelection([selected as Renderer<ShapeElement>])
          as ElementSelection<T>;
    }
    if (selected is Renderer<SvgElement>) {
      return SvgElementSelection([selected as Renderer<SvgElement>])
          as ElementSelection<T>;
    }
    return ElementSelection([selected]);
  }

  @override
  List<Widget> buildProperties(BuildContext context) {
    final position = selected.length > 1 ? null : selected.first.rect?.topLeft;
    return [
      ...super.buildProperties(context),
      OffsetPropertyView(
        value: position,
        title: Text(AppLocalizations.of(context).position),
        clearValue: selected.length > 1,
        onChanged: (value) {
          updateElements(
              context,
              selected
                  .map((e) =>
                      e.transform(position: value, relative: false)?.element ??
                      e.element)
                  .whereType<T>()
                  .toList());
        },
      ),
      ExactSlider(
        value: elements.first.rotation,
        defaultValue: 0,
        min: 0,
        max: 360,
        header: Text(AppLocalizations.of(context).rotation),
        onChangeEnd: (value) {
          updateElements(
              context,
              selected
                  .map((e) =>
                      e.transform(rotation: value, relative: false)?.element ??
                      e.element)
                  .whereType<T>()
                  .toList());
        },
      ),
    ];
  }

  @override
  void update(BuildContext context, List<Renderer<T>> selected) {
    final bloc = context.read<DocumentBloc>();
    final state = bloc.state;
    if (state is! DocumentLoaded) return;
    final updatedElements = <String, List<PadElement>>{};
    for (var i = 0; i < selected.length; i++) {
      final element = selected[i];
      final oldElement = this.selected[i];
      final id = oldElement.element.id;
      if (element.element != oldElement.element && id != null) {
        updatedElements[id] = [element.element];
      }
    }
    bloc.add(ElementsChanged(updatedElements));
    super.update(context, selected);
  }

  List<T> get elements => selected.map((e) => e.element).toList();

  @override
  bool get showDeleteButton => true;

  Future<void> updateElements(BuildContext context, List<T> elements) async {
    final state = context.read<DocumentBloc>().state;
    if (state is! DocumentLoadSuccess) return;
    final page = state.page;
    final document = state.data;
    final assetService = state.assetService;
    final renderers = await Future.wait(elements.map((e) async {
      final renderer = Renderer.fromInstance(e);
      await renderer.setup(document, assetService, page);
      return renderer;
    }).toList());
    // ignore: use_build_context_synchronously
    update(context, renderers);
  }

  Rect? get rect =>
      _expandRects(selected.map((e) => e.rect).whereNotNull().toList());

  Rect? get expandedRect =>
      _expandRects(selected.map((e) => e.expandedRect).whereNotNull().toList());

  Rect? _expandRects(List<Rect> rects) {
    var rect = rects.firstOrNull;
    for (final current in selected.sublist(1)) {
      final currentRect = current.rect;
      if (currentRect != null) {
        rect = rect?.expandToInclude(currentRect);
      }
    }
    return rect;
  }

  @override
  void onDelete(BuildContext context) {
    final bloc = context.read<DocumentBloc>();
    final state = bloc.state;
    if (state is! DocumentLoadSuccess) return;
    final ids = selected.map((r) => r.element.id).whereNotNull().toList();
    context.read<DocumentBloc>().add(ElementsRemoved(ids));
  }

  @override
  Selection insert(dynamic element) {
    if (element is Renderer<PadElement>) {
      return ElementSelection([...selected, element]);
    }
    return Selection.from(element);
  }

  @override
  Selection? remove(dynamic selected) {
    final selections = List.from(this.selected);
    selections.removeWhere((element) =>
        element == selected ||
        (element is Renderer && element.element == selected));
    final success = selections.length != this.selected.length;
    if (!success) return this;
    if (selections.isEmpty) return null;
    var selection = Selection.from(selections.first);
    for (int i = 1; i < selections.length; i++) {
      selection = selection.insert(selections[i]);
    }
    return selection;
  }

  @override
  String getLocalizedName(BuildContext context) =>
      AppLocalizations.of(context).element;

  @override
  IconGetter get icon => PhosphorIcons.cube;
}

class OffsetPropertyView extends StatelessWidget {
  final Widget title;
  final Offset? value;
  final bool clearValue;
  final Function(Offset) onChanged;
  final TextEditingController _xController;
  final TextEditingController _yController;
  final int round;

  OffsetPropertyView(
      {super.key,
      required this.title,
      this.clearValue = false,
      this.value,
      this.round = 4,
      required this.onChanged})
      : _xController = TextEditingController(
            text: value?.dx.toPrecision(round).toString() ?? ''),
        _yController = TextEditingController(
            text: value?.dy.toPrecision(round).toString() ?? '');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrained) {
      final isRow = constrained.maxWidth > 100;
      final title = DefaultTextStyle(
          style: Theme.of(context).textTheme.titleMedium ?? const TextStyle(),
          child: this.title);
      final controls = Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Expanded(
          child: TextFormField(
            controller: _xController,
            decoration: const InputDecoration(
              labelText: 'X',
              alignLabelWithHint: true,
              floatingLabelAlignment: FloatingLabelAlignment.center,
              filled: true,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onFieldSubmitted: (value) {
              if (value.isEmpty) return;
              final dx = double.tryParse(value);
              if (dx == null) return;
              if (clearValue) {
                _xController.text = '';
                _yController.text = '';
              }
              onChanged(Offset(dx, this.value?.dy ?? 0));
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _yController,
            decoration: const InputDecoration(
              labelText: 'Y',
              alignLabelWithHint: true,
              floatingLabelAlignment: FloatingLabelAlignment.center,
              filled: true,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onFieldSubmitted: (value) {
              if (value.isEmpty) return;
              final dy = double.tryParse(value);
              if (dy == null) return;
              if (clearValue) {
                _xController.text = '';
                _yController.text = '';
              }
              onChanged(Offset(this.value?.dx ?? 0, dy));
            },
          ),
        ),
      ]);
      if (isRow) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(flex: 1, child: title),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: controls),
            ],
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: 8),
          controls,
        ],
      );
    });
  }
}
