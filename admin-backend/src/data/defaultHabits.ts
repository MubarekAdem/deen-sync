import { Habit } from '../types';

export const defaultHabits: Omit<Habit, '_id' | 'created_at'>[] = [
  // Default Prayer Habits (habit_id 1-5)
  {
    habit_id: 1,
    title: 'Fajr',
    emoji: '🌅',
    color: '#FF6B6B',
    type: 'default',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 2,
    title: 'Dhuhr',
    emoji: '☀️',
    color: '#4ECDC4',
    type: 'default',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 3,
    title: 'Asr',
    emoji: '🌤️',
    color: '#45B7D1',
    type: 'default',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 4,
    title: 'Maghrib',
    emoji: '🌇',
    color: '#F7B731',
    type: 'default',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 5,
    title: 'Isha',
    emoji: '🌙',
    color: '#5F27CD',
    type: 'default',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  
  // Pre-made Learning & Dawah Habits (habit_id 6-8)
  {
    habit_id: 6,
    title: 'Read Islamic Books',
    emoji: '📚',
    color: '#00D2D3',
    type: 'pre-made',
    category: 'Learning & Dawah',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 7,
    title: 'Listen Quran',
    emoji: '📖',
    color: '#FF9FF3',
    type: 'pre-made',
    category: 'Learning & Dawah',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 8,
    title: 'Listen Lectures',
    emoji: '🎧',
    color: '#54A0FF',
    type: 'pre-made',
    category: 'Learning & Dawah',
    repeat_frequency: 'everyday'
  },
  
  // Pre-made Prayer Habits (habit_id 9-14)
  {
    habit_id: 9,
    title: 'Tarawih',
    emoji: '🤲',
    color: '#5F27CD',
    type: 'pre-made',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 10,
    title: 'Sunnah',
    emoji: '🕌',
    color: '#10AC84',
    type: 'pre-made',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 11,
    title: 'Witr',
    emoji: '🌟',
    color: '#F79F1F',
    type: 'pre-made',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 12,
    title: 'Ishraq',
    emoji: '🌄',
    color: '#FDA7DF',
    type: 'pre-made',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 13,
    title: 'Tahajjud',
    emoji: '✨',
    color: '#9980FA',
    type: 'pre-made',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  {
    habit_id: 14,
    title: 'Tahiyatul Masjid',
    emoji: '🕊️',
    color: '#12CBC4',
    type: 'pre-made',
    category: 'Prayers',
    repeat_frequency: 'everyday'
  },
  
  // Pre-made Fasting Habits (habit_id 15)
  {
    habit_id: 15,
    title: 'Monday and Thursday Fasting',
    emoji: '🌙',
    color: '#C44569',
    type: 'pre-made',
    category: 'Fasting',
    repeat_frequency: 'everyweek'
  }
];
