# offline-ems-triage-flutter
A high-performance, resilient Paramedic Triage Intake Application built with Flutter and Dart. 
Designed specifically for emergency medical services (EMS) operating in high-stress, low-connectivity, or zero-network environments.

## Key Features
* **Offline-First Resilience Engine:** Intercepts submissions when offline, instantly saving records locally to prevent critical patient data loss.
* **Automated Background Sync Queue:** Monitors network state changes and automatically streams or batch-uploads cached records to the server upon connection restoration without user intervention.
* **High-Visibility UI:** Single-screen design optimized for fast, under-pressure thumb input, featuring visual hazard color-coding (deep reds/oranges) for critical Priority 1 & 2 cases.
* **Decoupled Architecture:** Production-grade state management ensuring strict separation of concerns between UI presentation, data persistence, and sync logic.

## Technical Stack
* **Framework:** Flutter (Dart)
* **Local Persistence:** Hive (Lightweight, ultra-fast NoSQL storage)
* **State Management:** Riverpod / Provider
* **Network Monitoring:** Connectivity Plus
