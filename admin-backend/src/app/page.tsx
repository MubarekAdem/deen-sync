'use client';
import { useState, useEffect } from 'react';

interface AdminStats {
  totalUsers: number;
  newUsers: number;
  activeUsers: number;
  totalTrackingRecords: number;
  mostTrackedHabits: Array<{
    habit_id: number;
    title: string;
    emoji: string;
    count: number;
  }>;
  dailyActivity: Array<{
    date: string;
    count: number;
  }>;
  userEngagement: Array<{
    _id: string;
    users: number;
  }>;
}

export default function AdminDashboard() {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const response = await fetch('/api/admin/stats');
      const data = await response.json();
      
      if (data.success) {
        setStats(data.data);
      } else {
        setError(data.error || 'Failed to fetch stats');
      }
    } catch (err) {
      setError('Failed to connect to server');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-xl">Loading admin dashboard...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-red-500 text-xl">Error: {error}</div>
      </div>
    );
  }

  if (!stats) return null;

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Deen Tracker Admin Dashboard</h1>
        
        {/* Overview Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-sm font-medium text-gray-500">Total Users</h3>
            <p className="text-3xl font-bold text-blue-600">{stats.totalUsers}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-sm font-medium text-gray-500">New Users (30d)</h3>
            <p className="text-3xl font-bold text-green-600">{stats.newUsers}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-sm font-medium text-gray-500">Active Users (7d)</h3>
            <p className="text-3xl font-bold text-purple-600">{stats.activeUsers}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-sm font-medium text-gray-500">Total Tracking Records</h3>
            <p className="text-3xl font-bold text-orange-600">{stats.totalTrackingRecords}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Most Tracked Habits */}
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-bold text-gray-900 mb-4">Most Tracked Habits</h2>
            <div className="space-y-3">
              {stats.mostTrackedHabits.map((habit, index) => (
                <div key={habit.habit_id} className="flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <span className="text-2xl">{habit.emoji}</span>
                    <span className="font-medium">{habit.title}</span>
                  </div>
                  <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-sm">
                    {habit.count} users
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* User Engagement */}
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-bold text-gray-900 mb-4">User Engagement Levels</h2>
            <div className="space-y-3">
              {stats.userEngagement.map((engagement, index) => (
                <div key={index} className="flex items-center justify-between">
                  <span className="font-medium">{engagement._id}</span>
                  <span className="bg-green-100 text-green-800 px-2 py-1 rounded-full text-sm">
                    {engagement.users} users
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Daily Activity */}
        <div className="mt-8 bg-white p-6 rounded-lg shadow">
          <h2 className="text-xl font-bold text-gray-900 mb-4">Daily Activity (Last 30 Days)</h2>
          <div className="grid grid-cols-7 gap-2">
            {stats.dailyActivity.slice(-21).map((day, index) => (
              <div key={index} className="text-center">
                <div className="text-xs text-gray-500 mb-1">
                  {new Date(day.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                </div>
                <div 
                  className="bg-blue-500 rounded text-white text-xs py-1"
                  style={{ opacity: Math.min(day.count / 50, 1) }}
                >
                  {day.count}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Refresh Button */}
        <div className="mt-8 text-center">
          <button
            onClick={fetchStats}
            className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Refresh Data
          </button>
        </div>
      </div>
    </div>
  );
}
