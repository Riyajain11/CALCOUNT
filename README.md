# CalCount (AI Food & Macro Tracker)

**CalCount** is a photo-first mobile application designed to estimate calories and macronutrients on meal plates (especially Indian dishes and thalis) in seconds using Vision AI.

---

## 📁 Repository Structure

```
CalCount/
├── docs/                      # Original design documents and screen mockups
│   ├── AI Food & Macro Tracker – Core Screens.pdf
│   ├── AI Food and Macro Tracker – V1 Design Document.pdf
│   └── AI_Food_Macro_Tracker_V1_Design_Baseline.pdf
│
├── frontend/                  # Mobile Application Frontend (Flutter / Dart)
│   ├── android/               # Android native configuration
│   ├── lib/                   # Flutter source code
│   │   ├── api/               # API route contracts, client & error types
│   │   ├── core/              # Theme, colors, dimensions, date helpers
│   │   ├── data/              # Models & Repositories (Auth, Profile, Meal, Scan)
│   │   ├── estimator/         # NutritionEstimator abstraction seam
│   │   ├── logic/             # TargetCalculator, PortionScaler, AlertEvaluator, RetentionCleaner
│   │   ├── providers/         # Riverpod state management
│   │   ├── router/            # GoRouter navigation
│   │   └── ui/                # 14 Screens (Home, Scan, Result, History, Settings, Onboarding, Auth)
│   ├── test/                  # Automated unit and widget tests
│   └── pubspec.yaml           # Flutter dependencies
│
└── backend/                   # Backend Cloud Functions & Firebase Configuration
    └── README.md              # Backend specifications, API contracts & deploy instructions
```

---

## 🚀 Running the Frontend

To run the Flutter app:

```bash
cd frontend
flutter pub get
flutter run
```

To run automated tests:
```bash
cd frontend
flutter test
```

