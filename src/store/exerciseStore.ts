import { create } from 'zustand';
import { ExerciseClass, ExerciseImage } from '../types/exercise.types';
import { exerciseService } from '../services/exercise.service';

interface ExerciseStore {
  classes: ExerciseClass[];
  loading: boolean;
  error: string | null;
  fetchClasses: () => Promise<void>;
  addClass: (exerciseClass: Omit<ExerciseClass, 'id' | 'created_at'>) => Promise<ExerciseClass>;
  deleteClass: (id: string) => Promise<void>;
}

export const useExerciseStore = create<ExerciseStore>((set) => ({
  classes: [],
  loading: false,
  error: null,

  fetchClasses: async () => {
    set({ loading: true, error: null });
    try {
      const classes = await exerciseService.getAllClasses();
      set({ classes, loading: false });
    } catch (error) {
      set({ error: (error as Error).message, loading: false });
    }
  },

  addClass: async (exerciseClass) => {
    set({ loading: true, error: null });
    try {
      const newClass = await exerciseService.createClass(exerciseClass);
      set((state) => ({
        classes: [...state.classes, newClass],
        loading: false,
      }));
      return newClass;
    } catch (error) {
      set({ error: (error as Error).message, loading: false });
      throw error;
    }
  },

  deleteClass: async (id) => {
    set({ loading: true, error: null });
    try {
      await exerciseService.deleteClass(id);
      set((state) => ({
        classes: state.classes.filter((c) => c.id !== id),
        loading: false,
      }));
    } catch (error) {
      set({ error: (error as Error).message, loading: false });
      throw error;
    }
  },
}));
