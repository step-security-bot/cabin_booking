import 'package:cabin_booking/model.dart';
import 'package:cabin_booking/utils/date_time_extension.dart';
import 'package:cabin_booking/widgets/item/activity_line_chart.dart';
import 'package:cabin_booking/widgets/layout/centered_icon_message.dart';
import 'package:cabin_booking/widgets/layout/danger_alert_dialog.dart';
import 'package:cabin_booking/widgets/layout/data_table_toolbar.dart';
import 'package:cabin_booking/widgets/layout/detailed_figure.dart';
import 'package:cabin_booking/widgets/layout/duration_figure_unit.dart';
import 'package:cabin_booking/widgets/layout/wrapped_chip_list.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef OnSortFunction = void Function({bool ascending});

class ItemsTable<T extends Item> extends StatefulWidget {
  final String Function(ItemsTableRow<T>)? itemTitle;
  final IconData? itemIcon;
  final String itemHeaderLabel;
  final List<ItemsTableRow<T>> rows;
  final String? emptyMessage;

  final bool shallEdit;
  final bool shallEmpty;
  final bool shallRemove;

  final Future<void> Function(List<ItemsTableRow<T>>)? onEditPressed;

  final String? onEmptyTitle;
  final void Function(List<String>)? onEmptyPressed;

  final String? onRemoveTitle;
  final void Function(List<String>)? onRemovePressed;

  const ItemsTable({
    super.key,
    this.itemTitle,
    this.itemIcon,
    this.itemHeaderLabel = 'Item',
    required this.rows,
    this.emptyMessage,
    this.shallEdit = true,
    this.shallEmpty = true,
    this.shallRemove = true,
    this.onEditPressed,
    this.onEmptyTitle,
    this.onEmptyPressed,
    this.onRemoveTitle,
    this.onRemovePressed,
  });

  @override
  State<ItemsTable<T>> createState() => _ItemsTableState<T>();
}

class _ItemsTableState<T extends Item> extends State<ItemsTable<T>> {
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  final List<int> _selectedIndices = [];

  List<ItemsTableRow<T>> get _selectedRows => widget.rows
      .whereIndexed((index, row) => _selectedIndices.contains(index))
      .toList();

  List<String> get _selectedIds =>
      _selectedRows.map((row) => row.item.id).toList();

  bool get _selectedAreBooked {
    for (final row in _selectedRows) {
      if (row.bookingsCount > 0 || row.recurringBookingsCount > 0) return true;
    }

    return false;
  }

  void _unselect() {
    setState(_selectedIndices.clear);
  }

  void _onSortItem({bool ascending = true}) {
    if (ascending) {
      widget.rows.sort((a, b) => a.item.compareTo(b.item));
    } else {
      widget.rows.sort((a, b) => b.item.compareTo(a.item));
    }
  }

  void _onSortBookingsCount({bool ascending = true}) {
    if (ascending) {
      widget.rows.sort((a, b) => a.bookingsCount.compareTo(b.bookingsCount));
    } else {
      widget.rows.sort((a, b) => b.bookingsCount.compareTo(a.bookingsCount));
    }
  }

  void _onSortAccumulatedDuration({bool ascending = true}) {
    if (ascending) {
      widget.rows.sort(
        (a, b) => a.occupiedDuration.compareTo(b.occupiedDuration),
      );
    } else {
      widget.rows.sort(
        (a, b) => b.occupiedDuration.compareTo(a.occupiedDuration),
      );
    }
  }

  void onSortColumn(int columnIndex, {bool ascending = true}) {
    <OnSortFunction>[
      _onSortItem,
      _onSortBookingsCount,
      _onSortAccumulatedDuration,
    ][columnIndex](ascending: ascending);

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    if (widget.rows.isEmpty) {
      return CenteredIconMessage(
        icon: widget.itemIcon,
        message: widget.emptyMessage,
      );
    }

    final theme = Theme.of(context);

    final columns = [
      ItemsTableColumn(widget.itemHeaderLabel, numeric: false),
      ItemsTableColumn(appLocalizations.bookings),
      ItemsTableColumn(appLocalizations.accumulatedTime),
      ItemsTableColumn(appLocalizations.mostOccupiedTimeRange, sortable: false),
      ItemsTableColumn(appLocalizations.activity, sortable: false),
    ];

    return Stack(
      children: [
        ListView(
          key: PageStorageKey('${T}ListView'),
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 54),
              child: DataTable(
                columns: [
                  for (final column in columns)
                    DataColumn(
                      label: Flexible(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: column.numeric ? 8 : 0,
                            end: column.numeric ? 0 : 8,
                          ),
                          child: Text(
                            column.title,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                      tooltip: column.sortable
                          ? '${appLocalizations.sortBy} ${column.title}'
                          : null,
                      numeric: column.numeric,
                      onSort: column.sortable
                          ? (columnIndex, ascending) {
                              onSortColumn(columnIndex, ascending: ascending);
                            }
                          : null,
                    ),
                ],
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                dataRowHeight: 82,
                rows: List<DataRow>.generate(widget.rows.length, (index) {
                  final row = widget.rows[index];

                  return DataRow(
                    selected: _selectedIndices.contains(index),
                    onSelectChanged: (selected) {
                      if (selected == null) return;
                      setState(() {
                        selected
                            ? _selectedIndices.add(index)
                            : _selectedIndices.removeWhere(
                                (selectedIndex) => selectedIndex == index,
                              );
                      });
                    },
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Icon(
                              widget.itemIcon,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.itemTitle?.call(row) ?? '${row.item}',
                              style: theme.textTheme.headline5,
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        DetailedFigure(
                          figure:
                              row.bookingsCount + row.recurringBookingsCount,
                          details: [
                            row.bookingsCount,
                            row.recurringBookingsCount,
                          ],
                          tooltipMessage: '${appLocalizations.bookings}'
                              ' + ${appLocalizations.recurringBookings}',
                        ),
                      ),
                      DataCell(DurationFigureUnit(row.occupiedDuration)),
                      DataCell(
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: WrappedChipList<List<TimeOfDay>>(
                            items: row.mostOccupiedTimeRanges.toList(),
                            labelBuilder: (context, timeRange) {
                              return Text(
                                timeRange
                                    .map((time) => time.format(context))
                                    .join('–'),
                              );
                            },
                            maxChips: 1,
                          ),
                        ),
                      ),
                      DataCell(
                        ActivityLineChart(
                          occupiedDurationPerWeek: row.occupiedDurationPerWeek,
                          dateRange: row.item is DateRanger
                              ? row.item as DateRanger
                              : DateRange(
                                  startDate: DateTime.now()
                                      .subtract(const Duration(days: 365))
                                      .firstDayOfWeek,
                                  endDate: DateTime.now().firstDayOfWeek,
                                ),
                          tooltipMessage: row.item is DateRanger
                              ? null
                              : appLocalizations.pastYearOfActivity,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
        DataTableToolbar(
          shown: _selectedRows.isNotEmpty,
          selectedItems: _selectedRows.length,
          onPressedLeading: _unselect,
          actions: [
            if (widget.shallEdit && _selectedRows.length == 1)
              IconButton(
                onPressed: () => widget.onEditPressed?.call(_selectedRows),
                tooltip: appLocalizations.edit,
                icon: const Icon(Icons.edit),
              ),
            if (widget.shallEmpty)
              IconButton(
                onPressed: widget.onEmptyPressed == null || !_selectedAreBooked
                    ? null
                    : () async {
                        final shallDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => DangerAlertDialog(
                            title: widget.onEmptyTitle ??
                                appLocalizations.emptyItemTitle,
                            content: appLocalizations.actionUndone,
                            okText: appLocalizations.empty,
                          ),
                        );

                        if (shallDelete == null || !shallDelete) return;

                        widget.onEmptyPressed!(_selectedIds);
                      },
                tooltip: appLocalizations.empty,
                icon: const Icon(Icons.delete_outline),
              ),
            if (widget.shallRemove)
              IconButton(
                onPressed: widget.onRemovePressed == null
                    ? null
                    : () async {
                        final shallDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => DangerAlertDialog(
                            title: widget.onRemoveTitle ??
                                appLocalizations.deleteItemTitle,
                            content: appLocalizations.actionUndone,
                          ),
                        );

                        if (shallDelete == null || !shallDelete) return;

                        widget.onRemovePressed!(_selectedIds);
                      },
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
      ],
    );
  }
}

class ItemsTableRow<T extends Item> {
  final T item;
  final int bookingsCount;
  final int recurringBookingsCount;
  final Duration occupiedDuration;
  final Map<DateTime, Duration> occupiedDurationPerWeek;
  final Set<List<TimeOfDay>> mostOccupiedTimeRanges;

  ItemsTableRow({
    required this.item,
    this.bookingsCount = 0,
    this.recurringBookingsCount = 0,
    this.occupiedDuration = Duration.zero,
    this.occupiedDurationPerWeek = const {},
    this.mostOccupiedTimeRanges = const {},
  });
}

class ItemsTableColumn {
  final String title;
  final bool numeric;
  final bool sortable;

  const ItemsTableColumn(
    this.title, {
    this.numeric = true,
    this.sortable = true,
  });
}
