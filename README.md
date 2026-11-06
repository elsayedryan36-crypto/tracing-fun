# Tracing App (v1, in progress)

Arabic and English letter tracing for children aged 3–5. Built from the Coloring World core.

- Spec: `TRACING_APP_SPEC.md` (in the owner's workspace)
- Mockup: `mockups/tracing-app-mockup.html` (approved)

## Run

    flutter pub get
    flutter run

Ads use Google's test IDs by default. For a release build with real IDs, add
`--dart-define=USE_TEST_ADS=false` after creating the app's own AdMob ad units.

## Before upload (must do)

- Change `applicationId` and `namespace` in `android/app/build.gradle.kts` to the new app's package name. The current value is the Coloring World package. Uploading with it would update the coloring app.
- Replace the `REPLACE_WITH_NEW_APP_*` ad unit IDs in `lib/data/services/ad_unit_ids.dart`.
- Add the new app's AdMob app ID in `android/app/src/main/AndroidManifest.xml`.
- Add the real letter images and free sounds (see the spec, section 5).
