# Deen Tracker - Islamic Habit Tracker App

A comprehensive Islamic habit tracking application with offline-first architecture, built with Flutter (Android) and Next.js backend.

## Features

### 📱 Mobile App (Flutter)
- **Offline-first architecture** with SQLite local storage
- **Default Prayer Habits**: Fajr, Dhuhr, Asr, Maghrib, Isha
- **Pre-made Habits**: 
  - Learning & Dawah: Read Islamic Books, Listen Quran, Listen Lectures
  - Additional Prayers: Tarawih, Sunnah, Witr, Ishraq, Tahajjud, Tahiyatul Masjid
  - Fasting: Monday and Thursday Fasting
- **Custom Habit Creation** with emoji, color, and frequency options
- **Mutually Exclusive Status Options**:
  - Prayers: Not Prayed, Late, On Time, In Jemaah
  - Other Habits: Not Completed, Completed
- **Beautiful Material Design UI**
- **Automatic sync** with cloud when online (latest wins on conflict)

### 🖥️ Admin Backend (Next.js)
- **User Management**: Registration and authentication
- **Habit Management**: CRUD operations for all habit types
- **Analytics Dashboard** with user engagement metrics
- **MongoDB integration** for cloud storage
- **RESTful API** for mobile app communication

## Tech Stack

- **Frontend**: Flutter (Android-focused)
- **Backend**: Next.js 15 with TypeScript
- **Database**: 
  - Local: SQLite (offline storage)
  - Cloud: MongoDB (sync and backup)
- **Authentication**: JWT tokens with bcrypt password hashing
- **State Management**: Provider pattern

## Setup Instructions

### Prerequisites
- Node.js 18+ and npm
- Flutter SDK 3.8+
- MongoDB (local or Atlas)

### Backend Setup
1. Navigate to admin-backend folder:
   ```bash
   cd admin-backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create `.env.local` file:
   ```env
   MONGODB_URI=mongodb://localhost:27017/deen-tracker
   JWT_SECRET=your-super-secret-jwt-key-change-in-production
   NODE_ENV=development
   ```

4. Start the development server:
   ```bash
   npm run dev
   ```

   The admin panel will be available at `http://localhost:3000`

### Flutter App Setup
1. Navigate to app folder:
   ```bash
   cd app
   ```

2. Get Flutter packages:
   ```bash
   flutter pub get
   ```

3. Update API base URL in `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://your-backend-url:3000/api';
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login

### Habits Management
- `GET /api/habits` - Get all available habits
- `POST /api/habits` - Create custom habit

### User Habits
- `GET /api/user-habits` - Get user's tracked habits
- `POST /api/user-habits` - Add habit to user's tracking
- `DELETE /api/user-habits` - Remove habit from tracking

### Tracking
- `GET /api/tracking` - Get tracking records
- `POST /api/tracking` - Log habit progress

### Admin
- `GET /api/admin/stats` - Get admin dashboard statistics

## Database Schema

### Users Table
- user_id (Primary Key)
- username
- email
- password_hash
- created_at
- last_sync_at

### Habits Table
- habit_id (Primary Key)
- title
- emoji
- color
- type (default/pre-made/custom)
- category
- repeat_frequency

### UserHabits Table
- user_habit_id (Primary Key)
- user_id (Foreign Key)
- habit_id (Foreign Key)
- added_at

### Tracking Table
- tracking_id (Primary Key)
- user_habit_id (Foreign Key)
- date
- status
- note
- created_at
- updated_at

## Key Features Implementation

### Offline-First Architecture
- SQLite for local storage
- Automatic sync when online
- Conflict resolution (latest wins)
- Graceful fallback to offline mode

### Habit Status System
- **Prayer Habits**: Mutually exclusive options (Not Prayed, Late, On Time, In Jemaah)
- **Other Habits**: Simple completion status (Not Completed, Completed)
- Status tracking with timestamps and optional notes

### Custom Habit Creation
- User-defined title, emoji, color
- Repeat frequency options (everyday, everyweek, one-time)
- Deletion allowed only for custom habits

### Admin Analytics
- Total users and new user registrations
- Active user tracking (7-day window)
- Most tracked habits
- User engagement levels
- Daily activity charts

## Development Notes

### Sync Strategy
- Offline-first: All operations work without internet
- Sync on app startup and user actions
- Conflict resolution: Latest timestamp wins
- Graceful error handling for network issues

### Security
- JWT tokens for authentication
- bcrypt for password hashing
- Input validation on all endpoints
- SQL injection prevention with parameterized queries

### Performance
- Indexed database queries
- Efficient pagination for large datasets
- Optimized Flutter widgets for smooth scrolling
- Minimal network requests with smart caching

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.
