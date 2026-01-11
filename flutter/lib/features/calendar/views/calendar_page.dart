import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/calendar_controller.dart';
import '../models/calendar_event_model.dart';
import '../models/calendar_connection_model.dart';

/// Calendar page - full implementation with event management
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final CalendarController controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller after the widget is fully created
    controller = Get.find<CalendarController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEventsForMonth(controller.focusedDate.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppBottomNavigationBar.getIndexForRoute(Get.currentRoute);

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                sliver: _buildContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: currentIndex),
    );
  }

  Widget _buildAppBar() {
    final tokens = AppUiTokens.of(context);

    return SliverAppBar(
      floating: true,
      elevation: 0,
      title: Text(
        'Calendar',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
      ),
      actions: [
        Obx(() => !controller.hasConnectedCalendar
            ? IconButton(
                icon: const Icon(Icons.link),
                onPressed: () => _showConnectCalendarSheet(),
                tooltip: 'Connect Calendar',
              )
            : const SizedBox.shrink()),
        IconButton(
          icon: const Icon(Icons.today),
          onPressed: () => controller.selectDate(DateTime.now()),
          tooltip: 'Go to Today',
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        _buildCalendar(),
        const SizedBox(height: AppConstants.spacing24),
        _buildEventsList(),
      ]),
    );
  }

  Widget _buildCalendar() {
    return AppGlassCard(
      padding: const EdgeInsets.all(0),
      child: _buildMonthView(),
    );
  }

  Widget _buildMonthView() {
    return Obx(() {
      final focusedMonth = controller.focusedDate.value;
      final selectedDate = controller.selectedDate.value;

      return Column(
        children: [
          // Month navigation header
          _buildMonthHeader(focusedMonth),

          // Weekday headers
          _buildWeekdayHeaders(),

          // Calendar grid
          _buildCalendarGrid(focusedMonth, selectedDate),
        ],
      );
    });
  }

  Widget _buildMonthHeader(DateTime focusedMonth) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newDate = DateTime(focusedMonth.year, focusedMonth.month - 1);
              controller.changeFocusedDate(newDate);
            },
          ),
          Text(
            _formatMonth(focusedMonth),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newDate = DateTime(focusedMonth.year, focusedMonth.month + 1);
              controller.changeFocusedDate(newDate);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime focusedMonth, DateTime selectedDate) {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    final daysInMonth = lastDayOfMonth.day;
    final daysBeforeMonth = firstWeekday;
    final totalCells = ((daysBeforeMonth + daysInMonth) / 7).ceil() * 7;

    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.spacing8),
        child: Column(
          children: List.generate((totalCells / 7).ceil(), (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final cellIndex = weekIndex * 7 + dayIndex;
                final dayNumber = cellIndex - daysBeforeMonth + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 40));
                }

                final date = DateTime(focusedMonth.year, focusedMonth.month, dayNumber);
                final dateKey = DateTime(date.year, date.month, date.day);
                final hasEvents = controller.eventsByDate.containsKey(dateKey);
                final isSelected = _isSameDay(date, selectedDate);
                final isToday = _isSameDay(date, DateTime.now());

                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectDate(date),
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : isToday
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppConstants.radius8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            dayNumber.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : isToday
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (hasEvents)
                            Positioned(
                              bottom: 2,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      );
    });
  }

  Widget _buildEventsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Events for ${_formatDate(controller.selectedDate.value)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () => _showAddEventDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing12),
        Obx(() {
          if (controller.isLoadingEvents.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.spacing32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.selectedDateEvents.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: controller.selectedDateEvents.map((event) => _buildEventCard(event)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEventCard(CalendarEventModel event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: AppGlassCard(
        padding: const EdgeInsets.all(0),
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppConstants.spacing12),
          leading: Container(
            width: 4,
            decoration: BoxDecoration(
              color: event.outfitId != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(AppConstants.radius8),
            ),
          ),
          title: Text(event.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatTime(event.startTime, event.endTime)),
              if (event.location != null) Text(event.location!),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (event.outfitId != null)
                Icon(
                  Icons.checkroom,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditEventDialog(event);
                      break;
                    case 'link_outfit':
                      Get.toNamed(Routes.outfits);
                      break;
                    case 'unlink_outfit':
                      controller.removeOutfit(event.id);
                      break;
                    case 'delete':
                      _showDeleteConfirmDialog(event);
                      break;
                  }
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'link_outfit', child: Text('Link Outfit')),
                  ];
                  if (event.outfitId != null) {
                    items.add(const PopupMenuItem(value: 'unlink_outfit', child: Text('Unlink Outfit')));
                  }
                  items.add(const PopupMenuItem(value: 'delete', child: Text('Delete')));
                  return items;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final tokens = AppUiTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing32),
      decoration: BoxDecoration(
        color: tokens.cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(color: tokens.cardBorderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event,
            size: 48,
            color: tokens.textMuted,
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'No events for this day',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'Tap + to add a new event',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime startTime = DateTime(
      controller.selectedDate.value.year,
      controller.selectedDate.value.month,
      controller.selectedDate.value.day,
      9,
    );
    DateTime endTime = DateTime(
      controller.selectedDate.value.year,
      controller.selectedDate.value.month,
      controller.selectedDate.value.day,
      10,
    );
    bool isAllDay = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  ListTile(
                    title: const Text('All Day'),
                    trailing: Switch(
                      value: isAllDay,
                      onChanged: (value) => setDialogState(() => isAllDay = value),
                    ),
                  ),
                  if (!isAllDay) ...[
                    ListTile(
                      title: const Text('Start Time'),
                      trailing: Text(_formatTimeOnly(startTime)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startTime,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(startTime),
                          );
                          if (time != null) {
                            setDialogState(() {
                              startTime = DateTime(
                                  picked.year, picked.month, picked.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('End Time'),
                      trailing: Text(_formatTimeOnly(endTime)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endTime,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(endTime),
                          );
                          if (time != null) {
                            setDialogState(() {
                              endTime = DateTime(
                                  picked.year, picked.month, picked.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                    ),
                  ],
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty) {
                    Get.snackbar('Error', 'Please enter a title');
                    return;
                  }
                  controller.createEvent(
                    title: titleController.text,
                    startTime: startTime,
                    endTime: endTime,
                    location: locationController.text.isEmpty ? null : locationController.text,
                    description: descriptionController.text.isEmpty ? null : descriptionController.text,
                    isAllDay: isAllDay,
                  );
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditEventDialog(CalendarEventModel event) {
    final titleController = TextEditingController(text: event.title);
    final locationController = TextEditingController(text: event.location ?? '');
    final descriptionController = TextEditingController(text: event.description ?? '');
    DateTime startTime = event.startTime;
    DateTime endTime = event.endTime;
    bool isAllDay = event.isAllDay;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  ListTile(
                    title: const Text('All Day'),
                    trailing: Switch(
                      value: isAllDay,
                      onChanged: (value) => setDialogState(() => isAllDay = value),
                    ),
                  ),
                  if (!isAllDay) ...[
                    ListTile(
                      title: const Text('Start Time'),
                      trailing: Text(_formatTimeOnly(startTime)),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(startTime),
                        );
                        if (time != null) {
                          setDialogState(() {
                            startTime = DateTime(startTime.year, startTime.month,
                                startTime.day, time.hour, time.minute);
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('End Time'),
                      trailing: Text(_formatTimeOnly(endTime)),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(endTime),
                        );
                        if (time != null) {
                          setDialogState(() {
                            endTime = DateTime(endTime.year, endTime.month,
                                endTime.day, time.hour, time.minute);
                          });
                        }
                      },
                    ),
                  ],
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty) {
                    Get.snackbar('Error', 'Please enter a title');
                    return;
                  }
                  controller.updateEvent(
                    event.id,
                    title: titleController.text,
                    startTime: startTime,
                    endTime: endTime,
                    location: locationController.text.isEmpty ? null : locationController.text,
                    description: descriptionController.text.isEmpty ? null : descriptionController.text,
                    isAllDay: isAllDay,
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(CalendarEventModel event) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Event?'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => controller.deleteEvent(event.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showConnectCalendarSheet() {
    final tokens = AppUiTokens.of(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          color: tokens.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radius24),
          ),
          border: Border.all(color: tokens.cardBorderColor),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Connect Calendar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacing24),
              _buildCalendarProviderTile(
                icon: Icons.calendar_today,
                name: 'Google Calendar',
                provider: CalendarProvider.google,
              ),
              const SizedBox(height: AppConstants.spacing8),
              _buildCalendarProviderTile(
                icon: Icons.apple,
                name: 'Apple Calendar',
                provider: CalendarProvider.apple,
              ),
              const SizedBox(height: AppConstants.spacing8),
              _buildCalendarProviderTile(
                icon: Icons.calendar_view_month,
                name: 'Outlook Calendar',
                provider: CalendarProvider.outlook,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarProviderTile({
    required IconData icon,
    required String name,
    required CalendarProvider provider,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Get.back();
        controller.connectCalendar(provider);
      },
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime start, DateTime end) {
    return '${_formatTimeOnly(start)} - ${_formatTimeOnly(end)}';
  }

  String _formatTimeOnly(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
