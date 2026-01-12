import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, Image, Alert, Pressable } from 'react-native';
import { TextInput, Button, Text, Surface, Chip, IconButton } from 'react-native-paper';
import * as ImagePicker from 'expo-image-picker';
import { useWorkoutStore } from '../store/workoutStore';
import { WorkoutFormData } from '../types/workout.types';
import { validateWorkoutForm } from '../utils/validators';
import { format } from 'date-fns';

const QUICK_ACTIVITIES = [
  { type: 'Running', icon: 'run' },
  { type: 'Cycling', icon: 'bike' },
  { type: 'Swimming', icon: 'swim' },
  { type: 'Strength Training', icon: 'dumbbell' },
  { type: 'Yoga', icon: 'yoga' },
  { type: 'Walking', icon: 'walk' },
  { type: 'Hiking', icon: 'hiking' },
  { type: 'Other', icon: 'dots-horizontal' },
];

export default function WorkoutLogScreen() {
  const { addWorkout } = useWorkoutStore();
  const [formData, setFormData] = useState<WorkoutFormData>({
    date: format(new Date(), 'yyyy-MM-dd'),
    activity_type: '',
    calories: '',
    duration: '',
    distance: '',
    heart_rate: '',
    notes: '',
    watch_screenshot: undefined,
  });
  const [loading, setLoading] = useState(false);
  const [showOptional, setShowOptional] = useState(false);

  const handleImagePick = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: true,
      quality: 0.8,
    });

    if (!result.canceled && result.assets[0]) {
      setFormData({ ...formData, watch_screenshot: result.assets[0].uri });
    }
  };

  const handleSubmit = async () => {
    const errors = validateWorkoutForm(formData);
    if (errors.length > 0) {
      Alert.alert('Validation Error', errors.join('\n'));
      return;
    }

    setLoading(true);
    try {
      await addWorkout({
        date: formData.date,
        activity_type: formData.activity_type,
        calories: parseInt(formData.calories),
        duration: parseInt(formData.duration),
        distance: formData.distance ? parseFloat(formData.distance) : undefined,
        heart_rate: formData.heart_rate ? parseInt(formData.heart_rate) : undefined,
        notes: formData.notes || undefined,
        watch_screenshot_url: formData.watch_screenshot,
      });

      Alert.alert('Success', 'Workout logged successfully!');

      // Reset form
      setFormData({
        date: format(new Date(), 'yyyy-MM-dd'),
        activity_type: '',
        calories: '',
        duration: '',
        distance: '',
        heart_rate: '',
        notes: '',
        watch_screenshot: undefined,
      });
      setShowOptional(false);
    } catch (error: any) {
      console.error('Failed to log workout:', error);
      Alert.alert('Error', error?.message || 'Failed to log workout. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Activity Type Selection */}
      <Surface style={styles.card} elevation={1}>
        <Text variant="titleMedium" style={styles.sectionTitle}>
          Activity Type
        </Text>
        <View style={styles.activityGrid}>
          {QUICK_ACTIVITIES.map((activity) => (
            <Pressable
              key={activity.type}
              onPress={() => setFormData({ ...formData, activity_type: activity.type })}
              style={[
                styles.activityItem,
                formData.activity_type === activity.type && styles.activityItemSelected,
              ]}
            >
              <IconButton
                icon={activity.icon}
                size={28}
                iconColor={formData.activity_type === activity.type ? '#fff' : '#6200ee'}
              />
              <Text
                variant="bodySmall"
                style={[
                  styles.activityLabel,
                  formData.activity_type === activity.type && styles.activityLabelSelected,
                ]}
                numberOfLines={1}
              >
                {activity.type}
              </Text>
            </Pressable>
          ))}
        </View>
      </Surface>

      {/* Core Data */}
      <Surface style={styles.card} elevation={1}>
        <Text variant="titleMedium" style={styles.sectionTitle}>
          Workout Data
        </Text>

        <View style={styles.row}>
          <TextInput
            label="Date"
            value={formData.date}
            onChangeText={(text) => setFormData({ ...formData, date: text })}
            mode="outlined"
            style={styles.halfInput}
            dense
          />
          <TextInput
            label="Duration (min)"
            value={formData.duration}
            onChangeText={(text) => setFormData({ ...formData, duration: text })}
            keyboardType="numeric"
            mode="outlined"
            style={styles.halfInput}
            dense
          />
        </View>

        <View style={styles.row}>
          <TextInput
            label="Calories"
            value={formData.calories}
            onChangeText={(text) => setFormData({ ...formData, calories: text })}
            keyboardType="numeric"
            mode="outlined"
            style={styles.halfInput}
            dense
            right={<TextInput.Affix text="kcal" />}
          />
          <TextInput
            label="Distance"
            value={formData.distance}
            onChangeText={(text) => setFormData({ ...formData, distance: text })}
            keyboardType="decimal-pad"
            mode="outlined"
            style={styles.halfInput}
            dense
            right={<TextInput.Affix text="km" />}
          />
        </View>
      </Surface>

      {/* Optional Fields Toggle */}
      <Pressable onPress={() => setShowOptional(!showOptional)} style={styles.toggleRow}>
        <Text variant="bodyMedium" style={styles.toggleText}>
          {showOptional ? 'Hide optional fields' : 'Show optional fields'}
        </Text>
        <IconButton
          icon={showOptional ? 'chevron-up' : 'chevron-down'}
          size={20}
          iconColor="#6200ee"
        />
      </Pressable>

      {/* Optional Fields */}
      {showOptional && (
        <Surface style={styles.card} elevation={1}>
          <TextInput
            label="Heart Rate (bpm)"
            value={formData.heart_rate}
            onChangeText={(text) => setFormData({ ...formData, heart_rate: text })}
            keyboardType="numeric"
            mode="outlined"
            style={styles.input}
            dense
            left={<TextInput.Icon icon="heart-pulse" />}
          />

          <TextInput
            label="Notes"
            value={formData.notes}
            onChangeText={(text) => setFormData({ ...formData, notes: text })}
            mode="outlined"
            multiline
            numberOfLines={2}
            style={styles.input}
            dense
          />

          <Button
            mode="outlined"
            icon="camera"
            onPress={handleImagePick}
            style={styles.imageButton}
            compact
          >
            {formData.watch_screenshot ? 'Change Screenshot' : 'Add Screenshot'}
          </Button>

          {formData.watch_screenshot && (
            <Image
              source={{ uri: formData.watch_screenshot }}
              style={styles.preview}
              resizeMode="contain"
            />
          )}
        </Surface>
      )}

      {/* Submit Button */}
      <Button
        mode="contained"
        onPress={handleSubmit}
        loading={loading}
        disabled={loading || !formData.activity_type}
        style={styles.submitButton}
        contentStyle={styles.submitButtonContent}
      >
        Log Workout
      </Button>

      <View style={styles.bottomPadding} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 16,
  },
  card: {
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    backgroundColor: '#fff',
  },
  sectionTitle: {
    marginBottom: 12,
    fontWeight: '600',
    color: '#333',
  },
  activityGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: -4,
  },
  activityItem: {
    width: '25%',
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 4,
    borderRadius: 12,
    marginBottom: 4,
  },
  activityItemSelected: {
    backgroundColor: '#6200ee',
  },
  activityLabel: {
    fontSize: 11,
    color: '#666',
    textAlign: 'center',
  },
  activityLabelSelected: {
    color: '#fff',
    fontWeight: '600',
  },
  row: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 12,
  },
  halfInput: {
    flex: 1,
    backgroundColor: '#fff',
  },
  input: {
    marginBottom: 12,
    backgroundColor: '#fff',
  },
  toggleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 8,
  },
  toggleText: {
    color: '#6200ee',
  },
  imageButton: {
    marginTop: 4,
  },
  preview: {
    width: '100%',
    height: 150,
    marginTop: 12,
    borderRadius: 12,
  },
  submitButton: {
    marginTop: 8,
    borderRadius: 12,
  },
  submitButtonContent: {
    paddingVertical: 8,
  },
  bottomPadding: {
    height: 24,
  },
});
