#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# mac-cleaner — Comprehensive macOS junk & cache cleaner
# https://github.com/AlptugDag/Mac-Cleaner
#
# Usage:
#   ./clean.sh            dry run  (shows what would be deleted)
#   ./clean.sh --yes      apply    (actually deletes)
#   ./clean.sh --help     show help
# ─────────────────────────────────────────────────────────────────────────────

set -uo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "mac-cleaner — Comprehensive macOS junk & cache cleaner"
  echo ""
  echo "Usage:"
  echo "  ./clean.sh            Dry run (safe, deletes nothing)"
  echo "  ./clean.sh --yes      Apply (actually deletes files)"
  echo "  ./clean.sh --help     Show this help message"
  exit 0
fi

APPLY=0
[[ "${1:-}" == "--yes" ]] && APPLY=1

# ── Colours ────────────────────────────────────────────────────────────────
if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
  RED=$'\033[31m'; RESET=$'\033[0m'
else
  BOLD=""; DIM=""; GREEN=""; YELLOW=""; RED=""; RESET=""
fi

say()    { printf '%s\n' "$*"; }
header() { printf '\n%s══ %s%s\n' "$BOLD" "$*" "$RESET"; }
note()   { printf '   %s%s%s\n' "$DIM" "$*" "$RESET"; }
ok()     { printf '   %s✓ %s%s\n' "$GREEN" "$*" "$RESET"; }
warn()   { printf '   %s⚠ %s%s\n' "$YELLOW" "$*" "$RESET" >&2; }

# ── Helpers ────────────────────────────────────────────────────────────────
free_kb() { df -k / | awk 'NR==2{print $4}'; }
human_kb() {
  awk -v kb="$1" 'BEGIN{
    if(kb>=1048576) printf "%.2f GB",kb/1048576;
    else if(kb>=1024) printf "%.0f MB",kb/1024;
    else printf "%d KB",kb;
  }'
}

wipe() {
  # wipe <label> <paths...>
  local label="$1"; shift
  local removed=0
  for path in "$@"; do
    [ -e "$path" ] || continue
    if [ "$APPLY" -eq 1 ]; then
      rm -rf "$path" 2>/dev/null && removed=1 || warn "could not remove: $path"
    else
      note "would remove: $path"
      removed=1
    fi
  done
  [ "$removed" -eq 1 ] && ok "$label" || true
}

wipe_glob() {
  # wipe_glob <label> <glob>  — expands the glob safely
  local label="$1" pattern="$2"
  local found=0
  # use find to avoid "no matches found" errors
  while IFS= read -r -d '' path; do
    found=1
    if [ "$APPLY" -eq 1 ]; then
      rm -rf "$path" 2>/dev/null || warn "could not remove: $path"
    else
      note "would remove: $path"
    fi
  done < <(find $pattern -maxdepth 0 -print0 2>/dev/null || true)
  [ "$found" -eq 1 ] && ok "$label" || true
}

wipe_contents() {
  # wipe_contents <label> <dir> — empties dir but keeps it
  local label="$1" dir="$2"
  [ -d "$dir" ] || return 0
  if [ "$APPLY" -eq 1 ]; then
    find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null
    ok "$label"
  else
    note "would empty: $dir"
    ok "$label (dry run)"
  fi
}

# ── Banner ─────────────────────────────────────────────────────────────────
say "${BOLD}mac-cleaner${RESET}"
if [ "$APPLY" -eq 0 ]; then
  say "${YELLOW}Dry run — nothing will be deleted. Pass --yes to apply.${RESET}"
else
  say "${GREEN}Applying — files will be deleted.${RESET}"
fi

BEFORE=$(free_kb)

# ═══════════════════════════════════════════════════════════════════════════
header "Adobe Creative Cloud (all versions)"
# ═══════════════════════════════════════════════════════════════════════════
ADOBE_AS="$HOME/Library/Application Support/Adobe"
ADOBE_SYS="/Library/Application Support/Adobe"
ADOBE_CACHE="$HOME/Library/Caches"

# Shared media caches (Premiere / AME)
wipe_contents "Premiere · Media Cache Files"   "$ADOBE_AS/Common/Media Cache Files"
wipe_contents "Premiere · Media Cache"         "$ADOBE_AS/Common/Media Cache"
wipe_contents "Premiere · Peak Files"          "$ADOBE_AS/Common/Peak Files"
wipe_contents "Premiere · PTX"                 "$ADOBE_AS/Common/PTX"
wipe_contents "Premiere · Common Cache"        "$ADOBE_AS/Common/Cache"
wipe_glob     "Premiere · Project Media Cache" "$HOME/Documents/Adobe/Premiere Pro/*/Profile-*/Media Cache Files/*"
wipe_glob     "Premiere · Project Media Cache" "$HOME/Documents/Adobe/Premiere Pro/*/Profile-*/Media Cache/*"

# After Effects
wipe_glob     "After Effects · Disk Cache"    "$ADOBE_AS/After Effects/*/Disk Cache/*"
wipe_glob     "After Effects · Preview"       "$ADOBE_AS/After Effects/*/preview/*"
wipe_glob     "After Effects · Temp"          "$ADOBE_AS/After Effects/*/temp/*"
wipe_contents "After Effects · Caches"        "$ADOBE_CACHE/Adobe/After Effects"

# Photoshop
wipe_glob     "Photoshop · AutoRecover"       "$ADOBE_AS/Adobe Photoshop */AutoRecover/*"
wipe_glob     "Photoshop · Temp"              "$ADOBE_AS/Adobe Photoshop */Temp/*"

# Lightroom Classic
wipe_glob     "Lightroom Classic · Cache"     "$HOME/Library/Caches/com.adobe.LightroomClassicCC7/*"
wipe_glob     "Lightroom Classic · Preview"   "$HOME/Pictures/Lightroom/Lightroom Catalog Previews.lrdata/*"

# Lightroom CC (Cloud)
wipe_contents "Lightroom CC · Cache"          "$HOME/Library/Application Support/com.adobe.LightRoom/Caches"

# Audition
wipe_glob     "Audition · Autosave"           "$ADOBE_AS/Audition/*/Autosave/*"
wipe_glob     "Audition · Peaks"              "$ADOBE_AS/Audition/*/Peaks/*"

# InDesign
wipe_glob     "InDesign · Recovery"           "$ADOBE_AS/Adobe InDesign/*/InDesign Recovery/*"

# Media Encoder
wipe_glob     "Media Encoder · Surround"      "$ADOBE_AS/Adobe Media Encoder/*/MediaIO/surround/*"
wipe_glob     "Media Encoder · Logs"          "$ADOBE_AS/Adobe Media Encoder/*/Logs/*"

# Bridge
wipe_glob     "Bridge · Cache"                "$HOME/Library/Caches/Adobe/Bridge CC/*"
wipe_glob     "Bridge · Thumb Cache"          "$HOME/Library/Caches/com.adobe.bridgeCC/*"

# Acrobat / Reader
wipe_contents "Acrobat · Cache"               "$HOME/Library/Caches/Adobe/Acrobat"
wipe_glob     "Acrobat · Caches"              "$HOME/Library/Caches/com.adobe.Reader/*"
wipe_glob     "Acrobat · Caches"              "$HOME/Library/Caches/com.adobe.Acrobat.Pro/*"

# Adobe XD
wipe_glob     "Adobe XD · Logs"               "$HOME/Library/Logs/Adobe/AdobeXD/*"

# Character Animator
wipe_glob     "Character Animator · Cache"    "$ADOBE_AS/Character Animator/*/Cache/*"

# Substance 3D (Painter, Designer, Sampler, Stager)
wipe_glob     "Substance · Cache"             "$HOME/Library/Application Support/Adobe Substance*/cache/*"
wipe_glob     "Substance · Temp"              "$HOME/Library/Application Support/Adobe Substance*/temp/*"

# Camera Raw
wipe_contents "Camera Raw · Cache"            "$HOME/Library/Caches/Adobe Camera Raw"
wipe_glob     "Camera Raw · App Support"      "$ADOBE_AS/CameraRaw/Cache/*"

# Creative Cloud app
wipe_glob     "Creative Cloud · Logs"         "$HOME/Library/Logs/Adobe/CoreSync/*"
wipe_glob     "Creative Cloud · App Cache"    "$HOME/Library/Application Support/Adobe/OOBE/Logs/*"
wipe_glob     "Creative Cloud · UPIDC"        "$HOME/Library/Application Support/Adobe/UPI/*/cache/*"

# Dynamic Link
wipe_glob     "Dynamic Link · Cache"          "$ADOBE_AS/dynamiclinkmediaserver/*/cache/*"

# Shared
wipe_glob     "Adobe · Shared Logs"           "$HOME/Library/Logs/Adobe/*"
wipe_glob     "Adobe · Scratch"               "$ADOBE_AS/*/Scratch/*"
wipe_contents "Adobe · Global Cache"          "$HOME/Library/Caches/Adobe"
wipe_glob     "Adobe · com.adobe.dunamis"     "$HOME/Library/Application Support/com.adobe.dunamis/cache/*"

# ═══════════════════════════════════════════════════════════════════════════
header "DaVinci Resolve"
# ═══════════════════════════════════════════════════════════════════════════
wipe_contents "DaVinci · CacheClip"           "$HOME/Movies/CacheClip"
wipe_contents "DaVinci · Gallery"             "$HOME/Movies/.gallery"
wipe_glob     "DaVinci · App Support Cache"   "$HOME/Library/Application Support/Blackmagic Design/DaVinci Resolve/Cache/*"

# ═══════════════════════════════════════════════════════════════════════════
header "Xcode & iOS Developer"
# ═══════════════════════════════════════════════════════════════════════════
wipe_contents "Xcode · DerivedData"    "$HOME/Library/Developer/Xcode/DerivedData"
wipe_contents "Simulator · Caches"    "$HOME/Library/Developer/CoreSimulator/Caches"
wipe_glob     "Xcode · iOS DeviceSupport" "$HOME/Library/Developer/Xcode/iOS DeviceSupport/*"
wipe_glob     "Xcode · watchOS DeviceSupport" "$HOME/Library/Developer/Xcode/watchOS DeviceSupport/*"
wipe_glob     "Xcode · tvOS DeviceSupport" "$HOME/Library/Developer/Xcode/tvOS DeviceSupport/*"
if command -v xcrun &>/dev/null; then
  if [ "$APPLY" -eq 1 ]; then
    xcrun simctl delete unavailable 2>/dev/null && ok "Simulator · Unavailable devices removed"
  else
    note "would run: xcrun simctl delete unavailable"
    ok "Simulator · Unavailable devices (dry run)"
  fi
fi

# ═══════════════════════════════════════════════════════════════════════════
header "Package Managers"
# ═══════════════════════════════════════════════════════════════════════════
if command -v brew &>/dev/null; then
  if [ "$APPLY" -eq 1 ]; then
    brew cleanup -s 2>/dev/null && brew autoremove 2>/dev/null && ok "Homebrew · cleanup"
  else
    note "would run: brew cleanup -s && brew autoremove"
    ok "Homebrew (dry run)"
  fi
fi

if command -v npm &>/dev/null; then
  if [ "$APPLY" -eq 1 ]; then
    npm cache clean --force 2>/dev/null && ok "npm · cache clean"
  else
    note "would run: npm cache clean --force"
    ok "npm (dry run)"
  fi
else
  wipe_contents "npm · cacache"      "$HOME/.npm/_cacache"
fi

if command -v pip3 &>/dev/null; then
  if [ "$APPLY" -eq 1 ]; then
    pip3 cache purge 2>/dev/null && ok "pip · cache purge"
  else
    note "would run: pip3 cache purge"
    ok "pip (dry run)"
  fi
fi

if command -v uv &>/dev/null; then
  if [ "$APPLY" -eq 1 ]; then
    uv cache clean 2>/dev/null && ok "uv · cache clean"
  else
    note "would run: uv cache clean"
    ok "uv (dry run)"
  fi
fi

if command -v pnpm &>/dev/null; then
  if [ "$APPLY" -eq 1 ]; then
    pnpm store prune 2>/dev/null && ok "pnpm · store prune"
  else
    note "would run: pnpm store prune"
    ok "pnpm (dry run)"
  fi
fi

if command -v yarn &>/dev/null; then
  if [ "$APPLY" -eq 1 ]; then
    yarn cache clean 2>/dev/null && ok "yarn · cache clean"
  else
    note "would run: yarn cache clean"
    ok "yarn (dry run)"
  fi
fi

wipe_contents "Gradle · Caches"         "$HOME/.gradle/caches"
wipe "Cargo · Registry Cache"           "$HOME/.cargo/registry/cache" "$HOME/.cargo/registry/src"
wipe_contents "CocoaPods · Cache"       "$HOME/Library/Caches/CocoaPods"
wipe_contents "SwiftPM · Cache"         "$HOME/Library/Caches/org.swift.swiftpm"
wipe_contents "Go · Build Cache"        "$HOME/Library/Caches/go-build"
wipe_contents "Cypress · Cache"         "$HOME/Library/Caches/Cypress"
wipe_contents "Playwright · Cache"      "$HOME/Library/Caches/ms-playwright"

# ═══════════════════════════════════════════════════════════════════════════
header "System & User Caches"
# ═══════════════════════════════════════════════════════════════════════════
wipe_contents "User Library · Caches"   "$HOME/Library/Caches"
wipe_contents "User Library · Logs"     "$HOME/Library/Logs"

# Temp files older than 3 days
USER_TEMP=$(getconf DARWIN_USER_TEMP_DIR 2>/dev/null || true)
USER_CACHE=$(getconf DARWIN_USER_CACHE_DIR 2>/dev/null || true)
if [ -n "$USER_TEMP" ] && [ -d "$USER_TEMP" ]; then
  if [ "$APPLY" -eq 1 ]; then
    find "$USER_TEMP" -mindepth 1 -type f -mtime +3 -delete 2>/dev/null
    find "$USER_TEMP" -mindepth 1 -type d -empty -delete 2>/dev/null
    ok "Temp · files older than 3 days"
  else
    note "would prune files >3 days from: $USER_TEMP"
    ok "Temp (dry run)"
  fi
fi
if [ -n "$USER_CACHE" ] && [ -d "$USER_CACHE" ]; then
  if [ "$APPLY" -eq 1 ]; then
    find "$USER_CACHE" -mindepth 1 -type f -mtime +3 -delete 2>/dev/null
    find "$USER_CACHE" -mindepth 1 -type d -empty -delete 2>/dev/null
    ok "User Cache · files older than 3 days"
  else
    note "would prune files >3 days from: $USER_CACHE"
    ok "User Cache (dry run)"
  fi
fi

# ═══════════════════════════════════════════════════════════════════════════
header "Messaging & Social Apps"
# ═══════════════════════════════════════════════════════════════════════════
# WhatsApp
wipe_contents "WhatsApp · Caches"     "$HOME/Library/Containers/net.whatsapp.WhatsApp/Data/Library/Caches"
wipe_contents "WhatsApp · Caches"     "$HOME/Library/Containers/desktop.WhatsApp/Data/Library/Caches"
wipe_contents "WhatsApp · Group Cache" "$HOME/Library/Group Containers/group.net.whatsapp.WhatsApp.shared/Library/Caches"

# Telegram
wipe_glob     "Telegram · Caches"     "$HOME/Library/Group Containers/*.ru.keepcoder.Telegram/Library/Caches/*"
wipe_glob     "Telegram · Media"      "$HOME/Library/Group Containers/*.ru.keepcoder.Telegram/account-*/postbox/media/*"

# Discord
wipe_contents "Discord · Cache"       "$HOME/Library/Application Support/discord/Cache"
wipe_contents "Discord · Code Cache"  "$HOME/Library/Application Support/discord/Code Cache"
wipe_contents "Discord · Crashpad"    "$HOME/Library/Application Support/discord/Crashpad"

# Slack
wipe_contents "Slack · Cache"         "$HOME/Library/Application Support/Slack/Cache"
wipe_contents "Slack · Service Worker" "$HOME/Library/Application Support/Slack/Service Worker/CacheStorage"

# Spotify
wipe_contents "Spotify · Cache"       "$HOME/Library/Application Support/Spotify/PersistentCache"

# Zoom
wipe_contents "Zoom · Logs"           "$HOME/Library/Application Support/zoom.us/Logs"
wipe_contents "Zoom · Support"        "$HOME/Library/Application Support/zoom.us/support"

# Teams
wipe_glob     "Microsoft Teams · Cache" "$HOME/Library/Application Support/Microsoft/Teams/Cache/*"
wipe_glob     "Microsoft Teams · Blobs" "$HOME/Library/Application Support/Microsoft/Teams/blob_storage/*"

# ═══════════════════════════════════════════════════════════════════════════
header "Browsers"
# ═══════════════════════════════════════════════════════════════════════════
# Safari
wipe_contents "Safari · Cache"        "$HOME/Library/Caches/com.apple.Safari"

# Chrome
wipe_glob     "Chrome · Cache"        "$HOME/Library/Caches/Google/Chrome/Default/Cache/*"
wipe_glob     "Chrome · Media Cache"  "$HOME/Library/Caches/Google/Chrome/Default/Media Cache/*"

# Firefox
wipe_glob     "Firefox · Cache"       "$HOME/Library/Caches/Firefox/Profiles/*/cache2/*"

# Edge
wipe_glob     "Edge · Cache"          "$HOME/Library/Caches/Microsoft Edge/Default/Cache/*"

# Arc
wipe_glob     "Arc · Cache"           "$HOME/Library/Caches/Company/Arc/Default/Cache/*"

# ═══════════════════════════════════════════════════════════════════════════
header "Other Developer Tools"
# ═══════════════════════════════════════════════════════════════════════════
# Docker (if running)
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  if [ "$APPLY" -eq 1 ]; then
    docker system prune -f 2>/dev/null && ok "Docker · system prune"
    docker builder prune -f 2>/dev/null && ok "Docker · builder prune"
  else
    note "would run: docker system prune -f && docker builder prune -f"
    ok "Docker (dry run)"
  fi
else
  note "Docker not running — skipping"
fi

# VS Code
wipe_glob     "VS Code · Logs"        "$HOME/Library/Application Support/Code/logs/*"
wipe_glob     "VS Code · CachedData"  "$HOME/Library/Application Support/Code/CachedData/*"

# Cursor
wipe_glob     "Cursor · Logs"         "$HOME/Library/Application Support/Cursor/logs/*"
wipe_glob     "Cursor · CachedData"   "$HOME/Library/Application Support/Cursor/CachedData/*"

# Android Studio
wipe_contents "Android Studio · Cache" "$HOME/Library/Caches/Google/AndroidStudio*"

# ═══════════════════════════════════════════════════════════════════════════
header "Trash"
# ═══════════════════════════════════════════════════════════════════════════
if [ "$APPLY" -eq 1 ]; then
  osascript -e 'tell application "Finder" to empty trash' 2>/dev/null && ok "Trash · emptied"
else
  note "would empty Trash via Finder"
  ok "Trash (dry run)"
fi

# ═══════════════════════════════════════════════════════════════════════════
AFTER=$(free_kb)
GAINED=$((AFTER - BEFORE))
say ""
if [ "$APPLY" -eq 1 ]; then
  say "${BOLD}${GREEN}Done.${RESET} Free space: $(human_kb $BEFORE) → $(human_kb $AFTER)  (${GREEN}+$(human_kb $GAINED) reclaimed${RESET})"
  say "${DIM}Storage pane in System Settings recalculates lazily — reopen it or wait a moment.${RESET}"
else
  say "${BOLD}Dry run complete.${RESET} Run with ${BOLD}--yes${RESET} to apply."
fi
