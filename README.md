# Kolla

A collaborative task management system built with Flutter Web, featuring MVCS architecture, Provider state management, and go_router for navigation.

## Features

- 🎯 **Task Management**: Create, track, and manage tasks with work steps
- 👥 **Actor Views**: Individual dashboards for team members
- 📊 **Workflow Manager**: Kanban board view similar to Trello/Jira
- 🔄 **Real-time Updates**: Stream-based real-time task updates
- 📈 **Priority System**: Automatic priority calculation based on deadlines
- 🎨 **Modern UI**: Beautiful, responsive design with Material 3

## Architecture

- **MVCS Pattern**: Model-View-Controller-Service separation
- **Provider**: State management
- **go_router**: Declarative routing
- **Mock Services**: Ready for API integration

## Tech Stack

- Flutter Web
- Provider (State Management)
- go_router (Routing)
- RxDart (Streams)
- fl_chart (Charts)
- Google Fonts

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run -d chrome
   ```

## Project Structure

```
lib/
├── models/          # Data models
├── services/        # Service layer (interfaces & mock implementations)
├── controllers/     # State management (Provider)
├── views/           # UI components
├── config/          # App configuration (routes, theme, constants)
└── utils/           # Utility functions
```

## License

This project is a prototype for demonstrating frontend architecture.
