import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/app_ui.dart';
import '../../outfits/providers/outfit_providers.dart';
import '../models/calendar_connection_model.dart';
import '../models/calendar_event_model.dart';
import '../providers/calendar_providers.dart';

const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// "Wednesday, Sep 23".
String _dayTitle(DateTime d) {
  final date = AppDateUtils.formatMonthDayYear(d);
  return '${_weekdayNames[d.weekday - 1]}, ${date.substring(0, date.lastIndexOf(','))}';
}

/// Month grid, the chosen day's events, and event editing.
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(calendarEventsProvider);
    final day = ref.watch(calendarSelectedDayProvider);
    final notifier = ref.read(calendarEventsProvider.notifier);
    // A month change keeps the old month's events until the new ones land;
    // they must not show on the new month's days.
    final current = events.isReloading ? null : events.value;
    final byDay = eventsByDay(current ?? const []);

    return PaperStockScope(
      stock: PaperStockId.clay,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calendar'),
          actions: [
            IconButton(
              tooltip: 'Go to today',
              icon: const Icon(Icons.today_outlined),
              onPressed: () {
                final now = DateTime.now();
                ref.read(calendarMonthProvider.notifier).show(now);
                ref.read(calendarSelectedDayProvider.notifier).select(now);
              },
            ),
            IconButton(
              tooltip: 'Connect a calendar',
              icon: const Icon(Icons.link_rounded),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _ConnectSheet(),
              ),
            ),
          ],
        ),
        // Hidden while the error state owns the screen, so its retry stays
        // clear of the button.
        floatingActionButton: current == null && events.hasError
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _editEvent(context, day: day),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add event'),
              ),
        body: AppPageBackground(
          child: RefreshIndicator(
            onRefresh: notifier.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacing16,
                    AppConstants.spacing8,
                    AppConstants.spacing16,
                    AppConstants.spacing20,
                  ),
                  sliver: SliverToBoxAdapter(child: _MonthCard(byDay: byDay)),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacing20,
                    0,
                    AppConstants.spacing20,
                    AppConstants.spacing12,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      _dayTitle(day),
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                ..._events(
                  context,
                  ref,
                  events,
                  current,
                  byDay[day] ?? const [],
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _events(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CalendarEventModel>> events,
    List<CalendarEventModel>? current,
    List<CalendarEventModel> dayEvents,
  ) {
    void retry() => ref.invalidate(calendarEventsProvider);
    if (current == null) {
      if (events.hasError && !events.isLoading) {
        return [
          SliverToBoxAdapter(
            child: AppErrorState(error: events.error, onRetry: retry),
          ),
        ];
      }
      return const [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing8),
          sliver: SliverToBoxAdapter(
            child: SkeletonListLoaderBox(itemCount: 3, hasLeading: false),
          ),
        ),
      ];
    }
    return [
      if (events.hasError)
        SliverToBoxAdapter(
          child: AppErrorBanner(
            error: events.error,
            onRetry: ref.read(calendarEventsProvider.notifier).refresh,
          ),
        ),
      if (dayEvents.isEmpty)
        const SliverToBoxAdapter(
          child: AppEmptyState(
            scene: PaperScenes.studio,
            title: 'Nothing planned',
            message: 'Add an event and plan what to wear.',
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing16,
          ),
          sliver: SliverList.separated(
            itemCount: dayEvents.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppConstants.spacing12),
            itemBuilder: (context, i) => _EventRow(event: dayEvents[i]),
          ),
        ),
    ];
  }
}

Future<void> _editEvent(
  BuildContext context, {
  DateTime? day,
  CalendarEventModel? event,
}) => showDialog<void>(
  context: context,
  builder: (_) => _EventDialog(day: day, event: event),
);

class _MonthCard extends ConsumerWidget {
  const _MonthCard({required this.byDay});

  final Map<DateTime, List<CalendarEventModel>> byDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final selected = ref.watch(calendarSelectedDayProvider);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final leading = DateTime(month.year, month.month).weekday % 7;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final weeks = ((leading + days) / 7).ceil();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    void go(int delta) {
      final target = DateTime(month.year, month.month + delta);
      ref.read(calendarMonthProvider.notifier).show(target);
      final sameMonth =
          target.year == today.year && target.month == today.month;
      ref
          .read(calendarSelectedDayProvider.notifier)
          .select(sameMonth ? today : target);
    }

    return PaperSurface(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing8,
        AppConstants.spacing8,
        AppConstants.spacing8,
        AppConstants.spacing12,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => go(-1),
              ),
              Expanded(
                child: Text(
                  AppDateUtils.formatMonthYear(month),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.displaySmall?.copyWith(fontSize: 28),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => go(1),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing8),
          ExcludeSemantics(
            child: Row(
              children: [
                for (final w in _weekdays)
                  Expanded(
                    child: Text(
                      w,
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(color: tokens.textMuted),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          for (var w = 0; w < weeks; w++)
            Row(
              children: [
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: switch (w * 7 + d - leading + 1) {
                      final n when n < 1 || n > days => const SizedBox(
                        height: _DayCell.height,
                      ),
                      final n => _DayCell(
                        date: DateTime(month.year, month.month, n),
                        selected:
                            selected == DateTime(month.year, month.month, n),
                        today: today == DateTime(month.year, month.month, n),
                        events:
                            byDay[DateTime(month.year, month.month, n)]
                                ?.length ??
                            0,
                      ),
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({
    required this.date,
    required this.selected,
    required this.today,
    required this.events,
  });

  static const height = 50.0;
  static const _disc = 38.0;

  final DateTime date;
  final bool selected;
  final bool today;
  final int events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final label = [
      _dayTitle(date),
      if (today) 'today',
      if (events == 1) '1 event' else if (events > 1) '$events events',
    ].join(', ');
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () =>
            ref.read(calendarSelectedDayProvider.notifier).select(date),
        child: SizedBox(
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _disc,
                height: _disc,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? tokens.stock.accent : null,
                  border: today
                      ? Border.all(color: tokens.stock.accent, width: 1.5)
                      : null,
                ),
                child: Text(
                  '${date.day}',
                  style: text.bodyLarge?.copyWith(
                    height: 1,
                    color: selected
                        ? tokens.stock.onAccent
                        : today
                        ? tokens.stock.accent
                        : tokens.textPrimary,
                    fontWeight: selected || today
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              // A quiet bar under days with events: wider for busier days.
              Container(
                width: events == 0 ? 0 : (events == 1 ? 10 : 18),
                height: 3,
                decoration: BoxDecoration(
                  color: tokens.stock.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventRow extends ConsumerWidget {
  const _EventRow({required this.event});

  final CalendarEventModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final busy = ref.watch(calendarBusyProvider).contains(event.id);
    final notifier = ref.read(calendarEventsProvider.notifier);
    final hasOutfit = event.outfitId != null;
    final time = event.isAllDay
        ? 'All day'
        : '${AppDateUtils.formatTimeOnly(event.startTime)} to '
              '${AppDateUtils.formatTimeOnly(event.endTime)}';

    return PaperSurface(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing12,
        AppConstants.spacing4,
        AppConstants.spacing12,
      ),
      onTap: () => _editEvent(context, event: event),
      semanticLabel:
          '${event.title}, $time${hasOutfit ? ', outfit linked' : ''}',
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: ExcludeSemantics(
              child: event.isAllDay
                  ? Text('All day', style: text.titleSmall)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppDateUtils.formatTimeOnly(event.startTime),
                          style: text.titleSmall,
                        ),
                        Text(
                          AppDateUtils.formatTimeOnly(event.endTime),
                          style: text.bodySmall?.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: text.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.location?.isNotEmpty ?? false)
                    Text(
                      event.location!,
                      style: text.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          if (hasOutfit)
            Padding(
              padding: const EdgeInsets.only(left: AppConstants.spacing8),
              child: Icon(
                Icons.checkroom_outlined,
                size: 20,
                color: tokens.stock.accent,
                semanticLabel: 'Outfit linked',
              ),
            ),
          if (busy)
            const SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            PopupMenuButton<String>(
              tooltip: 'Event options',
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (action) async {
                switch (action) {
                  case 'edit':
                    await _editEvent(context, event: event);
                  case 'link':
                    final outfitId = await showModalBottomSheet<String>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => const FractionallySizedBox(
                        heightFactor: 0.7,
                        child: _LinkOutfitSheet(),
                      ),
                    );
                    if (outfitId != null) {
                      await notifier.linkOutfit(event.id, outfitId);
                    }
                  case 'unlink':
                    await notifier.removeOutfit(event.id);
                  case 'delete':
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete this event?'),
                        content: Text('"${event.title}" will be removed.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: PaperTokens.of(context).error,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) await notifier.delete(event.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'link',
                  child: Text(hasOutfit ? 'Change outfit' : 'Link an outfit'),
                ),
                if (hasOutfit)
                  const PopupMenuItem(
                    value: 'unlink',
                    child: Text('Remove outfit'),
                  ),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
    );
  }
}

/// Create or edit an event. Owns its text controllers, closes only after a
/// successful save and ignores a second tap while saving.
class _EventDialog extends ConsumerStatefulWidget {
  const _EventDialog({this.day, this.event});

  final DateTime? day;
  final CalendarEventModel? event;

  @override
  ConsumerState<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends ConsumerState<_EventDialog> {
  late final _title = TextEditingController(text: widget.event?.title);
  late final _location = TextEditingController(text: widget.event?.location);
  late final _description = TextEditingController(
    text: widget.event?.description,
  );
  late DateTime _start;
  late DateTime _end;
  late bool _allDay = widget.event?.isAllDay ?? false;
  bool _saving = false;
  String? _titleError;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    if (event != null) {
      // Event times are UTC instants; edit the local wall-clock time.
      _start = event.startTime.toLocal();
      _end = event.endTime.toLocal();
    } else {
      final d = widget.day ?? DateTime.now();
      _start = DateTime(d.year, d.month, d.day, 9);
      _end = DateTime(d.year, d.month, d.day, 10);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool start}) async {
    final initial = start ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (start) {
        _start = picked;
      } else {
        _end = picked;
      }
      _timeError = null;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final title = _title.text.trim();
    setState(() {
      _titleError = title.isEmpty ? 'Add a title' : null;
      _timeError = !_allDay && !_end.isAfter(_start)
          ? 'End after the start time'
          : null;
    });
    if (_titleError != null || _timeError != null) return;

    setState(() => _saving = true);
    final notifier = ref.read(calendarEventsProvider.notifier);
    final event = widget.event;
    final saved = event == null
        ? await notifier.create(
            title: title,
            startTime: _start,
            endTime: _end,
            location: _location.text.trim().isEmpty
                ? null
                : _location.text.trim(),
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
            isAllDay: _allDay,
          )
        : await notifier.edit(
            event.id,
            title: title,
            startTime: _start,
            endTime: _end,
            // '' clears the field; null would keep the old value.
            location: _location.text.trim(),
            description: _description.text.trim(),
            isAllDay: _allDay,
          );
    if (!mounted) return;
    if (saved != null) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  Widget _timeTile(String label, DateTime value, {required bool start}) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        trailing: Text(
          '${AppDateUtils.formatMonthDayYear(value)}  '
          '${AppDateUtils.formatTimeOnly(value)}',
        ),
        onTap: _saving ? null : () => _pick(start: start),
      );

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(widget.event == null ? 'New event' : 'Edit event'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              autofocus: widget.event == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: _titleError,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('All day'),
              value: _allDay,
              onChanged: _saving
                  ? null
                  : (v) => setState(() {
                      _allDay = v;
                      _timeError = null;
                    }),
            ),
            if (!_allDay) ...[
              _timeTile('Starts', _start, start: true),
              _timeTile('Ends', _end, start: false),
              if (_timeError != null)
                Text(
                  _timeError!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.error),
                ),
            ],
            const SizedBox(height: AppConstants.spacing12),
            TextField(
              controller: _location,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Place (optional)'),
            ),
            const SizedBox(height: AppConstants.spacing12),
            TextField(
              controller: _description,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving' : 'Save'),
          ),
        ],
      ),
    );
  }
}

/// Picks one outfit; pops with its id.
class _LinkOutfitSheet extends ConsumerWidget {
  const _LinkOutfitSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfits = ref.watch(outfitsProvider);
    final tokens = PaperTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacing20,
            AppConstants.spacing20,
            AppConstants.spacing20,
            AppConstants.spacing8,
          ),
          child: Text(
            'Link an outfit',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: switch (outfits) {
            AsyncValue(:final value?) when value.items.isEmpty => AppEmptyState(
              scene: PaperScenes.outfits,
              title: 'No outfits yet',
              message: 'Build an outfit, then link it to this event.',
              actionLabel: 'Build an outfit',
              onAction: () {
                Navigator.pop(context);
                context.push(Routes.outfitBuilder);
              },
            ),
            AsyncValue(:final value?) => ListView.builder(
              padding: const EdgeInsets.only(bottom: AppConstants.spacing16),
              itemCount: value.items.length,
              itemBuilder: (context, i) {
                final outfit = value.items[i];
                return ListTile(
                  minTileHeight: 56,
                  leading: Icon(
                    Icons.checkroom_outlined,
                    color: tokens.textSecondary,
                  ),
                  title: Text(
                    outfit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: outfit.style == null
                      ? null
                      : Text(outfit.style!.displayName),
                  onTap: () => Navigator.pop(context, outfit.id),
                );
              },
            ),
            AsyncValue(:final error?) => AppErrorState(
              error: error,
              onRetry: ref.read(outfitsProvider.notifier).refresh,
            ),
            _ => const SkeletonListLoaderBox(itemCount: 4, hasLeading: false),
          },
        ),
      ],
    );
  }
}

/// Connected calendars and the ones that can be connected later.
class _ConnectSheet extends ConsumerWidget {
  const _ConnectSheet();

  static const _options = [
    (CalendarProvider.google, 'Google Calendar', Icons.event_outlined),
    (CalendarProvider.apple, 'Apple Calendar', Icons.apple),
    (CalendarProvider.outlook, 'Outlook', Icons.mail_outline_rounded),
  ];

  static String _name(CalendarProvider p) => switch (p) {
    CalendarProvider.google => 'Google Calendar',
    CalendarProvider.apple => 'Apple Calendar',
    CalendarProvider.outlook => 'Outlook',
    CalendarProvider.local => 'This app',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(calendarConnectionsProvider);
    final busy = ref.watch(calendarBusyProvider);
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    final connected = [
      for (final c in connections.value ?? const <CalendarConnectionModel>[])
        if (c.isConnected) c,
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Calendars', style: text.headlineSmall),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              'Events you add here stay in FitCheck.',
              style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppConstants.spacing16),
            if (connections.hasError && !connections.hasValue)
              AppErrorBanner(
                error: connections.error,
                onRetry: () => ref.invalidate(calendarConnectionsProvider),
              )
            else if (connections.isLoading && !connections.hasValue)
              const SkeletonListLoaderBox(itemCount: 1, hasLeading: false),
            if (connected.isNotEmpty) ...[
              PaperSurface(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacing4,
                ),
                child: Column(
                  children: [
                    for (final c in connected)
                      ListTile(
                        title: Text(c.displayName ?? _name(c.provider)),
                        subtitle: c.email.isEmpty ? null : Text(c.email),
                        trailing: busy.contains(c.id)
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : TextButton(
                                onPressed: () => ref
                                    .read(calendarConnectionsProvider.notifier)
                                    .disconnect(c.id),
                                child: const Text('Disconnect'),
                              ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
            ],
            PaperSurface(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacing4,
              ),
              child: Column(
                children: [
                  for (final (provider, name, icon) in _options)
                    ListTile(
                      leading: Icon(icon, color: tokens.textSecondary),
                      title: Text(name),
                      subtitle: const Text('Not available yet'),
                      onTap: () {
                        Navigator.pop(context);
                        ErrorHandler.showInfo(
                          'Syncing with ${_name(provider)} is not available '
                          'yet. You can still add events here.',
                          title: 'Not available yet',
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
