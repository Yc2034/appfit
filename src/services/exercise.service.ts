import { supabase } from './supabase';
import { ExerciseClass, ExerciseImage, ExerciseClassWithImages } from '../types/exercise.types';

export const exerciseService = {
  // Get all exercise classes
  async getAllClasses(): Promise<ExerciseClass[]> {
    const { data, error } = await supabase
      .from('exercise_classes')
      .select('*')
      .order('name', { ascending: true });

    if (error) throw error;
    return data || [];
  },

  // Get exercise class with images
  async getClassWithImages(classId: string): Promise<ExerciseClassWithImages | null> {
    const { data: classData, error: classError } = await supabase
      .from('exercise_classes')
      .select('*')
      .eq('id', classId)
      .single();

    if (classError) throw classError;

    const { data: images, error: imagesError } = await supabase
      .from('exercise_images')
      .select('*')
      .eq('class_id', classId)
      .order('order', { ascending: true});

    if (imagesError) throw imagesError;

    return {
      ...classData,
      images: images || [],
    };
  },

  // Get images for a class
  async getClassImages(classId: string): Promise<ExerciseImage[]> {
    const { data, error } = await supabase
      .from('exercise_images')
      .select('*')
      .eq('class_id', classId)
      .order('order', { ascending: true });

    if (error) throw error;
    return data || [];
  },

  // Create a new exercise class
  async createClass(exerciseClass: Omit<ExerciseClass, 'id' | 'created_at'>): Promise<ExerciseClass> {
    const { data, error } = await supabase
      .from('exercise_classes')
      .insert([exerciseClass])
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  // Upload exercise image
  async uploadExerciseImage(uri: string, classId: string, order: number): Promise<ExerciseImage> {
    const response = await fetch(uri);
    const blob = await response.blob();
    const arrayBuffer = await new Response(blob).arrayBuffer();
    const fileName = `${classId}-${order}-${Date.now()}.jpg`;

    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('exercise-images')
      .upload(fileName, arrayBuffer, {
        contentType: 'image/jpeg',
      });

    if (uploadError) throw uploadError;

    const { data: urlData } = supabase.storage
      .from('exercise-images')
      .getPublicUrl(fileName);

    const { data, error } = await supabase
      .from('exercise_images')
      .insert([{
        class_id: classId,
        image_url: urlData.publicUrl,
        order,
      }])
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  // Delete exercise class
  async deleteClass(id: string): Promise<void> {
    const { error } = await supabase
      .from('exercise_classes')
      .delete()
      .eq('id', id);

    if (error) throw error;
  },
};
