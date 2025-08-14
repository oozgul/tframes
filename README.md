# TFrames

A sleek notification addon for **Turtle WoW** (1.12) that displays beautiful gliding notifications for loot, XP gains, and money.

![Version](https://img.shields.io/badge/version-0.9-blue)
![WoW Version](https://img.shields.io/badge/WoW-1.12-orange)
![Server](https://img.shields.io/badge/server-Turtle%20WoW-green)

## Demo

https://github.com/user-attachments/assets/dcc2f353-f108-449d-988c-720317a81b9c

## Features

- 🎯 **Gliding Notifications**: Smooth sliding animations with fade effects
- 🎒 **Loot Tracking**: Shows item icons, quality colors, and interactive tooltips
- ⚡ **XP Notifications**: Purple-bordered experience gain alerts
- 💰 **Money Tracking**: Gold-bordered currency notifications
- 📍 **Repositionable**: Drag the anchor to position notifications anywhere
- ⚙️ **Configurable**: Toggle individual notification types on/off

## Installation

1. Open your TurtleWoW launcher and navigate to Addons section
2. Click on "Add new Addon" button
3. Paste in the repository URL: https://github.com/oozgul/tframes/
4. All done! You can launch the game now.

## Commands

| Command | Description |
|---------|-------------|
| `/tframes anchor` | Toggle the positioning anchor (green box) |
| `/tframes loot on/off` | Enable/disable loot notifications |
| `/tframes xp on/off` | Enable/disable XP notifications |
| `/tframes money on/off` | Enable/disable money notifications |
| `/tftest loot` | Test loot notification |
| `/tftest xp` | Test XP notification |
| `/tftest money` | Test money notification |

## Setup

1. Type `/tframes anchor` to show the green positioning box
2. Drag it to where you want notifications to appear
3. Type `/tframes anchor` again to hide the positioning box
4. Use `/tftest loot` to preview how notifications will look

## Features in Detail

### Loot Notifications
- Displays actual item icons from the game
- Shows item quality with appropriate colors (white, green, blue, purple, etc.)
- Interactive tooltips when hovering over notifications
- Stack quantity display for stackable items
- Special handling for quest items (teal color)

### Smart Positioning
- Notifications stack vertically from your chosen anchor point
- Smooth gliding animation as they fade out
- Automatic cleanup prevents notification buildup

### 1.12 Compatibility
- Fully compatible with Turtle WoW's 1.12 client
- Uses period-appropriate APIs and functions
- Tested with the classic UI framework

## Technical Details

- **Interface Version**: 11200 (WoW 1.12)
- **Dependencies**: None
- **Saved Variables**: TFramesSettingsSaved
- **Events Monitored**: CHAT_MSG_LOOT, CHAT_MSG_COMBAT_XP_GAIN, CHAT_MSG_MONEY, ITEM_PUSH

## Contributing

Feel free to submit issues, feature requests, or pull requests! This addon is designed specifically for the Turtle WoW community.

## License

Open source - feel free to modify and redistribute.

---

**Made for Turtle WoW** 🐢
