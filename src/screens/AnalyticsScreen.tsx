import React, { useEffect, useMemo } from 'react';
import { View, StyleSheet, ScrollView, Dimensions } from 'react-native';
import { Text, Surface, useTheme } from 'react-native-paper';
import { BarChart } from 'react-native-chart-kit';
import { useWorkoutStore } from '../store/workoutStore';
import { format, startOfWeek, endOfWeek, eachDayOfInterval } from 'date-fns';
import ScreenLayout from '../components/ScreenLayout';
import { SPACING } from '../constants/theme';

const screenWidth = Dimensions.get('window').width;

export default function AnalyticsScreen() {
  const theme = useTheme();
  const { workouts, fetchWorkouts } = useWorkoutStore();

  useEffect(() => {
    fetchWorkouts();
  }, []);

  const chartConfig = {
    backgroundColor: '#fff',
    backgroundGradientFrom: '#fff',
    backgroundGradientTo: '#fff',
    decimalPlaces: 0,
    color: (opacity = 1) => theme.colors.primary,
    labelColor: (opacity = 1) => theme.colors.onSurfaceVariant,
    barPercentage: 0.6,
    propsForBackgroundLines: {
      strokeDasharray: '',
      stroke: theme.colors.outline,
      strokeOpacity: 0.2,
    },
  };

  const weekData = useMemo(() => {
    const today = new Date();
    const weekStart = startOfWeek(today, { weekStartsOn: 1 });
    const weekEnd = endOfWeek(today, { weekStartsOn: 1 });
    const daysInWeek = eachDayOfInterval({ start: weekStart, end: weekEnd });

    const caloriesByDay = daysInWeek.map((day) => {
      const dayStr = format(day, 'yyyy-MM-dd');
      const dayWorkouts = workouts.filter((w) => w.date.startsWith(dayStr));
      return dayWorkouts.reduce((sum, w) => sum + w.calories, 0);
    });

    return {
      labels: daysInWeek.map((d) => format(d, 'EEE')),
      datasets: [{ data: caloriesByDay.length > 0 ? caloriesByDay : [0] }],
    };
  }, [workouts]);

  const activityData = useMemo(() => {
    const activityCounts: { [key: string]: number } = {};
    workouts.forEach((workout) => {
      activityCounts[workout.activity_type] = (activityCounts[workout.activity_type] || 0) + 1;
    });

    const sortedActivities = Object.entries(activityCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5);

    return {
      labels: sortedActivities.map(([name]) => name.substring(0, 6)),
      datasets: [{ data: sortedActivities.length > 0 ? sortedActivities.map(([, count]) => count) : [0] }],
    };
  }, [workouts]);

  const stats = useMemo(() => {
    const totalWorkouts = workouts.length;
    const totalCalories = workouts.reduce((sum, w) => sum + w.calories, 0);
    const totalDuration = workouts.reduce((sum, w) => sum + w.duration, 0);
    const totalDistance = workouts.reduce((sum, w) => sum + (w.distance || 0), 0);

    return {
      totalWorkouts,
      totalCalories,
      avgCalories: totalWorkouts > 0 ? Math.round(totalCalories / totalWorkouts) : 0,
      totalDuration,
      totalDistance: totalDistance.toFixed(1),
    };
  }, [workouts]);

  const StatCard = ({ label, value, unit }: { label: string; value: string | number; unit?: string }) => (
    <View style={styles.statCardWrapper}>
      <Surface style={styles.statCardInner} elevation={0}>
        <Text variant="bodySmall" style={styles.statLabel}>{label}</Text>
        <View style={styles.statValueRow}>
          <Text variant="headlineMedium" style={[styles.statValue, { color: theme.colors.primary }]}>{value}</Text>
          {unit && <Text variant="bodySmall" style={styles.statUnit}>{unit}</Text>}
        </View>
      </Surface>
    </View>
  );

  return (
    <ScreenLayout scrollable>
      {/* Overview Stats */}
      <View style={styles.statsGrid}>
        <StatCard label="Workouts" value={stats.totalWorkouts} />
        <StatCard label="Calories" value={stats.totalCalories.toLocaleString()} unit="kcal" />
        <StatCard label="Avg/Session" value={stats.avgCalories} unit="kcal" />
        <StatCard label="Distance" value={stats.totalDistance} unit="km" />
      </View>

      {/* Weekly Chart */}
      <Surface style={styles.chartCard} elevation={0}>
        <Text variant="titleMedium" style={styles.chartTitle}>
          This Week
        </Text>
        <Text variant="bodySmall" style={styles.chartSubtitle}>
          Calories burned per day
        </Text>
        <BarChart
          data={weekData}
          width={screenWidth - (SPACING.md * 2) - (SPACING.md * 2)} // Screen padding - Card padding
          height={180}
          chartConfig={chartConfig}
          yAxisLabel=""
          yAxisSuffix=""
          fromZero
          showValuesOnTopOfBars
          withInnerLines={false}
          style={styles.chart}
        />
      </Surface>

      {/* Activity Distribution */}
      {activityData.labels.length > 0 && (
        <Surface style={styles.chartCard} elevation={0}>
          <Text variant="titleMedium" style={styles.chartTitle}>
            Top Activities
          </Text>
          <Text variant="bodySmall" style={styles.chartSubtitle}>
            Workout frequency by type
          </Text>
          <BarChart
            data={activityData}
            width={screenWidth - (SPACING.md * 2) - (SPACING.md * 2)}
            height={180}
            chartConfig={chartConfig}
            yAxisLabel=""
            yAxisSuffix=""
            fromZero
            showValuesOnTopOfBars
            withInnerLines={false}
            style={styles.chart}
          />
        </Surface>
      )}

      <View style={styles.bottomPadding} />
    </ScreenLayout>
  );
}

const styles = StyleSheet.create({
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: -6,
    marginBottom: SPACING.sm,
  },
  statCardWrapper: {
    width: '50%',
    paddingHorizontal: 6,
    marginBottom: SPACING.md,
  },
  statCardInner: {
    borderRadius: 16,
    padding: SPACING.md,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#F3F4F6',
  },
  statLabel: {
    opacity: 0.6,
    marginBottom: 4,
  },
  statValueRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
  },
  statValue: {
    fontWeight: '700',
  },
  statUnit: {
    opacity: 0.5,
    marginLeft: 4,
  },
  chartCard: {
    borderRadius: 16,
    padding: SPACING.md,
    marginBottom: SPACING.md,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#F3F4F6',
  },
  chartTitle: {
    fontWeight: '600',
    opacity: 0.9,
    marginBottom: 4,
  },
  chartSubtitle: {
    opacity: 0.6,
    marginBottom: SPACING.md,
  },
  chart: {
    marginLeft: -16, // Adjust for left padding of chart lib
    borderRadius: 8,
  },
  bottomPadding: {
    height: SPACING.xl,
  },
});
