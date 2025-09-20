export interface User {
  _id?: string;
  user_id: number;
  username: string;
  email: string;
  password_hash: string;
  created_at?: Date;
  last_sync_at?: Date;
}

export interface Habit {
  _id?: string;
  habit_id: number;
  title: string;
  emoji: string;
  color: string;
  type: 'default' | 'pre-made' | 'custom';
  category: 'Prayers' | 'Learning & Dawah' | 'Fasting' | 'Custom';
  repeat_frequency: 'everyday' | 'everyweek' | 'dont_repeat';
  created_at?: Date;
}

export interface UserHabit {
  _id?: string;
  user_habit_id: number;
  user_id: number;
  habit_id: number;
  added_at?: Date;
}

export interface Tracking {
  _id?: string;
  tracking_id: number;
  user_habit_id: number;
  date: string; // YYYY-MM-DD format
  status: 'not_prayed' | 'late' | 'on_time' | 'in_jemaah' | 'completed' | 'not_completed';
  note?: string;
  created_at?: Date;
  updated_at?: Date;
}

export interface PrayerStatus {
  not_prayed: string;
  late: string;
  on_time: string;
  in_jemaah: string;
}

export interface HabitStatus {
  completed: string;
  not_completed: string;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

