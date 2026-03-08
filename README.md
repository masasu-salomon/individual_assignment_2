# Kigali City Services & Places Directory

Flutter app to find and manage service and place listings in Kigali (hospitals, police stations, libraries, restaurants, cafés, parks, etc.). Backend is Firebase Auth and Cloud Firestore.

## What it does

- **Auth** – Sign up, login, logout with email/password. You have to verify your email before using the app. User profile is saved in Firestore.
- **Directory** – List of all listings, search by name and filter by category. Updates when Firestore data changes.
- **My Listings** – Create, edit, and delete your own listings. Only yours show here.
- **Map View** – All listings on a map. Tap a marker to open the detail screen.
- **Detail** – Full info for one listing, map with a marker, and a button to open Google Maps for directions.
- **Settings** – Your profile (email, UID) and a toggle for location notifications (saved on device).

Bottom bar has four tabs: Directory, My Listings, Map View, Settings.

## Firestore

Two collections:

**users** – One doc per user, id = Auth UID. Fields: uid, email, displayName, createdAt.

**listings** – One doc per place. Fields: name, category, address, contactNumber, description, latitude, longitude, createdBy (UID), timestamp. Doc id is auto-generated.

Listings are read with real-time streams. Create/update/delete go through the listing service.

## State management

Using Provider. No Firestore calls in the UI.

- **AuthProvider** – Auth state, user, profile. Uses AuthService for sign up, login, profile in Firestore.
- **ListingsProvider** – List of all listings and list of current user’s listings. Subscribes to streams from ListingService. Create/update/delete call the service. Screens watch the provider so they rebuild when data or loading/error changes.
- **SettingsProvider** – Notification on/off, stored in SharedPreferences.

Firestore and Auth are only used inside `lib/services/` (AuthService, ListingService). Screens and widgets use the providers.

## Setup

1. Clone and get packages:
   ```bash
   flutter pub get
   ```

2. Firebase: Create a project, turn on Email/Password auth and create a Firestore database. Add an Android app (package name `com.example.individual_assignment2`), download `google-services.json` into `android/app/`. Run `dart run flutterfire configure` to generate `lib/firebase_options.dart` (or copy your config into that file).

3. Android sign-up: If sign-up fails with CONFIGURATION_NOT_FOUND, add your debug SHA-1 in Firebase Console → Project settings → Your apps → the Android app → Add fingerprint. Get SHA-1 with:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

4. If the map is blank, add a Google Maps API key in `android/app/src/main/AndroidManifest.xml` (Maps SDK for Android enabled in Cloud Console).

5. Run on a device or emulator:
   ```bash
   flutter run
   ```

## Project layout

```
lib/
  main.dart              – app entry, routes, auth gate (login / verify / main)
  firebase_options.dart   – Firebase config (from flutterfire configure)
  core/                   – theme, colors
  models/                 – Listing, UserProfile
  services/               – AuthService, ListingService (all Firestore/Auth here)
  providers/              – AuthProvider, ListingsProvider, SettingsProvider
  screens/
    auth/                 – login, signup, verify email
    home/                 – main_shell (bottom nav), directory, my_listings, map_view, settings, bookmarks, reviews
    listing_detail_screen.dart
    add_edit_listing_screen.dart
```
