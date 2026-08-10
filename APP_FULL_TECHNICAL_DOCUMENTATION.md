# HydroSmart Full Technical Documentation

## 1. Executive Overview
HydroSmart is a full-stack hydroponics farm management platform that combines:
- A cross-platform Flutter application for farmers and agribusiness users
- A Python backend for crop intelligence, data processing, and app update APIs
- An ML inference backend for crop recommendation based on environment and location
- Firebase services for authentication, real-time data, document storage, and app configuration

Primary objective: help hydroponic growers choose suitable crops, monitor farm conditions, and get AI-assisted operational guidance.

---

## 2. System Architecture

### 2.1 High-Level Components
1. Frontend App (Flutter)
- Platform targets: Android, iOS, Web, Windows, macOS, Linux
- UI modules for auth, dashboards, sensors, recommendations, finance, subsidies, growth tracking, and AI chat

2. Application Backend (Python Flask)
- Crop recommendation and crop catalog APIs
- Seasonal/state climate logic
- PDF crop data extraction and ingestion
- App update and runtime config endpoints

3. ML Backend (Python FastAPI)
- Model-based crop prediction APIs
- Trained RandomForest model with location and season-aware features

4. Firebase Platform
- Firebase Auth: login/sign-up
- Cloud Firestore: user profile, farms, crop and AI config/knowledge
- Realtime Database: sensor streams from IoT devices
- Firebase Storage: file/media support
- Firebase Messaging: notifications support

### 2.2 Layering Pattern (Frontend)
The Flutter app follows clean architecture boundaries in many features:
- Presentation layer: UI pages/widgets + Riverpod providers
- Domain layer: abstract repositories + domain models
- Data layer: concrete repository implementations + DTO models + service clients

### 2.3 Runtime Integration Topology
1. Mobile app authenticates via Firebase Auth
2. App reads/writes user and farm records in Firestore
3. Sensor streams are consumed from Realtime Database
4. Crop recommendations are fetched from Flask backend and/or FastAPI ML backend
5. AI chat uses Gemini with Firestore-hosted RAG context
6. Update checks call backend version endpoint

---

## 3. Frontend Architecture (Flutter)

### 3.1 Entry Points
- `lib/main.dart`: primary app bootstrap, Firebase init, splash/update integration
- `lib/main_new.dart`: alternate startup flow
- `lib/main_crop_example.dart`: isolated crop recommendation example flow

### 3.2 Core Modules
- `lib/core/config/api_config.dart`
  - Defines API base URLs for production/local
- `lib/core/theme/*`
  - App theme systems and reusable visual components
- `lib/core/providers/update_providers.dart`
  - Update flow state provisioning
- `lib/core/providers/update_service.dart`
  - Version check, APK download/install handoff
- `lib/core/services/error_handler.dart`
  - Cross-cutting error logic

### 3.3 Data and Domain Layers
- Data models:
  - recommendation, sensor, farm, user
- Repository implementations:
  - recommendation repository implementation for backend API calls
  - crop repository with API-first plus local JSON fallback
  - auth/farm/sensor repositories for Firebase-backed persistence and streams
- Domain contracts:
  - repository interfaces and filter models used by presentation layer

### 3.4 Key Feature Modules

1. Auth (`lib/features/auth`)
- Email/password auth and user profile setup
- Profile includes language, state, account type, and contact details
- Riverpod stream for auth state and user profile state

2. Dashboard (`lib/features/dashboard`)
- Main navigation hub and onboarding/tutorial entry points
- Integrates sensor summaries and shortcuts to major app capabilities

3. Crop Recommendation (`lib/features/crop_recommendation`)
- Crop browsing and detailed crop pages
- Advanced filtering (difficulty, technique, season, etc.)
- PDF upload workflow to extract crop data via backend
- ML/weather/location-assisted recommendation providers

4. Sensors (`lib/features/sensors`)
- Real-time provider for live device telemetry
- Historical persistence and retrieval logic through repositories

5. Farm (`lib/features/farm`)
- Farm CRUD and farm selection state
- Ownership tied to authenticated user profile

6. AI Chat (`lib/features/ai_chat`)
- RAG-style answer generation using Firestore knowledge documents
- Gemini integration with streaming responses
- Config values and API key loaded from Firestore config document

7. Additional Modules
- Market prices, finance tracking, growth tracking, subsidy advisor, marketplace, onboarding, profile, splash

### 3.5 State Management
HydroSmart uses Riverpod patterns:
- StreamProvider for auth and real-time Firebase streams
- StateNotifierProvider for mutation-heavy controllers (auth, farms, recommendation logic)
- FutureProvider for one-time async reads

### 3.6 Frontend Data Sources and Fallbacks
- Primary crop data source: backend crop APIs
- Fallback crop data source: local `assets/crop_dataset.json`
- Weather data: Open-Meteo and geocoding integration in feature services

---

## 4. Backend Architecture (Flask)

### 4.1 Service Responsibilities
- Health/status checks
- Core recommendation APIs
- Multi-crop ranking and crop compatibility scoring
- Seasonal and state-aware recommendation logic
- Crop catalog/category APIs
- PDF ingestion endpoint for crop knowledge extraction
- App update/version and config endpoints

### 4.2 Core Backend Modules
- `backend/app.py`
  - Flask app, route definitions, request handling
- `backend/crop_database.py`
  - Crop intelligence data store and recommendation scoring logic
- `backend/database.py`
  - Firestore integration utilities for crop records and searches
- `backend/pdf_extractor.py`
  - PDF parsing/extraction for crop data ingestion
- `backend/ml_api.py`
  - Supplemental ML API integration module

### 4.3 Recommendation Engine Logic
The backend recommendation process generally evaluates:
- Temperature fit
- Humidity fit
- pH fit
- Seasonal fit
- Regional/climate-zone suitability

Then computes a compatibility score and returns ranked options and details such as estimated harvest windows and expected output metrics.

### 4.4 Data Persistence
Backend persistence is Firestore-driven for crop entities and related metadata. Documents include status flags, source attribution, timestamps, and agronomic fields.

---

## 5. ML Backend Architecture (FastAPI)

### 5.1 Service Scope
The ML backend is a separate FastAPI service focused on predictive inference.

Primary endpoints include:
- Health and service metadata
- Single prediction endpoint
- Top-N recommendation endpoint
- Supported crop and location listing

### 5.2 Model and Features
Model type: RandomForestClassifier

Input feature family:
- Temperature
- Humidity
- Encoded location
- Month index
- Cyclical month encoding (sin/cos)
- Interaction features (for example temperature-humidity interaction)

Training pipeline supports synthetic generation plus optional real feed integration (for better distribution shaping).

### 5.3 Training Artifacts and Lifecycle
- Model artifact (`model.pkl`) generated during training/build pipeline
- Encoders/scalers bundled with model artifact
- Deployment build step can retrain before start, depending on target runtime strategy

---

## 6. Firebase Architecture

### 6.1 Auth
- Firebase Authentication for account lifecycle and session state

### 6.2 Firestore
Representative collections used across app features:
- `users`: user profiles and account metadata
- `farms`: user-owned farm records
- `devices/.../sensors`: sensor snapshots/streams (if mirrored)
- `ai_knowledge_base`: RAG context corpus
- `config`: runtime app config and AI config
- `crops`: backend-ingested crop records (including PDF-derived entries)

### 6.3 Realtime Database
- Live sensor telemetry consumed by app providers for near real-time dashboards and automations

### 6.4 Storage and Messaging
- Storage for file/media workflows
- Messaging for notification capability

---

## 7. API and Integration Contracts

### 7.1 Frontend to Flask Backend
The Flutter app calls recommendation and crop APIs using HTTP clients (Dio/HTTP).

Common request profile:
- temperature
- humidity
- pH
- farm size
- optional state/month/category/difficulty filters

Common response profile:
- recommended crop(s)
- confidence/compatibility score(s)
- crop metadata (time to harvest, expected output, required ranges)

### 7.2 Frontend to ML Backend
ML-specific predictions are requested with climate and location context:
- temperature
- humidity
- location
- month

Response includes predicted crop and confidence metrics; top-N endpoint returns ranked candidates.

### 7.3 Frontend to Firebase
- Auth for identity/session
- Firestore streams and snapshots for user/farm/chat config data
- Realtime DB subscriptions for sensor telemetry

### 7.4 AI Chat Integration Pattern
1. Receive user query
2. Retrieve relevant docs from Firestore knowledge base
3. Build contextual prompt
4. Call Gemini model
5. Stream response chunks to UI

---

## 8. Data Architecture

### 8.1 Static and Semi-Static Data Assets
- `assets/crop_dataset.json`: local fallback crop dataset for offline/API failure continuity
- `feeds.csv`: sensor feed data used by ML training utilities

### 8.2 Derived/Generated Data
- Trained model artifacts and preprocessing objects
- Firestore crop records from PDF extraction/import

### 8.3 Data Quality Considerations
- Field schema consistency between backend crop model and frontend crop model
- Unit normalization (temperature, humidity, pH bounds)
- Seasonal and region mapping correctness
- Duplicate crop entry handling during ingestion

---

## 9. Deployment and Operations

### 9.1 Deployment Targets
- Flutter app binaries for mobile and desktop/web
- Render-hosted Python services (Flask/FastAPI)
- Firebase project for cloud services and runtime configuration

### 9.2 Containerization
- Dockerfiles exist at repository root and backend folders
- Services expose configurable host/port and rely on environment variables where applicable

### 9.3 Render Configuration
- `render.yaml` defines service runtime, build/start commands, health route, and plan settings

### 9.4 Runtime Configuration Surface
- API base URLs in Flutter config
- Firebase project binding in generated options
- Backend model path/port settings
- Update service config endpoint and release metadata

### 9.5 Observability and Reliability
Current baseline:
- Health endpoints for backend services
- Basic exception handling in UI/backend
- Log-based troubleshooting docs in repository

Recommended next maturity steps:
- Structured logging and correlation IDs
- Error telemetry dashboarding
- API latency and failure-rate monitoring
- Alerting on health endpoint degradation

---

## 10. Security Architecture

### 10.1 Identity and Access
- Firebase Auth controls user identity
- Firestore/Realtime Database rules enforce resource access boundaries

### 10.2 Secrets and Config
- API keys and credentials should remain outside version-controlled plain text
- Firestore-hosted AI config should be rules-protected and admin-writable only

### 10.3 Transport and Endpoint Security
- Use HTTPS for all production API endpoints
- Restrict CORS origins to expected clients in production
- Validate request payloads and enforce schema at API boundaries

### 10.4 Data Governance
- Avoid storing sensitive PII unnecessarily
- Apply data retention/deletion strategy for telemetry and chat traces

---

## 11. Testing and Quality

### 11.1 Flutter Testing
- Repository-level tests exist for recommendation logic patterns
- `flutter_test` based unit tests

### 11.2 Python Testing
- API test files exist in backend module
- Expand contract tests for all major endpoints and edge cases

### 11.3 Static Analysis and Linting
- Flutter lint setup in `analysis_options.yaml`
- Python dependencies pinned; optional improvement: integrate lint/type checks into CI

### 11.4 Recommended Quality Pipeline
1. Flutter: format, analyze, test
2. Python backend: lint, unit test, API contract test
3. Build and smoke test containers
4. Run staged deployment health checks

---

## 12. End-to-End Workflow Scenarios

### 12.1 New User Onboarding
1. User registers with Firebase Auth
2. Profile stored in Firestore
3. User creates/selects farm
4. Dashboard initializes sensor and recommendation context

### 12.2 Live Crop Recommendation
1. App receives sensor/environment values
2. App sends request to recommendation API/ML API
3. Backend computes and returns ranked crops
4. UI displays recommendation details and confidence

### 12.3 Sensor Monitoring
1. Device publishes readings to Realtime Database
2. Stream providers update UI in near real-time
3. User monitors anomalies and trend panels

### 12.4 AI Advisory Chat
1. User asks agronomy question
2. App retrieves RAG documents
3. Gemini response generated and streamed
4. User gets context-grounded answer

### 12.5 Crop Knowledge Expansion via PDF
1. User uploads agronomy PDF
2. Backend extracts crop fields and normalizes records
3. Records written to Firestore
4. App can consume expanded crop catalog

---

## 13. Folder-by-Folder Technical Map

### 13.1 Frontend
- `lib/core`: global app systems (theme, config, providers, utilities)
- `lib/data`: implementations, DTOs, service adapters
- `lib/domain`: interfaces and domain models
- `lib/features`: feature-centric presentation + state + service orchestration
- `assets`: static datasets/models/labels
- `test`: Flutter test suites

### 13.2 Backend
- `backend`: Flask APIs, Firestore integration, crop intelligence and PDF extraction
- `ml_backend`: FastAPI inference service and training pipeline

### 13.3 Platform and Tooling
- `android`, `ios`, `web`, `windows`, `macos`, `linux`: Flutter platform runners
- `firebase.json`: Firebase integration metadata
- `Dockerfile` and `render.yaml`: deployment/build infrastructure

---

## 14. Known Architectural Strengths
1. Practical hybrid architecture: Firebase + custom Python services
2. Resilience via local crop dataset fallback
3. Modular feature structure in Flutter with Riverpod state boundaries
4. Separate ML inference backend allows independent scaling and model iteration
5. Domain-focused functionality for hydroponics operations (season, climate, crop economics)

## 15. Known Architectural Risks
1. Multi-backend endpoint coordination complexity (Flask + FastAPI + Firebase)
2. Potential schema drift between frontend models and backend responses
3. Secret/config management risk if credentials are not fully externalized
4. Free-tier hosting limitations (cold starts, memory/CPU constraints)
5. Need for stronger automated test and CI coverage for regression safety

---

## 16. Recommended Improvements (Implementation Roadmap)
1. API Governance
- Introduce OpenAPI specs and generated clients
- Add strict request/response validation

2. Configuration and Secrets
- Move all sensitive values to environment-managed secret stores
- Add startup config validation and redacted logging

3. Data and Model Consistency
- Version crop schema and model features explicitly
- Add migration tooling for Firestore documents

4. Reliability
- Add retries/circuit breakers for inter-service calls
- Add caching for read-heavy recommendation and catalog endpoints

5. CI/CD
- Add end-to-end pipeline for Flutter + Python services
- Enforce lint, tests, and health smoke tests before deployment

6. Observability
- Add centralized logging, metrics, and alerting
- Track recommendation quality metrics and model drift indicators

---

## 17. Developer Runbook (Quick Ops)

### 17.1 Frontend
- Install Flutter dependencies
- Configure Firebase project and generated options
- Run app on target platform

### 17.2 Flask Backend
- Create Python environment
- Install requirements
- Run Flask app and test health endpoint

### 17.3 FastAPI ML Backend
- Install requirements
- Train model
- Run service and verify health and predict endpoints

### 17.4 Integration Smoke Checklist
1. Auth works end-to-end
2. Sensor data stream appears in dashboard
3. Recommendation endpoint responds with valid crop object
4. AI chat returns streamed answer
5. Update endpoint returns compatible payload

---

## 18. Conclusion
HydroSmart is a comprehensive agri-tech platform with a strong functional surface: real-time sensing, recommendation intelligence, and AI advisory support. Its architecture is already modular and practical for product iteration. The next major gains are in standardization (API/schema), operational rigor (CI/monitoring), and production hardening (security/secrets/reliability).

This document is intended to be the single master technical reference for engineering, deployment, and maintenance of the HydroSmart application stack.

---

## 19. Detailed Frontend Specification

### 19.1 Bootstrap and Startup Lifecycle
1. `main()` initializes Flutter binding.
2. Firebase initializes with generated platform options.
3. Global providers are attached via Riverpod `ProviderScope`.
4. Splash/onboarding gate is evaluated.
5. Auth stream resolves current user.
6. Route selection sends user to login or main dashboard shell.
7. Update check is triggered in startup-safe zone (non-blocking unless forced).

### 19.2 Navigation and Screen Topology
Primary user journey:
1. Splash
2. Authentication
3. Home dashboard
4. Domain module entry points (crop, sensors, farm, finance, subsidy, AI chat)

Operational note:
- Feature entry points are independent enough to allow partial offline behavior when backend APIs are unavailable.

### 19.3 Provider and State Ownership Model
Provider responsibilities are separated by concern:
- Session identity state: auth stream provider
- User profile state: Firestore-backed profile stream
- Feature mutation controllers: state notifier providers
- Async fetches: future providers
- Real-time telemetry: stream providers

Design result:
- UI components remain mostly declarative.
- Business logic is centralized in controllers/repositories.
- Data source substitution (API/fallback JSON) is possible without large UI refactors.

### 19.4 Feature-Level Deep Dive

Auth feature:
- Handles registration, login, and profile persistence.
- Maintains account segmentation (`farmer` vs `company`) for future authorization branching.
- Fails safely with user-readable error strings and retained form context.

Dashboard feature:
- Aggregates high-value summaries (sensor values, recommendations, navigation shortcuts).
- Hosts onboarding/tutorial anchors and guided interactions.

Crop recommendation feature:
- Supports catalog browsing and granular filtering.
- Supports recommendation pathways:
  - Rule/score based backend recommendation
  - ML endpoint prediction
  - Weather/location-assisted suggestion
- Supports ingestion extension via PDF upload to backend.

Sensors feature:
- Streams real-time telemetry from Firebase.
- Allows historical retrieval and display patterns.
- Designed for noisy data tolerance (sporadic updates, missing values).

Farm feature:
- Supports multi-farm ownership model per user.
- Selection state drives context for recommendations/sensor displays.

AI chat feature:
- Implements retrieval-augmented generation from Firestore knowledge docs.
- Streams response chunks for a progressive UI experience.

### 19.5 UI Resilience Behavior
Fallback hierarchy for crop data:
1. Backend API response
2. Local dataset asset
3. Empty-state with retry controls

Fallback hierarchy for recommendation:
1. Live backend recommendation
2. Cached/latest usable recommendation
3. Rule hint using available local values

### 19.6 Performance Characteristics (Frontend)
- Riverpod stream granularity reduces full-screen re-renders.
- Repository pattern supports memoization/caching insertion points.
- Async boundaries isolate network jitter from widget tree stability.

---

## 20. Detailed Backend Specification (Flask)

### 20.1 Service Initialization
Backend startup responsibilities:
1. Initialize Flask app and CORS policy.
2. Initialize or validate Firestore connectivity.
3. Preload crop intelligence structures.
4. Expose health route for orchestrator readiness checks.

### 20.2 Endpoint Contract Matrix (Detailed)

`GET /health`
- Purpose: liveness/readiness probe
- Typical response:
```json
{
  "status": "healthy",
  "service": "hydrosmart-api",
  "version": "v1",
  "crops_in_database": 120
}
```

`POST /api/v1/recommendations`
- Input fields:
  - temperature
  - humidity
  - pH
  - farmSize
  - optional state, month
- Output fields:
  - recommendedCrop
  - compatibilityScore
  - daysToHarvest
  - yieldPerSqm
  - profitMargin
  - reason/explanation metadata

`POST /api/v1/recommendations/multiple`
- Adds `count`, optional `category`, optional `difficulty`.
- Returns ranked candidate list with score and agronomic metadata.

`POST /api/v1/recommendations/evaluate`
- Evaluates a provided crop against input parameters.
- Useful for what-if analysis UI in the app.

`POST /api/v1/recommendations/seasonal`
- Uses state and month context to return season-prioritized recommendations.

`GET /api/v1/crops`
- Returns active crop catalog records.

`GET /api/v1/crops/{id}`
- Returns single crop details or not-found status.

`GET /api/v1/crops/category/{category}`
- Returns category-filtered crop list.

`POST /api/v1/upload-crop-pdf`
- Multipart upload endpoint.
- Extracts crop details and optionally persists them.
- Returns extraction/persistence summary.

`GET /api/app/version`
- Provides app update metadata.
- Supports optional forced-update controls.

`GET /api/app/config`
- Returns configurable app runtime flags.

### 20.3 Recommendation Scoring Logic (Conceptual)
Compatibility score includes weighted components:
- Temperature fit
- Humidity fit
- pH fit
- Seasonal fit
- Regional suitability

Generalized score form:
$$
Score = 100 \times (w_t f_t + w_h f_h + w_p f_p + w_s f_s + w_r f_r)
$$
with $\sum w_i = 1$.

### 20.4 Error Model and Status Behavior
Recommended status behavior (implemented or target state):
- 200: success
- 400: validation/input errors
- 404: missing resource
- 429: rate limited
- 500: unhandled backend error

Recommended error payload shape:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Humidity must be between 0 and 100",
    "details": {
      "field": "humidity"
    }
  }
}
```

---

## 21. Detailed ML Backend Specification (FastAPI)

### 21.1 Inference API Contract
`POST /predict`
- Input:
```json
{
  "temperature": 25.0,
  "humidity": 62.0,
  "location": "Karnataka",
  "month": 3
}
```
- Output:
```json
{
  "recommended_crop": "Tomato",
  "confidence": 92.3,
  "location_used": "Karnataka",
  "input_summary": {
    "temperature": 25.0,
    "humidity": 62.0,
    "month": 3
  }
}
```

`POST /predict/top`
- Same input plus `n`.
- Returns ranked probability candidates.

### 21.2 Feature Engineering Details
Core engineered features:
1. Raw temperature
2. Raw humidity
3. Encoded location index
4. Month index
5. `sin(month)` seasonal cyclic component
6. `cos(month)` seasonal cyclic component
7. Temperature-humidity interaction feature

Seasonality encoding rationale:
- Avoids discontinuity between month 12 and month 1 by representing month on a unit circle.

### 21.3 Model Quality and Validation Strategy
Recommended quality checks:
1. Train/test split metrics
2. Cross-validation consistency
3. Per-crop precision/recall review
4. Drift checks when feed distributions change

### 21.4 Model Lifecycle Controls
- Version model artifacts and preprocessing bundle together.
- Track training data snapshot and generation parameters.
- Expose model version in `/health` response.

---

## 22. Data Schema Reference

### 22.1 User Profile Schema (`users`)
Representative fields:
- uid
- email
- fullName
- phone
- state
- language
- accountType
- createdAt
- updatedAt

### 22.2 Farm Schema (`farms`)
Representative fields:
- id
- ownerId
- name
- location
- deviceId
- areaSqm
- cropType
- createdAt
- updatedAt

### 22.3 Sensor Sample Schema (`devices/{deviceId}/sensors`)
Representative fields:
- timestamp
- temperature
- humidity
- pH
- ec
- dissolvedOxygen
- sourceDevice

### 22.4 Crop Schema (`crops`)
Representative fields:
- id
- name
- emoji
- category
- difficulty
- temperatureRange
- humidityRange
- pHRange
- daysToHarvest
- yieldPerSqm
- profitMargin
- active
- source
- createdAt

### 22.5 AI Knowledge Schema (`ai_knowledge_base`)
Representative fields:
- id
- title
- topic
- content
- tags
- updatedAt

---

## 23. End-to-End Sequence Narratives

### 23.1 Authenticated Startup Sequence
1. App boots and initializes Firebase.
2. Auth stream resolves current user.
3. If user exists, profile stream fetches user document.
4. Dashboard loads with user context and farm selection.
5. Sensor stream subscriptions start for selected farm/device.

### 23.2 Recommendation Sequence (Hybrid)
1. UI captures live or manual environment inputs.
2. App sends recommendation request to Flask backend.
3. Optional ML prediction request is sent to FastAPI backend.
4. Client combines/chooses recommendation set.
5. UI presents crop cards with confidence and actionability details.

### 23.3 PDF Ingestion Sequence
1. User chooses PDF in app.
2. App uploads multipart file to backend endpoint.
3. Backend extracts candidate crop fields.
4. Backend validates and persists normalized entries.
5. App displays extraction and persistence result counts.

### 23.4 AI Chat Sequence
1. User sends agronomy question.
2. App retrieves relevant knowledge docs.
3. Prompt context is assembled.
4. LLM call streams response chunks.
5. Chat UI appends chunks until completion.

---

## 24. Environment and Configuration Matrix

### 24.1 Frontend Runtime Variables
Typical runtime configuration surfaces:
- API base URL
- ML endpoint URL
- update service URL
- feature flags (maintenance mode, minimum supported version)

### 24.2 Backend Environment Variables (Recommended)
- `PORT`
- `FLASK_ENV`
- `FIREBASE_CREDENTIALS_PATH` or credential JSON env payload
- `CORS_ALLOWED_ORIGINS`
- `LOG_LEVEL`

### 24.3 ML Backend Environment Variables (Recommended)
- `PORT`
- `MODEL_PATH`
- `PYTHON_VERSION`
- `LOG_LEVEL`

### 24.4 Configuration Governance
1. Keep non-secret config in checked-in templates.
2. Keep secrets in deploy platform secret manager.
3. Validate required config at startup and fail fast with clear logs.

---

## 25. Reliability and Failure Handling

### 25.1 Expected Failure Modes
1. Backend cold start delays
2. Intermittent sensor stream disconnects
3. Firestore rules misconfiguration
4. ML model artifact unavailable
5. Third-party AI API throttling

### 25.2 Mitigation Patterns
1. Client-side timeout and retry with backoff
2. Circuit-breaker behavior for repeated backend failures
3. Cached fallback recommendations and local crop catalog
4. Health-based routing and startup validation
5. User-facing degraded-mode messaging

### 25.3 SLO/SLA Candidate Targets
- Recommendation API availability: 99.5%
- P95 recommendation response time: < 2.5 seconds
- Sensor stream freshness lag: < 10 seconds (when source active)

---

## 26. Security Hardening Checklist (Detailed)

### 26.1 Authentication and Authorization
1. Enforce authenticated writes for user-owned documents.
2. Restrict config and AI key documents to privileged roles.
3. Validate ownership checks for farm/device reads and writes.

### 26.2 Input Validation
1. Enforce numeric ranges for agronomic inputs.
2. Sanitize free text where needed.
3. Reject malformed multipart uploads.

### 26.3 Secrets Handling
1. Remove plaintext secrets from repository history where needed.
2. Use environment-backed secret injection in deployment.
3. Rotate API keys and service credentials periodically.

### 26.4 Auditability
1. Log admin config changes.
2. Log failed authentication and permission denials.
3. Add immutable deployment/version metadata to logs.

---

## 27. Testing Blueprint (Detailed)

### 27.1 Frontend Test Categories
1. Unit tests for provider/controller logic
2. Repository tests with mocked API/Firebase layers
3. Widget tests for primary screens and state transitions
4. Integration tests for auth-to-dashboard and recommendation journey

### 27.2 Backend Test Categories
1. Endpoint contract tests
2. Recommendation scoring logic tests
3. PDF extraction parser tests (valid/invalid samples)
4. Firestore integration tests with emulator or mocked gateway

### 27.3 ML Test Categories
1. Input schema validation tests
2. Prediction determinism/sanity tests for known samples
3. Regression tests across model versions
4. Health endpoint and artifact loading tests

### 27.4 Release Gate Criteria
1. All critical path tests pass
2. No P0/P1 open defects
3. Deployment smoke tests pass
4. Rollback plan verified

---

## 28. CI/CD and Release Management

### 28.1 Proposed Pipeline Stages
1. Source checkout and dependency install
2. Static analysis and formatting checks
3. Unit/integration test execution
4. Build artifacts (Flutter + backend containers)
5. Deploy to staging and run smoke tests
6. Promote to production on approval

### 28.2 Versioning Strategy
- App: semantic versioning + build number
- API: path-based versioning (`/api/v1`)
- Model: explicit model version tag in artifact metadata

### 28.3 Rollback Strategy
1. Keep previous deploy artifact and config snapshot.
2. Repoint traffic to prior stable release.
3. Validate health checks and critical journeys post-rollback.

---

## 29. Operations Runbooks

### 29.1 Incident: Recommendation API Down
1. Confirm `/health` status.
2. Check hosting logs for boot/import errors.
3. Validate Firestore credential availability.
4. Enable client degraded mode and fallback catalog usage.
5. Restore service and verify smoke checklist.

### 29.2 Incident: ML Endpoint Unavailable
1. Check model artifact presence and load logs.
2. Validate memory and startup timing constraints.
3. Temporarily route recommendations to rule-based backend only.

### 29.3 Incident: Sensor Data Stale
1. Confirm device publishing status.
2. Validate Realtime DB path and permissions.
3. Restart stream subscribers and inspect timestamp lag.

### 29.4 Incident: AI Chat Failing
1. Validate Gemini key retrieval path.
2. Check rate limit and API quota.
3. Fallback to static guidance content if needed.

---

## 30. Product Analytics and Telemetry Recommendations

### 30.1 Core Product Metrics
- Daily active users
- Recommendation requests per user
- Recommendation acceptance rate
- AI chat sessions and completion rate

### 30.2 Agronomic Outcome Metrics
- Crop cycle success rate
- Mean time to actionable recommendation
- Sensor anomaly detection frequency

### 30.3 Model Monitoring Metrics
- Confidence distribution drift
- Class distribution drift across crops
- Prediction latency and error rates

---

## 31. Glossary
- RAG: Retrieval-Augmented Generation
- EC: Electrical Conductivity
- pH: Potential of Hydrogen acidity/alkalinity measure
- DTO: Data Transfer Object
- SLO: Service Level Objective
- P95: 95th percentile latency

---

## 32. Final Note
Sections 1 through 18 provide architecture and implementation overview. Sections 19 through 31 provide deep operational, schema, reliability, security, testing, and lifecycle detail intended for engineering execution, audits, and long-term maintenance.
