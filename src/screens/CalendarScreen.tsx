import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, Image, FlatList } from 'react-native';
import { Calendar } from 'react-native-calendars';
import { Card, Text, Chip, Surface, IconButton } from 'react-native-paper';
import { useWorkoutStore } from '../store/workoutStore';
import { WorkoutLog } from '../types/workout.types';
import { formatTime, formatDistance, formatCalories, formatHeartRate } from '../utils/formatters';
import { format, parseISO, isToday, isYesterday } from 'date-fns';

export default function CalendarScreen() {
  const { workouts, fetchWorkouts } = useWorkoutStore();
  const [selectedDate, setSelectedDate] = useState(format(new Date(), 'yyyy-MM-dd'));
  const [markedDates, setMarkedDates] = useState<any>({});
  const [calendarExpanded, setCalendarExpanded] = useState(false);

  useEffect(() => {
    fetchWorkouts();
  }, []);

  useEffect(() => {
    const marked: any = {};
    workouts.forEach((workout) => {
      const date = workout.date.split('T')[0];
      marked[date] = { marked: true, dotColor: '#6200ee' };
    });

    marked[selectedDate] = {
      ...marked[selectedDate],
      selected: true,
      selectedColor: '#6200ee',
    };

    setMarkedDates(marked);
  }, [workouts, selectedDate]);

  const selectedWorkouts = workouts.filter((w) => w.date.startsWith(selectedDate));

  const getDateLabel = (dateStr: string) => {
    const date = parseISO(dateStr);
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return format(date, 'MMM d, yyyy');
  };

  const renderWorkoutCard = ({ item: workout }: { item: WorkoutLog }) => (
    <Surface style={styles.workoutCard} elevation={1}>
      <View style={styles.cardHeader}>
        <View style={styles.activityInfo}>
          <Text variant="titleMedium" style={styles.activityType}>
            {workout.activity_type}
          </Text>
          <Chip compact style={styles.calorieChip} textStyle={styles.calorieText}>
            {formatCalories(workout.calories)}
          </Chip>
        </View>
      </View>

      <View style={styles.statsRow}>
        <View style={styles.statItem}>
          <Text variant="bodySmall" style={styles.statLabel}>Duration</Text>
          <Text variant="titleSmall" style={styles.statValue}>
            {formatTime(workout.duration)}
          </Text>
        </View>

        {workout.distance && (
          <View style={styles.statItem}>
            <Text variant="bodySmall" style={styles.statLabel}>Distance</Text>
            <Text variant="titleSmall" style={styles.statValue}>
              {formatDistance(workout.distance)}
            </Text>
          </View>
        )}

        {workout.heart_rate && (
          <View style={styles.statItem}>
            <Text variant="bodySmall" style={styles.statLabel}>Heart Rate</Text>
            <Text variant="titleSmall" style={styles.statValue}>
              {formatHeartRate(workout.heart_rate)}
            </Text>
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
    </Surface>
  );

  return (
    <View style={styles.container}>
      {/* Compact Calendar Header */}
      <Surface style={styles.calendarContainer} elevation={1}>
        <View style={styles.calendarHeader}>
          <Text variant="titleMedium" style={styles.dateLabel}>
            {getDateLabel(selectedDate)}
          </Text>
          <IconButton
            icon={calendarExpanded ? 'chevron-up' : 'calendar'}
            size={20}
            onPress={() => setCalendarExpanded(!calendarExpanded)}
            iconColor="#6200ee"
          />
        </View>

        {calendarExpanded && (
          <Calendar
            markedDates={markedDates}
            onDayPress={(day) => {
              setSelectedDate(day.dateString);
              setCalendarExpanded(false);
            }}
            theme={{
              todayTextColor: '#6200ee',
              selectedDayBackgroundColor: '#6200ee',
              dotColor: '#6200ee',
              arrowColor: '#6200ee',
              textDayFontSize: 14,
              textMonthFontSize: 16,
              textDayHeaderFontSize: 12,
            }}
            style={styles.calendar}
          />
        )}

        {!calendarExpanded && (
          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.weekStrip}>
            {Array.from({ length: 7 }, (_, i) => {
              const date = new Date();
              date.setDate(date.getDate() - 3 + i);
              const dateStr = format(date, 'yyyy-MM-dd');
              const isSelected = dateStr === selectedDate;
              const hasWorkout = workouts.some((w) => w.date.startsWith(dateStr));

              return (
                <Surface
                  key={dateStr}
                  style={[styles.dayItem, isSelected && styles.dayItemSelected]}
                  elevation={isSelected ? 2 : 0}
                  onTouchEnd={() => setSelectedDate(dateStr)}
                >
                  <Text
                    variant="bodySmall"
                    style={[styles.dayName, isSelected && styles.dayTextSelected]}
                  >
                    {format(date, 'EEE')}
                  </Text>
                  <Text
                    variant="titleMedium"
                    style={[styles.dayNumber, isSelected && styles.dayTextSelected]}
                  >
                    {format(date, 'd')}
                  </Text>
                  {hasWorkout && <View style={[styles.dot, isSelected && styles.dotSelected]} />}
                </Surface>
              );
            })}
          </ScrollView>
        )}
      </Surface>

      {/* Workout List */}
      <View style={styles.listContainer}>
        <Text variant="titleMedium" style={styles.sectionTitle}>
          {selectedWorkouts.length > 0
            ? `${selectedWorkouts.length} Workout${selectedWorkouts.length > 1 ? 's' : ''}`
            : 'No Workouts'}
        </Text>

        {selectedWorkouts.length > 0 ? (
          <FlatList
            data={selectedWorkouts}
            renderItem={renderWorkoutCard}
            keyExtractor={(item) => item.id}
            showsVerticalScrollIndicator={false}
            contentContainerStyle={styles.listContent}
          />
        ) : (
          <Surface style={styles.emptyCard} elevation={1}>
            <Text variant="bodyMedium" style={styles.emptyText}>
              No workouts on this day
            </Text>
            <Text variant="bodySmall" style={styles.emptyHint}>
              Tap the Log tab to add one
            </Text>
          </Surface>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  calendarContainer: {
    backgroundColor: '#fff',
    borderBottomLeftRadius: 20,
    borderBottomRightRadius: 20,
    paddingBottom: 12,
  },
  calendarHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 8,
  },
  dateLabel: {
    fontWeight: '600',
    color: '#333',
  },
  calendar: {
    marginHorizontal: 8,
  },
  weekStrip: {
    paddingHorizontal: 12,
    marginTop: 8,
  },
  dayItem: {
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 14,
    marginHorizontal: 4,
    borderRadius: 12,
    backgroundColor: '#f5f5f5',
  },
  dayItemSelected: {
    backgroundColor: '#6200ee',
  },
  dayName: {
    color: '#666',
    fontSize: 11,
  },
  dayNumber: {
    color: '#333',
    fontWeight: '600',
  },
  dayTextSelected: {
    color: '#fff',
  },
  dot: {
    width: 5,
    height: 5,
    borderRadius: 2.5,
    backgroundColor: '#6200ee',
    marginTop: 4,
  },
  dotSelected: {
    backgroundColor: '#fff',
  },
  listContainer: {
    flex: 1,
    padding: 16,
  },
  sectionTitle: {
    marginBottom: 12,
    fontWeight: '600',
    color: '#333',
  },
  listContent: {
    paddingBottom: 16,
  },
  workoutCard: {
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    backgroundColor: '#fff',
  },
  cardHeader: {
    marginBottom: 12,
  },
  activityInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  activityType: {
    fontWeight: '600',
    color: '#333',
  },
  calorieChip: {
    backgroundColor: '#6200ee15',
  },
  calorieText: {
    color: '#6200ee',
    fontSize: 12,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    gap: 24,
  },
  statItem: {
    alignItems: 'flex-start',
  },
  statLabel: {
    color: '#999',
    marginBottom: 2,
  },
  statValue: {
    color: '#333',
    fontWeight: '500',
  },
  notes: {
    marginTop: 12,
    fontStyle: 'italic',
    color: '#666',
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
  },
  screenshot: {
    width: '100%',
    height: 150,
    marginTop: 12,
    borderRadius: 12,
  },
  emptyCard: {
    borderRadius: 16,
    padding: 32,
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  emptyText: {
    color: '#666',
    marginBottom: 4,
  },
  emptyHint: {
    color: '#999',
  },
});
