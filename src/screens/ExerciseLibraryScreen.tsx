import React, { useEffect } from 'react';
import { View, StyleSheet, FlatList } from 'react-native';
import { Text, ActivityIndicator, Surface, Chip, useTheme } from 'react-native-paper';
import { useExerciseStore } from '../store/exerciseStore';
import { ExerciseClass } from '../types/exercise.types';
import ScreenLayout from '../components/ScreenLayout';
import { SPACING } from '../constants/theme';

interface Props {
  navigation: any;
}

export default function ExerciseLibraryScreen({ navigation }: Props) {
  const theme = useTheme();
  const { classes, loading, fetchClasses } = useExerciseStore();

  useEffect(() => {
    fetchClasses();
  }, []);

  const renderClassItem = ({ item }: { item: ExerciseClass }) => (
    <Surface
      style={styles.card}
      elevation={0}
      onTouchEnd={() => navigation.navigate('ExerciseGallery', { classId: item.id, className: item.name })}
    >
      <View style={styles.cardHeader}>
        <Text variant="titleMedium" style={styles.cardTitle}>{item.name}</Text>
        <Chip compact style={[styles.categoryChip, { backgroundColor: theme.colors.primary + '15' }]} textStyle={{ color: theme.colors.primary }}>
          {item.category}
        </Chip>
      </View>
      {item.description && (
        <Text variant="bodySmall" style={styles.description} numberOfLines={2}>
          {item.description}
        </Text>
      )}
    </Surface>
  );

  if (loading && classes.length === 0) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }

  return (
    <ScreenLayout>
      <FlatList
        data={classes}
        renderItem={renderClassItem}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <Surface style={styles.emptyCard} elevation={0}>
            <Text variant="titleMedium" style={styles.emptyTitle}>No Exercises Yet</Text>
            <Text variant="bodySmall" style={styles.emptyHint}>
              Add exercise classes in your database
            </Text>
          </Surface>
        }
      />
    </ScreenLayout>
  );
}

const styles = StyleSheet.create({
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  list: {
    paddingBottom: SPACING.xl,
  },
  card: {
    borderRadius: 16,
    padding: SPACING.md,
    marginBottom: SPACING.md,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#F3F4F6',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  cardTitle: {
    fontWeight: '600',
    opacity: 0.9,
    flex: 1,
  },
  categoryChip: {
    height: 24,
  },
  description: {
    marginTop: SPACING.sm,
    opacity: 0.7,
    lineHeight: 18,
  },
  emptyCard: {
    borderRadius: 16,
    padding: SPACING.xl,
    alignItems: 'center',
    backgroundColor: '#fff',
    marginTop: SPACING.lg,
    borderWidth: 1,
    borderColor: '#F3F4F6',
    borderStyle: 'dashed',
  },
  emptyTitle: {
    marginBottom: 8,
    opacity: 0.8,
  },
  emptyHint: {
    opacity: 0.5,
    textAlign: 'center',
  },
});
