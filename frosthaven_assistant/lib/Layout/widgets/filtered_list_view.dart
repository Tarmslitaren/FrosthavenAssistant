import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/app_constants.dart';
import 'package:frosthaven_assistant/l10n/app_localizations.dart';

class FilteredListView<T> extends StatefulWidget {
  const FilteredListView({
    super.key,
    required this.items,
    required this.itemBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  State<FilteredListView<T>> createState() => _FilteredListViewState<T>();
}

class _FilteredListViewState<T> extends State<FilteredListView<T>> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Expanded(
        child: Text(AppLocalizations.of(context)!.noResultsFound,
            style: kHeadingStyle),
      );
    }
    return Expanded(
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: widget.items.length,
          itemBuilder: widget.itemBuilder,
        ),
      ),
    );
  }
}
