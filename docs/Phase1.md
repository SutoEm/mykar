# Phase 1: Product Design

Phase 1 is code-free. Its job is to define what the product is, who it serves, and how the MVP proves value before feature implementation begins.

## Required Artifacts

| Artifact         | File                     | Status  |
| ---------------- | ------------------------ | ------- |
| Vision           | `docs/Vision.md`         | Drafted |
| Manifesto        | `docs/Manifesto.md`      | Drafted |
| MVP              | `docs/MVP.md`            | Drafted |
| User Personas    | `docs/UserPersonas.md`   | Drafted |
| User Stories     | `docs/UserStories.md`    | Drafted |
| Feature Matrix   | `docs/FeatureMatrix.md`  | Drafted |
| Data Trust Model | `docs/DataTrustModel.md` | Drafted |
| Success Metrics  | `docs/SuccessMetrics.md` | Drafted |
| UI Flow          | `docs/UIFlow.md`         | Drafted |
| Wireframes       | `design/Wireframes.md`   | Drafted |

## Completion Criteria

- All required artifacts exist.
- MVP scope is explicit.
- Out-of-scope items are reflected in `docs/Graveyard.md`.
- User stories map to phases.
- Data trust rules are clear before database design.
- UI flow is clear enough to support wireframes.
- Decision review records whether Phase 2 can start.

## Local Validation

Phase 1 has no product code. Validate it with:

```bash
npm run format:check
npm run lint
npm test
npm run typecheck
npm run audit:moderate
```

## Open Review Questions

- Is the first MVP focused on private individual owners only?
- Should document upload be in the first MVP or delayed until after maintenance records?
- Should fuel tracking be inside the first MVP or remain later in Phase 6?
- What exact project board columns should mirror the phase gates?

## Decision Review

Phase 1 is drafted, not closed. It should close only after the product owner accepts the MVP scope, personas, feature matrix, and success metrics.
