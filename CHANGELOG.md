# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-01-02

### Added

- **SelectTable component**: Interactive single-selection in a grid layout
  - Items displayed in auto-calculated columns based on terminal width
  - Navigate with h/j/k/l, arrow keys, or Tab/Shift+Tab
  - Visual cursor indicator with customizable styling
  - Theme integration for automatic colors
  - Requires OTP 28+ for native raw terminal mode
- **MultiSelectTable component**: Interactive multi-selection in a grid layout
  - Same navigation as SelectTable plus Space to toggle selections
  - Support for min/max selection constraints
  - Pre-selection of items via `preselect/2`
  - Select all (a) and clear all (n) shortcuts
  - Customizable selection markers (*, ✓, ●, etc.)

### Fixed

- Character width calculation for Dingbats (✓, ✔, →, etc.) now correctly treated as width 1
- Table module now strips ANSI codes when calculating display width for styled content
- Grid sizing includes safety margin to prevent line wrapping at terminal edge

## [0.4.0] - 2026-01-02

### Added

- **Select component**: Interactive selection menus for CLI applications
  - Keyboard navigation with arrow keys and vim bindings (j/k)
  - Support for items with custom return values via tuples
  - Theme integration for automatic styling
  - Requires OTP 28+ for native raw terminal mode
- **Theme system**: Global themes with 12 built-in color schemes
  - Themes: dracula, nord, gruvbox, one, solarized, monokai, material, github, aura, dolphin, chalk, cobalt
  - Automatic theme colors for Table, Tree, List, and Select components
  - Semantic color roles: background, foreground, header, border, emphasis, muted, success, warning, error
- **Table text wrapping**: Automatic text wrapping with terminal width detection
  - Words wrap at column boundaries
  - Long words break with hyphens
  - Auto-sizing based on terminal width

### Fixed

- Table border intersections render correctly
- Improved cell styling in tables

## [0.1.0] - 2025-12-31

### Added

- Initial release of Esc terminal styling library
- **Core styling**: ANSI color support (basic 16, 256-color, true color/RGB)
- **Box model**: Padding, margins, and borders
- **Border styles**: Rounded, double, thick, hidden, normal, and custom borders
- **Text alignment**: Left, center, right alignment with dimensional constraints
- **List component**: Ordered and unordered lists with customizable markers
- **Table component**: Data tables with headers, custom borders, and column alignment
- **Tree component**: Hierarchical tree rendering with connectors

[Unreleased]: https://github.com/vectorfrog/esc/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/vectorfrog/esc/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/vectorfrog/esc/compare/v0.1.0...v0.4.0
[0.1.0]: https://github.com/vectorfrog/esc/releases/tag/v0.1.0
