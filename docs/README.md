# FitCheck AI Documentation

Last updated: 2026-02-15

This folder contains product, technical, and implementation documentation for the full FitCheck AI monorepo (backend API, React web app, Flutter app, and supporting assets).

## Start Here

- Complete project implementation map: [`PROJECT_OVERVIEW.md`](./PROJECT_OVERVIEW.md)
- Development setup: [`5-development/setup.md`](./5-development/setup.md)
- Current docs status/index: [`SUMMARY.md`](./SUMMARY.md)

## Documentation Structure

### 1. Product (`1-product/`)

- [`overview.md`](./1-product/overview.md): product framing and scope
- [`user-stories.md`](./1-product/user-stories.md): user journey coverage
- [`features/`](./1-product/features/): feature-specific PRD sections

### 2. Technical (`2-technical/`)

- [`architecture.md`](./2-technical/architecture.md): architecture and boundaries
- [`data-models.md`](./2-technical/data-models.md): schema and model documentation
- [`api-spec.md`](./2-technical/api-spec.md): endpoint-level API details
- [`auth-flow.md`](./2-technical/auth-flow.md): authentication flow details
- [`tech-stack.md`](./2-technical/tech-stack.md): technology choices and rationale

### 3. Features (`3-features/`)

- [`authentication.md`](./3-features/authentication.md)
- [`user-management.md`](./3-features/user-management.md)
- [`core-features.md`](./3-features/core-features.md)
- [`error-handling.md`](./3-features/error-handling.md)

### 4. Implementation (`4-implementation/`)

- [`file-structure.md`](./4-implementation/file-structure.md)
- [`components.md`](./4-implementation/components.md)
- [`workflows.md`](./4-implementation/workflows.md)
- [`validation.md`](./4-implementation/validation.md)
- [`security.md`](./4-implementation/security.md)

### 5. Development (`5-development/`)

- [`setup.md`](./5-development/setup.md): local setup and verification
- [`launch-checklist.md`](./5-development/launch-checklist.md): release checklist

## Companion Documents

- [`IMPLEMENTATION_STATUS.md`](./IMPLEMENTATION_STATUS.md): feature-level implementation tracker
- Root repository guide: [`../README.md`](../README.md)
- Agent-oriented repo guide: [`../AGENTS.md`](../AGENTS.md)

## Recommended Reading Paths

### Product/Planning

1. [`1-product/overview.md`](./1-product/overview.md)
2. [`1-product/user-stories.md`](./1-product/user-stories.md)
3. Relevant feature doc in [`1-product/features/`](./1-product/features/)

### Backend/API Development

1. [`PROJECT_OVERVIEW.md`](./PROJECT_OVERVIEW.md)
2. [`2-technical/architecture.md`](./2-technical/architecture.md)
3. [`2-technical/data-models.md`](./2-technical/data-models.md)
4. [`2-technical/api-spec.md`](./2-technical/api-spec.md)
5. [`5-development/setup.md`](./5-development/setup.md)

### Frontend/Mobile Development

1. [`PROJECT_OVERVIEW.md`](./PROJECT_OVERVIEW.md)
2. [`4-implementation/file-structure.md`](./4-implementation/file-structure.md)
3. [`4-implementation/components.md`](./4-implementation/components.md)
4. [`4-implementation/workflows.md`](./4-implementation/workflows.md)
5. [`5-development/setup.md`](./5-development/setup.md)

## Documentation Maintenance Rules

- Keep endpoint, schema, and env variable docs synchronized with code changes.
- Update setup instructions when startup commands or required services change.
- Prefer linking to canonical files over duplicating large blocks of source information.
- When behavior changes, update both the relevant deep-dive doc and this index if navigation changed.
