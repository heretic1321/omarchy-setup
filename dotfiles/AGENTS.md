# Agent Guidelines for Dotfiles Repository

## Build/Test Commands
- **Validate configs**: `hyprctl reload` (test Hyprland config syntax)
- **Shell lint**: `shellcheck scripts/*` (check shell scripts for issues)
- **Single script test**: `bash -n scripts/script_name` (syntax check specific script)

## Code Style Guidelines

### Shell Scripts
- Use `#!/usr/bin/env bash` or `#!/bin/sh` shebangs
- Enable strict mode: `set -euo pipefail`
- UPPER_CASE for global variables/constants
- lower_case_with_underscores for functions/variables
- Check command availability with `command -v cmd >/dev/null 2>&1`
- Use `|| true` for non-fatal commands
- Quote variables: `"$VAR"`

### Hyprland Configs
- Use `bindd` for documented keybindings, `bind` for undocumented
- Variables prefixed with `$`: `$terminal = alacritty`
- Comments with `#`
- Group related settings with blank lines
- Source files in logical order

### General
- No trailing whitespace
- Use 2-space indentation for configs
- Keep lines under 100 characters
- Add descriptive comments for complex logic
