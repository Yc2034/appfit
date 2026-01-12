import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, Image, FlatList } from 'react-native';
import { Calendar } from 'react-native-calendars';
import { Text, Chip, Surface, IconButton, useTheme } from 'react-native-paper';
import { useWorkoutStore } from '../store/workoutStore';
import { WorkoutLog } from '../types/workout.types';
import { formatTime, formatDistance, formatCalories, formatHeartRate } from '../utils/formatters';
import { format, parseISO, isToday, isYesterday } from 'date-fns';
import ScreenLayout from '../components/ScreenLayout';
import { SPACING } from '../constants/theme';

export default function CalendarScreen() {
  const theme = useTheme();
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
      marked[date] = { marked: true, dotColor: theme.colors.primary };
    });

    marked[selectedDate] = {
      ...marked[selectedDate],
      selected: true,
      selectedColor: theme.colors.primary,
    };

    setMarkedDates(marked);
  }, [workouts, selectedDate, theme.colors.primary]);

  const selectedWorkouts = workouts.filter((w) => w.date.startsWith(selectedDate));

  const getDateLabel = (dateStr: string) => {
    const date = parseISO(dateStr);
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return format(date, 'MMM d, yyyy');
  };

  const renderWorkoutCard = ({ item: workout }: { item: WorkoutLog }) => (
    <Surface style={styles.workoutCard} elevation={0}>
      <View style={styles.cardHeader}>
        <View style={styles.activityInfo}>
          <Text variant="titleMedium" style={styles.activityType}>
            {workout.activity_type}
          </Text>
          <Chip compact style={[styles.calorieChip, { backgroundColor: theme.colors.secondary + '15' }]} textStyle={{ color: theme.colors.secondary }}>
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
    <ScreenLayout useSafeArea={true} scrollable={false} contentContainerStyle={{ paddingHorizontal: 0, paddingTop: 0 }}>
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
              iconColor={theme.colors.primary}
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
                todayTextColor: theme.colors.primary,
                selectedDayBackgroundColor: theme.colors.primary,
                dotColor: theme.colors.primary,
                arrowColor: theme.colors.primary,
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
                    style={[
                      styles.dayItem,
                      isSelected && { backgroundColor: theme.colors.primary }
                    ]}
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
                    {hasWorkout && (
                      <View style={[
                        styles.dot,
                        { backgroundColor: isSelected ? theme.colors.onPrimary : theme.colors.primary }
                      ]} />
                    )}
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
            <Surface style={styles.emptyCard} elevation={0}>
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
    </ScreenLayout>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  calendarContainer: {
    backgroundColor: '#fff',
    borderBottomLeftRadius: 24,
    borderBottomRightRadius: 24,
    paddingBottom: SPACING.md,
    zIndex: 1,
  },
  calendarHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: SPACING.md,
    paddingTop: SPACING.sm,
  },
  dateLabel: {
    fontWeight: '600',
    opacity: 0.9,
  },
  calendar: {
    marginHorizontal: SPACING.sm,
  },
  weekStrip: {
    paddingHorizontal: SPACING.md,
    marginTop: SPACING.sm,
  },
  dayItem: {
    alignItems: 'center',
    paddingVertical: SPACING.sm,
    paddingHorizontal: 14,
    marginHorizontal: 4,
    borderRadius: 16,
    backgroundColor: '#F3F4F6', // Surface variant
  },
  dayName: {
    opacity: 0.7,
    fontSize: 11,
  },
  dayNumber: {
    fontWeight: '600',
  },
  dayTextSelected: {
    color: '#fff',
    opacity: 1,
  },
  dot: {
    width: 4,
    height: 4,
    borderRadius: 2,
    marginTop: 4,
  },
  listContainer: {
    flex: 1,
    padding: SPACING.md,
  },
  sectionTitle: {
    marginBottom: SPACING.md,
    fontWeight: '600',
    opacity: 0.8,
  },
  listContent: {
    paddingBottom: SPACING.xl,
  },
  workoutCard: {
    borderRadius: 16,
    padding: SPACING.md,
    marginBottom: SPACING.md,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#F3F4F6',
  },
  cardHeader: {
    marginBottom: SPACING.md,
  },
  activityInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  activityType: {
    fontWeight: '600',
    opacity: 0.9,
  },
  calorieChip: {
    height: 24,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    gap: SPACING.lg,
  },
  statItem: {
    alignItems: 'flex-start',
  },
  statLabel: {
    opacity: 0.6,
    marginBottom: 2,
  },
  statValue: {
    fontWeight: '500',
  },
  notes: {
    marginTop: SPACING.md,
    fontStyle: 'italic',
    opacity: 0.7,
    paddingTop: SPACING.md,
    borderTopWidth: 1,
    borderTopColor: '#F3F4F6',
  },
  screenshot: {
    width: '100%',
    height: 150,
    marginTop: SPACING.md,
    borderRadius: 12,
  },
  emptyCard: {
    borderRadius: 16,
    padding: SPACING.xl,
    alignItems: 'center',
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#F3F4F6',
    borderStyle: 'dashed',
  },
  emptyText: {
    opacity: 0.7,
    marginBottom: 4,
  },
  emptyHint: {
    opacity: 0.5,
  },
});
