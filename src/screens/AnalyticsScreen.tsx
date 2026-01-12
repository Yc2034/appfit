import React, { useEffect, useMemo } from 'react';
import { View, StyleSheet, ScrollView, Dimensions } from 'react-native';
import { Text, Surface } from 'react-native-paper';
import { BarChart } from 'react-native-chart-kit';
import { useWorkoutStore } from '../store/workoutStore';
import { format, startOfWeek, endOfWeek, eachDayOfInterval } from 'date-fns';

const screenWidth = Dimensions.get('window').width;

export default function AnalyticsScreen() {
  const { workouts, fetchWorkouts } = useWorkoutStore();

  useEffect(() => {
    fetchWorkouts();
  }, []);

  const chartConfig = {
    backgroundColor: '#fff',
    backgroundGradientFrom: '#fff',
    backgroundGradientTo: '#fff',
    decimalPlaces: 0,
    color: (opacity = 1) => `rgba(98, 0, 238, ${opacity})`,
    labelColor: (opacity = 1) => `rgba(102, 102, 102, ${opacity})`,
    barPercentage: 0.6,
    propsForBackgroundLines: {
      strokeDasharray: '',
      stroke: '#f0f0f0',
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

  const StatCard = ({ label, value, unit, icon }: { label: string; value: string | number; unit?: string; icon?: string }) => (
    <Surface style={styles.statCard} elevation={1}>
      <Text variant="bodySmall" style={styles.statLabel}>{label}</Text>
      <View style={styles.statValueRow}>
        <Text variant="headlineMedium" style={styles.statValue}>{value}</Text>
        {unit && <Text variant="bodySmall" style={styles.statUnit}>{unit}</Text>}
      </View>
    </Surface>
  );

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Overview Stats */}
      <View style={styles.statsGrid}>
        <StatCard label="Workouts" value={stats.totalWorkouts} />
        <StatCard label="Calories" value={stats.totalCalories.toLocaleString()} unit="kcal" />
        <StatCard label="Avg/Session" value={stats.avgCalories} unit="kcal" />
        <StatCard label="Distance" value={stats.totalDistance} unit="km" />
      </View>

      {/* Weekly Chart */}
      <Surface style={styles.chartCard} elevation={1}>
        <Text variant="titleMedium" style={styles.chartTitle}>
          This Week
        </Text>
        <Text variant="bodySmall" style={styles.chartSubtitle}>
          Calories burned per day
        </Text>
        <BarChart
          data={weekData}
          width={screenWidth - 64}
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
        <Surface style={styles.chartCard} elevation={1}>
          <Text variant="titleMedium" style={styles.chartTitle}>
            Top Activities
          </Text>
          <Text variant="bodySmall" style={styles.chartSubtitle}>
            Workout frequency by type
          </Text>
          <BarChart
            data={activityData}
            width={screenWidth - 64}
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
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 16,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: -6,
    marginBottom: 8,
  },
  statCard: {
    width: '50%',
    paddingHorizontal: 6,
    marginBottom: 12,
  },
  statCardInner: {
    borderRadius: 16,
    padding: 16,
    backgroundColor: '#fff',
  },
  statLabel: {
    color: '#999',
    marginBottom: 4,
    paddingHorizontal: 16,
    paddingTop: 16,
  },
  statValueRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  statValue: {
    color: '#6200ee',
    fontWeight: '700',
  },
  statUnit: {
    color: '#999',
    marginLeft: 4,
  },
  chartCard: {
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
    backgroundColor: '#fff',
  },
  chartTitle: {
    fontWeight: '600',
    color: '#333',
    marginBottom: 4,
  },
  chartSubtitle: {
    color: '#999',
    marginBottom: 16,
  },
  chart: {
    marginLeft: -16,
    borderRadius: 8,
  },
  bottomPadding: {
    height: 24,
  },
});
