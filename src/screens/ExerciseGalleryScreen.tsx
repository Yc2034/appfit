import React, { useEffect, useState } from 'react';
import { View, StyleSheet, FlatList, Image, Dimensions, TouchableOpacity, Modal } from 'react-native';
import { Text, ActivityIndicator, IconButton } from 'react-native-paper';
import { exerciseService } from '../services/exercise.service';
import { ExerciseImage } from '../types/exercise.types';

interface Props {
  route: any;
}

const { width } = Dimensions.get('window');
const IMAGE_SIZE = width / 2 - 24;

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
    <TouchableOpacity
      style={styles.imageContainer}
      onPress={() => setSelectedImage(item.image_url)}
    >
      <Image
        source={{ uri: item.image_url }}
        style={styles.thumbnail}
        resizeMode="cover"
      />
      {item.description && (
        <Text variant="bodySmall" style={styles.imageDescription} numberOfLines={2}>
          {item.description}
        </Text>
      )}
    </TouchableOpacity>
  );

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" />
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
        ListEmptyComponent={
          <View style={styles.empty}>
            <Text variant="bodyLarge">No images yet</Text>
            <Text variant="bodySmall" style={styles.emptyHint}>
              Add exercise demonstration images for {className}
            </Text>
          </View>
        }
      />

      <Modal
        visible={selectedImage !== null}
        transparent={true}
        onRequestClose={() => setSelectedImage(null)}
      >
        <View style={styles.modalContainer}>
          <IconButton
            icon="close"
            size={30}
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
    backgroundColor: '#f6f6f6',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  gallery: {
    padding: 8,
  },
  imageContainer: {
    width: IMAGE_SIZE,
    margin: 8,
    backgroundColor: '#fff',
    borderRadius: 8,
    overflow: 'hidden',
  },
  thumbnail: {
    width: IMAGE_SIZE,
    height: IMAGE_SIZE,
  },
  imageDescription: {
    padding: 8,
  },
  empty: {
    alignItems: 'center',
    marginTop: 48,
    paddingHorizontal: 24,
  },
  emptyHint: {
    marginTop: 8,
    color: '#999',
    textAlign: 'center',
  },
  modalContainer: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.9)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  closeButton: {
    position: 'absolute',
    top: 40,
    right: 16,
    zIndex: 1,
  },
  fullImage: {
    width: '100%',
    height: '100%',
  },
});
