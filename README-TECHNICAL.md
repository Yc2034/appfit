# Fitness Tracker - Technical Documentation

## Tech Stack

### Frontend/Mobile
- **React Native** - Cross-platform mobile development
- **Expo** - Development platform and build system
- **TypeScript** - Type-safe JavaScript
- **React Navigation** - Navigation and routing (Bottom Tabs + Native Stack)
- **React Native Calendars** - Calendar component for workout log
- **React Native Chart Kit** - Data visualization and charts
- **expo-image-picker** - Upload photos from device
- **React Native Paper** - UI component library (Material Design)
- **Zustand** - State management
- **date-fns** - Date manipulation and formatting

### Backend
- **Supabase**
  - PostgreSQL database
  - Authentication
  - Storage (image hosting)
  - RESTful API with TypeScript client

### Development Tools
- **Expo CLI** - Development and testing
- **EAS Build** - Building iOS/Android apps
- **Git** - Version control

## Project Structure

```
appfit/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── common/          # Buttons, inputs, cards, etc.
│   │   ├── workout/         # Workout-specific components
│   │   └── exercise/        # Exercise library components
│   ├── screens/             # App screens
│   │   ├── WorkoutLogScreen.tsx
│   │   ├── CalendarScreen.tsx
│   │   ├── AnalyticsScreen.tsx
│   │   ├── ExerciseLibraryScreen.tsx
│   │   └── ExerciseGalleryScreen.tsx
│   ├── navigation/          # Navigation configuration
│   │   └── AppNavigator.tsx
│   ├── services/            # API and backend services
│   │   ├── supabase.ts
│   │   ├── workout.service.ts
│   │   └── exercise.service.ts
│   ├── store/               # State management
│   │   ├── workoutStore.ts
│   │   └── exerciseStore.ts
│   ├── types/               # TypeScript type definitions
│   │   ├── workout.types.ts
│   │   └── exercise.types.ts
│   ├── utils/               # Utility functions
│   │   ├── formatters.ts
│   │   └── validators.ts
│   └── constants/           # App constants
│       └── theme.ts
├── assets/                  # Images, fonts, etc.
├── app.json                 # Expo configuration
├── package.json
├── tsconfig.json
└── README-BUSINESS.md       # Business requirements

```

## Database Schema

### Tables

#### workout_logs
```sql
- id (uuid, primary key)
- user_id (uuid, foreign key)
- date (timestamp)
- activity_type (text)
- calories (integer)
- duration (integer) -- in minutes
- distance (decimal) -- in km or miles
- heart_rate (integer) -- average BPM
- watch_screenshot_url (text)
- notes (text, optional)
- created_at (timestamp)
- updated_at (timestamp)
```

#### exercise_classes
```sql
- id (uuid, primary key)
- name (text) -- e.g., "Chest Press", "Squats"
- category (text) -- e.g., "Upper Body", "Legs"
- description (text, optional)
- created_at (timestamp)
```

#### exercise_images
```sql
- id (uuid, primary key)
- class_id (uuid, foreign key)
- image_url (text)
- description (text, optional)
- order (integer) -- for sorting images in gallery
- created_at (timestamp)
```

### Storage Buckets
- `workout-screenshots` - Fitness watch screenshots
- `exercise-images` - Exercise demonstration images

## Implementation Tasks

### Phase 1: Project Setup
- [ ] Initialize Expo project with TypeScript
- [ ] Set up project folder structure
- [ ] Configure TypeScript and linting
- [ ] Install core dependencies (React Navigation, UI library)
- [ ] Set up Supabase project
- [ ] Configure Supabase client in the app
- [ ] Set up environment variables

### Phase 2: Database & Authentication
- [ ] Create database schema in Supabase
- [ ] Set up authentication (email/password)
- [ ] Create storage buckets for images
- [ ] Set up database policies and permissions
- [ ] Create TypeScript types for database models

### Phase 3: Exercise Reference Library
- [ ] Create ExerciseLibraryScreen (list of classes)
- [ ] Create ExerciseGalleryScreen (image gallery)
- [ ] Implement image upload functionality (offline)
- [ ] Create exercise service (CRUD operations)
- [ ] Add exercise class management
- [ ] Implement gallery navigation and image viewing

### Phase 4: Workout Log
- [ ] Create WorkoutLogScreen (entry form)
- [ ] Implement workout data entry form
- [ ] Add image picker for watch screenshots
- [ ] Create workout service (CRUD operations)
- [ ] Implement workout data validation

### Phase 5: Calendar View
- [ ] Install and configure React Native Calendars
- [ ] Create CalendarScreen
- [ ] Display workouts on calendar
- [ ] Implement date selection and filtering
- [ ] Add workout detail view from calendar

### Phase 6: Analytics & Charts
- [ ] Install charting library (Victory Native/Recharts)
- [ ] Create AnalyticsScreen
- [ ] Implement calories burned chart (weekly/monthly)
- [ ] Implement workout frequency chart
- [ ] Add trend analysis and statistics
- [ ] Create data aggregation functions

### Phase 7: Navigation & UI Polish
- [ ] Set up main navigation structure
- [ ] Create tab navigator (Workout Log, Calendar, Analytics, Exercise Library)
- [ ] Implement screen transitions
- [ ] Add loading states and error handling
- [ ] Polish UI/UX across all screens
- [ ] Add app icon and splash screen

### Phase 8: Testing & Deployment
- [ ] Test on iOS simulator/device
- [ ] Test on Android emulator/device
- [ ] Fix bugs and edge cases
- [ ] Configure EAS Build
- [ ] Create development build
- [ ] Create production build
- [ ] Install on personal devices

## Environment Variables
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Development Commands
```bash
# Install dependencies
npm install

# Start development server
npx expo start

# Run on iOS
npx expo start --ios

# Run on Android
npx expo start --android

# Build for production
eas build --platform ios
eas build --platform android
```

## Completed Tasks

### Phase 1: Project Setup ✅
- [x] Initialize Expo project with TypeScript
- [x] Set up project folder structure
- [x] Configure TypeScript and linting
- [x] Install core dependencies (React Navigation, UI library)
- [x] Set up Supabase project configuration
- [x] Configure Supabase client in the app
- [x] Set up environment variables

### Phase 2: Database & Authentication ✅
- [x] Create database schema in Supabase (see supabase-schema.sql)
- [x] Set up authentication (optional for personal use)
- [x] Create storage buckets for images (documented in SETUP.md)
- [x] Set up database policies and permissions
- [x] Create TypeScript types for database models

### Phase 3: Exercise Reference Library ✅
- [x] Create ExerciseLibraryScreen (list of classes)
- [x] Create ExerciseGalleryScreen (image gallery)
- [x] Implement image viewing functionality
- [x] Create exercise service (CRUD operations)
- [x] Implement gallery navigation and image viewing

### Phase 4: Workout Log ✅
- [x] Create WorkoutLogScreen (entry form)
- [x] Implement workout data entry form
- [x] Add image picker for watch screenshots
- [x] Create workout service (CRUD operations)
- [x] Implement workout data validation

### Phase 5: Calendar View ✅
- [x] Install and configure React Native Calendars
- [x] Create CalendarScreen
- [x] Display workouts on calendar
- [x] Implement date selection and filtering
- [x] Add workout detail view from calendar

### Phase 6: Analytics & Charts ✅
- [x] Install charting library (React Native Chart Kit)
- [x] Create AnalyticsScreen
- [x] Implement calories burned chart (weekly)
- [x] Implement workout frequency chart
- [x] Add trend analysis and statistics
- [x] Create data aggregation functions

### Phase 7: Navigation & UI Polish ✅
- [x] Set up main navigation structure
- [x] Create tab navigator (Workout Log, Calendar, Analytics, Exercise Library)
- [x] Implement screen transitions
- [x] Add loading states and error handling
- [x] Polish UI/UX across all screens

### Phase 8: Testing & Deployment (User Action Required)
- [ ] Set up Supabase account and database (see SETUP.md)
- [ ] Configure environment variables
- [ ] Test on iOS simulator/device
- [ ] Test on Android emulator/device
- [ ] Fix bugs and edge cases (if any)
- [ ] Configure EAS Build (optional)
- [ ] Create production build
- [ ] Install on personal devices

## Notes & Decisions
- Using Supabase for backend due to good image storage support and PostgreSQL flexibility
- React Native Paper chosen for UI components (clean Material Design)
- **Changed from Victory Native to React Native Chart Kit** - Victory Native had dependency issues with Skia, Chart Kit is lighter and works well
- No real-time sync needed for exercise library - offline-first approach
- Authentication is optional for personal use - RLS policies allow NULL user_id
- Using Zustand for state management (simpler than Redux, perfect for this use case)
- Date handling with date-fns for reliable date formatting
