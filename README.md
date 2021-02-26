# BetterCapsLock
Fixes caps lock occasionally not working when switching input source with it.
This is for the people who uses caps lock key to change input source.

# Caution
- To enable "real caps lock" feature, instead of long pressing caps lock key, enter ```Shift + Caps Lock```.
- I suck at programming. Use at your own risk.
- There is a known issue on macOS when changing input source, especially when selecting CJK, so I assume/simulate CMD + Shift to change between input sources.

# Usage
1. Archive & put ```BetterCapsLock.app``` to ```Application``` directory
2. System Preferences > Keyboard > Modifier Keys...
  - Map Caps Lock to ```No Action```
3. System Preferences > Secyrity & Privacy > Privacy tab
  - Add the application to ```Accessibility```
4. System Preferences > Users & Groups > Login Items tab
  - Add the application to the list
