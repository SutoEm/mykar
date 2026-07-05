# Decision Log

Record important product and technical decisions here.

## 2026-07-05: Monorepo Foundation

Decision: Use a TypeScript monorepo with Expo mobile app, Supabase backend folder, shared packages, docs, design, scripts, and GitHub configuration.

Reason: This keeps the MVP simple while preserving clear boundaries for future platform growth.

## 2026-07-05: Development OS

Decision: Manage the project through a 13-phase Development OS, starting with Phase 0 Foundation and ending with Phase 12 Scale.

Reason: My Kar needs phase gates, documentation, tests, and decision reviews before feature work. This prevents premature scope and keeps the company-building plan tied to operational proof.

## 2026-07-05: Simple First Architecture

Decision: Start with a clean monolith-style architecture and avoid Repository Pattern, CQRS, Event Bus, DDD, and microservices until the product creates real pressure for them.

Reason: The MVP needs speed, clarity, and low operational load. Premature architecture would create technical debt before product learning.

## 2026-07-05: Phase 0 Closed

Decision: Close Phase 0 Foundation after creating the GitHub Project board and verifying `develop`, `main` branch protection, CI, documentation, issue templates, Husky, and branch strategy.

Reason: All Phase 0 gates now have operational evidence. Phase 1 can proceed as a code-free product design phase.
