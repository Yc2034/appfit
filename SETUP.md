# AppFit - Setup Guide

This guide will help you set up and run the fitness tracker app.

## Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Expo CLI
- A Supabase account (free tier is fine)
- iOS Simulator (for Mac) or Android Emulator, or physical device with Expo Go app

## Step 1: Install Dependencies

```bash
npm install
```

## Step 2: Set Up Supabase

### 2.1 Create a Supabase Project

1. Go to [Supabase](https://supabase.com)
2. Sign up or log in
3. Click "New Project"
4. Fill in your project details
5. Wait for the project to be created (1-2 minutes)

### 2.2 Run Database Schema

1. In your Supabase project, go to the **SQL Editor**
2. Copy the entire contents of `supabase-schema.sql`
3. Paste it into the SQL Editor
4. Click "Run" to execute the SQL
5. Verify that the tables were created under **Database** > **Tables**

### 2.3 Create Storage Buckets

1. Go to **Storage** in your Supabase dashboard
2. Click "New Bucket"
3. Create a bucket named `workout-screenshots`
   - Make it **public**
4. Create another bucket named `exercise-images`
   - Make it **public**

### 2.4 Get Your Supabase Credentials

1. Go to **Project Settings** > **API**
2. Copy the **Project URL** (looks like `https://xxxxx.supabase.co`)
3. Copy the **anon public** key (starts with `eyJ...`)

## Step 3: Configure Environment Variables

1. Copy `.env.example` to create a new `.env` file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your Supabase credentials:
   ```
   EXPO_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
   EXPO_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
   ```

## Step 4: Run the App

### On iOS Simulator (Mac only)

```bash

open -a Simulator

npm run ios
```

### On Android Emulator

```bash
npm run android
```

### Using Expo Go on Physical Device

1. Install Expo Go app from App Store or Play Store
2. Run:
   ```bash
   npm start
   ```
3. Scan the QR code with your device

## Step 5: Optional - Set Up Authentication

For personal use, you can disable authentication by modifying the Supabase policies, or you can set up a simple email/password auth:

1. In Supabase Dashboard, go to **Authentication** > **Providers**
2. Enable **Email** provider
3. You can create a user in **Authentication** > **Users** > **Add User**

Note: The current implementation allows usage without authentication for simplicity. The `user_id` field is optional in the database.

## Features

### 1. Log Workout
- Add new workouts with activity type, calories, duration, distance, heart rate
- Upload screenshots from your fitness watch
- All fields except date, activity type, calories, and duration are optional

### 2. Calendar
- View all your workouts on a calendar
- Click a date to see workouts for that day
- See detailed information including screenshots

### 3. Analytics
- View statistics (total workouts, calories, distance)
- Weekly calories burned chart
- Workout frequency by activity type

### 4. Exercise Library
- Browse exercise classes/categories
- View demonstration images for proper form
- Add new exercise classes and images

## Troubleshooting

### App won't start
- Make sure all dependencies are installed: `npm install`
- Clear the cache: `npx expo start -c`

### Can't save workouts
- Check that your Supabase credentials in `.env` are correct
- Verify the database tables were created successfully
- Check the browser console for specific error messages

### Images not uploading
- Verify storage buckets are created and set to **public**
- Check storage bucket names match exactly: `workout-screenshots` and `exercise-images`

### Charts not showing data
- Make sure you have logged some workouts first
- Try pulling down to refresh the Analytics screen

## Next Steps

- Customize the activity types in `src/constants/theme.ts`
- Add your own exercise classes and demonstration images
- Modify the color theme in `src/constants/theme.ts`
- Build the app for production using EAS Build (see Expo docs)

## Support

For issues and questions, refer to:
- [Expo Documentation](https://docs.expo.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [React Native Paper](https://reactnativepaper.com/)
