# Setup Instructions
Save [gestures.lua](https://raw.githubusercontent.com/CleveTok3125/AniYT-mpv-gestures/refs/heads/master/gestures.lua) to working directory and the tool will load it automatically.

# Gestures
| Gesture/Button       | Direction  | Action                       |
| -------------------- | ---------- | ---------------------------- |
| **MOUSE\_BTN0 drag** | Horizontal | Seek video                   |
|                      | Vertical   | Adjust volume                |
|                      | Hold 300ms | Temporarily set speed to 2.0 |
|**MOUSE\_BTN0 click** | Hold <300ms| Play/Pause                   |
| **MBTN\_MID drag**   | Horizontal | Adjust playback speed        |
|                      | Vertical   | Reset speed to 1             |
| **Toggle key `g`**   | —          | Enable/disable gestures      |

# mpv-gestures
Touchscreen and mouse gestures for mpv.

Supports seeking via horizontal swiping with hysteresis and volume and speed control via vertical swiping (left half of the screen for speed, right for volume). You can also click-n-drag for fine control. Swiping with the middle mouse button allows for finer speed controls; horizontal swipes with the middle mouse button change the relative speed, vertical swipes resets it back to 1.00.

You need to set `no-window-dragging` in you `mpv.conf` for this script to work.

For configuration options see the source.
