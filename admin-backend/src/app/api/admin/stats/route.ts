import { NextRequest, NextResponse } from 'next/server';
import { getDatabase } from '../../../../lib/mongodb';
import { ApiResponse } from '../../../../types';

// GET /api/admin/stats - Get admin statistics
export async function GET(request: NextRequest) {
  try {
    const db = await getDatabase();
    
    // Total users
    const totalUsers = await db.collection('users').countDocuments();
    
    // Users registered in last 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const newUsers = await db.collection('users').countDocuments({
      created_at: { $gte: thirtyDaysAgo }
    });
    
    // Active users (users who have tracking records in last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const activeUserIds = await db.collection('tracking').distinct('user_habit_id', {
      created_at: { $gte: sevenDaysAgo }
    });
    
    // Get user IDs from user_habit_ids
    const userHabits = await db.collection('user_habits').find({
      user_habit_id: { $in: activeUserIds }
    }).toArray();
    const activeUserIdsUnique = [...new Set(userHabits.map(uh => uh.user_id))];
    const activeUsers = activeUserIdsUnique.length;
    
    // Total tracking records
    const totalTrackingRecords = await db.collection('tracking').countDocuments();
    
    // Most tracked habits
    const mostTrackedHabits = await db.collection('user_habits')
      .aggregate([
        {
          $group: {
            _id: '$habit_id',
            count: { $sum: 1 }
          }
        },
        {
          $lookup: {
            from: 'habits',
            localField: '_id',
            foreignField: 'habit_id',
            as: 'habit'
          }
        },
        { $unwind: '$habit' },
        { $sort: { count: -1 } },
        { $limit: 10 },
        {
          $project: {
            habit_id: '$_id',
            title: '$habit.title',
            emoji: '$habit.emoji',
            count: 1
          }
        }
      ])
      .toArray();
    
    // Daily tracking activity (last 30 days)
    const dailyActivity = await db.collection('tracking')
      .aggregate([
        {
          $match: {
            created_at: { $gte: thirtyDaysAgo }
          }
        },
        {
          $group: {
            _id: {
              $dateToString: { format: '%Y-%m-%d', date: '$created_at' }
            },
            count: { $sum: 1 }
          }
        },
        { $sort: { _id: 1 } },
        {
          $project: {
            date: '$_id',
            count: 1,
            _id: 0
          }
        }
      ])
      .toArray();
    
    // User engagement levels
    const userEngagement = await db.collection('user_habits')
      .aggregate([
        {
          $group: {
            _id: '$user_id',
            habitsTracked: { $sum: 1 }
          }
        },
        {
          $group: {
            _id: {
              $switch: {
                branches: [
                  { case: { $lte: ['$habitsTracked', 2] }, then: 'Low (1-2 habits)' },
                  { case: { $lte: ['$habitsTracked', 5] }, then: 'Medium (3-5 habits)' },
                  { case: { $lte: ['$habitsTracked', 10] }, then: 'High (6-10 habits)' }
                ],
                default: 'Very High (10+ habits)'
              }
            },
            users: { $sum: 1 }
          }
        },
        { $sort: { users: -1 } }
      ])
      .toArray();

    return NextResponse.json<ApiResponse>({
      success: true,
      data: {
        totalUsers,
        newUsers,
        activeUsers,
        totalTrackingRecords,
        mostTrackedHabits,
        dailyActivity,
        userEngagement
      }
    });

  } catch (error) {
    console.error('Get admin stats error:', error);
    return NextResponse.json<ApiResponse>({
      success: false,
      error: 'Internal server error'
    }, { status: 500 });
  }
}

