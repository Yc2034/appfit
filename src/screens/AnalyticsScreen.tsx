import React, { useEffect, useMemo } from 'react';
import { View, StyleSheet, ScrollView, Dimensions } from 'react-native';
import { Text, Card } from 'react-native-paper';
import { BarChart } from 'react-native-chart-kit';
import { useWorkoutStore } from '../store/workoutStore';
import { format, subDays, startOfWeek, endOfWeek, eachDayOfInterval } from 'date-fns';

const screenWidth = Dimensions.get('window').width;

export default function AnalyticsScreen() {
  const { workouts, fetchWorkouts } = useWorkoutStore();

  useEffect(() => {
    fetchWorkouts();
  }, []);

  const chartConfig = {
    backgroundColor: '#ffffff',
    backgroundGradientFrom: '#ffffff',
    backgroundGradientTo: '#ffffff',
    decimalPlaces: 0,
    color: (opacity = 1) => `rgba(98, 0, 238, ${opacity})`,
    labelColor: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`,
    style: {
      borderRadius: 16,
    },
    propsForDots: {
      r: '6',
      strokeWidth: '2',
      stroke: '#6200ee',
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
      labels: sortedActivities.map(([name]) => name.substring(0, 8)),
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

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Text variant="headlineSmall" style={styles.title}>
          Statistics
        </Text>

        <View style={styles.statsGrid}>
          <Card style={styles.statCard}>
            <Card.Content>
              <Text variant="bodySmall" style={styles.statLabel}>
                Total Workouts
              </Text>
              <Text variant="headlineMedium" style={styles.statValue}>
                {stats.totalWorkouts}
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.statCard}>
            <Card.Content>
              <Text variant="bodySmall" style={styles.statLabel}>
                Total Calories
              </Text>
              <Text variant="headlineMedium" style={styles.statValue}>
                {stats.totalCalories}
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.statCard}>
            <Card.Content>
              <Text variant="bodySmall" style={styles.statLabel}>
                Avg Calories
              </Text>
              <Text variant="headlineMedium" style={styles.statValue}>
                {stats.avgCalories}
              </Text>
            </Card.Content>
          </Card>

          <Card style={styles.statCard}>
            <Card.Content>
              <Text variant="bodySmall" style={styles.statLabel}>
                Total Distance
              </Text>
              <Text variant="headlineMedium" style={styles.statValue}>
                {stats.totalDistance} km
              </Text>
            </Card.Content>
          </Card>
        </View>

        <Text variant="titleLarge" style={styles.sectionTitle}>
          Weekly Calories Burned
        </Text>
        <Card style={styles.chartCard}>
          <Card.Content>
            <BarChart
              data={weekData}
              width={screenWidth - 64}
              height={220}
              chartConfig={chartConfig}
              yAxisLabel=""
              yAxisSuffix=""
              fromZero
              showValuesOnTopOfBars
            />
          </Card.Content>
        </Card>

        <Text variant="titleLarge" style={styles.sectionTitle}>
          Workout Frequency by Type
        </Text>
        <Card style={styles.chartCard}>
          <Card.Content>
            <BarChart
              data={activityData}
              width={screenWidth - 64}
              height={220}
              chartConfig={chartConfig}
              yAxisLabel=""
              yAxisSuffix=""
              fromZero
              showValuesOnTopOfBars
            />
          </Card.Content>
        </Card>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f6f6f6',
  },
  content: {
    padding: 16,
  },
  title: {
    marginBottom: 16,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 24,
  },
  statCard: {
    width: '48%',
    marginBottom: 12,
  },
  statLabel: {
    color: '#666',
    marginBottom: 4,
  },
  statValue: {
    color: '#6200ee',
    fontWeight: 'bold',
  },
  sectionTitle: {
    marginTop: 8,
    marginBottom: 12,
  },
  chartCard: {
    marginBottom: 24,
  },
});
