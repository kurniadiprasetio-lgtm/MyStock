# DivVest - Aplikasi Dividend Reinvestment Tracker Saham Indonesia

> **Plan file location:** `/Users/kurniadiprasetio/MyStock/PLAN.md`

## Overview

Aplikasi mobile untuk tracking portofolio saham Indonesia dengan fokus pada **dividend investing & reinvestment (DRIP)**. Memecahkan pain point utama: kebanyakan aplikasi hanya menampilkan capital gain, padahal dividend investor perlu metrik berbeda seperti BEP dinamis, yield on cost, dan projected passive income.

---

## Tech Stack

| Layer | Teknologi | Alasan | Status |
|-------|-----------|--------|--------|
| Framework | Flutter | Cross-platform (iOS + Android), single codebase | ✅ Implemented |
| Language | Dart | Native Flutter | ✅ Implemented |
| Local DB | SQLite (via `sqflite`) | Offline-first, data portofolio sensitif | ✅ Implemented (Phase 2) |
| State Management | Provider | Scalable, simple | ✅ Implemented (changed from Riverpod) |
| API Client | `http` | Yahoo Finance API integration | ✅ Implemented |
| Charts | `fl_chart` | Price history charts | ✅ Implemented |
| DI | Manual via Provider | Simple for MVP | ✅ Implemented |

---

## Data Sources (API)

| Data | Sumber | Ketersediaan | Status |
|------|--------|-------------|--------|
| Harga saham (realtime & historical) | Yahoo Finance (suffix `.JK`) | Gratis, via unofficial API | ✅ Implemented (individual fetch) |
| Data dividen (ex-date, amount, ratio) | Manual input | User input via Add Dividend screen | ✅ Implemented |
| Data fundamental (EPS, PER, DER) | Simplize / manual input | Simplize ada free tier, atau user input manual | ⬜ Planned (Phase 4) |
| Informasi corporate action | Scraping idx.co.id / manual input | Tidak ada API publik yang lengkap | ⬜ Planned (Phase 4) |

**Strategi hybrid:** API untuk harga + manual input (dengan auto-suggest) untuk data dividen. Nanti bisa ditambah scrapers jika data cukup trustworthy.

---

## Core Features (MVP)

### 1. Portfolio Management
- ✅ Input pembelian saham: ticker, lot, harga, tanggal, fee (UI + DB connected)
- ✅ Support multiple buy entries per ticker (averaging) (implemented)
- ✅ Track lot yang berbeda untuk reinvested dividend vs initial purchase (implemented via `isReinvested` flag)
- ✅ Edit/Delete transaction (implemented)
- ✅ Searchable stock dropdown dengan auto-complete (implemented)

### 2. Dividend Tracking
- ✅ Input data dividen: ex-date, payment date, amount/lot (UI + DB connected)
- ✅ Tag dividen: **cash out** atau **reinvested** (implemented)
- ✅ Jika reinvested: otomatis buat entry pembelian baru di tanggal payment (implemented)
- ✅ Dividend history per stock (implemented in Stock Detail)

### 3. BEP (Break Even Point) Dinamis
- ⬜ **Capital BEP**: harga dimana total sell = total buy cost (including fees) (planned)
- ⬜ **True BEP** (dividend-adjusted): harga dimana total sell + total dividends received = total buy cost (planned)
- ✅ **Dividend BEP**: kapan cumulative dividends = total buy cost (UI + data connected)
- ✅ Tampilan progress bar: "Anda sudah BEP 72% dari modal via dividen" (widget working)

### 4. Dividend Metrics
- ✅ **Yield on Cost**: annual dividend / average buy price per lot (display working)
- ⬜ **Current Yield**: annual dividend / current price (planned)
- ⬜ **Dividend Growth Rate**: YoY pertumbuhan DPS (planned)
- ⬜ **Projected Annual Income**: berdasarkan current holding + projected dividend (planned)

### 5. Dashboard
- ✅ Total portfolio value (current price x total lots) (working with real data)
- ✅ Total invested (sum of all buys) (working)
- ✅ Unrealized gain/loss (working)
- ✅ Total dividends received (cash + reinvested value) (working)
- ✅ **Effective gain** = unrealized gain + dividends received (working)
- ✅ Progress menuju dividend BEP (working)
- ⬜ Projected monthly passive income (planned)

### 6. Dividend Calendar
- ✅ Upcoming ex-dates & payment dates (UI + DB connected, dynamic month navigation)
- ✅ Filter dividen per bulan (implemented)
- ✅ Monthly summary total (implemented)
- ⬜ Estimasi dividend berdasarkan historical data (planned)
- ⬜ Reminder/notifikasi (planned)

---

## Data Model

```
PortfolioEntry
├── id: int (PK)
├── ticker: String (e.g., "BBCA")
├── buyDate: DateTime
├── lots: int
├── pricePerLot: double
├── fee: double
├── totalCost: double (computed)
├── isReinvested: bool
├── sourceDividendId: int? (FK ke DividendRecord, jika reinvested)
└── notes: String?
Status: ✅ Model implemented + SQLite connected

DividendRecord
├── id: int (PK)
├── ticker: String
├── exDate: DateTime
├── paymentDate: DateTime
├── dividendPerLot: double (IDR)
├── dividendType: enum { CASH, REINVEST }
├── lotsHeldAtExDate: int
├── taxRate: double (PPh default 10%, 0% untuk reinvest)
└── netAmount: double (computed)
Status: ✅ Model implemented + SQLite connected

Stock
├── ticker: String (PK)
├── name: String
├── currentPrice: double
├── change: double
├── changePercent: double
└── lastUpdated: DateTime
Status: ✅ Model implemented + SQLite connected + Yahoo Finance API

StockPrice (historical cache)
├── id: int (PK)
├── ticker: String (FK)
├── date: DateTime
├── open: double
├── high: double
├── low: double
├── close: double
└── volume: int
Status: ✅ Implemented (fetched from Yahoo Finance, displayed in Stock Detail chart)
```

---

## Architecture

```
lib/
├── main.dart                         ✅ Implemented
├── core/
│   ├── constants/
│   │   └── app_constants.dart        ✅ Implemented
│   ├── utils/
│   │   └── format_utils.dart         ✅ Implemented
│   └── theme/
│       └── app_theme.dart            ✅ Implemented (Dark + Light mode)
├── data/
│   ├── models/
│   │   └── models.dart               ✅ Implemented (PortfolioEntry, DividendRecord, Stock)
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── database_helper.dart  ✅ Implemented (SQLite)
│   │   │   ├── database_seeder.dart  ✅ Implemented (API-driven seeding)
│   │   │   ├── portfolio_dao.dart    ✅ Implemented
│   │   │   ├── stock_dao.dart        ✅ Implemented
│   │   │   └── dividend_dao.dart     ✅ Implemented
│   │   └── remote/
│   │       └── yahoo_finance_api.dart ✅ Implemented (price + history)
│   └── repositories/
│       └── portfolio_repository.dart ✅ Implemented (SQLite + API)
├── providers/
│   ├── portfolio_provider.dart       ✅ Implemented (Provider pattern)
│   └── theme_provider.dart           ✅ Implemented
├── routes/
│   └── app_router.dart               ✅ Implemented
├── screens/
│   ├── dashboard/
│   │   └── dashboard_screen.dart     ✅ Implemented (refactored with reusable components)
│   ├── portfolio/
│   │   └── portfolio_screen.dart     ✅ Implemented (refactored with reusable components)
│   ├── stock_detail/
│   │   └── stock_detail_screen.dart  ✅ Implemented (price history chart, refactored)
│   ├── add_transaction/
│   │   └── add_transaction_screen.dart ✅ Implemented (searchable dropdown, refactored)
│   ├── edit_transaction/
│   │   └── edit_transaction_screen.dart ✅ Implemented
│   ├── add_dividend/
│   │   └── add_dividend_screen.dart  ✅ Implemented (searchable dropdown, refactored)
│   ├── calendar/
│   │   └── calendar_screen.dart      ✅ Implemented (dynamic month navigation, refactored)
│   └── settings/
│       └── settings_screen.dart      ✅ Implemented (Material Icons, refactored)
└── widgets/
    ├── main_shell.dart               ✅ Implemented (bottom navigation)
    ├── common_widgets.dart           ✅ Implemented (GlassCard, GradientCard, BEPProgressBar, etc.)
    └── components/                   ✅ Implemented (Reusable component library)
        ├── app_text_field.dart       ✅ AppTextField, AppCurrencyField, AppDateField, AppDropdownField
        ├── app_card.dart             ✅ AppCard, AppGradientCard
        ├── app_button.dart           ✅ AppButton (primary/secondary/destructive/text)
        ├── app_icon_button.dart      ✅ AppIconButton
        ├── app_toggle.dart           ✅ AppToggle (segmented toggle)
        ├── app_loading_overlay.dart  ✅ AppLoadingOverlay
        ├── app_dialog.dart           ✅ AppDialog (confirmation dialogs)
        ├── app_snack_bar.dart        ✅ AppSnackBar (success/error/warning)
        └── app_scaffold.dart         ✅ AppScaffold (standard app bar pattern)
```

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)
- [x] Setup Flutter project, folder structure, dependencies
- [x] Setup SQLite database & migrations
- [x] Implement data models & DAOs
- [x] Setup Provider state management & base architecture
- [x] Theme & design system (colors, typography, components)
- [x] Base navigation (bottom nav: Dashboard, Portfolio, Calendar, Settings)

### Phase 2: Portfolio Core (Week 3-4)
- [x] SQLite database setup & migrations
- [x] Add/Edit/Delete portfolio entries (connect UI to DB)
- [x] Portfolio list page with current price integration
- [x] Yahoo Finance API integration untuk harga terkini (individual fetch per stock)
- [x] Portfolio summary card (total invested, current value, gain/loss)
- [x] Average price & lot calculation per ticker
- [x] Price history chart (fl_chart) di Stock Detail screen

### Phase 3: Dividend Engine (Week 5-6)
- [x] SQLite dividend table & DAO
- [x] Add/Edit dividend records (connect UI to DB)
- [x] Auto-calculate net dividend setelah PPh
- [x] Reinvestment flow: dividen → auto-create portfolio entry
- [x] Dividend history per stock
- [x] Dividend calendar view (dynamic month navigation, filter by month)

### Phase 4: BEP & Metrics (Week 7-8)
- [ ] Capital BEP calculation
- [ ] True BEP (dividend-adjusted) calculation
- [x] Dividend BEP timeline calculation (UI + data connected)
- [x] Yield on Cost vs Current Yield (display working)
- [x] BEP progress bar widget (working with real data)
- [ ] Dividend growth rate tracking

### Phase 5: Dashboard & Insights (Week 9-10)
- [x] Dashboard page agregat (connect to real data)
- [ ] Projected annual/monthly passive income
- [ ] Dividend income chart (per bulan/tahun)
- [ ] Portfolio composition (per sector)
- [ ] Dividend calendar dengan estimasi

### Phase 6: Polish & Extras (Week 11+)
- [ ] Export data (CSV/Excel)
- [ ] Backup/restore (local file or cloud sync)
- [ ] Notifications (ex-date reminders)
- [ ] Watchlist (stock tanpa position, untuk monitoring)
- [x] Dark mode (fully implemented with light/dark toggle)
- [x] Reusable component library (AppTextField, AppCard, AppButton, etc.)
- [ ] Widget home screen (upcoming dividends)

---

## Key Design Decisions (Perlu Diskusi)

1. **Offline-first vs Real-time?** 
   - ✅ Keputusan: Offline-first dengan periodic sync harga. Portofolio data 100% lokal, harga di-refresh saat buka app atau manual refresh.

2. **Data dividen: fully manual vs semi-auto?**
   - ✅ Keputusan: Semi-auto. User input ex-date & amount, app auto-calculate total based on lots held. Nanti bisa ditambah crowd-sourced data.

3. **PPh dividen: 10% default atau configurable?**
   - ✅ Keputusan: Default 10%, tapi bisa di-set 0% per entry (untuk kasus reinvest sesuai regulasi OJK).

4. **Lots vs Shares?**
   - ✅ Keputusan: Gunakan "lot" (1 lot = 100 lembar) karena ini standar BEI.

5. **Currency:**
   - ✅ Keputusan: Semua dalam IDR. Tidak perlu multi-currency untuk MVP.

6. **State Management:**
   - ✅ Keputusan: Menggunakan `Provider` (bukan Riverpod) untuk kesederhanaan dan kompatibilitas dengan Flutter best practices.

7. **Routing:**
   - ✅ Keputusan: Menggunakan standard `Navigator` dengan `onGenerateRoute` (bukan go_router) untuk simplicity.

8. **UI Components:**
   - ✅ Keputusan: Semua UI menggunakan reusable component library (`lib/widgets/components/`) untuk konsistensi dan maintainability.

---

## Open Questions

- [x] Nama aplikasi: "DivVest" ✅ Confirmed
- [x] Target platform: Android dulu, atau iOS juga di MVP? → **iOS simulator tested, cross-platform ready**
- [ ] Apakah perlu fitur koneksi ke sekuritas (auto-import transaksi), atau manual input sudah cukup?
- [ ] Minimum Android/iOS version target?

---

## Current Status (Updated: 2026-06-02)

### ✅ Completed
1. **Project Setup**: Flutter project initialized di `/Users/kurniadiprasetio/MyStock/divvest`
2. **Architecture**: Provider-based state management, clean folder structure
3. **Theme System**: Full dark mode + light mode dengan glassmorphism design
4. **Data Models**: PortfolioEntry, DividendRecord, Stock (SQLite connected)
5. **Database Layer**: SQLite with DAOs (PortfolioDAO, StockDAO, DividendDAO)
6. **API Integration**: Yahoo Finance API untuk stock price + price history (individual fetch)
7. **All 8 Screens**: Dashboard, Portfolio, Stock Detail, Add Transaction, Edit Transaction, Add Dividend, Calendar, Settings
8. **Reusable Component Library**: 12 components (AppTextField, AppCurrencyField, AppDateField, AppDropdownField, AppCard, AppButton, AppIconButton, AppToggle, AppLoadingOverlay, AppDialog, AppSnackBar, AppScaffold)
9. **Navigation**: Bottom navigation shell with 4 tabs
10. **CRUD Operations**: Add/Edit/Delete transactions and dividends connected to SQLite
11. **Dividend Reinvestment Flow**: Auto-create portfolio entry from dividend
12. **Price History Chart**: fl_chart integration di Stock Detail (1mo, 3mo, 6mo, 1y)
13. **Calendar Navigation**: Dynamic month navigation dengan filter data per bulan
14. **Searchable Dropdowns**: Auto-complete stock search di Add Transaction & Add Dividend
15. **Settings Screen**: Material Icons, working theme toggle, clear all data
16. **Build Status**: ✅ Successfully builds on iOS simulator, no compilation errors

### ⬜ Next Steps
1. **Capital BEP Calculation**: Implement actual BEP logic
2. **True BEP (Dividend-Adjusted)**: Calculate break-even with dividends
3. **Dividend Growth Rate**: Track YoY DPS growth
4. **Projected Passive Income**: Estimate monthly/yearly dividend income
5. **Export/Backup**: CSV export and local file backup
6. **Notifications**: Ex-date reminders

### 📱 Testing
- App successfully builds and runs on iPhone 16e simulator
- All screens tested with both dark and light mode
- No compilation errors, only minor linting warnings (prefer_const_constructors)
