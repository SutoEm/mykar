# Phase 0: Foundation

Phase 0 creates the technical and operational base. No business features should be implemented before this phase is complete.

## Completion Criteria

- GitHub repository exists and is connected to local development.
- Monorepo boundaries are defined.
- React Native and Expo mobile app starts from `apps/mobile`.
- TypeScript strict mode is enabled.
- ESLint, Prettier, EditorConfig, Husky, and lint-staged are configured.
- CI runs install, lint, tests, typecheck, formatting, and security audit.
- Issue templates and pull request template exist.
- Branch strategy is documented.
- `main` is protected and product work flows through pull requests.
- `develop` exists as the integration branch.
- Project board exists for operating system phase tracking.
- Foundation documentation is current.

## Local Quality Gate

Run these before opening or merging pull requests:

```bash
npm ci
npm run lint
npm test
npm run typecheck
npm run format:check
npm run audit:moderate
```

## Phase 0 Checklist

| Item              | Status | Evidence                                                       |
| ----------------- | ------ | -------------------------------------------------------------- |
| GitHub repository | Done   | `origin` points to `SutoEm/mykar.git`                          |
| Monorepo          | Done   | `apps/*`, `packages/*`, `backend`, `docs`, `design`, `scripts` |
| React Native      | Done   | `react-native` dependency in `apps/mobile`                     |
| Expo              | Done   | `expo` and `expo-router` in `apps/mobile`                      |
| TypeScript        | Done   | `tsconfig.base.json` and mobile `tsconfig.json`                |
| ESLint            | Done   | `apps/mobile/.eslintrc.cjs`                                    |
| CI                | Done   | `.github/workflows/ci.yml`                                     |
| Documentation     | Done   | `docs/` operating documents                                    |
| Project board     | Done   | `https://github.com/orgs/SutoEm/projects/1`                    |
| Issue templates   | Done   | `.github/ISSUE_TEMPLATE`                                       |
| Husky             | Done   | `.husky/pre-commit`                                            |
| Branch strategy   | Done   | README and branch protection rules                             |

## Decision Review

Phase 0 is complete. The external GitHub controls are verified:

- `develop` branch exists on GitHub.
- `main` branch protection is active.
- Project board exists and tracks phases.

Phase 1 can proceed as a code-free product design phase.
