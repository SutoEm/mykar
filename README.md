# My Kar

My Kar is an AI-powered digital vehicle memory platform. The product starts as a focused car maintenance foundation and is designed to become the digital identity of every vehicle.

## Vision

My Kar helps vehicle owners preserve the full memory of a car: maintenance, ownership context, documents, service history, fuel activity, diagnostics, and eventually AI-assisted insights. Every technical decision should keep the MVP simple while leaving room for Vehicle Management, Maintenance Records, Fuel Tracking, Documents, Notifications, OBD-II, AI Assistant, Marketplace, Service Directory, Authentication, Photo Analysis, and Audio Analysis.

## Current Status

Foundation setup. No business features are implemented yet.

## Tech Stack

- Mobile: React Native, Expo, TypeScript, Expo Router
- Backend: Supabase, PostgreSQL, Storage, Auth
- Tooling: ESLint, Prettier, EditorConfig, Husky, lint-staged
- Future: NestJS, AI services, OBD integration, marketplace, service platform

## Folder Structure

```text
/
├── apps/
│   └── mobile/
├── backend/
├── packages/
├── docs/
├── design/
├── scripts/
├── .github/
└── README.md
```

## Architecture

The mobile app uses feature-based architecture. Shared UI and utilities live in top-level `src` folders, while future product areas should be added as isolated feature modules.

Business logic must stay out of UI components. Prefer typed services, hooks, and utility functions that can be tested and reused.

## Development Setup

1. Install dependencies:

```bash
npm install
```

2. Copy environment variables:

```bash
cp apps/mobile/.env.example apps/mobile/.env
```

3. Start the mobile app:

```bash
npm run dev --workspace @my-kar/mobile
```

4. Run quality checks:

```bash
npm run lint
npm run typecheck
npm run format:check
```

## Contribution Guide

- Keep changes small and focused.
- Use TypeScript everywhere.
- Keep UI components presentation-focused.
- Put reusable logic in hooks, services, utils, or feature modules.
- Avoid unnecessary dependencies.
- Update documentation when architecture or product decisions change.

## Branch Strategy

- `main`: production-ready code
- `develop`: integration branch
- `feature/*`: new functionality
- `fix/*`: bug fixes
- `hotfix/*`: urgent production fixes

## Commit Convention

Use Conventional Commits:

- `feat:` new user-facing capability
- `fix:` bug fix
- `docs:` documentation only
- `refactor:` code change without behavior change
- `style:` formatting or style-only change
- `test:` tests
- `chore:` tooling, config, maintenance
