module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
  ],
  ignorePatterns: ['dist', '.eslintrc.cjs', 'scripts', 'netlify'],
  parser: '@typescript-eslint/parser',
  plugins: ['react-refresh'],
  rules: {
    // Allow intentional infinite loops (e.g., SSE stream readers)
    'no-constant-condition': ['error', { checkLoops: false }],
    // Allow exporting constants alongside components (common pattern in this codebase)
    'react-refresh/only-export-components': 'off',
    // These two are the bug class this codebase actually has -- a stale
    // closure in an effect, and an `any` that hides a wrong property read.
    // Kept at 'warn' rather than 'error': the lint script runs with
    // --max-warnings 0, so CI still fails on a new one, but a targeted
    // eslint-disable-next-line with a reason stays the escape hatch.
    'react-hooks/exhaustive-deps': 'warn',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': [
      'error',
      { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
    ],
  },
}
