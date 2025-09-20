import 'package:flutter/material.dart';
import '../../services/habit_service.dart';
import '../../services/auth_service.dart';
import '../../models/habit.dart';
import 'create_custom_habit_screen.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final HabitService _habitService = HabitService();
  final AuthService _authService = AuthService();
  List<Habit> _availableHabits = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Prayers', 'Learning & Dawah', 'Fasting'];

  @override
  void initState() {
    super.initState();
    _loadAvailableHabits();
  }

  Future<void> _loadAvailableHabits() async {
    setState(() => _isLoading = true);
    
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      final habits = await _habitService.getAvailableHabits(currentUser.userId);
      setState(() {
        _availableHabits = habits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading habits: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Habit> get _filteredHabits {
    var filtered = _availableHabits;
    
    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((habit) => habit.category == _selectedCategory).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((habit) => 
          habit.title.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  Future<void> _addHabit(Habit habit) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;
      
      final success = await _habitService.addHabitToUser(habit.habitId, currentUser.userId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${habit.title} added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Failed to add habit');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding habit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateCustomHabitScreen(),
                ),
              );
              if (result == true) {
                _loadAvailableHabits();
              }
            },
            tooltip: 'Create Custom Habit',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search habits...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Category filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Habits list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHabits.isEmpty
                    ? _buildEmptyState()
                    : _buildHabitsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No habits found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or create a custom habit',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateCustomHabitScreen(),
                ),
              );
              if (result == true) {
                _loadAvailableHabits();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Custom Habit'),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    // Group by category
    final Map<String, List<Habit>> groupedHabits = {};
    for (final habit in _filteredHabits) {
      groupedHabits.putIfAbsent(habit.category, () => []).add(habit);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedHabits.entries.map((entry) {
        final category = entry.key;
        final habits = entry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedCategory == 'All') ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
            ...habits.map((habit) => _buildHabitTile(habit)),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHabitTile(Habit habit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(int.parse(habit.color.replaceFirst('#', '0xFF'))),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              habit.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          habit.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(habit.category),
            Text(
              'Repeats: ${habit.repeatFrequency}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _addHabit(habit),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Add'),
        ),
      ),
    );
  }
}

