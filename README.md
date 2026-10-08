<div align="center">

# 🙈 please_dont_look
### *The aesthetic frosted-glass privacy veil for macOS*

<p align="center">
  <em>Because what's on your screen is strictly between you and your conscience — not that coworker hovering by your desk or the stranger squinting at your screen at Starbucks.</em>
</p>

[![macOS](https://img.shields.io/badge/macOS-13.0%2B%20Ventura%20%7C%20Sonoma%20%7C%20Sequoia-000000?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/Shivanshu-S-AI/please_dont_look)
[![Swift](https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![Architecture](https://img.shields.io/badge/Architecture-Apple%20Silicon%20%2F%20Intel-success?style=for-the-badge)](https://github.com/Shivanshu-S-AI/please_dont_look)
[![Permissions](https://img.shields.io/badge/Permissions-Zero%20Screen%20Recording-blueviolet?style=for-the-badge)](https://github.com/Shivanshu-S-AI/please_dont_look)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

<br/>

### 📦 [⬇️ Download Latest DMG Installer (v1.0.0)](https://github.com/Shivanshu-S-AI/please_dont_look/releases/download/v1.0.0/GlassScreen.dmg)
**Ready-to-use macOS disk image • Drag-and-drop install • Apple Silicon & Intel**

---

</div>

## 🧐 What is this, and why do you desperately need it?

Picture this: You step away from your laptop for 45 seconds to grab coffee, pet your cat, or stretch. You suddenly freeze mid-stride remembering:

- 💸 Your bank account balance and credit score are displayed in glorious 4K resolution.
- 💬 You left a spicy Slack message or uncensored group chat in full view.
- 🍝 Your terrifying spaghetti code is exposed to judging senior engineers.
- 🔍 Your search tab says *"how to exit vim without crying"* or *"can my boss see my open tabs"*.

Locking your screen every 60 seconds is exhausting — nobody wants to type a 24-character master password 50 times a day. Turning off your monitor takes seconds and rearranges your multi-display setup.

**`please_dont_look`** (internally known as *GlassScreen*) is the elegant, witty answer:

> The second you step away from your Mac, your entire display is automatically cloaked in a **breathtaking, hardware-accelerated frosted glass veil**. The microsecond you twitch your mouse or tap a key, the frost instantly vanishes and you're back to work. 

No passwords. No awkward minimize frenzies. No nosy peepers. Just pure, frosted serenity. 💅✨

---

## ✨ Features That Make It Sing

- ⏳ **Smart Auto-Idle Privacy Shield**: Detects when your Mac goes idle (customizable from 1 to 30 minutes) and silently drops the frosted glass curtain. Touch the trackpad or keyboard, and it dissolves instantly.
- 🚨 **Panic Key `⌥⌘B` (Option + Command + B)**: Someone approaching your desk with "do you have a quick sec?" energy? Hit `⌥⌘B` and blanket your screen instantly. Hit it again to unblur.
- 🎲 **Aesthetic Shuffle `⌥⇧⌘B`**: Roll the dice and switch between 10 hand-crafted glassmorphism styles on the fly.
- 🛡️ **Zero Screen-Recording Permissions**: Unlike naive screen blur apps that run continuous screen-capture loops (killing battery and triggering scary macOS security warnings), `please_dont_look` taps directly into native Apple WindowServer compositor backdrops (`NSVisualEffectView` + `CGSSetWindowBackgroundBlurRadius`). **0.0% CPU overhead, zero battery drain.**
- 🎛️ **Live Customization Studio**: Tweak Blur Strength, Tint Opacity, Frosted Noise Grain, Specular Lighting Bevel, and Vignette in real-time.
- 🖥️ **Multi-Display Synchronized**: Veils all attached external monitors simultaneously without dropping a frame.
- 🖱️ **Click-Through Mode**: Want the dreamy frosted aesthetic while still clicking on Spotify, watching a lecture, or typing in a document? Toggle Click-Through on.
- 🕹️ **Menu Bar Resident**: Sits unobtrusively in your status bar with a sleek aperture lens icon that pulses when blur is active. Option-click for instant toggle.
- 🤖 **CLI & Automation Ready**: Control everything via `./glass` in terminal or `glassscreen://` URL scheme from Raycast, Alfred, and Shortcuts.

---

## 🎨 10 Hand-Crafted Glassmorphic Styles

### 🌸 Pastel Frost & Luminous Glass
| Preset | Vibe & Aesthetic | Accent Palette |
| :--- | :--- | :--- |
| **Sakura Pink** | Delicate Japanese cherry blossom frost | Rose Blush & Sakura Pink |
| **Mint Matcha** | Refreshing light seafoam and matcha acrylic | Fresh Mint & Pastel Seafoam |
| **Glacier Sky** | Crisp arctic baby blue with crystalline frost | Baby Sky Blue & Arctic Ice |
| **Lavender Lilac** | Dreamy soft wisteria and lilac pastel glass | Soft Wisteria & Pastel Lilac |
| **Peach Sunrise** | Warm morning apricot glow with coral diffusion | Apricot Gold & Peach Coral |
| **Lemon Chiffon** | Gentle sunlight and buttercup pastel frost | Buttercup Cream & Sunny Lemon |
| **Prismatic Opal** | Shimmering multi-spectral iridescent sheen | Multi-Spectral Pastel Sheen |
| **Coral Blossom** | Luminous soft coral and champagne pink | Coral Pink & Champagne Petal |

### ❄️ Architectural Frost & 🌌 Noir Privacy
| Preset | Vibe & Aesthetic | Accent Palette |
| :--- | :--- | :--- |
| **Pure Crystal Frost** | Quintessential Cupertino frosted architectural glass | Pure Alabaster & Diamond White |
| **Frosted Pearl** | Velvety opal milk diffusion with tactile grain | Opal White & Diffused Pearl |
| **Neon Synthwave** | Rainy cyberpunk neon reflections | Electric Cyan & Hot Magenta |
| **Aurora Borealis** | Ethereal dancing northern lights | Emerald Teal & Deep Violet |
| **Obsidian Stealth** | Deep matte charcoal for high-contrast stealth | Midnight Slate & Charcoal |
| **Privacy Shield** | Ultra-dense obfuscation veil for flights and cafes | High-Density Obsidian Veil |

---

## 🚀 Quick Start & Installation

### Option 1: Install via DMG Installer (Easiest)

1. Download [**GlassScreen.dmg**](https://github.com/Shivanshu-S-AI/please_dont_look/releases/download/v1.0.0/GlassScreen.dmg) from GitHub Releases or from the [`release/`](release/GlassScreen.dmg) folder.
2. Open the `.dmg` file.
3. Drag **GlassScreen.app** into your **Applications** folder.
4. Launch **GlassScreen** — it will appear directly in your macOS menu bar!

```bash
# Or open the downloaded DMG right from terminal
open release/GlassScreen.dmg
```

### Option 2: Build & Run from Source

Requirements: macOS 13.0+ and Xcode / Swift 6.0 toolchain.

```bash
# 1. Clone the repository
git clone https://github.com/Shivanshu-S-AI/please_dont_look.git
cd please_dont_look

# 2. Build the app bundle
./scripts/build_app.sh

# 3. Launch the app
open build/GlassScreen.app
```

Want to generate your own clean DMG installer package?
```bash
./scripts/build_dmg.sh
```

---

## ⌨️ Shortcuts & Cheatsheet

| Action | Shortcut / Trigger |
| :--- | :--- |
| **Toggle Screen Veil** | `⌥⌘B` (*Option + Command + B*) |
| **Shuffle to Random Preset** | `⌥⇧⌘B` (*Option + Shift + Command + B*) |
| **Quick Toggle via Menu Bar** | `⌥` + Click (*Option-Click*) on menu bar icon |
| **Open Control Panel** | Click menu bar icon |
| **Dismiss Veil Manually** | Double-click screen (when Click-Through is disabled) |
| **Auto-Wake** | Move mouse / tap any keyboard key |

---

## 💻 CLI & Automation (`./glass`)

Control `please_dont_look` directly from your terminal, Alfred, Raycast, or Stream Deck:

```bash
# Toggle blur on/off
./glass --toggle

# Explicit commands
./glass --blur
./glass --unblur
./glass --random

# Switch to a specific preset
./glass --preset sakura_pink
./glass --preset obsidian
./glass --preset neon
./glass --preset frost

# Inspect status
./glass --status

# List available presets
./glass --list-presets

# Gracefully quit
./glass --quit
```

### URL Schemes (Raycast, Alfred, Apple Shortcuts)
You can also trigger actions using `open`:
- `open glassscreen://toggle`
- `open glassscreen://blur`
- `open glassscreen://unblur`
- `open "glassscreen://preset?name=obsidian"`

---

## 🏗️ Architecture: Why It's Blazing Fast

```
+-----------------------------------------------------------+
|                      macOS Display                        |
+-----------------------------------------------------------+
                              ▲
                              │  GPU Hardware Compositor Pass
+-----------------------------------------------------------+
|            GlassOverlayWindow (NSPanel / Window)          |
|  - NSVisualEffectView (.behindWindow, hardware composited)|
|  - CGSSetWindowBackgroundBlurRadius (Direct WindowServer) |
|  - Procedural micro-grain noise layer                     |
|  - 1px Specular top-edge gradient bevel                   |
+-----------------------------------------------------------+
                              ▲
                              │  Zero Frame Grabs / Zero CPU
+-----------------------------------------------------------+
|              Underlying macOS Apps & Windows              |
+-----------------------------------------------------------+
```

1. **Hardware Compositing**: Rather than taking constant screenshots, we direct macOS's native WindowServer engine to apply gaussian blur matrices directly during display rasterization.
2. **Procedural Grain Layer**: Noise grain is calculated once upon launch into an efficient bitmap pattern and tiled with GPU caching.
3. **Smart Idle Monitoring**: Uses low-level `CGEventSource.secondsSinceLastEventType` to measure idle time without requiring Accessibility / Keylogger permissions.
4. **Energy Conservation**: When blur is deactivated, overlay windows are removed from the window hierarchy, dropping resource usage to true **0.0% CPU**.

---

## 🤝 Contributing

Contributions, issue reports, and feature requests are welcome!
Feel free to open an issue or submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push -u origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.

<div align="center">
<sub>Made with ❤️ for privacy, aesthetic lovers, and anyone who values peace of mind.</sub>
</div>
