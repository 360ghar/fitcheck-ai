// @ts-check
/**
 * ESLint 9 flat config for fitcheck-admin.
 *
 * - typescript-eslint recommended-type-checked (projectService discovers the
 *   right tsconfig for each file: tsconfig.json for src/, tsconfig.node.json
 *   for tooling).
 * - react-hooks (rules-of-hooks + exhaustive-deps) — both errors, CI runs
 *   with --max-warnings 0 so a warning would fail the build anyway.
 * - import-x/order for deterministic import grouping.
 * - Feature isolation is enforced by import-x/no-restricted-paths: a feature
 *   may import from itself, shared/, config/, app/, and test/ — never from
 *   another feature.
 */
import eslint from '@eslint/js'
import eslintConfigPrettier from 'eslint-config-prettier'
import importX from 'eslint-plugin-import-x'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import globals from 'globals'
import tseslint from 'typescript-eslint'

const featureDirs = [
  'auth',
  'dashboard',
  'users',
  'subscriptions',
  'quotas',
  'content',
  'promo',
  'feedback',
  'ops',
  'audit',
  'search',
  'settings',
]

const featureIsolationZones = featureDirs.map((feature) => ({
  target: `./src/features/${feature}`,
  from: './src/features',
  // `except` is resolved relative to the target zone, so a feature may import
  // from itself but nothing else under src/features.
  except: [`./${feature}`],
}))

export default tseslint.config(
  {
    ignores: [
      'dist/**',
      'node_modules/**',
      'coverage/**',
      'contracts/**',
      'src/shared/api/schema.d.ts',
    ],
  },
  eslint.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: {
          // Tooling files live outside tsconfig.json's include (they are
          // still verified by `tsc -p tsconfig.node.json`); the project
          // service parses them via the default project instead.
          allowDefaultProject: [
            'vite.config.ts',
            'openapi-ts.config.ts',
            'eslint.config.js',
            'scripts/*.mjs',
          ],
        },
        tsconfigRootDir: import.meta.dirname,
      },
      globals: {
        ...globals.browser,
        ...globals.node,
      },
    },
  },
  {
    files: ['**/*.{ts,tsx,js,mjs}'],
    plugins: {
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
      'import-x': importX,
    },
    rules: {
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'error',
      'react-refresh/only-export-components': 'off',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/consistent-type-imports': [
        'error',
        { prefer: 'type-imports', fixStyle: 'inline-type-imports' },
      ],
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      // React 19 event-handler types still declare `=> void`; async handlers
      // are idiomatic. Keep the "Promise passed where a non-Promise was
      // expected" half of the rule and drop the void-return half.
      '@typescript-eslint/no-misused-promises': [
        'error',
        { checksVoidReturn: false },
      ],
      'import-x/order': [
        'error',
        {
          groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
          'newlines-between': 'always',
          alphabetize: { order: 'asc', caseInsensitive: true },
        },
      ],
      'import-x/no-restricted-paths': ['error', { zones: featureIsolationZones }],
    },
  },
  eslintConfigPrettier,
)
