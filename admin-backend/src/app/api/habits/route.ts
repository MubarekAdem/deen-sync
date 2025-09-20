import { NextRequest, NextResponse } from 'next/server';
import { getDatabase } from '../../../lib/mongodb';
import { verifyToken } from '../../../lib/auth';
import { Habit, ApiResponse } from '../../../types';
import { defaultHabits } from '../../../data/defaultHabits';

// Initialize default habits in database
export async function initializeDefaultHabits() {
  try {
    const db = await getDatabase();
    const habitsCollection = db.collection<Habit>('habits');
    
    // Check if habits are already initialized
    const existingHabits = await habitsCollection.countDocuments();
    
    if (existingHabits === 0) {
      const habitsToInsert = defaultHabits.map(habit => ({
        ...habit,
        created_at: new Date()
      }));
      
      await habitsCollection.insertMany(habitsToInsert as Habit[]);
      console.log('Default habits initialized');
    }
  } catch (error) {
    console.error('Error initializing default habits:', error);
  }
}

// GET /api/habits - Get all available habits
export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    const token = authHeader?.replace('Bearer ', '');

    if (!token) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Authentication token required'
      }, { status: 401 });
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Invalid or expired token'
      }, { status: 401 });
    }

    const db = await getDatabase();
    
    // Initialize default habits if not exists
    await initializeDefaultHabits();
    
    // Get all habits
    const habits = await db.collection<Habit>('habits')
      .find({})
      .sort({ habit_id: 1 })
      .toArray();

    return NextResponse.json<ApiResponse>({
      success: true,
      data: habits
    });

  } catch (error) {
    console.error('Get habits error:', error);
    return NextResponse.json<ApiResponse>({
      success: false,
      error: 'Internal server error'
    }, { status: 500 });
  }
}

// POST /api/habits - Create custom habit
export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    const token = authHeader?.replace('Bearer ', '');

    if (!token) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Authentication token required'
      }, { status: 401 });
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Invalid or expired token'
      }, { status: 401 });
    }

    const { title, emoji, color, repeat_frequency } = await request.json();

    // Validation
    if (!title || !emoji || !color || !repeat_frequency) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Title, emoji, color, and repeat_frequency are required'
      }, { status: 400 });
    }

    if (!['everyday', 'everyweek', 'dont_repeat'].includes(repeat_frequency)) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Invalid repeat_frequency. Must be: everyday, everyweek, or dont_repeat'
      }, { status: 400 });
    }

    const db = await getDatabase();
    
    // Get next habit_id
    const lastHabit = await db.collection<Habit>('habits')
      .findOne({}, { sort: { habit_id: -1 } });
    const nextHabitId = (lastHabit?.habit_id || 15) + 1; // Start after pre-made habits

    // Create custom habit
    const newHabit: Omit<Habit, '_id'> = {
      habit_id: nextHabitId,
      title,
      emoji,
      color,
      type: 'custom',
      category: 'Custom',
      repeat_frequency,
      created_at: new Date()
    };

    const result = await db.collection<Habit>('habits').insertOne(newHabit as Habit);

    return NextResponse.json<ApiResponse>({
      success: true,
      data: { ...newHabit, _id: result.insertedId },
      message: 'Custom habit created successfully'
    }, { status: 201 });

  } catch (error) {
    console.error('Create habit error:', error);
    return NextResponse.json<ApiResponse>({
      success: false,
      error: 'Internal server error'
    }, { status: 500 });
  }
}

