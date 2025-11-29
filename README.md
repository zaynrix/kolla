# Kolla

Ein kollaboratives Aufgabenmanagementsystem entwickelt im Rahmen des Projekts "Software-Architekturen und Qualitätssicherung" an der TH Brandenburg.

Kolla steuert die Zusammenarbeit von verschiedenen Akteuren per Workflow, ermöglicht eine individuelle Arbeitsplanung mit Priorisierung und unterstützt eine immer aktuelle Fortschrittsüberwachung.

## Features

- 🎯 **Aufgabenmanagement**: Erstellen, verfolgen und verwalten von Aufgaben mit Arbeitsschritten
- 👥 **Akteur-Ansichten**: Individuelle Dashboards für Teammitglieder
- 📊 **Workflow-Manager**: Kanban-Board-Ansicht mit Deadline-Tracking
- 🔄 **Echtzeit-Updates**: Stream-basierte automatische Aktualisierungen ohne Benutzerinteraktion
- 📈 **Prioritätssystem**: Automatische Priorisierung basierend auf Deadlines
  - **Sofort**: ≤ 8 Stunden bis zum Deadline
  - **Mittelfristig**: > 8 und ≤ 32 Stunden
  - **Langfristig**: > 32 Stunden
- 🎨 **Moderne UI**: Responsives Design mit Material 3
- 🔐 **Rollenbasierte Zugriffskontrolle**: Arbeitsschritte sind an Rollen gebunden
- 📱 **Mehrere Ansichten**: List, Chart und Kanban-Ansichten für verschiedene Bedürfnisse

## Architektur

Das Projekt implementiert eine **MVCS (Model-View-Controller-Service)** Architektur, die folgende Qualitätsanforderungen erfüllt:

- **Modifiability**: GUI und Anwendungslogik sind strikt getrennt und unabhängig änderbar
- **Testability**: Jede Schicht kann isoliert getestet werden
- **Usability**: Mehrere Darstellungsformen und automatische Updates
- **Security**: Rollenbasierte Zugriffskontrolle
- **Portability**: GUI kann für verschiedene Plattformen ausgetauscht werden

### Architektur-Komponenten

- **Model**: Reine Datenklassen ohne Business-Logik
- **View**: UI-Komponenten (austauschbar)
- **Controller**: State Management mit Provider
- **Service**: Datenzugriff und Business-Logik (abstrahiert durch Interfaces)

Siehe [ARCHITECTURE.md](docs/ARCHITECTURE.md) für detaillierte Architektur-Dokumentation.

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

## Qualitätsanforderungen

Das Projekt erfüllt die folgenden Qualitätsanforderungen:

- ✅ **Modifiability**: GUI-Integration in max. 2h, Änderungen in max. 1h
- ✅ **Testability**: Unit-Tests entwickelbar in max. 2h
- ✅ **Usability**: Mindestens 2 Darstellungen, automatische Updates
- ✅ **Security**: Zugriff innerhalb von 0,5 Sekunden
- ✅ **Portability**: Portierung auf neue Plattform in max. 4h

## Tests

```bash
flutter test
```

Unit-Tests für Models und Services sind implementiert.

## Dokumentation

- [Architektur-Dokumentation](docs/ARCHITECTURE.md)
- [Deployment Guide](DEPLOYMENT.md)

## Projekt-Kontext

Dieses Projekt wurde im Rahmen des Moduls "Software-Architekturen und Qualitätssicherung" an der TH Brandenburg entwickelt.

**Wintersemester 2025/2026**  
**Prof. Dr. Gabriele Schmidt**
