import 'package:flutter/material.dart';
import '../../services/habit_service.dart';

class CreateCustomHabitScreen extends StatefulWidget {
  const CreateCustomHabitScreen({super.key});

  @override
  State<CreateCustomHabitScreen> createState() => _CreateCustomHabitScreenState();
}

class _CreateCustomHabitScreenState extends State<CreateCustomHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final HabitService _habitService = HabitService();
  
  String _selectedEmoji = '📝';
  String _selectedColor = '#4CAF50';
  String _selectedFrequency = 'everyday';
  bool _isLoading = false;

  final List<String> _emojis = [
    '📝', '📚', '🤲', '🕌', '🌙', '⭐', '💪', '🏃', '🧘', '💧',
    '🍎', '🥗', '🎯', '📱', '💻', '🎨', '🎵', '📖', '✍️', '🌱',
    '🔥', '💎', '🌟', '⚡', '🎪', '🎭', '🎨', '🎯', '🚀', '💫'
  ];

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Green', 'value': '#4CAF50'},
    {'name': 'Blue', 'value': '#2196F3'},
    {'name': 'Red', 'value': '#F44336'},
    {'name': 'Orange', 'value': '#FF9800'},
    {'name': 'Purple', 'value': '#9C27B0'},
    {'name': 'Teal', 'value': '#009688'},
    {'name': 'Pink', 'value': '#E91E63'},
    {'name': 'Indigo', 'value': '#3F51B5'},
    {'name': 'Amber', 'value': '#FFC107'},
    {'name': 'Deep Orange', 'value': '#FF5722'},
  ];

  final List<Map<String, dynamic>> _frequencies = [
    {'name': 'Every day', 'value': 'everyday'},
    {'name': 'Every week', 'value': 'everyweek'},
    {'name': 'One time', 'value': 'dont_repeat'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final habit = await _habitService.createCustomHabit(
        _titleController.text.trim(),
        _selectedEmoji,
        _selectedColor,
        _selectedFrequency,
      );

      // Also add it to user's habits
      await _habitService.addHabitToUser(habit.habitId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom habit created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating habit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Habit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          _selectedEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.isEmpty ? 'Habit Title' : _titleController.text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Repeats: ${_frequencies.firstWhere((f) => f['value'] == _selectedFrequency)['name']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Habit Title',
                hintText: 'e.g., Read 10 pages daily',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit title';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Refresh preview
              },
            ),
            const SizedBox(height: 24),

            // Emoji selection
            const Text(
              'Choose Emoji',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _emojis.length,
                itemBuilder: (context, index) {
                  final emoji = _emojis[index];
                  final isSelected = _selectedEmoji == emoji;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = emoji;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.teal : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Color selection
            const Text(
              'Choose Color',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color['value'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color['value'];
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color['value'].replaceFirst('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Frequency selection
            const Text(
              'Repeat Frequency',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: _frequencies.map((frequency) {
                return RadioListTile<String>(
                  title: Text(frequency['name']),
                  value: frequency['value'],
                  groupValue: _selectedFrequency,
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency = value!;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createHabit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Habit',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
