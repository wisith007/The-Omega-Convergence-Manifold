# Ensure proper permissions are set
permissions:
  contents: read
  packages: write
  pull-requests: write
  # Cache dependencies to avoid installation errors
- name: Cache dependencies
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
      # Set up proper environment variables
env:
  NODE_ENV: production
  CI: true
  name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build project
        run: npm run build

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "Deployment logic here"
        # .github/workflows/reusable-build.yml
name: Reusable Build Workflow
on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: '18'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci
      - run: npm run build
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node-version: [16, 18, 20]
- name: Debug Information
  if: ${{ failure() }}
  run: |
    echo "Current directory: $(pwd)"
    echo "Files in directory: $(ls -la)"
    echo "Environment variables: $(env)"
- name: Upload logs on failure
  if: failure()
  uses: actions/upload-artifact@v3
  with:
    name: error-logs
    path: |
      logs/
      test-results/
    