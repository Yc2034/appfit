# First-Time Setup

Run these steps once when setting up the project.

## 1. Install Dependencies

```bash
npm install
```

## 2. Supabase Setup

### Create Project
1. Go to [supabase.com](https://supabase.com) → New Project
2. Wait for project creation (~2 min)

### Create Database Tables
1. Go to **SQL Editor**
2. Paste contents of `supabase-schema.sql`
3. Click **Run**

### Create Storage Buckets
1. Go to **Storage** → New Bucket
2. Create `workout-screenshots` (public)
3. Create `exercise-images` (public)

### Get Credentials
1. Go to **Project Settings** → **API**
2. Copy **Project URL** (`https://xxxxx.supabase.co`)
3. Copy **anon public** key (`eyJ...`)

## 3. Environment Variables

```bash
cp .env.example .env
```

Edit `.env`:
```
EXPO_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

## 4. Run the App

```bash
open -a Simulator && npm run ios
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| App won't start | `npm install` then `npx expo start -c` |
| Can't save workouts | Check `.env` credentials |
| Images not uploading | Verify storage buckets are **public** |
