import { afterEach, describe, expect, it, vi } from 'vitest';

async function loadEnvironment() {
  vi.resetModules();
  return import('./environment');
}

describe('environment service', () => {
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it('uses development as the default app environment', async () => {
    vi.stubEnv('EXPO_PUBLIC_APP_ENV', undefined);

    const { environment } = await loadEnvironment();

    expect(environment.appEnv).toBe('development');
  });

  it('reads public Expo environment variables', async () => {
    vi.stubEnv('EXPO_PUBLIC_APP_ENV', 'staging');
    vi.stubEnv('EXPO_PUBLIC_SUPABASE_ANON_KEY', 'anon-key');
    vi.stubEnv('EXPO_PUBLIC_SUPABASE_URL', 'https://example.supabase.co');

    const { environment } = await loadEnvironment();

    expect(environment).toEqual({
      appEnv: 'staging',
      supabaseAnonKey: 'anon-key',
      supabaseUrl: 'https://example.supabase.co',
    });
  });
});
