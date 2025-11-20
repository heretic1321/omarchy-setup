#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Error handling
handle_error() {
    log_error "An error occurred on line $1"
    exit 1
}

# Confirmation prompt
confirm() {
    read -r -p "$1 [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

# Check if running as root (we usually don't want this for the main script, but sudo for specific commands)
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "Please do not run this script as root. It will ask for sudo when needed."
        exit 1
    fi
}

# Check if package is installed
package_is_installed() {
    pacman -Qi "$1" &> /dev/null
}
