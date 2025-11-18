import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, Image } from 'react-native';
import { Calendar } from 'react-native-calendars';
import { Card, Text, Chip } from 'react-native-paper';
import { useWorkoutStore } from '../store/workoutStore';
import { WorkoutLog } from '../types/workout.types';
import { formatTime, formatDistance, formatCalories, formatHeartRate } from '../utils/formatters';
import { format } from 'date-fns';

export default function CalendarScreen() {
  const { workouts, fetchWorkouts } = useWorkoutStore();
  const [selectedDate, setSelectedDate] = useState(format(new Date(), 'yyyy-MM-dd'));
  const [markedDates, setMarkedDates] = useState<any>({});

  useEffect(() => {
    fetchWorkouts();
  }, []);

  useEffect(() => {
    // Create marked dates object for calendar
    const marked: any = {};
    workouts.forEach((workout) => {
      const date = workout.date.split('T')[0];
      marked[date] = { marked: true, dotColor: '#6200ee' };
    });

    // Highlight selected date
    marked[selectedDate] = {
      ...marked[selectedDate],
      selected: true,
      selectedColor: '#6200ee',
    };

    setMarkedDates(marked);
  }, [workouts, selectedDate]);

  const selectedWorkouts = workouts.filter((w) => w.date.startsWith(selectedDate));

  const renderWorkoutCard = (workout: WorkoutLog) => (
    <Card key={workout.id} style={styles.card}>
      <Card.Content>
        <View style={styles.header}>
          <Text variant="titleMedium">{workout.activity_type}</Text>
          <Chip>{formatCalories(workout.calories)}</Chip>
        </View>

        <View style={styles.stats}>
          <View style={styles.stat}>
            <Text variant="bodySmall" style={styles.label}>
              Duration
            </Text>
            <Text variant="bodyMedium">{formatTime(workout.duration)}</Text>
          </View>

          {workout.distance && (
            <View style={styles.stat}>
              <Text variant="bodySmall" style={styles.label}>
                Distance
              </Text>
              <Text variant="bodyMedium">{formatDistance(workout.distance)}</Text>
            </View>
          )}

          {workout.heart_rate && (
            <View style={styles.stat}>
              <Text variant="bodySmall" style={styles.label}>
                Heart Rate
              </Text>
              <Text variant="bodyMedium">{formatHeartRate(workout.heart_rate)}</Text>
            </View>
          )}
        </View>

        {workout.notes && (
          <Text variant="bodySmall" style={styles.notes}>
            {workout.notes}
          </Text>
        )}

        {workout.watch_screenshot_url && (
          <Image
            source={{ uri: workout.watch_screenshot_url }}
            style={styles.screenshot}
            resizeMode="contain"
          />
        )}
      </Card.Content>
    </Card>
  );

  return (
    <View style={styles.container}>
      <Calendar
        markedDates={markedDates}
        onDayPress={(day) => setSelectedDate(day.dateString)}
        theme={{
          todayTextColor: '#6200ee',
          selectedDayBackgroundColor: '#6200ee',
          dotColor: '#6200ee',
        }}
      />

      <ScrollView style={styles.workouts}>
        <Text variant="titleMedium" style={styles.sectionTitle}>
          Workouts on {selectedDate}
        </Text>

        {selectedWorkouts.length > 0 ? (
          selectedWorkouts.map(renderWorkoutCard)
        ) : (
          <View style={styles.empty}>
            <Text variant="bodyMedium" style={styles.emptyText}>
              No workouts logged for this date
            </Text>
          </View>
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f6f6f6',
  },
  workouts: {
    flex: 1,
    padding: 16,
  },
  sectionTitle: {
    marginBottom: 12,
  },
  card: {
    marginBottom: 12,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  stats: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 8,
  },
  stat: {
    alignItems: 'center',
  },
  label: {
    color: '#666',
    marginBottom: 4,
  },
  notes: {
    marginTop: 8,
    fontStyle: 'italic',
    color: '#666',
  },
  screenshot: {
    width: '100%',
    height: 200,
    marginTop: 12,
    borderRadius: 8,
  },
  empty: {
    alignItems: 'center',
    marginTop: 24,
  },
  emptyText: {
    color: '#999',
  },
});
