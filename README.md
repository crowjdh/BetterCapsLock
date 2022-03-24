# BetterCapsLock
Fixes caps lock occasionally not working when switching input source with it.
This is for the people who uses caps lock key to change input source.
- To enable "real caps lock" feature, instead of long pressing caps lock key, enter ```Shift + Caps Lock```.
- You can also use **right ⌘** to switch input source.

# Usage
## Common
1. Build & archive & put ```BetterCapsLock.app``` to ```Application``` directory. Or you can download pre-built application from [Releases](https://github.com/crowjdh/BetterCapsLock/releases).
   - There're zero dependencies, so I suggest you to build by yourself.
2. System Preferences > Secyrity & Privacy > Privacy tab
   - Add the application to ```Accessibility```

## For CapsLock users
- System Preferences > Keyboard > Modifier Keys...
  - Map Caps Lock to ```No Action```

## For right ⌘ users
![Usage](./resources/usage.png)

## Launch on startup
- System Preferences > Users & Groups > Login Items tab
  - Add the application to the list

# Meta Flags
## Device-Independent
|CGEventFlags|NeXT|hex|binary|
|-|-|-:|-:|
|maskShift|NX_SHIFTMASK|0x20000|10 0000 0000 0000 0000|
|maskControl|NX_CONTROLMASK|0x40000|100 0000 0000 0000 0000|
|maskAlternate|NX_ALTERNATEMASK|0x80000|1000 0000 0000 0000 0000|
|maskCommand|NX_COMMANDMASK|0x100000|1 0000 0000 0000 0000 0000|
|maskNumericPad|NX_NUMERICPADMASK|0x200000|10 0000 0000 0000 0000 0000|
|maskSecondaryFn|NX_SECONDARYFNMASK|0x800000|1000 0000 0000 0000 0000 0000|
|maskAlphaShift|NX_ALPHASHIFTMASK|0x10000|1 0000 0000 0000 0000|
|maskHelp|NX_HELPMASK|0x400000|100 0000 0000 0000 0000 0000|
|N/A|NX_ALPHASHIFT_STATELESS_MASK|0x1000000|1 0000 0000 0000 0000 0000 0000|

## Device-Dependent
- There're no coresponding CGEventFlags

|NeXT|Human-readable|hex|binary|
|-|-|-:|-:|
|NX_DEVICELSHIFTKEYMASK|Left Shift|0x2|10|
|NX_DEVICERSHIFTKEYMASK|Right Shift|0x4|100|
|NX_DEVICELCTLKEYMASK|Left Control|0x1|1|
|NX_DEVICERCTLKEYMASK|Right Control|0x2000|10 0000 0000 0000|
|NX_DEVICELALTKEYMASK|Left Alt|0x20|10 0000|
|NX_DEVICERALTKEYMASK|Right Alt|0x40|100 0000|
|NX_DEVICELCMDKEYMASK|Left Command|0x8|1000|
|NX_DEVICERCMDKEYMASK|Right Command|0x10|1 0000|
|NX_DEVICE_ALPHASHIFT_STATELESS_MASK||0x80|1000 0000|
|NX_STYLUSPROXIMITYMASK||0x80|1000 0000|
|NX_NONCOALSESCEDMASK||0x100|1 0000 0000|

## References
- https://opensource.apple.com/source/IOHIDFamily/IOHIDFamily-1035.1.4/IOHIDEventTranslation/
- https://opensource.apple.com/source/IOHIDFamily/IOHIDFamily-86/IOHIDSystem/IOKit/hidsystem/IOLLEvent.h.auto.html
- https://www.hammerspoon.org/docs/hs.eventtap.event.html
- https://discourse.libsdl.org/t/international-keyboard-support/851/4
