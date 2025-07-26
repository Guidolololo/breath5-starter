# Audio Assets for Breathing App

This directory contains audio files for breathing cues, ambient sounds, and meditation audio.

## Required Audio Files

### Breathing Cues (for Qigong 4-1-6-1 pattern)
- `inhale.mp3` - Audio cue for inhale phase
- `hold.mp3` - Audio cue for hold phase  
- `exhale.mp3` - Audio cue for exhale phase
- `rest.mp3` - Audio cue for rest phase

### Ambient Background Audio
- `bamboo_wind.mp3` - Looping ambient background sound
- `forest_ambience.mp3` - Nature sounds for meditation
- `ocean_waves.mp3` - Calming ocean sounds

### Tick Sounds
- `tick.mp3` - Short tick sound for timing feedback (plays every second)

## Audio File Guidelines

- **Format**: MP3 recommended for compatibility
- **Duration**: 
  - Breathing cues: 1-3 seconds
  - Ambient audio: 30+ seconds (will loop)
  - Tick sounds: 0.5-1 second
- **Quality**: 44.1kHz, 128kbps or higher
- **Volume**: Normalized to consistent levels

## Example Sources

You can find free breathing sounds from:
- Freesound.org
- Pixabay.com
- Zapsplat.com

Or create your own using:
- Meditation apps
- White noise generators
- Nature sounds

## Testing Without Audio

If you don't have audio files yet, the app will work without them. Just set:
- `enableAudio: false` in the BreathTimer constructor
- `enableTicks: false` to disable tick sounds

## Audio Features

- **Breathing Cues**: Play at the start of each phase
- **Ambient Audio**: Loops continuously during the session
- **Tick Sounds**: Play every second for timing feedback
- **Haptic Feedback**: Works alongside audio for enhanced experience 