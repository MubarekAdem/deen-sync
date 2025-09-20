import { NextRequest, NextResponse } from 'next/server';
import { getDatabase } from '../../../lib/mongodb';
import { verifyToken } from '../../../lib/auth';
import { UserHabit, Habit, ApiResponse } from '../../../types';

// GET /api/user-habits - Get user's tracked habits
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
    
    // Get user's habits with habit details
    const userHabits = await db.collection<UserHabit>('user_habits')
      .aggregate([
        { $match: { user_id: decoded.userId } },
        {
          $lookup: {
            from: 'habits',
            localField: 'habit_id',
            foreignField: 'habit_id',
            as: 'habit'
          }
        },
        { $unwind: '$habit' },
        { $sort: { 'habit.habit_id': 1 } }
      ])
      .toArray();

    return NextResponse.json<ApiResponse>({
      success: true,
      data: userHabits
    });

  } catch (error) {
    console.error('Get user habits error:', error);
    return NextResponse.json<ApiResponse>({
      success: false,
      error: 'Internal server error'
    }, { status: 500 });
  }
}

// POST /api/user-habits - Add habit to user's tracking list
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

    const { habit_id } = await request.json();

    if (!habit_id) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'habit_id is required'
      }, { status: 400 });
    }

    const db = await getDatabase();
    
    // Check if habit exists
    const habit = await db.collection<Habit>('habits').findOne({ habit_id });
    if (!habit) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Habit not found'
      }, { status: 404 });
    }

    // Check if user already tracking this habit
    const existingUserHabit = await db.collection<UserHabit>('user_habits')
      .findOne({ user_id: decoded.userId, habit_id });

    if (existingUserHabit) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Habit already being tracked'
      }, { status: 409 });
    }

    // Get next user_habit_id
    const lastUserHabit = await db.collection<UserHabit>('user_habits')
      .findOne({}, { sort: { user_habit_id: -1 } });
    const nextUserHabitId = (lastUserHabit?.user_habit_id || 0) + 1;

    // Create user habit
    const newUserHabit: Omit<UserHabit, '_id'> = {
      user_habit_id: nextUserHabitId,
      user_id: decoded.userId,
      habit_id,
      added_at: new Date()
    };

    const result = await db.collection<UserHabit>('user_habits').insertOne(newUserHabit as UserHabit);

    return NextResponse.json<ApiResponse>({
      success: true,
      data: { ...newUserHabit, _id: result.insertedId, habit },
      message: 'Habit added to tracking list'
    }, { status: 201 });

  } catch (error) {
    console.error('Add user habit error:', error);
    return NextResponse.json<ApiResponse>({
      success: false,
      error: 'Internal server error'
    }, { status: 500 });
  }
}

// DELETE /api/user-habits - Remove habit from user's tracking list
export async function DELETE(request: NextRequest) {
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

    const { habit_id } = await request.json();

    if (!habit_id) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'habit_id is required'
      }, { status: 400 });
    }

    const db = await getDatabase();
    
    // Find and delete user habit
    const result = await db.collection<UserHabit>('user_habits')
      .deleteOne({ user_id: decoded.userId, habit_id });

    if (result.deletedCount === 0) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Habit not found in tracking list'
      }, { status: 404 });
    }

    // Also delete all tracking records for this user habit
    await db.collection('tracking').deleteMany({
      user_habit_id: { $in: await db.collection<UserHabit>('user_habits')
        .find({ user_id: decoded.userId, habit_id })
        .map(uh => uh.user_habit_id)
        .toArray()
      }
    });

    return NextResponse.json<ApiResponse>({
      success: true,
      message: 'Habit removed from tracking list'
    });

  } catch (error) {
    console.error('Delete user habit error:', error);
    return NextResponse.json<ApiResponse>({
      success: false,
      error: 'Internal server error'
    }, { status: 500 });
  }
}

