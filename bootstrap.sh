#!/usr/bin/env bash
set -e

echo "🍏 Fox's Mac Bootstrap"
echo "======================"

# ─── Homebrew ────────────────────────────
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ─── Taps ────────────────────────────────
echo "🍺 Adding taps..."
brew tap nikitabobko/tap

# ─── Brewfile ────────────────────────────
echo "📦 Installing packages..."
brew bundle --file=Brewfile

# ─── macOS Defaults ──────────────────────
echo "⚙️  Setting macOS defaults..."

# Tangentbord
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Screenshots
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots

# ─── Restart affected apps ───────────────
echo "🔄 Restarting apps..."
killall Finder || true
killall Dock || true
killall SystemUIServer || true

# ─── Reminder ────────────────────────────
echo ""
echo "✅ Done!"
echo ""
echo "Manual steps:"
echo "  1. System Settings → Keyboard → Modifier Keys → Caps Lock: Control"
echo "  2. Log out/in for all changes to take effect"
echo ""
echo "🍺 Enjoy your new Mac!"
