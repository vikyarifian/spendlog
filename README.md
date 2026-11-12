# spendlog

Offline-first mobile application built for internal corporate staff to log daily field expenses and petty cash outlays on the go. Designed for fast data entry without needing an active internet connection, with local SQLite storage and CSV exports for monthly reimbursement submission.

## Features
- **Expense Logging**: Record out-of-pocket expenses with categories, descriptions, amounts, and receipt photos.
- **Offline Storage**: All transactions and receipt image paths are stored locally in SQLite.
- **Kasbon Dashboard**: Track total spent, pending reimbursement claims, and category breakdowns per month.
- **CSV Export**: Generate itemized `.csv` reports formatted for standard finance team submission.

## Setup & Building

### Prerequisites
- Flutter SDK 3.44.x
- Android SDK (for Android builds) or Xcode (for iOS)

### Installation
1. Clone the repository:
   ```bash
   git clone git@github.com:internal-corp/spendlog.git
   cd spendlog
   ```
2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```
3. Run on a connected dev device:
   ```bash
   flutter run
   ```

### Building Release APK
To build the standalone release APK for side-loading onto company Android devices:
```bash
flutter build apk --release
```
The resulting file will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## Known Framework Notes
- Image picker cache on iOS may purge temporary file references across cold app restarts; local paths are copied explicitly into the app storage directory as a workaround.

## Screenshots
![Spendlog Dashboard Placeholder](docs/screenshots/dashboard_placeholder.png)
