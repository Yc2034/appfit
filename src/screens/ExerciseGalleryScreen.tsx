import React, { useEffect, useState } from 'react';
import { View, StyleSheet, FlatList, Image, Dimensions, Pressable, Modal } from 'react-native';
import { Text, ActivityIndicator, IconButton, Surface } from 'react-native-paper';
import { exerciseService } from '../services/exercise.service';
import { ExerciseImage } from '../types/exercise.types';

interface Props {
  route: any;
}

const { width } = Dimensions.get('window');
const IMAGE_SIZE = (width - 48) / 2;

export default function ExerciseGalleryScreen({ route }: Props) {
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
      <Surface style={styles.imageSurface} elevation={1}>
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
        <ActivityIndicator size="large" color="#6200ee" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={images}
        renderItem={renderImageItem}
        keyExtractor={(item) => item.id}
        numColumns={2}
        contentContainerStyle={styles.gallery}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <Surface style={styles.emptyCard} elevation={1}>
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
  gallery: {
    padding: 16,
  },
  imageContainer: {
    width: '50%',
    padding: 4,
  },
  imageSurface: {
    borderRadius: 16,
    overflow: 'hidden',
    backgroundColor: '#fff',
  },
  thumbnail: {
    width: '100%',
    height: IMAGE_SIZE,
  },
  descriptionContainer: {
    padding: 12,
  },
  imageDescription: {
    color: '#666',
    lineHeight: 16,
  },
  emptyCard: {
    borderRadius: 16,
    padding: 32,
    alignItems: 'center',
    backgroundColor: '#fff',
    marginTop: 24,
    marginHorizontal: 4,
  },
  emptyTitle: {
    color: '#333',
    marginBottom: 8,
  },
  emptyHint: {
    color: '#999',
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
