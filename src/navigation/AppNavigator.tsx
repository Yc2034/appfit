import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { MaterialCommunityIcons } from '@expo/vector-icons';

import WorkoutLogScreen from '../screens/WorkoutLogScreen';
import CalendarScreen from '../screens/CalendarScreen';
import AnalyticsScreen from '../screens/AnalyticsScreen';
import ExerciseLibraryScreen from '../screens/ExerciseLibraryScreen';
import ExerciseGalleryScreen from '../screens/ExerciseGalleryScreen';

const Tab = createBottomTabNavigator();
const Stack = createNativeStackNavigator();

function ExerciseStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen
        name="ExerciseLibrary"
        component={ExerciseLibraryScreen}
        options={{ title: 'Exercise Library' }}
      />
      <Stack.Screen
        name="ExerciseGallery"
        component={ExerciseGalleryScreen}
        options={({ route }: any) => ({ title: route.params?.className || 'Gallery' })}
      />
    </Stack.Navigator>
  );
}

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Tab.Navigator
        screenOptions={{
          tabBarActiveTintColor: '#6200ee',
          tabBarInactiveTintColor: '#999',
        }}
      >
        <Tab.Screen
          name="Log"
          component={WorkoutLogScreen}
          options={{
            title: 'Log Workout',
            tabBarIcon: ({ color, size }) => (
              <MaterialCommunityIcons name="pencil-plus" size={size} color={color} />
            ),
          }}
        />
        <Tab.Screen
          name="Calendar"
          component={CalendarScreen}
          options={{
            tabBarIcon: ({ color, size }) => (
              <MaterialCommunityIcons name="calendar" size={size} color={color} />
            ),
          }}
        />
        <Tab.Screen
          name="Analytics"
          component={AnalyticsScreen}
          options={{
            tabBarIcon: ({ color, size }) => (
              <MaterialCommunityIcons name="chart-bar" size={size} color={color} />
            ),
          }}
        />
        <Tab.Screen
          name="Exercises"
          component={ExerciseStack}
          options={{
            headerShown: false,
            title: 'Exercises',
            tabBarIcon: ({ color, size }) => (
              <MaterialCommunityIcons name="dumbbell" size={size} color={color} />
            ),
          }}
        />
      </Tab.Navigator>
    </NavigationContainer>
  );
}
