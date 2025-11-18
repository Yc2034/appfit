export interface WorkoutLog {
  id: string;
  user_id?: string;
  date: string;
  activity_type: string;
  calories: number;
  duration: number; // in minutes
  distance?: number; // in km or miles
  heart_rate?: number; // average BPM
  watch_screenshot_url?: string;
  notes?: string;
  created_at?: string;
  updated_at?: string;
}

export interface WorkoutFormData {
  date: string;
  activity_type: string;
  calories: string;
  duration: string;
  distance?: string;
  heart_rate?: string;
  notes?: string;
  watch_screenshot?: string;
}
