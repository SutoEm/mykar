# Architecture

My Kar uses a monorepo with app, backend, package, documentation, design, and script boundaries.

The mobile app follows feature-based architecture. Shared primitives live in `src/components`, `src/hooks`, `src/services`, `src/types`, `src/utils`, and `src/constants`. Domain-specific code belongs in `src/features/<feature-name>`.

Principles:

- Keep UI components presentation-focused.
- Keep business logic in services, hooks, or feature modules.
- Use TypeScript strict mode.
- Prefer simple composition over inheritance.
- Add dependencies only when they clearly reduce risk or complexity.
