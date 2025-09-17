import { NextRequest, NextResponse } from 'next/server';
import { getDatabase } from '../../../../lib/mongodb';
import { verifyPassword, generateToken } from '../../../../lib/auth';
import { User, ApiResponse } from '../../../../types';

export async function POST(request: NextRequest) {
  try {
    const { email, password } = await request.json();

    // Validation
    if (!email || !password) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Email and password are required'
      }, { status: 400 });
    }

    const db = await getDatabase();
    
    // Find user
    const user = await db.collection<User>('users').findOne({ email });

    if (!user) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Invalid email or password'
      }, { status: 401 });
    }

    // Verify password
    const isValidPassword = await verifyPassword(password, user.password_hash);

    if (!isValidPassword) {
      return NextResponse.json<ApiResponse>({
        success: false,
        error: 'Invalid email or password'
      }, { status: 401 });
    }

    // Update last sync time
    await db.collection<User>('users').updateOne(
      { user_id: user.user_id },
      { $set: { last_sync_at: new Date() } }
    );

    // Generate token
    const token = generateToken(user.user_id);

    return NextResponse.json<ApiResponse>({
      success: true,
      data: {
        user: {
          user_id: user.user_id,
          username: user.username,
          email: user.email,
          created_at: user.created_at,
          last_sync_at: new Date()
        },
        token
      },
      message: 'Login successful'
    });

  } catch (error) {
    console.error('Login error:', error);
    return NextResponse.json<ApiResponse>({
      success: false,
      error: 'Internal server error'
    }, { status: 500 });
  }
}
