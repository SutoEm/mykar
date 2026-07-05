import { StyleSheet, Text, View } from 'react-native';

import { ScreenContainer } from '../components/layout';
import { appConfig } from '../constants/appConfig';
import { spacing } from '../constants/spacing';
import { colors, typography } from '../constants/theme';

export function HomeScreen() {
  return (
    <ScreenContainer>
      <View style={styles.content}>
        <Text style={styles.eyebrow}>Foundation ready</Text>
        <Text style={styles.title}>{appConfig.name}</Text>
        <Text style={styles.description}>
          AI-powered digital vehicle memory platform. Business features will be added as isolated,
          scalable modules.
        </Text>
      </View>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  content: {
    gap: spacing.md,
  },
  description: {
    color: colors.textMuted,
    fontSize: typography.body,
    lineHeight: 24,
  },
  eyebrow: {
    color: colors.accent,
    fontSize: typography.caption,
    fontWeight: '700',
    textTransform: 'uppercase',
  },
  title: {
    color: colors.text,
    fontSize: typography.title,
    fontWeight: '800',
  },
});
