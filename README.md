<p align="center">
  <img src="assets/icon.png" width="120" alt="mac-cleaner icon">
</p>

<h1 align="center">mac-cleaner</h1>

<p align="center">
  A zero-dependency bash script and one-click macOS Automator app that deep-cleans every cache, log and junk folder your Mac accumulates — with a special focus on Adobe Creative Cloud.
  <br><br>
  <img src="https://img.shields.io/badge/macOS-12%2B-black" alt="macOS 12+">
  <img src="https://img.shields.io/badge/shell-bash-blue" alt="bash">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT">
</p>

---

## What it cleans

| Category | Details |
|---|---|
| **Adobe Creative Cloud** | Premiere Pro, After Effects, Photoshop, Lightroom, Audition, InDesign, Media Encoder, Bridge, Acrobat, XD, Character Animator, Substance 3D, Camera Raw — disk caches, preview renders, temp files, peak files, autosave data, shared media cache |
| **DaVinci Resolve** | CacheClip, Gallery, app support cache |
| **Xcode & iOS Dev** | DerivedData, DeviceSupport symbols, Simulator caches, unavailable simulator devices |
| **Package managers** | Homebrew, npm, pip, pnpm, yarn, uv, Gradle, Cargo, CocoaPods, SwiftPM, Go, Cypress, Playwright |
| **System & user** | `~/Library/Caches`, `~/Library/Logs`, per-user temp & cache in `/var/folders` (files > 3 days) |
| **Messaging apps** | WhatsApp, Telegram (media cache), Discord, Slack, Spotify, Zoom, Microsoft Teams |
| **Browsers** | Safari, Chrome, Firefox, Edge, Arc |
| **Developer tools** | Docker (`system prune`), VS Code, Cursor, Android Studio |
| **Trash** | Empties all Trash volumes via Finder |

> **Nothing is deleted without your explicit confirmation.** Running without `--yes` is always a safe dry run.

---

## Install

```bash
git clone https://github.com/alptug/mac-cleaner.git
cd mac-cleaner
chmod +x clean.sh
```

---

## Usage

### Terminal (recommended for first use)

```bash
./clean.sh            # dry run — see what would be deleted
./clean.sh --yes      # actually delete
```

### One-click Automator app

The repo includes a ready-to-use macOS Automator application in `OTOMATİK PC TEMİZLEME.app`.
Double-click it from Finder — it will:

1. Show a start notification immediately.
2. Run the full clean in the background.
3. Show a completion notification when done.

#### Optional: Full Disk Access (recommended)

macOS silently blocks access to `Trash`, `Mail`, `Messages` and other sandboxed folders without this grant.

1. **Apple menu → System Settings → Privacy & Security → Full Disk Access**
2. Click `+` and add **OTOMATİK PC TEMİZLEME.app**
3. Toggle it on. macOS will quit the app — reopen it afterwards.

---

## How it works

Every category uses a two-pass design:

1. **Dry run** (`./clean.sh`) — expands all globs, prints every path it *would* remove, then exits. Nothing is touched.
2. **Apply** (`./clean.sh --yes`) — iterates the same list, removes each path, prints a coloured summary, then reports how much disk space was reclaimed.

Package managers that ship their own prune commands (`brew cleanup`, `npm cache clean`, `pip cache purge`, …) are called natively so their internal bookkeeping stays consistent. Plain `rm -rf` is used only when no native command exists.

After the run, free space before and after is printed. macOS's Storage pane in System Settings recalculates lazily — reopen it or wait a moment to see the updated number.

---

## Adobe coverage

mac-cleaner targets every writable cache that Adobe applications produce, across **all installed versions** simultaneously:

- **Shared** — `Common/Media Cache Files`, `Common/Media Cache`, `Common/Peak Files`, `Common/PTX`, `Common/Cache`
- **Premiere Pro** — project-level media cache inside `~/Documents/Adobe`
- **After Effects** — Disk Cache, preview renders, temp directories
- **Photoshop** — AutoRecover files, Temp folder
- **Lightroom Classic** — preview catalogue (`*.lrdata`), application caches
- **Lightroom CC** — cloud sync caches
- **Audition** — Autosave, Peaks
- **InDesign** — InDesign Recovery folder
- **Media Encoder** — Surround & Log folders
- **Bridge** — thumbnail and metadata caches
- **Acrobat / Reader** — application caches
- **Camera Raw** — full cache directory
- **Substance 3D** — Painter, Designer, Sampler, Stager — cache & temp
- **Character Animator** — scene cache
- **Creative Cloud app** — CoreSync logs, OOBE logs, UPI cache
- **Dynamic Link** — media server cache
- **Shared** — `~/Library/Logs/Adobe/*`, `~/Library/Caches/Adobe/*`, `com.adobe.dunamis` cache

---

## Requirements

macOS 12 (Monterey) or later. No third-party tools required.

---

## License

MIT — see [LICENSE](LICENSE).

---

*Made with ❤️ to stop Adobe from eating your SSD.*
