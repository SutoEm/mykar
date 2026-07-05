import type { Environment } from '../types/environment';

const defaultEnvironment: Environment = 'development';

export const environment = {
  appEnv: process.env.EXPO_PUBLIC_APP_ENV ?? defaultEnvironment,
  supabaseAnonKey: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '',
  supabaseUrl: process.env.EXPO_PUBLIC_SUPABASE_URL ?? '',
} as const;
