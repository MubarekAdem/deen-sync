import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekView extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const WeekView({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late ScrollController _scrollController;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentWeekStart = _getWeekStart(widget.selectedDate);
    
    // Scroll to selected date after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(WeekView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _currentWeekStart = _getWeekStart(widget.selectedDate);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    // Get Monday as the start of the week
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _scrollToSelectedDate() {
    final startDate = _currentWeekStart.subtract(const Duration(days: 7));
    final selectedIndex = widget.selectedDate.difference(startDate).inDays;
    if (selectedIndex >= 0 && selectedIndex < 21) {
      final itemWidth = 68.0; // Width of each day circle + margin
      final targetOffset = selectedIndex * itemWidth - (MediaQuery.of(context).size.width / 2) + (itemWidth / 2);
      
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  List<DateTime> _getWeekDates() {
    final dates = <DateTime>[];
    // Show 3 weeks: previous, current, and next week
    final startDate = _currentWeekStart.subtract(const Duration(days: 7));
    for (int i = 0; i < 21; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }
    return dates;
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == widget.selectedDate.year &&
           date.month == widget.selectedDate.month &&
           date.day == widget.selectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // Month and year header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM y').format(widget.selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
                          });
                        },
                        icon: const Icon(Icons.chevron_left),
                        iconSize: 20,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Horizontal scrollable week days
            SizedBox(
              height: 80,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: weekDates.length,
                itemBuilder: (context, index) {
                  final date = weekDates[index];
                  final isToday = _isToday(date);
                  final isSelected = _isSelected(date);
                  
                  return GestureDetector(
                    onTap: () => widget.onDateSelected(date),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Day name
                          Text(
                            DateFormat('E').format(date),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isToday 
                                  ? Colors.teal 
                                  : isSelected 
                                      ? Colors.teal.shade700
                                      : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Day number in circle
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday
                                  ? Colors.teal
                                  : isSelected
                                      ? Colors.teal.shade100
                                      : Colors.transparent,
                              border: Border.all(
                                color: isSelected && !isToday
                                    ? Colors.teal
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                DateFormat('d').format(date),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isToday
                                      ? Colors.white
                                      : isSelected
                                          ? Colors.teal.shade700
                                          : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
