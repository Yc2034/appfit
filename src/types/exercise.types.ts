export interface ExerciseClass {
  id: string;
  name: string;
  category: string;
  description?: string;
  created_at?: string;
}

export interface ExerciseImage {
  id: string;
  class_id: string;
  image_url: string;
  description?: string;
  order: number;
  created_at?: string;
}

export interface ExerciseClassWithImages extends ExerciseClass {
  images: ExerciseImage[];
}
