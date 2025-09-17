import 'package:flutter/material.dart';
import '../../models/habit.dart';
import '../../models/tracking.dart';
import '../../services/habit_service.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final Tracking? tracking;
  final Function(String) onStatusChanged;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.habit,
    this.tracking,
    required this.onStatusChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final habitService = HabitService();
    final isPrayerHabit = habit.isPrayerHabit;
    final statusOptions = isPrayerHabit 
        ? habitService.getPrayerStatusOptions()
        : habitService.getHabitStatusOptions();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Habit emoji and color indicator
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(int.parse(habit.color.replaceFirst('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        habit.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Habit title and current status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (tracking != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(int.parse(tracking!.statusColor.replaceFirst('#', '0xFF'))),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tracking!.displayStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status indicator
                  Icon(
                    tracking != null ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: tracking != null ? Colors.green : Colors.grey,
                  ),
                ],
              ),
              
              // Status options
              const SizedBox(height: 16),
              _buildStatusOptions(statusOptions, habitService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOptions(List<String> statusOptions, HabitService habitService) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: statusOptions.map((status) {
        final isSelected = tracking?.status == status;
        final displayName = habitService.getStatusDisplayName(status);
        
        return GestureDetector(
          onTap: () => onStatusChanged(status),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.teal : Colors.grey[400]!,
              ),
            ),
            child: Text(
              displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
