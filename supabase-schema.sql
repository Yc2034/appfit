-- Fitness Tracker Database Schema
-- Run this SQL in your Supabase SQL Editor to set up the database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create workout_logs table
CREATE TABLE IF NOT EXISTS workout_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    activity_type TEXT NOT NULL,
    calories INTEGER NOT NULL,
    duration INTEGER NOT NULL, -- in minutes
    distance DECIMAL(10, 2), -- in km or miles
    heart_rate INTEGER, -- average BPM
    watch_screenshot_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create exercise_classes table
CREATE TABLE IF NOT EXISTS exercise_classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create exercise_images table
CREATE TABLE IF NOT EXISTS exercise_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID REFERENCES exercise_classes(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    description TEXT,
    "order" INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_workout_logs_date ON workout_logs(date DESC);
CREATE INDEX IF NOT EXISTS idx_workout_logs_user_id ON workout_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_exercise_images_class_id ON exercise_images(class_id);

-- Enable Row Level Security (RLS)
ALTER TABLE workout_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_images ENABLE ROW LEVEL SECURITY;

-- Create policies for workout_logs
CREATE POLICY "Users can view their own workout logs"
    ON workout_logs FOR SELECT
    USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert their own workout logs"
    ON workout_logs FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update their own workout logs"
    ON workout_logs FOR UPDATE
    USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can delete their own workout logs"
    ON workout_logs FOR DELETE
    USING (auth.uid() = user_id OR user_id IS NULL);

-- Create policies for exercise_classes (allow all authenticated users to read)
CREATE POLICY "Authenticated users can view exercise classes"
    ON exercise_classes FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can insert exercise classes"
    ON exercise_classes FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Authenticated users can update exercise classes"
    ON exercise_classes FOR UPDATE
    TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can delete exercise classes"
    ON exercise_classes FOR DELETE
    TO authenticated
    USING (true);

-- Create policies for exercise_images (allow all authenticated users to read)
CREATE POLICY "Authenticated users can view exercise images"
    ON exercise_images FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can insert exercise images"
    ON exercise_images FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Authenticated users can update exercise images"
    ON exercise_images FOR UPDATE
    TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can delete exercise images"
    ON exercise_images FOR DELETE
    TO authenticated
    USING (true);

-- Create storage buckets (you'll need to create these in the Supabase Dashboard)
-- 1. Go to Storage in Supabase Dashboard
-- 2. Create two buckets:
--    - workout-screenshots (public)
--    - exercise-images (public)

-- Insert some sample exercise classes (optional)
INSERT INTO exercise_classes (name, category, description) VALUES
    ('Chest Press', 'Upper Body', 'Standard chest press exercise'),
    ('Squats', 'Lower Body', 'Basic squat form'),
    ('Plank', 'Core', 'Core stability exercise'),
    ('Running Form', 'Cardio', 'Proper running technique'),
    ('Yoga Flow', 'Flexibility', 'Basic yoga sequence')
ON CONFLICT DO NOTHING;
