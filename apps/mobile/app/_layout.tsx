import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

import { appConfig } from '../src/constants/appConfig';

export default function RootLayout() {
  return (
    <>
      <Stack
        screenOptions={{
          headerTitle: appConfig.name,
        }}
      />
      <StatusBar style="auto" />
    </>
  );
}
