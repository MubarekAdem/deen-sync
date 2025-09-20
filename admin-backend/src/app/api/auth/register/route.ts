import { NextRequest, NextResponse } from 'next/server';
import { getDatabase } from '../../../../lib/mongodb';
import { hashPassword, generateToken } from '../../../../lib/auth';
import { User, ApiResponse } from '../../../../types';

export async function POST(request: NextRequest) {
  try {
    const { username, email, password } = await request.json();

    // Validation
    if (!username || !email || !password) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Username, email, and password are required'
      }, { status: 400 });
    }

    if (password.length < 6) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Password must be at least 6 characters long'
      }, { status: 400 });
    }

    const db = await getDatabase();
    
    // Check if user already exists
    const existingUser = await db.collection<User>('users').findOne({
      $or: [{ email }, { username }]
    });

    if (existingUser) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'User with this email or username already exists'
      }, { status: 409 });
    }

    // Get next user_id
    const lastUser = await db.collection<User>('users')
      .findOne({}, { sort: { user_id: -1 } });
    const nextUserId = (lastUser?.user_id || 0) + 1;

    // Hash password
    const password_hash = await hashPassword(password);

    // Create user
    const newUser: Omit<User, '_id'> = {
      user_id: nextUserId,
      username,
      email,
      password_hash,
      created_at: new Date(),
      last_sync_at: new Date()
    };

    const result = await db.collection<User>('users').insertOne(newUser as User);

    // Generate token
    const token = generateToken(nextUserId);

    return NextResponse.json<ApiResponse>({
      success: true,
      data: {
        user: {
          user_id: nextUserId,
          username,
          email,
          created_at: newUser.created_at
        },
        token
      },
      message: 'User registered successfully'
    }, { status: 201 });

  } catch (error) {
    console.error('Registration error:', error);
    return NextResponse.json<ApiResponse>({
      success: false,
      error: 'Internal server error'
    }, { status: 500 });
  }
}

