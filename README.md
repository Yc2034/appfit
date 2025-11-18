# AppFit - Personal Fitness Tracker

A mobile-first fitness tracking application built with React Native and Expo for iOS and Android.

## Overview

AppFit is a personal fitness tracker that helps you:
- 📝 Log daily workouts with detailed metrics
- 📅 View workouts in a calendar format
- 📊 Track progress with analytics and charts
- 💪 Maintain an exercise reference library with demonstration images

## Quick Start

See [SETUP.md](SETUP.md) for detailed setup instructions.

```bash
# Install dependencies
npm install

# Set up your environment variables (see SETUP.md)
cp .env.example .env

# Start the development server
npm start
```

## Documentation

- **[SETUP.md](SETUP.md)** - Complete setup guide
- **[README-BUSINESS.md](README-BUSINESS.md)** - Business requirements and features
- **[README-TECHNICAL.md](README-TECHNICAL.md)** - Technical documentation and architecture

## Tech Stack

- **Frontend:** React Native, Expo, TypeScript
- **UI:** React Native Paper
- **Backend:** Supabase (PostgreSQL, Storage, Auth)
- **State Management:** Zustand
- **Navigation:** React Navigation
- **Charts:** React Native Chart Kit

## Features

### Workout Log
Track your fitness activities with:
- Activity type
- Calories burned
- Duration
- Distance
- Heart rate
- Fitness watch screenshots
- Notes

### Calendar View
- View workouts organized by date
- Visual calendar with marked workout days
- Detailed workout information

### Analytics & Charts
- Total statistics (workouts, calories, distance)
- Weekly calories burned chart
- Workout frequency by activity type

### Exercise Reference Library
- Organize exercises by class/category
- Store demonstration images for proper form
- Gallery view for exercise images

## Project Structure

```
appfit/
├── src/
│   ├── components/      # Reusable UI components
│   ├── screens/         # App screens
│   ├── navigation/      # Navigation configuration
│   ├── services/        # API and backend services
│   ├── store/          # State management
│   ├── types/          # TypeScript types
│   ├── utils/          # Utility functions
│   └── constants/      # App constants
├── assets/             # Images, fonts, etc.
├── SETUP.md           # Setup guide
├── README-BUSINESS.md  # Business requirements
├── README-TECHNICAL.md # Technical documentation
└── supabase-schema.sql # Database schema
```

## Development

```bash
# Start development server
npm start

# Run on iOS
npm run ios

# Run on Android
npm run android

# Run tests (if added)
npm test
```

## Building for Production

See [Expo EAS Build documentation](https://docs.expo.dev/build/introduction/) for building production apps.

## License

MIT

## Author

Built with React Native and Expo
