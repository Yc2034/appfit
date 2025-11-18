import React, { useEffect } from 'react';
import { View, StyleSheet, FlatList } from 'react-native';
import { Card, Text, FAB, ActivityIndicator } from 'react-native-paper';
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
    <Card
      style={styles.card}
      onPress={() => navigation.navigate('ExerciseGallery', { classId: item.id, className: item.name })}
    >
      <Card.Content>
        <Text variant="titleLarge">{item.name}</Text>
        <Text variant="bodyMedium" style={styles.category}>
          {item.category}
        </Text>
        {item.description && (
          <Text variant="bodySmall" style={styles.description}>
            {item.description}
          </Text>
        )}
      </Card.Content>
    </Card>
  );

  if (loading && classes.length === 0) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" />
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
        ListEmptyComponent={
          <View style={styles.empty}>
            <Text variant="bodyLarge">No exercise classes yet</Text>
            <Text variant="bodySmall" style={styles.emptyHint}>
              Add exercise classes in your Supabase database
            </Text>
          </View>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f6f6f6',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  list: {
    padding: 16,
  },
  card: {
    marginBottom: 12,
  },
  category: {
    marginTop: 4,
    color: '#666',
  },
  description: {
    marginTop: 8,
    color: '#999',
  },
  empty: {
    alignItems: 'center',
    marginTop: 48,
  },
  emptyHint: {
    marginTop: 8,
    color: '#999',
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
  },
});
