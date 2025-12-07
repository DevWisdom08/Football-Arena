# ⚽ Football Arena

<div align="center">

![Football Arena Banner](assets/images/banner.png)

**The Ultimate Football Quiz & Challenge Platform**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![NestJS](https://img.shields.io/badge/NestJS-10.0+-E0234E?style=for-the-badge&logo=nestjs)](https://nestjs.com)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-3178C6?style=for-the-badge&logo=typescript)](https://www.typescriptlang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791?style=for-the-badge&logo=postgresql)](https://www.postgresql.org)

</div>

---

## 📖 Overview

**Football Arena** is a comprehensive mobile application that combines football trivia, competitive gaming, and social features into one engaging platform. Challenge your football knowledge in solo mode, compete against friends in real-time 1v1 matches, participate in daily quizzes, or stake coins in competitive arena matches.

### ✨ Key Features

#### 🎮 Game Modes

- **🏃 Solo Mode** - Test your football knowledge with randomized questions across multiple difficulty levels
- **⚔️ 1v1 Challenge** - Real-time multiplayer matches with WebSocket-powered matchmaking
- **📅 Daily Quiz** - Complete daily challenges to earn rewards and maintain streaks
- **👥 Team Match** - Collaborate with teammates in group competitions
- **💰 Stake Match Arena** - Bet coins on your knowledge and compete for real rewards

#### 🛍️ Store & Economy

- **Coin Packs** - Purchase in-game currency for premium features
- **VIP Membership** - Unlock exclusive benefits and reduced commission rates
- **Power-ups & Boosts** - Enhance your gameplay with special items
- **Withdrawable Winnings** - Convert earned coins to real rewards

#### 👤 Profile & Social

- **Custom Avatars** - Upload and personalize your profile picture
- **Achievement System** - Track your progress with XP, levels, and badges
- **Leaderboards** - Compete globally and see your ranking
- **Match History** - Review past games and performance statistics
- **Friends System** - Connect with other players

#### ⚙️ Settings & Customization

- **Notifications** - Manage push notification preferences
- **Sound & Haptics** - Customize audio and tactile feedback
- **Multiple Languages** - Support for international users
- **Data Management** - Control your app data and storage

---

## 🏗️ Tech Stack

### Frontend (Mobile)

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile framework (iOS & Android) |
| **Dart** | Programming language |
| **Riverpod** | State management solution |
| **Go Router** | Navigation and routing |
| **Dio** | HTTP client for API requests |
| **Socket.IO Client** | Real-time WebSocket communication |
| **Image Picker** | Camera and gallery integration |
| **Shared Preferences** | Local storage |

### Backend (Server)

| Technology | Purpose |
|------------|---------|
| **NestJS** | Node.js framework for scalable server applications |
| **TypeScript** | Type-safe JavaScript |
| **TypeORM** | Database ORM |
| **PostgreSQL** | Relational database |
| **Socket.IO** | Real-time bidirectional communication |
| **Passport JWT** | Authentication middleware |
| **Class Validator** | Request validation |
| **Multer** | File upload handling |

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### For Frontend Development

- **Flutter SDK** (3.0 or higher) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **iOS Simulator** (macOS) or **Android Emulator**

### For Backend Development

- **Node.js** (18.0 or higher) - [Install Node.js](https://nodejs.org/)
- **npm** or **yarn** package manager
- **PostgreSQL** (15 or higher) - [Install PostgreSQL](https://www.postgresql.org/download/)

### Verify Installation

```bash
# Check Flutter
flutter --version
flutter doctor

# Check Node.js
node --version
npm --version

# Check PostgreSQL
psql --version
```

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/football-arena.git
cd football-arena
```

### 2. Backend Setup

```bash
cd football-arena-backend

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env
# Edit .env with your database credentials and settings
```

**Environment Variables** (`.env`):

```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_password
DATABASE_NAME=football_arena

# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=your_super_secret_key_here
JWT_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=http://localhost:*

# Socket.IO
SOCKET_CORS_ORIGIN=http://localhost:*
```

**Create Database:**

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE football_arena;
\q
```

**Run Migrations:**

```bash
# Generate migrations (if needed)
npm run migration:generate

# Run migrations
npm run migration:run
```

**Start Backend Server:**

```bash
# Development mode with hot reload
npm run start:dev

# Production mode
npm run build
npm run start:prod
```

Server will be running at `http://localhost:3000`

### 3. Frontend Setup

```bash
cd ../football_arena

# Install dependencies
flutter pub get

# Generate code (for JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs
```

**Configure API Endpoint** (`lib/core/network/api_client.dart`):

```dart
static const String baseUrl = 'http://localhost:3000'; // Local development
// static const String baseUrl = 'https://api.yourserver.com'; // Production
```

**Run Flutter App:**

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode with hot reload
flutter run

# Build release APK (Android)
flutter build apk --release

# Build iOS app (macOS only)
flutter build ios --release
```

---

## 📁 Project Structure

### Backend Structure

```
football-arena-backend/
├── src/
│   ├── modules/
│   │   ├── auth/              # Authentication & authorization
│   │   ├── users/             # User management
│   │   ├── questions/         # Quiz questions
│   │   ├── game/              # Game logic
│   │   │   ├── stake-match/   # Stake match system
│   │   │   └── daily-quiz/    # Daily quiz logic
│   │   ├── store/             # In-app purchases
│   │   ├── leaderboard/       # Rankings & leaderboards
│   │   └── unlocks/           # Avatar & item unlocks
│   ├── common/
│   │   ├── guards/            # Auth guards
│   │   ├── decorators/        # Custom decorators
│   │   └── filters/           # Exception filters
│   ├── config/                # Configuration files
│   └── main.ts               # Application entry point
├── migrations/               # Database migrations
├── test/                    # Unit & E2E tests
└── package.json            # Dependencies
```

### Frontend Structure

```
football_arena/
├── lib/
│   ├── core/
│   │   ├── constants/         # App constants & colors
│   │   ├── models/            # Data models
│   │   ├── network/           # API services & endpoints
│   │   └── services/          # Core services (storage, socket)
│   ├── features/
│   │   ├── auth/              # Login, register, guest login
│   │   ├── home/              # Home screen
│   │   ├── solo_mode/         # Solo quiz game
│   │   ├── challenge_1v1/     # Real-time 1v1 matches
│   │   ├── daily_quiz/        # Daily quiz feature
│   │   ├── team_match/        # Team competitions
│   │   ├── stake_match/       # Stake match arena
│   │   ├── store/             # In-app store
│   │   ├── profile/           # User profile & stats
│   │   ├── leaderboard/       # Global rankings
│   │   └── settings/          # App settings
│   ├── shared/
│   │   ├── models/            # Shared data models
│   │   └── widgets/           # Reusable UI components
│   ├── routes/                # Navigation routes
│   └── main.dart             # App entry point
├── assets/
│   ├── images/               # Background images & icons
│   └── fonts/                # Custom fonts
├── test/                     # Widget & unit tests
└── pubspec.yaml             # Flutter dependencies
```

---

## 🔌 API Documentation

### Base URL

```
http://localhost:3000
```

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | User login |
| POST | `/auth/guest` | Guest login |
| GET | `/auth/me` | Get current user |

### User Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users/:id` | Get user by ID |
| PUT | `/users/:id` | Update user profile |
| POST | `/users/:id/avatar` | Upload avatar image |
| GET | `/users/leaderboard` | Get top players |

### Game Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/questions/random` | Get random questions |
| POST | `/game/solo/start` | Start solo game |
| POST | `/game/solo/submit` | Submit solo game results |

### Stake Match Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/stake-matches` | Create new stake match |
| GET | `/stake-matches/available` | Get available matches |
| GET | `/stake-matches/user/:userId` | Get user's matches |
| POST | `/stake-matches/:id/join` | Join a stake match |
| DELETE | `/stake-matches/:id` | Cancel stake match |

### Store Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/store/items` | Get all store items |
| POST | `/store/purchase` | Purchase store item |

---

## 🎨 UI/UX Features

### Modern Design Elements

- **Glass-morphism** - Transparent gradient cards with blur effects
- **Golden Accents** - Vibrant gold colors for premium features
- **Dark Theme** - Eye-friendly dark color scheme
- **Smooth Animations** - Fluid transitions and micro-interactions
- **Responsive Layout** - Optimized for various screen sizes
- **Custom Gradients** - Beautiful color transitions throughout

### Mobile Optimization

- Touch-friendly button sizes
- Swipe gestures for navigation
- Pull-to-refresh functionality
- Optimized loading states
- Error handling with user feedback
- Offline mode support (coming soon)

---

## 🧪 Testing

### Backend Tests

```bash
cd football-arena-backend

# Run unit tests
npm run test

# Run E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

### Frontend Tests

```bash
cd football_arena

# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Integration tests
flutter drive --target=test_driver/app.dart
```

---

## 🚢 Deployment

### Backend Deployment

**Docker Deployment:**

```bash
# Build Docker image
docker build -t football-arena-backend .

# Run container
docker run -p 3000:3000 --env-file .env football-arena-backend
```

**Heroku Deployment:**

```bash
heroku create football-arena-api
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main
```

### Frontend Deployment

**Android APK:**

```bash
flutter build apk --release
# APK located at: build/app/outputs/flutter-apk/app-release.apk
```

**iOS App Store:**

```bash
flutter build ios --release
# Open Xcode and archive for distribution
```

**App Bundle (Google Play):**

```bash
flutter build appbundle --release
# Bundle located at: build/app/outputs/bundle/release/app-release.aab
```

---

## 📱 Features Roadmap

### ✅ Completed

- [x] User authentication (email, guest, social)
- [x] Solo quiz mode with multiple difficulties
- [x] Real-time 1v1 challenges with WebSocket
- [x] Daily quiz with streak system
- [x] Stake match arena with betting
- [x] In-app store with coin purchases
- [x] Profile management with avatar upload
- [x] Global leaderboard
- [x] Settings customization

### 🚧 In Progress

- [ ] Team match functionality
- [ ] Tournament system
- [ ] Friend challenges
- [ ] Chat system
- [ ] Push notifications

### 📝 Planned

- [ ] Offline mode support
- [ ] Video replays
- [ ] Seasonal events
- [ ] Custom quiz creation
- [ ] Clan/Guild system
- [ ] Spectator mode
- [ ] Achievement badges
- [ ] Social media integration

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### Code Style Guidelines

**Flutter/Dart:**
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` to check code quality
- Format code with `flutter format`

**NestJS/TypeScript:**
- Follow [TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- Use ESLint for linting: `npm run lint`
- Format code with Prettier: `npm run format`

### Commit Message Convention

```
<type>(<scope>): <subject>

Examples:
feat(auth): add social login support
fix(stake-match): resolve coin deduction bug
docs(readme): update installation instructions
style(ui): improve card gradients
refactor(api): optimize database queries
test(game): add unit tests for scoring logic
```

---

## 🐛 Bug Reports & Feature Requests

Found a bug or have a feature idea? Please open an issue:

- **Bug Report:** [Create Bug Report](https://github.com/yourusername/football-arena/issues/new?template=bug_report.md)
- **Feature Request:** [Request Feature](https://github.com/yourusername/football-arena/issues/new?template=feature_request.md)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Football Arena

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

## 👨‍💻 Authors & Contributors

- **Your Name** - *Initial work* - [@yourusername](https://github.com/yourusername)

See also the list of [contributors](https://github.com/yourusername/football-arena/contributors) who participated in this project.

---

## 🙏 Acknowledgments

- Football trivia data sourced from various football databases
- Icons and assets from [Flaticon](https://www.flaticon.com)
- Background images optimized for mobile performance
- Community feedback and testing support

---

## 📞 Support & Contact

- **Documentation:** [Wiki](https://github.com/yourusername/football-arena/wiki)
- **Issues:** [GitHub Issues](https://github.com/yourusername/football-arena/issues)
- **Email:** support@footballarena.com
- **Discord:** [Join our community](https://discord.gg/footballarena)
- **Twitter:** [@FootballArena](https://twitter.com/footballarena)

---

## 📊 Project Statistics

![GitHub stars](https://img.shields.io/github/stars/yourusername/football-arena?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/football-arena?style=social)
![GitHub issues](https://img.shields.io/github/issues/yourusername/football-arena)
![GitHub pull requests](https://img.shields.io/github/issues-pr/yourusername/football-arena)
![GitHub last commit](https://img.shields.io/github/last-commit/yourusername/football-arena)

---

<div align="center">

**⚽ Built with passion for football and technology ⚽**

[⬆ Back to Top](#-football-arena)

</div>

