import React, { useEffect } from 'react';
import { View, StyleSheet, FlatList } from 'react-native';
import { Text, ActivityIndicator, Surface, Chip } from 'react-native-paper';
import { useExerciseStore } from '../store/exerciseStore';
import { ExerciseClass } from '../types/exercise.types';

interface Props {
  navigation: any;
}

export default function ExerciseLibraryScreen({ navigation }: Props) {
  const { classes, loading, fetchClasses } = useExerciseStore();

  useEffect(() => {
    fetchClasses();
  }, []);

  const renderClassItem = ({ item }: { item: ExerciseClass }) => (
    <Surface
      style={styles.card}
      elevation={1}
      onTouchEnd={() => navigation.navigate('ExerciseGallery', { classId: item.id, className: item.name })}
    >
      <View style={styles.cardHeader}>
        <Text variant="titleMedium" style={styles.cardTitle}>{item.name}</Text>
        <Chip compact style={styles.categoryChip} textStyle={styles.categoryText}>
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
        <ActivityIndicator size="large" color="#6200ee" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={classes}
        renderItem={renderClassItem}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <Surface style={styles.emptyCard} elevation={1}>
            <Text variant="titleMedium" style={styles.emptyTitle}>No Exercises Yet</Text>
            <Text variant="bodySmall" style={styles.emptyHint}>
              Add exercise classes in your database
            </Text>
          </Surface>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  list: {
    padding: 16,
  },
  card: {
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    backgroundColor: '#fff',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  cardTitle: {
    fontWeight: '600',
    color: '#333',
    flex: 1,
  },
  categoryChip: {
    backgroundColor: '#6200ee15',
  },
  categoryText: {
    color: '#6200ee',
    fontSize: 11,
  },
  description: {
    marginTop: 8,
    color: '#666',
    lineHeight: 18,
  },
  emptyCard: {
    borderRadius: 16,
    padding: 32,
    alignItems: 'center',
    backgroundColor: '#fff',
    marginTop: 24,
  },
  emptyTitle: {
    color: '#333',
    marginBottom: 8,
  },
  emptyHint: {
    color: '#999',
    textAlign: 'center',
  },
});
