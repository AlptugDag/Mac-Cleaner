<p align="center">
  <img src="assets/icon.png" width="160" alt="Mac-Cleaner Liquid Glass Icon" style="border-radius: 34px;">
</p>

<h1 align="center">mac-cleaner</h1>

<p align="center">
  A zero-dependency bash script and one-click macOS Automator app that deep-cleans every cache, log, messaging media dump, and "System Data" junk folder your Mac accumulates — with special focus on Adobe Creative Cloud, video editors, and bloated communication apps.
  <br><br>
  <img src="https://img.shields.io/badge/macOS-12%2B-black" alt="macOS 12+">
  <img src="https://img.shields.io/badge/shell-bash-blue" alt="bash">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT">
  <img src="https://img.shields.io/badge/safe-local_cache_only-brightgreen" alt="Safe: Local Cache Only">
</p>

---

## Why mac-cleaner?

Ever opened **System Settings → General → Storage** only to find that **"System Data" (Sistem Verileri)** is hogging 50GB to 150GB+ of your SSD with no built-in way to see or clear what's inside?

Finder lumps everything it doesn't consider standard user documents or photos into "System Data":
- Huge media caches from video & audio suites (Adobe Premiere, After Effects, DaVinci Resolve)
- Gigabytes of cached images, videos, and voice messages from **WhatsApp, Telegram, and Discord**
- Hidden system temporary folders in `/private/var/folders` that macOS forgets to sweep
- Build caches and toolchains from developer tools & package managers (Homebrew, npm, pip, Xcode)

`mac-cleaner` hunts down these hidden disk hogs and reclaims your SSD in seconds.

---

## What It Cleans

### 1. 💬 Messaging & Social Apps (Local Caches Only)
> **Safe guarantee:** This **only** deletes temporary media caches stored on your Mac. It **never** touches your chat histories or deletes media from your phone / cloud servers. Next time you view older media on WhatsApp or Telegram, it will simply re-download on demand.

- **WhatsApp:** Cleans cache, temporary media downloads, and group container caches across both Mac App Store and direct Web downloads (`net.whatsapp.WhatsApp`, `desktop.WhatsApp`, and shared group containers).
- **Telegram:** Wipes cached stickers, downloaded media (`account-*/postbox/media`), and account database caches.
- **Discord:** Clears regular `Cache`, Chromium `Code Cache`, and accumulated crash reports (`Crashpad`).
- **Slack:** Clears message caches and Service Worker `CacheStorage`.
- **Spotify:** Purges bloated offline streaming cache (`PersistentCache`).
- **Zoom & Microsoft Teams:** Purges diagnostic logs, support dump folders, and temporary blob storage.

---

### 2. 🖥️ macOS "System Data" & OS-Level Cleanup
- **`/private/var/folders` Temporary Files:** macOS holds onto user temp and cache directories for weeks on machines that sleep instead of rebooting. Scans and prunes files older than 3 days.
- **Deep User & System Logs:** Empties `~/Library/Logs/*` and user application error archives.
- **System Caches:** Wipes user-level cache repositories in `~/Library/Caches/*`.
- **Trash Bin:** Triggers native Finder AppleScript cleanup across all connected internal and external APFS volumes.

---

### 3. 🎨 Adobe Creative Cloud & Post-Production Suites
Targets all installed versions of Adobe applications dynamically using recursive directory matching:

- **Shared Media Caches:** Empties `Common/Media Cache Files`, `Common/Media Cache`, `Common/Peak Files`, `Common/PTX`, and `Common/Cache`.
- **Premiere Pro:** Deletes project-level media cache files inside `~/Documents/Adobe/Premiere Pro/*/Profile-*/`.
- **After Effects:** Cleans Disk Cache, preview renders, and temporary composition files.
- **Photoshop:** Purges AutoRecover scratch state and temporary work files.
- **Lightroom Classic & CC:** Wipes preview catalog files (`*.lrdata`) and sync caches.
- **Audition:** Empties peak files and autosave directories.
- **InDesign:** Removes orphaned `InDesign Recovery` files.
- **Media Encoder:** Clears Surround cache and render log history.
- **Substance 3D Suite:** Cleans Painter, Designer, Sampler, and Stager cache & temp folders.
- **Camera Raw & Bridge:** Empties full RAW image cache and thumbnail libraries.
- **Creative Cloud Desktop:** Clears CoreSync, OOBE, and UPI runtime cache files.
- **DaVinci Resolve:** Clears `CacheClip`, gallery stills (`.gallery`), and application render cache.

---

### 4. 🛠️ Package Managers & Developer Stores
Where tools provide built-in safe cleanup routines, `mac-cleaner` calls them natively to maintain registry integrity:

- **Homebrew:** `brew cleanup -s` and `brew autoremove`
- **Node.js:** `npm cache clean --force`, `pnpm store prune`, `yarn cache clean`
- **Python:** `pip3 cache purge`, `uv cache clean`
- **Apple / iOS:** Xcode `DerivedData`, `iOS/watchOS/tvOS DeviceSupport` symbol caches, CoreSimulator caches, and uninstalled simulator cleanup (`xcrun simctl delete unavailable`)
- **Other Stores:** Gradle (`~/.gradle/caches`), Cargo registry caches, CocoaPods, SwiftPM, Go build cache, Cypress, and Playwright browsers

---

### 5. 🌐 Web Browsers
- **Safari:** Cleans `com.apple.Safari` browser caches.
- **Google Chrome & Edge:** Clears `Default/Cache` and `Media Cache`.
- **Firefox:** Wipes `cache2` disk storage across all user profiles.

---

## Usage

### Option A: Interactive Terminal Script

1. Clone the repository:
   ```bash
   git clone https://github.com/AlptugDag/Mac-Cleaner.git
   cd Mac-Cleaner
   chmod +x clean.sh
   ```

2. Perform a **safe dry run** (shows exactly what would be removed without deleting anything):
   ```bash
   ./clean.sh
   ```

3. Run with `--yes` to apply the cleanup and reclaim disk space:
   ```bash
   ./clean.sh --yes
   ```

---

### Option B: One-Click Desktop Application

For daily convenience, the repo includes `OTOMATİK PC TEMİZLEME.app` (an Automator launcher):

1. Double-click `OTOMATİK PC TEMİZLEME.app`.
2. A banner notification appears: *"PC Temizleme Başladı 🚀"*.
3. Runs all cleanup tasks quietly in the background.
4. When finished, displays a summary notification displaying completed tasks.

#### 💡 Granting Full Disk Access (Recommended)
macOS restricts scripts from touching the Trash bin, Mail downloads, and select container directories unless granted permission:
1. Open **System Settings → Privacy & Security → Full Disk Access**.
2. Click `+` and add **OTOMATİK PC TEMİZLEME.app** (or your Terminal app).
3. Toggle it **ON**.

---

## Safety & Design Philosophy

- **Zero External Dependencies:** Runs entirely on stock macOS bash, standard UNIX utilities (`find`, `awk`, `rm`), and AppleScript.
- **Dry-Run by Default:** Calling `./clean.sh` without flags will never delete a single byte.
- **Preserves Your Data:** Never touches projects, documents, photo libraries, or chat histories.

---

## License

MIT License — feel free to fork, customize, and share!
