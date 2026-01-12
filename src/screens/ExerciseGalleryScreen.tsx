import React, { useEffect, useState } from 'react';
import { View, StyleSheet, FlatList, Image, Dimensions, Pressable, Modal } from 'react-native';
import { Text, ActivityIndicator, IconButton, Surface, useTheme } from 'react-native-paper';
import { exerciseService } from '../services/exercise.service';
import { ExerciseImage } from '../types/exercise.types';
import ScreenLayout from '../components/ScreenLayout';
import { SPACING } from '../constants/theme';

interface Props {
  route: any;
}

const { width } = Dimensions.get('window');
// Calculate image size based on screen width and spacing
// (Screen Width - (Left Padding + Right Padding + Middle Gap)) / 2
const IMAGE_SIZE = (width - (SPACING.md * 2) - SPACING.sm) / 2;

export default function ExerciseGalleryScreen({ route }: Props) {
  const theme = useTheme();
  const { classId, className } = route.params;
  const [images, setImages] = useState<ExerciseImage[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedImage, setSelectedImage] = useState<string | null>(null);

  useEffect(() => {
    loadImages();
  }, [classId]);

  const loadImages = async () => {
    try {
      setLoading(true);
      const data = await exerciseService.getClassImages(classId);
      setImages(data);
    } catch (error) {
      console.error('Error loading images:', error);
    } finally {
      setLoading(false);
    }
  };

  const renderImageItem = ({ item }: { item: ExerciseImage }) => (
    <Pressable
      style={styles.imageContainer}
      onPress={() => setSelectedImage(item.image_url)}
    >
      <Surface style={styles.imageSurface} elevation={0}>
        <Image
          source={{ uri: item.image_url }}
          style={styles.thumbnail}
          resizeMode="cover"
        />
        {item.description && (
          <View style={styles.descriptionContainer}>
            <Text variant="bodySmall" style={styles.imageDescription} numberOfLines={2}>
              {item.description}
            </Text>
          </View>
        )}
      </Surface>
    </Pressable>
  );

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }

  return (
    <ScreenLayout>
      <FlatList
        data={images}
        renderItem={renderImageItem}
        keyExtractor={(item) => item.id}
        numColumns={2}
        columnWrapperStyle={styles.columnWrapper}
        contentContainerStyle={styles.gallery}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <Surface style={styles.emptyCard} elevation={0}>
            <Text variant="titleMedium" style={styles.emptyTitle}>No Images Yet</Text>
            <Text variant="bodySmall" style={styles.emptyHint}>
              Add demonstration images for {className}
            </Text>
          </Surface>
        }
      />

      <Modal
        visible={selectedImage !== null}
        transparent
        animationType="fade"
        onRequestClose={() => setSelectedImage(null)}
      >
        <View style={styles.modalContainer}>
          <Pressable style={styles.modalBackdrop} onPress={() => setSelectedImage(null)} />
          <IconButton
            icon="close"
            size={28}
            iconColor="#fff"
            style={styles.closeButton}
            onPress={() => setSelectedImage(null)}
          />
          {selectedImage && (
            <Image
              source={{ uri: selectedImage }}
              style={styles.fullImage}
              resizeMode="contain"
            />
          )}
        </View>
      </Modal>
    </ScreenLayout>
  );
}

const styles = StyleSheet.create({
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  gallery: {
    paddingBottom: SPACING.xl,
  },
  columnWrapper: {
    justifyContent: 'space-between',
  },
  imageContainer: {
    width: IMAGE_SIZE,
    marginBottom: SPACING.md,
  },
  imageSurface: {
    borderRadius: 16,
    overflow: 'hidden',
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#F3F4F6',
  },
  thumbnail: {
    width: '100%',
    height: IMAGE_SIZE,
  },
  descriptionContainer: {
    padding: SPACING.sm,
  },
  imageDescription: {
    opacity: 0.7,
    lineHeight: 16,
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
  modalContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalBackdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0, 0, 0, 0.95)',
  },
  closeButton: {
    position: 'absolute',
    top: 50,
    right: 16,
    zIndex: 10,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
  },
  fullImage: {
    width: '100%',
    height: '80%',
  },
});
