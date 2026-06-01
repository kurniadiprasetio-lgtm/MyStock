# DivVest - Dividend Reinvestment Tracker

Aplikasi mobile untuk tracking portofolio saham Indonesia dengan fokus pada **dividend investing & reinvestment (DRIP)**.

## Features

- **Portfolio Management** - Input dan tracking pembelian saham
- **Dividend Tracking** - Track dividen cash dan reinvested
- **BEP (Break Even Point)** - Progress tracking modal tercover via dividen
- **Dividend Calendar** - Lihat upcoming ex-dates dan payment dates
- **Dashboard** - Overview portfolio, monthly income, yield on cost

## Tech Stack

- **Flutter** - Cross-platform mobile framework
- **Provider** - State management
- **SQLite** (planned) - Local database
- **Yahoo Finance API** (planned) - Stock price data

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants, routes
│   ├── theme/          # Theme, colors, typography
│   └── utils/          # Utility functions (formatting, etc)
├── data/
│   ├── models/         # Data models
│   ├── repositories/   # Data repositories
│   └── mock_data.dart  # Mock data for development
├── providers/          # State management (Provider)
├── screens/            # UI screens
│   ├── dashboard/
│   ├── portfolio/
│   ├── stock_detail/
│   ├── add_transaction/
│   ├── add_dividend/
│   ├── calendar/
│   └── settings/
├── widgets/            # Reusable widgets
├── routes/             # Navigation/routing
└── main.dart           # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK >= 3.2.0
- Dart SDK >= 3.2.0

### Installation

```bash
cd divvest
flutter pub get
flutter run
```

### Running on Device

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web (for preview)
flutter run -d chrome
```

## UI Design

Design berdasarkan mockup `modern.html` dengan:
- Dark theme
- Glassmorphism cards
- Purple/indigo gradient accents
- Green for positive values
- Clean, modern typography (Inter)

## Next Steps

- [ ] Implement SQLite for persistent storage
- [ ] Integrate Yahoo Finance API for real-time prices
- [ ] Add notification for upcoming dividends
- [ ] Export data to CSV/Excel
- [ ] Backup & restore functionality
- [ ] Dark/Light theme toggle

## License

MIT
