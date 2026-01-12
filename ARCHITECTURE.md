# Project Architecture

## Tech Stack

- **Framework:** React Native + Expo (SDK 52)
- **Language:** TypeScript
- **UI Library:** react-native-paper (Material Design 3)
- **Navigation:** @react-navigation/bottom-tabs + native-stack
- **State:** Zustand
- **Backend:** Supabase (PostgreSQL + Storage)
- **Charts:** react-native-chart-kit
- **Calendar:** react-native-calendars

## Directory Structure

```
appfit/
├── src/
│   ├── screens/          # UI screens (5 screens)
│   ├── navigation/       # Tab & stack navigation
│   ├── services/         # Supabase API calls
│   ├── store/            # Zustand state management
│   ├── types/            # TypeScript interfaces
│   ├── utils/            # Helper functions
│   └── constants/        # Theme & config
├── assets/               # App icons & splash
├── App.tsx               # Root component (wraps with PaperProvider)
└── supabase-schema.sql   # Database schema
```

## Screens (`src/screens/`)

| File | Purpose |
|------|---------|
| `WorkoutLogScreen.tsx` | Log workouts - 8 activity type buttons, form with date/duration/calories/distance, optional fields (heart rate, notes, screenshot) |
| `CalendarScreen.tsx` | History view - horizontal week strip (default), expandable full calendar, workout cards list |
| `AnalyticsScreen.tsx` | Stats dashboard - 4 stat cards (workouts/calories/avg/distance), 2 bar charts (weekly, by activity) |
| `ExerciseLibraryScreen.tsx` | Exercise class list - cards with category chips |
| `ExerciseGalleryScreen.tsx` | Exercise images - 2-column grid, fullscreen modal on tap |

## Navigation (`src/navigation/`)

| File | Purpose |
|------|---------|
| `AppNavigator.tsx` | 4 bottom tabs: History (default) → Log → Stats → Exercises. Exercises has nested stack for Gallery. |

## Services (`src/services/`)

| File | Purpose |
|------|---------|
| `supabase.ts` | Supabase client init with AsyncStorage for auth persistence |
| `workout.service.ts` | `getAllWorkouts()`, `createWorkout()`, `deleteWorkout()`, `uploadWatchScreenshot()` |
| `exercise.service.ts` | `getClasses()`, `getClassImages()`, `addClass()`, `addImage()` |

## State (`src/store/`)

| File | State | Actions |
|------|-------|---------|
| `workoutStore.ts` | `workouts[]`, `loading`, `error` | `fetchWorkouts()`, `addWorkout()`, `deleteWorkout()` |
| `exerciseStore.ts` | `classes[]`, `loading`, `error` | `fetchClasses()`, `addClass()`, `deleteClass()` |

## Types (`src/types/`)

```typescript
// workout.types.ts
interface WorkoutLog {
  id: string;
  date: string;              // 'yyyy-MM-dd'
  activity_type: string;     // 'Running', 'Cycling', etc.
  calories: number;
  duration: number;          // minutes
  distance?: number;         // km
  heart_rate?: number;       // bpm
  notes?: string;
  watch_screenshot_url?: string;
}

// exercise.types.ts
interface ExerciseClass {
  id: string;
  name: string;
  category: string;          // 'Upper Body', 'Cardio', etc.
  description?: string;
}

interface ExerciseImage {
  id: string;
  class_id: string;
  image_url: string;
  description?: string;
}
```

## Utils (`src/utils/`)

| File | Functions |
|------|-----------|
| `formatters.ts` | `formatTime(min)` → "45 min", `formatDistance(km)` → "5.2 km", `formatCalories(cal)` → "350 kcal" |
| `validators.ts` | `validateWorkoutForm(data)` → returns error string[] |

## Constants (`src/constants/theme.ts`)

```typescript
// Colors
primary: '#6200ee'    // Purple - buttons, charts, selected states
background: '#f5f5f5' // Light gray
surface: '#ffffff'    // White cards

// Activity types (for workout logging)
ACTIVITY_TYPES = ['Running', 'Cycling', 'Swimming', 'Strength Training', 'Yoga', 'Walking', 'Hiking', 'Other']

// Exercise categories
EXERCISE_CATEGORIES = ['Upper Body', 'Lower Body', 'Core', 'Cardio', 'Flexibility', 'Full Body']
```

## Database Tables (Supabase)

| Table | Columns |
|-------|---------|
| `workout_logs` | id, user_id?, date, activity_type, calories, duration, distance?, heart_rate?, notes?, watch_screenshot_url?, created_at |
| `exercise_classes` | id, name, category, description?, created_at |
| `exercise_images` | id, class_id (FK), image_url, description?, created_at |

## UI Patterns

- **Cards:** `<Surface elevation={1}>` with `borderRadius: 16`, `padding: 16`
- **Forms:** `<TextInput mode="outlined" dense />` from react-native-paper
- **Lists:** `<FlatList>` with card items
- **Loading:** `<ActivityIndicator color="#6200ee" />`
- **Empty state:** `<Surface>` with centered text

## Adding New Features

### New Screen
1. Create `src/screens/NewScreen.tsx`
2. Add to `AppNavigator.tsx` (new tab or nested in existing stack)
3. Use `<Surface>` for cards, follow existing styling patterns

### New Data Type
1. Add interface in `src/types/newType.types.ts`
2. Create `src/services/newType.service.ts` with Supabase queries
3. Create `src/store/newTypeStore.ts` with Zustand
4. Add table to Supabase via SQL Editor
5. Use in screen: `const { data, fetch } = useNewTypeStore()`

### Modify Existing Screen
1. Find screen in `src/screens/`
2. Check related store in `src/store/` for state
3. Check service in `src/services/` for API calls
4. Types are in `src/types/`
