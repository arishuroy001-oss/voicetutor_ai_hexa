# 🎙 VoiceTutor AI

**Hands-Free Voice-Based Exam Preparation for Indian Competitive Exams**

> Built with Flutter · Gemini 1.5 Flash · Picovoice Porcupine · Hive · Riverpod

---

## Overview

VoiceTutor AI lets exam aspirants practice unlimited questions entirely through voice — no screen interaction required. Say **"Hey Tutor"** to begin, speak your answers, and receive instant AI-evaluated feedback in Bengali or English.

---

## Project Structure

```
voicetutor_ai/
├── lib/
│   ├── main.dart                         # App entry point
│   ├── utils/constants.dart              # API keys & config
│   ├── models/
│   │   ├── question.dart                 # Hive model (typeId: 0)
│   │   ├── question.g.dart               # Generated adapter
│   │   ├── user_progress.dart            # Hive model (typeId: 1)
│   │   ├── user_progress.g.dart          # Generated adapter
│   │   └── exam.dart                     # Exam definitions
│   ├── services/
│   │   ├── voice_service.dart            # STT + TTS (singleton)
│   │   ├── wake_word_service.dart        # Porcupine wake word
│   │   ├── ai_service.dart               # Gemini Q-gen + eval
│   │   └── pyq_service.dart              # Previous Year Questions
│   ├── providers/
│   │   ├── practice_provider.dart        # Core state machine
│   │   └── progress_provider.dart        # Progress data
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── exam_selector_screen.dart
│   │   ├── language_selector_screen.dart
│   │   ├── practice_screen.dart          # Main voice screen
│   │   └── progress_screen.dart
│   └── widgets/
│       └── animated_mic.dart             # Animated mic indicator
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   ├── proguard-rules.pro
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/voicetutor/ai/MainActivity.kt
│   │       └── res/values/{styles,colors}.xml
│   ├── build.gradle
│   ├── gradle.properties
│   ├── settings.gradle
│   └── gradle/wrapper/gradle-wrapper.properties
├── assets/
│   ├── Hey_Tutor.ppn          # Picovoice wake word file (download separately)
│   ├── pyq_database.json      # Previous Year Questions
│   └── lottie/mic_pulse.json  # Mic animation
└── pubspec.yaml
```

---

## Quick Start

### 1. Prerequisites

- Flutter SDK 3.19+
- Android Studio + Android SDK (API 21+)
- Java JDK 17+
- Physical Android device (emulators don't support wake word)

### 2. Get API Keys

#### Gemini API Key (Free)
1. Visit https://ai.google.dev/
2. Click **Get API key** → Create API key in new project
3. Copy the key

#### Picovoice Access Key + Wake Word File
1. Visit https://console.picovoice.ai
2. Sign up (free) → Copy your **AccessKey**
3. Go to Porcupine → Train Wake Word
4. Phrase: `Hey Tutor` | Language: English | Platform: Android
5. Train → Download `.ppn` file → rename to `Hey_Tutor.ppn`
6. Place in `assets/Hey_Tutor.ppn`

#### Firebase Setup
1. Create a project at https://console.firebase.google.com
2. Add Android app with package name `com.voicetutor.ai`
3. Download `google-services.json` → place in `android/app/`

### 3. Configure Keys

Edit `lib/utils/constants.dart`:
```dart
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
static const String picovoiceAccessKey = 'YOUR_PICOVOICE_ACCESS_KEY_HERE';
```

### 4. Install & Build

```bash
# Install dependencies
flutter pub get

# Generate Hive adapters (already pre-generated, but run if you modify models)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on connected device
flutter run

# Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (Play Store)
flutter build appbundle --release
```

---

## Supported Exams

| Category     | Exams |
|--------------|-------|
| West Bengal  | WB Panchayat, WB PSC Clerkship, WB Police Constable, WB Police SI, WBCS, WB Group D |
| SSC          | SSC CGL, SSC CHSL, SSC MTS, SSC GD, SSC Stenographer |
| Railway      | RRB NTPC, RRB Group D, RRB ALP, RRB JE |
| Banking      | SBI PO, SBI Clerk, IBPS PO, IBPS Clerk, IBPS RRB, RBI Grade B |

---

## Voice Commands

| Command | Action |
|---------|--------|
| "Hey Tutor" | Start practice session |
| "Stop" / "বন্ধ করো" | End session |
| "Skip" / "Next" | Skip current question |
| "Repeat" / "আবার" | Repeat current question |
| "I don't know" / "জানি না" | Reveal answer & explanation |

---

## Architecture

```
State Machine (PracticeState):
IDLE → LISTEN_WAKE → GENERATING → SPEAKING_Q → LISTENING_ANS → EVALUATING → SPEAKING_FB → (loop)
```

Key design decisions:
- **Riverpod** StateNotifier for the voice state machine
- **Singleton services** (VoiceService, AIService) to prevent duplicate initializations
- **70% AI / 30% PYQ** hybrid question generation
- **Hive** for offline question cache (7-day TTL) and progress tracking
- **Semantic evaluation** via Gemini (not string matching)

---

## Cost Estimate

| Users/month | Gemini | Picovoice | Firebase | Total |
|------------|--------|-----------|----------|-------|
| 100 | $0 | $0 | $0 | ~$0 |
| 1,000 | ~$15 | $99 | ~$5 | ~$119 |
| 10,000 | ~$150 | $199 | ~$50 | ~$399 |

---

## License

MIT — © 2026 VoiceTutor AI
