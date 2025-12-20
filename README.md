# 🐾 Pet Expense Tracker

A modern, lightweight, and premium Personal Expense Tracking application built with Flutter. Take control of your finances with a sleek dark theme, local-first privacy, and smart AI-driven insights.

## ✨ Features

- **🏠 Comprehensive Dashboard**: Quick-glance view of your total balance, monthly income, and expenses with a mini growth chart.
- **🕒 Transaction History**: Manage your financial records with detailed descriptions, categorization, and editing support.
- **🔍 Advanced Filtering**: Instantly find transactions by type (Income/Expense) or category (Food, Salary, Rent, etc.).
- **📊 Rich Statistics**: Visualize your spending habits with interactive Pie charts and follow your Income vs Expense trends on a detailed Line chart.
- **🤖 AI Financial Advisor**: Receive smart, privacy-focused financial advice based on your spending patterns (Rule-based heuristics).
- **📁 CSV Export & Share**: Export your data to CSV and instantly share or open it with Excel, Google Sheets, or your preferred spreadsheet app.
- **🌙 Premium Dark Theme**: A beautifully crafted UI featuring glassmorphism, smooth animations, and a modern color palette.

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Cubit](https://pub.dev/packages/flutter_bloc) (flutter_bloc)
- **Local Database**: [Hive](https://pub.dev/packages/hive) (Fast & NoSQL)
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it)
- **Charts**: [FL Chart](https://pub.dev/packages/fl_chart)
- **File Sharing**: [Share Plus](https://pub.dev/packages/share_plus)
- **Architecture**: Feature-based Clean Architecture

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.7.2)
- Android Studio / VS Code
- A connected Android/iOS device or emulator

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/aboodsido/pet.git
   ```

2. **Navigate to the project directory**:
   ```bash
   cd pet
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run code generation (for Hive Adapters)**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

## 📱 Mobile Verification
The app is fully verified and optimized for physical mobile devices (Android API 34+). It features high-performance rendering and safe handling of platform-specific features like file sharing and storage.

## 🔒 Privacy
Your data never leaves your device. All calculations, storage, and AI analysis are performed locally to ensure maximum security and privacy.

---
Built with ❤️ by [Abdullah Abo-Sido](https://github.com/aboodsido)
