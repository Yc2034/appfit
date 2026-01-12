import React from 'react';
import { View, StyleSheet, ScrollView, ViewStyle, SafeAreaView } from 'react-native';
import { useTheme } from 'react-native-paper';
import { SPACING } from '../constants/theme';

interface ScreenLayoutProps {
    children: React.ReactNode;
    scrollable?: boolean;
    style?: ViewStyle;
    contentContainerStyle?: ViewStyle;
    useSafeArea?: boolean;
}

export default function ScreenLayout({
    children,
    scrollable = false,
    style,
    contentContainerStyle,
    useSafeArea = true,
}: ScreenLayoutProps) {
    const theme = useTheme();

    const Container = useSafeArea ? SafeAreaView : View;

    const baseStyle = [
        styles.container,
        { backgroundColor: theme.colors.background },
        style
    ];

    if (scrollable) {
        return (
            <Container style={baseStyle}>
                <ScrollView
                    style={styles.scrollView}
                    contentContainerStyle={[
                        styles.contentContainer,
                        contentContainerStyle
                    ]}
                    showsVerticalScrollIndicator={false}
                >
                    {children}
                </ScrollView>
            </Container>
        );
    }

    return (
        <Container style={baseStyle}>
            <View style={[styles.contentContainer, styles.fixedContainer, contentContainerStyle]}>
                {children}
            </View>
        </Container>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    scrollView: {
        flex: 1,
    },
    contentContainer: {
        paddingHorizontal: SPACING.md,
        paddingTop: SPACING.md,
        paddingBottom: SPACING.xl,
    },
    fixedContainer: {
        flex: 1,
    }
});
