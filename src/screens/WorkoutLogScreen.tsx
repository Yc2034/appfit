import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, Image, Alert } from 'react-native';
import { TextInput, Button, Menu, Text } from 'react-native-paper';
import * as ImagePicker from 'expo-image-picker';
import { useWorkoutStore } from '../store/workoutStore';
import { WorkoutFormData } from '../types/workout.types';
import { ACTIVITY_TYPES } from '../constants/theme';
import { validateWorkoutForm } from '../utils/validators';
import { format } from 'date-fns';

interface Props {
  navigation: any;
}

export default function WorkoutLogScreen({ navigation }: Props) {
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
  const [menuVisible, setMenuVisible] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleImagePick = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
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
    } catch (error) {
      Alert.alert('Error', 'Failed to log workout. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.form}>
        <TextInput
          label="Date *"
          value={formData.date}
          onChangeText={(text) => setFormData({ ...formData, date: text })}
          mode="outlined"
          style={styles.input}
        />

        <Menu
          visible={menuVisible}
          onDismiss={() => setMenuVisible(false)}
          anchor={
            <Button
              mode="outlined"
              onPress={() => setMenuVisible(true)}
              style={styles.input}
              contentStyle={styles.menuButton}
            >
              {formData.activity_type || 'Select Activity Type *'}
            </Button>
          }
        >
          {ACTIVITY_TYPES.map((type) => (
            <Menu.Item
              key={type}
              onPress={() => {
                setFormData({ ...formData, activity_type: type });
                setMenuVisible(false);
              }}
              title={type}
            />
          ))}
        </Menu>

        <TextInput
          label="Calories Burned *"
          value={formData.calories}
          onChangeText={(text) => setFormData({ ...formData, calories: text })}
          keyboardType="numeric"
          mode="outlined"
          style={styles.input}
        />

        <TextInput
          label="Duration (minutes) *"
          value={formData.duration}
          onChangeText={(text) => setFormData({ ...formData, duration: text })}
          keyboardType="numeric"
          mode="outlined"
          style={styles.input}
        />

        <TextInput
          label="Distance (km)"
          value={formData.distance}
          onChangeText={(text) => setFormData({ ...formData, distance: text })}
          keyboardType="decimal-pad"
          mode="outlined"
          style={styles.input}
        />

        <TextInput
          label="Average Heart Rate (bpm)"
          value={formData.heart_rate}
          onChangeText={(text) => setFormData({ ...formData, heart_rate: text })}
          keyboardType="numeric"
          mode="outlined"
          style={styles.input}
        />

        <TextInput
          label="Notes"
          value={formData.notes}
          onChangeText={(text) => setFormData({ ...formData, notes: text })}
          mode="outlined"
          multiline
          numberOfLines={3}
          style={styles.input}
        />

        <Button
          mode="outlined"
          icon="camera"
          onPress={handleImagePick}
          style={styles.input}
        >
          {formData.watch_screenshot ? 'Change Screenshot' : 'Add Watch Screenshot'}
        </Button>

        {formData.watch_screenshot && (
          <Image
            source={{ uri: formData.watch_screenshot }}
            style={styles.preview}
            resizeMode="contain"
          />
        )}

        <Button
          mode="contained"
          onPress={handleSubmit}
          loading={loading}
          disabled={loading}
          style={styles.submitButton}
        >
          Log Workout
        </Button>

        <Text variant="bodySmall" style={styles.hint}>
          * Required fields
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f6f6f6',
  },
  form: {
    padding: 16,
  },
  input: {
    marginBottom: 12,
  },
  menuButton: {
    justifyContent: 'flex-start',
  },
  preview: {
    width: '100%',
    height: 200,
    marginBottom: 12,
    borderRadius: 8,
  },
  submitButton: {
    marginTop: 8,
    marginBottom: 8,
  },
  hint: {
    color: '#999',
    textAlign: 'center',
  },
});
