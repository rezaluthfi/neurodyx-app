<div align="center">
  <img src="https://drive.google.com/uc?export=view&id=1S1GtMYawqnMkEjZhI3nEK1jv7ZJv_ZBU" alt="Neurodyx Logo" width="200"/>
  <p><em>Understand Dyslexia. Support. Empower.</em></p>
</div>

## 📱 Overview

Neurodyx is an integrated app designed to assist individuals with dyslexia by providing early screening detection, multisensory therapy, tracking progress, and reading support tools.

### ✨ Key Features

- **🧠 Smart Screening & Assessment**: Detect dyslexia in early and advanced stages through structured screening and evaluation
- **🎨 Multisensory Therapy**: Provide therapy using visual, tactile, auditory, and kinesthetic methods
- **🤖 Neurodyx Assistant**: AI-powered support to assist individuals with dyslexia in their developmental progress
- **📖 Scan Text**: Customizable text scanning and adjustment tools for personalized reading experiences
- **📊 Tracking Progress**: Monitor and visualize the progress of therapy sessions over time
- **📚 Get to Know Dyslexia**: Educational content about dyslexia, its causes, myths, and expert insights

## 🛠️ Tech Stack

- **Framework**: Flutter 3.24.0 with Dart 3.5.0
- **State Management**: Provider (https://pub.dev/packages/provider)
- **Authentication**: Firebase Authentication
- **Database**: Firebase Firestore
- **Storage**: Firebase Storage
- **AI Integration**: Gemini API
- **Text Recognition**: ML Kit Text Recognition
- **Ink Recognition**: ML Kit Digital Ink Recognition
- **Text-to-Speech**: flutter_tts (https://pub.dev/packages/flutter_tts)
- **Speech-to-Text**: speech_to_text (https://pub.dev/packages/speech_to_text)
- **Charts**: fl_chart (https://pub.dev/packages/fl_chart)

## 🚀 Getting Started

### Prerequisites

- Flutter 3.24.0 or higher

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/rezaluthfi/neurodyx-app
   cd neurodyx-app
   ```
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Create a `.env` file based on `.env.example`:

   ```bash
   cp .env.example .env
   ```

4. Fill in the environment variables in `.env`:

   - GEMINI_API_KEY=your_gemini_api_key
   - GEMINI_API_URL=your_gemini_api_url
   - BASE_URL_API=your_base_url_api

5. Start the app project:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib
├───core
│   ├───constants
│   ├───providers
│   ├───services
│   ├───widgets
│   └───wrappers
└───features
  ├───auth
  │   ├───data
  │   │   ├───repositories
  │   │   └───services
  │   ├───domain
  │   │   └───entities
  │   └───presentation
  │       ├───pages
  │       └───providers
  ├───chat
  │   ├───data
  │   │   ├───repositories
  │   │   └───services
  │   ├───domain
  │   │   └───entities
  │   └───presentation
  │       ├───pages
  │       ├───providers
  │       └───widgets
  ├───get_to_know
  │   └───presentation
  │       └───pages
  ├───home
  │   └───presentation
  │       └───pages
  ├───main
  │   └───presentation
  │       └───pages
  ├───multisensory_therapy_plan
  │   ├───domain
  │   │   └───repositories
  │   └───presentation
  │       ├───pages
  │       │   ├───auditory
  │       │   ├───data
  │       │   │   ├───models
  │       │   │   ├───repositories
  │       │   │   └───services
  │       │   ├───kinesthetic
  │       │   ├───tactile
  │       │   ├───visual
  │       │   └───widgets
  │       └───providers
  ├───onboarding
  │   ├───data
  │   │   └───models
  │   ├───domain
  │   │   └───entities
  │   └───presentation
  │       ├───controllers
  │       ├───pages
  │       └───widgets
  ├───profile
  │   └───presentation
  │       ├───controllers
  │       ├───pages
  │       └───widgets
  ├───progress
  │   ├───data
  │   │   ├───models
  │   │   ├───repositories
  │   │   └───services
  │   ├───domain
  │   │   ├───entities
  │   │   ├───repositories
  │   │   └───usecases
  │   └───presentation
  │       ├───pages
  │       └───providers
  ├───scan
  │   ├───data
  │   │   ├───models
  │   │   ├───repositories
  │   │   └───services
  │   │       └───tts
  │   │           └───models
  │   ├───domain
  │   │   ├───entities
  │   │   └───repositories
  │   └───presentation
  │       ├───pages
  │       ├───providers
  │       └───widgets
  └───smart_screening_and_assessment
      ├───data
      │   ├───models
      │   ├───repositories
      │   └───services
      ├───domain
      │   ├───entities
      │   ├───repositories
      │   └───usecases
      └───presentation
          ├───pages
          │   ├───assessment
          │   └───screening
          ├───providers
          └───widgets
```

## 🔐 Authentication and Security

Neurodyx uses Firebase Authentication for secure user management. User data is stored in Firebase Firestore, and API requests are authenticated with JWT tokens.

## 📱 Application Features

### 🧠 Smart Screening & Assessment

- Dyslexia quick screening
- Dyslexia assessment

### 🎨 Multisensory Therapy

- Visual therapy trains reading through completed words, letter, and word recognition.
- Auditory therapy builds sound awareness with letter guessing, word guessing, and repetition.
- Kinesthetic therapy uses movement to practice letter differences, similarities, and matching.
- Tactile therapy helps recognize and complete words using touch-based activities.

### 🤖 Neurodyx Assistant

- Chat with AI to get support
- Text-to-speech feature based on AI answer

### 📖 Scan Text

- Scan text
- Adjust scanned text
- Text-to-speech scanned text
- Download scanned text as PDF file

### 📊 Tracking Progress

- Monitor and track the user’s therapy progress over time

### 📚 Get to Know Dyslexia

- What is dyslexia
- Factors that influence dyslexia
- Experts insights
- Facts & myths
- Dyslexia vs learning delays

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
