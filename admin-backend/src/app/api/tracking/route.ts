import { NextRequest, NextResponse } from 'next/server';
import { getDatabase } from '../../../lib/mongodb';
import { verifyToken } from '../../../lib/auth';
import { Tracking, UserHabit, ApiResponse } from '../../../types';

// GET /api/tracking - Get user's tracking records
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

    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date'); // YYYY-MM-DD format
    const habit_id = searchParams.get('habit_id');

    const db = await getDatabase();
    
    // Build query
    let matchQuery: any = {};
    
    // Get user's habit IDs first
    const userHabits = await db.collection<UserHabit>('user_habits')
      .find({ user_id: decoded.userId })
      .toArray();
    
    const userHabitIds = userHabits.map(uh => uh.user_habit_id);
    matchQuery.user_habit_id = { $in: userHabitIds };

    if (date) {
      matchQuery.date = date;
    }

    if (habit_id) {
      const specificUserHabit = userHabits.find(uh => uh.habit_id === parseInt(habit_id));
      if (specificUserHabit) {
        matchQuery.user_habit_id = specificUserHabit.user_habit_id;
      } else {
        return NextResponse.json<ApiResponse>({
          success: true,
          data: []
        });
      }
    }

    // Get tracking records with habit details
    const trackingRecords = await db.collection<Tracking>('tracking')
      .aggregate([
        { $match: matchQuery },
        {
          $lookup: {
            from: 'user_habits',
            localField: 'user_habit_id',
            foreignField: 'user_habit_id',
            as: 'user_habit'
          }
        },
        { $unwind: '$user_habit' },
        {
          $lookup: {
            from: 'habits',
            localField: 'user_habit.habit_id',
            foreignField: 'habit_id',
            as: 'habit'
          }
        },
        { $unwind: '$habit' },
        { $sort: { date: -1, 'habit.habit_id': 1 } }
      ])
      .toArray();

    return NextResponse.json<ApiResponse>({
      success: true,
      data: trackingRecords
    });

  } catch (error) {
    console.error('Get tracking error:', error);
    return NextResponse.json<ApiResponse>({
      success: false,
      error: 'Internal server error'
    }, { status: 500 });
  }
}

// POST /api/tracking - Log habit progress
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

    const { habit_id, date, status, note } = await request.json();

    // Validation
    if (!habit_id || !date || !status) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'habit_id, date, and status are required'
      }, { status: 400 });
    }

    const validStatuses = ['not_prayed', 'late', 'on_time', 'in_jemaah', 'completed', 'not_completed'];
    if (!validStatuses.includes(status)) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Invalid status'
      }, { status: 400 });
    }

    const db = await getDatabase();
    
    // Find user habit
    const userHabit = await db.collection<UserHabit>('user_habits')
      .findOne({ user_id: decoded.userId, habit_id });

    if (!userHabit) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Habit not found in your tracking list'
      }, { status: 404 });
    }

    // Check if tracking record already exists for this date
    const existingTracking = await db.collection<Tracking>('tracking')
      .findOne({ user_habit_id: userHabit.user_habit_id, date });

    if (existingTracking) {
      // Update existing record (offline-first sync - latest wins)
      const updateResult = await db.collection<Tracking>('tracking')
        .updateOne(
          { tracking_id: existingTracking.tracking_id },
          {
            $set: {
              status,
              note: note || existingTracking.note,
              updated_at: new Date()
            }
          }
        );

      const updatedRecord = await db.collection<Tracking>('tracking')
        .findOne({ tracking_id: existingTracking.tracking_id });

      return NextResponse.json<ApiResponse>({
        success: true,
        data: updatedRecord,
        message: 'Tracking record updated'
      });
    } else {
      // Create new tracking record
      const lastTracking = await db.collection<Tracking>('tracking')
        .findOne({}, { sort: { tracking_id: -1 } });
      const nextTrackingId = (lastTracking?.tracking_id || 0) + 1;

      const newTracking: Omit<Tracking, '_id'> = {
        tracking_id: nextTrackingId,
        user_habit_id: userHabit.user_habit_id,
        date,
        status,
        note,
        created_at: new Date(),
        updated_at: new Date()
      };

      const result = await db.collection<Tracking>('tracking').insertOne(newTracking as Tracking);

      return NextResponse.json<ApiResponse>({
        success: true,
        data: { ...newTracking, _id: result.insertedId },
        message: 'Habit progress logged successfully'
      }, { status: 201 });
    }

  } catch (error) {
    console.error('Log tracking error:', error);
    return NextResponse.json<ApiResponse>({
      success: false,
      error: 'Internal server error'
    }, { status: 500 });
  }
}
