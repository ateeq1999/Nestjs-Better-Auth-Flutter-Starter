# Contributing to Flutter Starter

Thank you for your interest in contributing to Flutter Starter!

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/flutter_starter.git
   cd flutter_starter
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/original_owner/flutter_starter.git
   ```

## Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates
- `test/` - Test additions/changes

### 2. Make Your Changes

- Follow the existing code style and conventions
- Write meaningful commit messages
- Add tests for new functionality
- Update documentation as needed

### 3. Keep Your Branch Updated

```bash
git fetch upstream
git rebase upstream/main
```

### 4. Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/auth_repository_test.dart

# Run widget tests only
flutter test test/widget/

# Run unit tests only
flutter test test/unit/
```

### 5. Run Analysis

```bash
flutter analyze
```

Ensure there are no errors (warnings are okay but should be minimized).

### 6. Commit Your Changes

```bash
git add .
git commit -m "feat: add new authentication feature"
```

Commit message format: `<type>: <description>`

Types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, etc.)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

### 7. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Code Standards

### Code Style
- Use `flutter_lints` strict rules
- Maximum line length: 80 characters (soft limit)
- Use meaningful variable and function names
- Add comments only when necessary for understanding

### GetX Patterns
- Use `GetxService` for long-lived services
- Use `GetxController` for screen-specific state
- Use `Obx()` for reactive UI updates
- Use `Bindings` for dependency injection

### File Structure
```
lib/app/modules/
├── module_name/
│   ├── module_name_binding.dart
│   ├── module_name_controller.dart
│   └── module_name_view.dart
```

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Private members: `_camelCase`

## Testing Guidelines

### Unit Tests
- Test one thing per test function
- Use descriptive test names: `describe('when X', () => it('should Y', ...))`
- Mock external dependencies (Dio, repositories)
- Aim for 80%+ coverage on repositories and services

### Widget Tests
- Test user-facing behavior
- Test form validation
- Test loading states
- Test error handling

### Integration Tests
- Test complete user flows
- Test navigation between screens
- Test authentication flows

## Reporting Issues

### Bug Reports
Include:
- Flutter version
- Dart version
- Steps to reproduce
- Expected vs actual behavior
- Code sample or stack trace

### Feature Requests
Include:
- Clear description of the feature
- Use case / motivation
- Potential implementation approach (optional)

## Questions?

- Open an issue for bugs or feature requests
- Check existing issues before creating new ones

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
