# EstateIQ - Flutter Mobile App

A beautiful, AI-powered real estate analytics mobile application built with Flutter.

## Features

✨ **Property Listings** - Browse multiple properties with key metrics  
📊 **Investment Analytics** - Risk, growth, and cap rate analysis  
🏘️ **Neighborhood Scores** - Safety, schools, commute, amenities, stability  
🔍 **Search & Filter** - Find properties by title and metadata  
💡 **AI Insights** - Detailed analysis and recommendations  
🌙 **Dark Theme** - Modern, easy-on-the-eyes interface

## Getting Started

### Prerequisites
- Flutter 3.0+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Android SDK 21+ for Android development
- Dart 3.0+

### Installation

1. **Navigate to project directory:**
   ```bash
   cd EstateIQ_app-main
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Build APK (Android Release)

```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Domain models (property, user, listing, alerts)
├── providers/                # App state providers (auth, listings, watchlist)
├── screens/                  # Feature screens (auth, dashboard, market, reports, etc.)
│   ├── home_screen.dart      # Property listing screen
│   ├── detail_screen.dart    # Property details & analytics
│   └── main_shell.dart       # Bottom-nav shell
├── services/
│   └── prediction_service.dart   # AI valuation projection logic
├── theme/
│   └── theme.dart            # Color palette & theme configuration
└── widgets/
    ├── property_card.dart    # Property list item widget
    └── score_bar.dart        # Neighborhood score visualization
```

## State Management

Uses **Provider** pattern for efficient state management:
- `PropertyProvider` - Manages property list, search, and selected property
- `AuthProvider` - Demo authentication/session state
- `WatchlistProvider` - Saved listings + alerts
- `ListingProvider` - Listing management state

## Demo Authentication

- This app uses **demo-only authentication** with local in-memory users.
- Passwords are hashed locally for realism, but there is no backend/session token flow.
- Quick demo access users are available on the login screen (password: `demo123`).

## Data

Currently uses demo data embedded in the app. To integrate with an API:
1. Create API service in `lib/services/`
2. Update `PropertyProvider` to fetch data from API
3. Add error handling and loading states

## Customization

### Colors
Edit `lib/theme/theme.dart` to customize the color palette.

### Properties
Edit `_initializeDemoData()` in `lib/providers/property_provider.dart` to add/modify properties.

### Screens
Edit screens in `lib/screens/` to customize layout and functionality.

## Development

### Run with specific device
```bash
flutter devices  # List available devices
flutter run -d <device_id>
```

### Enable web debug
```bash
flutter run -v
```

## API Integration (Future)

To connect to a backend:
1. Create `lib/services/api_service.dart`
2. Implement API calls in the service
3. Update `PropertyProvider` to use the service
4. Add error handling and loading states

## Performance Tips

- Use `const` constructors where possible
- Implement proper widget lifecycle management
- Use `Consumer` wisely to avoid unnecessary rebuilds
- Consider `Selector` for fine-grained state updates

## Troubleshooting

**App won't run:**
```bash
flutter clean
flutter pub get
flutter run
```

**Build errors:**
```bash
flutter clean
flutter pub cache clean
flutter pub get
```

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please refer to the [Flutter Documentation](https://flutter.dev/docs).
