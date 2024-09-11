part of 'handler.dart';

class CollectionHandler extends Handler<CollectionTool> {
  CollectionHandler(super.data);

  @override
  bool onSelected(BuildContext context) {
    final bloc = context.read<DocumentBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: const CollectionsDialog(),
      ),
    );
    return false;
  }
}