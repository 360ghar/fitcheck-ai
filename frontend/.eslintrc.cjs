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
    // Pre-existing dependency arrays - changing them risks breaking functionality
    'react-hooks/exhaustive-deps': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-unused-vars': [
      'error',
      { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
    ],
  },
}
