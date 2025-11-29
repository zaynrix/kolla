# Kolla - Architektur-Dokumentation

## 1. Architektur-Übersicht

Kolla ist ein kollaboratives Aufgabenmanagementsystem, das nach dem **MVCS (Model-View-Controller-Service)** Architekturmuster entwickelt wurde. Die Architektur ist darauf ausgelegt, die Anforderungen an Modifiability, Testability, Usability, Security und Portability zu erfüllen.

## 2. Architektur-Entscheidungen

### 2.1 MVCS-Pattern

**Entscheidung**: Verwendung des MVCS-Patterns (Model-View-Controller-Service)

**Begründung**:
- **Modifiability**: GUI und Anwendungslogik sind strikt getrennt. GUI-Änderungen haben keine Auswirkung auf die Business-Logik und umgekehrt.
- **Testability**: Jede Schicht kann unabhängig getestet werden.
- **Portability**: Das GUI kann für verschiedene Plattformen (Web, Mobile, Desktop) ausgetauscht werden, ohne die Anwendungslogik zu ändern.

**Schichten**:
- **Model**: Reine Datenklassen ohne Business-Logik
- **View**: UI-Komponenten, die nur Daten anzeigen und Benutzerinteraktionen an Controller weiterleiten
- **Controller**: Verwaltet den State und koordiniert zwischen View und Service
- **Service**: Datenzugriff und Business-Logik, abstrahiert durch Interfaces

### 2.2 Provider für State Management

**Entscheidung**: Verwendung von Provider für State Management

**Begründung**:
- Einfach zu verstehen und zu testen
- Gute Performance durch selektive Rebuilds
- Gut dokumentiert und weit verbreitet
- Erfüllt die Anforderung, dass GUI und Logik unabhängig sind

### 2.3 Service-Interfaces

**Entscheidung**: Abstraktion der Services durch Interfaces

**Begründung**:
- **Modifiability**: Mock-Services können einfach durch echte API-Services ersetzt werden
- **Testability**: Services können für Tests gemockt werden
- **Flexibilität**: Verschiedene Implementierungen können zur Laufzeit ausgetauscht werden

### 2.4 Stream-basierte Real-time Updates

**Entscheidung**: Verwendung von RxDart Streams für Real-time Updates

**Begründung**:
- **Usability**: Automatische Updates ohne Benutzerinteraktion (Anforderung 3.3)
- **Performance**: Effiziente Datenübertragung
- **Skalierbarkeit**: Kann später auf WebSockets erweitert werden

### 2.5 go_router für Navigation

**Entscheidung**: Verwendung von go_router für deklarative Navigation

**Begründung**:
- Type-safe Routing
- URL-basierte Navigation (wichtig für Web)
- Einfach zu testen und zu warten

## 3. Qualitätsanforderungen

### 3.1 Modifiability

**Anforderung**: GUI-Integration in max. 2 Stunden, GUI-Änderungen in max. 1 Stunde

**Umsetzung**:
- Strikte Trennung von View und Controller durch Provider
- Service-Interfaces ermöglichen einfachen Austausch
- Keine direkten Abhängigkeiten zwischen View und Service

**Beispiel**: Ein neues GUI kann implementiert werden, indem:
1. Neue View-Komponenten erstellt werden
2. Bestehende Controller verwendet werden
3. Keine Änderungen an Services oder Models erforderlich sind

### 3.2 Testability

**Anforderung**: Unit-Tests in max. 2 Stunden entwickelbar

**Umsetzung**:
- Jede Schicht kann isoliert getestet werden
- Services können durch Mock-Implementierungen ersetzt werden
- Controller können ohne UI getestet werden

**Test-Struktur**:
```
test/
├── models/          # Model-Tests
├── services/        # Service-Tests
├── controllers/     # Controller-Tests
└── utils/           # Utility-Tests
```

### 3.3 Usability

**Anforderung**: Mindestens 2 verschiedene Darstellungen, automatische Updates

**Umsetzung**:
- **List View**: Prioritätsgruppierte Listenansicht
- **Chart View**: Pie-Chart für Prioritätsverteilung
- **Kanban View**: Board-Ansicht im Workflow Manager
- Stream-basierte automatische Updates ohne Benutzerinteraktion

### 3.4 Security

**Anforderung**: Zugriff innerhalb von 0,5 Sekunden

**Umsetzung**:
- Rollenbasierte Zugriffskontrolle (RBAC) in Models
- Service-Layer filtert Daten basierend auf Actor-Rolle
- Effiziente Datenstrukturen für schnellen Zugriff

### 3.5 Portability

**Anforderung**: Portierung auf neue Plattform in max. 4 Stunden

**Umsetzung**:
- View-Layer ist plattformunabhängig
- Controller und Services sind plattformunabhängig
- Nur View-Komponenten müssen für neue Plattform angepasst werden

## 4. Prioritätsberechnung

Die Prioritätsberechnung folgt den Anforderungen:

- **Sofort (immediate)**: ≤ 8 Stunden bis zum Deadline
- **Mittelfristig (medium)**: > 8 und ≤ 32 Stunden
- **Langfristig (longTerm)**: > 32 Stunden

Die Berechnung berücksichtigt:
- Verbleibende Zeit bis zum Deadline
- Dauer des aktuellen Arbeitsschritts
- Dauer der nachfolgenden Arbeitsschritte (geschätzt mit 8h pro Schritt)

## 5. Workflow-Management

- **Sequenzielle Workflows**: Arbeitsschritte werden nacheinander abgearbeitet
- **Automatische Zuweisung**: Nach Abschluss wird der nächste Schritt automatisch dem nächsten Akteur zugewiesen
- **Manuelle Priorisierung**: Workflow-Manager kann Prioritäten manuell überschreiben
- **Real-time Updates**: Alle Views werden automatisch aktualisiert

## 6. Erweiterbarkeit

Die Architektur ist darauf ausgelegt, erweitert zu werden:

- **Komplexere Workflows**: Service-Interfaces ermöglichen verschiedene Workflow-Implementierungen
- **Mandantenfähigkeit**: Kann durch zusätzliche Model-Felder implementiert werden
- **System-Akteure**: Actor-Model kann um System-Akteure erweitert werden
- **Verschiedene Priorisierungsverfahren**: PriorityCalculator kann erweitert werden

## 7. Technologie-Stack

- **Flutter Web**: Für plattformübergreifende Web-Applikation
- **Provider**: State Management
- **go_router**: Navigation
- **RxDart**: Streams für Real-time Updates
- **fl_chart**: Visualisierungen

## 8. Nächste Schritte

1. ✅ MVCS-Architektur implementiert
2. ✅ Service-Interfaces erstellt
3. ✅ Real-time Updates implementiert
4. ⏳ Unit-Tests hinzufügen
5. ⏳ Benachrichtigungssystem erweitern
6. ⏳ RBAC vollständig implementieren
7. ⏳ Persistierung vorbereiten

