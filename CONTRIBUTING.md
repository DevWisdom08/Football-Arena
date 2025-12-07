# Contributing to Football Arena

First off, thank you for considering contributing to Football Arena! It's people like you that make Football Arena such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to support@footballarena.com.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

**Bug Report Template:**

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
 - Device: [e.g. iPhone 12, Samsung Galaxy S21]
 - OS: [e.g. iOS 15.0, Android 12]
 - App Version: [e.g. 1.0.0]
 - Backend Version: [e.g. 1.0.0]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description** of the suggested enhancement
- **Provide specific examples** to demonstrate the steps
- **Describe the current behavior** and **explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **If you've added code** that should be tested, add tests
3. **If you've changed APIs**, update the documentation
4. **Ensure the test suite passes**
5. **Make sure your code lints**
6. **Issue that pull request!**

## Development Workflow

### Setting Up Development Environment

```bash
# Clone your fork
git clone https://github.com/your-username/football-arena.git
cd football-arena

# Add upstream remote
git remote add upstream https://github.com/original-owner/football-arena.git

# Create a new branch
git checkout -b feature/my-new-feature
```

### Backend Development

```bash
cd football-arena-backend

# Install dependencies
npm install

# Run in development mode
npm run start:dev

# Run tests
npm run test

# Lint code
npm run lint

# Format code
npm run format
```

### Frontend Development

```bash
cd football_arena

# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Commit Messages

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (formatting, etc.)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to build process or auxiliary tools

**Examples:**

```
feat(auth): add Google OAuth login

Implements Google sign-in functionality with proper token handling
and user profile creation.

Closes #123
```

```
fix(stake-match): prevent negative coin balance

Added validation to ensure users cannot create stake matches
with insufficient coins.

Fixes #456
```

### Code Style

#### Flutter/Dart

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use 2 spaces for indentation
- Maximum line length: 80 characters
- Use trailing commas for better formatting
- Prefer `const` constructors when possible
- Use meaningful variable and function names

**Example:**

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          if (subtitle != null) Text(subtitle!),
        ],
      ),
    );
  }
}
```

#### TypeScript/NestJS

- Follow [TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- Use 2 spaces for indentation
- Use semicolons
- Use single quotes for strings
- Use async/await instead of promises
- Add proper type annotations

**Example:**

```typescript
@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async findById(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }
}
```

### Testing

#### Backend Tests

```typescript
describe('StakeMatchService', () => {
  let service: StakeMatchService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [StakeMatchService],
    }).compile();

    service = module.get<StakeMatchService>(StakeMatchService);
  });

  it('should create stake match', async () => {
    const match = await service.createStakeMatch(userId, {
      stakeAmount: 1000,
      difficulty: 'mixed',
    });

    expect(match).toBeDefined();
    expect(match.stakeAmount).toBe(1000);
  });
});
```

#### Frontend Tests

```dart
void main() {
  testWidgets('StakeMatchCard displays correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StakeMatchCard(
          match: mockMatch,
        ),
      ),
    );

    expect(find.text('1000 coins'), findsOneWidget);
    expect(find.byIcon(Icons.monetization_on), findsOneWidget);
  });
}
```

## Project Structure

### Adding New Features

#### Backend

1. Create module in `src/modules/feature-name/`
2. Add controller, service, and DTOs
3. Register module in `app.module.ts`
4. Add API tests
5. Update API documentation

#### Frontend

1. Create feature directory in `lib/features/feature-name/`
2. Add presentation, domain, and data layers
3. Register routes in `lib/routes/app_router.dart`
4. Add widget tests
5. Update UI documentation

### Database Migrations

```bash
# Create migration
npm run migration:create -- -n MigrationName

# Generate migration from entity changes
npm run migration:generate -- -n MigrationName

# Run migrations
npm run migration:run

# Revert migration
npm run migration:revert
```

## Review Process

1. **Automated Checks:**
   - All tests must pass
   - Code must pass linting
   - No merge conflicts

2. **Code Review:**
   - At least one maintainer approval required
   - Address all review comments
   - Keep pull requests focused and small

3. **Merge:**
   - Squash commits if necessary
   - Use descriptive merge commit message
   - Delete branch after merge

## Community

- **Discord:** [Join our Discord](https://discord.gg/footballarena)
- **Twitter:** [@FootballArena](https://twitter.com/footballarena)
- **Email:** dev@footballarena.com

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- About page in the app

## Questions?

Feel free to ask questions in:
- GitHub Discussions
- Discord #dev-help channel
- Email: dev@footballarena.com

---

**Thank you for contributing to Football Arena! ⚽**

