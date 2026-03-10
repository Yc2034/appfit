# Local Audio Files

Put course guide audio files in this folder.

## Naming
- Use stable lowercase kebab-case file names.
- Keep file extensions explicit, for example: `strength-foundation-45min.mp3`.

## Xcode target membership
Files must be included in the app bundle.

1. Drag the audio file into the `Audio` group in Xcode.
2. Make sure `AppFitMVP` target membership is enabled.
3. Confirm the file appears in `Copy Bundle Resources`.

## JSON mapping
Reference file names from `Resources/Data/courses.json` using:

```json
"audioGuide": {
  "title": "45 min guide",
  "fileName": "strength-foundation-45min.mp3"
}
```
