# PulseCampus - Clean Architecture

## Project Structure

This Flutter project follows Clean Architecture principles with a well-organized folder structure.

### 📁 Folder Structure

```
lib/
├── core/                           # Core functionality shared across the app
│   ├── constants/                  # App constants and configuration
│   │   └── app_constants.dart      # Global constants
│   ├── theme/                      # App theming
│   │   └── app_theme.dart          # Light and dark themes
│   └── utils/                      # Utility functions
│       └── app_utils.dart           # Helper functions and utilities
│
├── features/                       # Feature-based modules
│   ├── auth/                       # Authentication feature
│   │   ├── data/                   # Data layer (repositories, data sources)
│   │   ├── domain/                 # Domain layer (entities, use cases)
│   │   └── presentation/           # Presentation layer (screens, widgets)
│   ├── home/                       # Home feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── housing/                    # Housing feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── tested_pages/                   # Previously developed pages (for reference)
│   ├── auths/                      # Old auth screens and models
│   ├── home/                       # Old home screens
│   └── housing/                    # Old housing screens and widgets
│
└── main.dart                       # App entry point
```

### 🏗️ Clean Architecture Layers

#### 1. **Core Layer** (`lib/core/`)
- **Constants**: App-wide constants and configuration
- **Theme**: Material Design theme configuration
- **Utils**: Reusable utility functions and helpers

#### 2. **Features Layer** (`lib/features/`)
Each feature follows Clean Architecture with three layers:

- **Data Layer** (`data/`): Handles data sources, repositories, and data models
- **Domain Layer** (`domain/`): Contains business logic, entities, and use cases
- **Presentation Layer** (`presentation/`): UI components, screens, and state management

### 🎨 Design System

#### Color Palette
- **Primary**: Indigo (#4F46E5)
- **Secondary**: Cyan (#06B6D4)
- **Accent**: Amber (#F59E0B)
- **Success**: Emerald (#10B981)
- **Error**: Red (#EF4444)
- **Warning**: Amber (#F59E0B)

#### Typography
- **Font Family**: Inter (Google Fonts)
- **Responsive**: Scales based on screen size
- **Consistent**: Predefined text styles for all use cases

### 🚀 Getting Started

1. **Run the app**:
   ```bash
   flutter run
   ```

2. **Current Status**:
   - ✅ Clean architecture structure created
   - ✅ Core theme and constants implemented
   - ✅ Splash screen with loading animation
   - 🔄 Features implementation in progress

### 📋 Next Steps

1. **Authentication Feature**:
   - Login/Register screens
   - User state management
   - Firebase integration

2. **Home Feature**:
   - Dashboard screen
   - Navigation structure
   - User profile management

3. **Housing Feature**:
   - Roommate finder
   - Hostel listings
   - Search and filtering

### 🧪 Tested Pages

The `tested_pages/` folder contains previously developed screens that can be referenced during implementation:
- Login/Register screens
- University selection
- Home dashboard
- Housing listings
- Roommate request cards

### 🔧 Development Guidelines

1. **Follow Clean Architecture**: Keep layers separated and dependencies pointing inward
2. **Use Design System**: Utilize predefined colors, typography, and components
3. **Responsive Design**: Use `AppUtils` for responsive layouts
4. **Consistent Naming**: Follow Dart naming conventions
5. **State Management**: Use Provider/Riverpod for state management
6. **Error Handling**: Implement proper error handling and user feedback

### 📱 Features Overview

**PulseCampus** is a comprehensive student life app featuring:

- 🏠 **Housing & Roommates**: Find accommodation and roommates
- 🛒 **Marketplace**: Buy/sell items within campus
- 📰 **Campus News**: Stay updated with university news
- 🎉 **Events**: Discover and join campus events
- 📊 **Polls**: Participate in campus polls
- 💬 **Messaging**: Connect with other students

### 🎯 Target Users

- **Students**: Primary users looking for housing, roommates, and campus services
- **Hostel Providers**: Secondary users offering accommodation services

---

*This architecture ensures scalability, maintainability, and testability of the PulseCampus application.*

