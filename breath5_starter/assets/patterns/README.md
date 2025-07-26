# Breathing Patterns

This directory contains JSON files defining different breathing patterns for the app.

## Pattern Format

Each pattern is defined in a JSON file with the following structure:

```json
{
  "name": "Pattern Name",
  "steps": [
    {"phase":"inhale","ms":4000},
    {"phase":"hold","ms":1000},
    {"phase":"exhale","ms":6000},
    {"phase":"rest","ms":1000}
  ],
  "cycles": 8,
  "ambience": "bamboo_wind.mp3"
}
```

### Fields

- **name**: Display name for the breathing pattern
- **steps**: Array of breathing steps, each with:
  - **phase**: One of "inhale", "hold", "exhale", "rest"
  - **ms**: Duration in milliseconds
- **cycles**: Number of times to repeat the pattern
- **ambience**: Optional ambient audio file (without path)

### Available Phases

- **inhale**: Breathing in
- **hold**: Holding breath
- **exhale**: Breathing out  
- **rest**: Rest period between cycles

### Example Patterns

- **Dan Tian Reverse 4-1-6-1**: Traditional Qigong pattern
- **Box Breathing 4-4-4-4**: Equal timing for all phases
- **Wim Hof Method**: Rapid breathing technique

### Usage

Patterns can be loaded from JSON files or created programmatically using the `BreathingPattern` class. 