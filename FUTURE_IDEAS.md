# Future Feature Ideas

Potential additions to the Esc terminal styling library.

## Input Components

- [ ] **TextInput** - Single-line text input with cursor navigation, input history, and validation support.
- [ ] **Password** - Masked input field with optional reveal toggle for password entry.
- [ ] **TextArea** - Multi-line text editor with line numbers, scrolling, and basic editing commands.
- [ ] **NumberInput** - Numeric input with increment/decrement (arrow keys), min/max bounds, and step size.

## Progress & Status

- [ ] **ProgressBar** - Determinate progress indicator with percentage display, ETA calculation, and customizable bar characters.
- [x] **Spinner** - Indeterminate loading indicator with multiple animation styles (dots, braille, arrows, bounce). [spec](plans/spinner/spec.md) | [plan](plans/spinner/plan.md)
- [ ] **Stepper** - Multi-step wizard indicator showing current position (e.g., "Step 2 of 5") with completion states.

## Feedback & Alerts

- [ ] **Toast** - Temporary notification messages that auto-dismiss, positioned at screen edges.
- [ ] **Alert** - Styled message boxes for info, success, warning, and error states with icons and borders.
- [ ] **Confirm** - Yes/No confirmation dialog with keyboard navigation and customizable button labels.
- [ ] **Badge** - Small inline status indicators for counts, states, or labels.

## Data Display

- [ ] **Syntax** - Code and JSON syntax highlighting with theme-aware colors.
- [ ] **Diff** - Side-by-side or unified diff viewer for comparing text/code changes.
- [ ] **KeyValue** - Aligned key-value pair display (like `git config --list` output).
- [ ] **Sparkline** - Inline mini charts using block characters (▁▂▃▅▇) for quick data visualization.

## Layout

- [ ] **Columns** - Side-by-side content layout with configurable widths and gutters.
- [ ] **Divider** - Horizontal and vertical separators with optional centered labels.
- [ ] **Panel / Card** - Bordered content containers with headers, footers, and padding.
- [ ] **Tabs** - Tabbed content switching with keyboard navigation between panes.

## Navigation

- [ ] **Breadcrumbs** - Path or hierarchy display with separators (Home > Projects > Esc).
- [x] **Pagination** - Page controls for navigating large datasets with page size options. [spec](plans/select-pagination/spec.md) | [plan](plans/select-pagination/plan.md)
- [ ] **CommandPalette** - Fuzzy-searchable command menu (like VS Code's Ctrl+Shift+P) for action discovery.

## Advanced Select

- [ ] **Autocomplete** - Text input with dropdown suggestions that filter as you type.
- [ ] **CascadingSelect** - Dependent dropdowns where selection in one updates options in the next (Country → State → City).
- [ ] **TreeSelect** - Hierarchical selection with expand/collapse nodes for nested data.

## Utility

- [ ] **KeyboardHints** - Display available keyboard shortcuts contextually (like vim's which-key plugin).
- [ ] **FuzzyFilter** - Add fuzzy matching option to existing filter mode (beyond glob patterns).
- [ ] **Scrollable** - Wrapper component for scrolling long content with visual scrollbar indicator.

---

## Priority Candidates

Components that would provide the most value:

- [ ] **TextInput** - Foundation for many other features
- [ ] **ProgressBar / Spinner** - Common need for CLI apps
- [ ] **Confirm** - Essential for destructive actions
- [ ] **Autocomplete** - High-value interactive component
- [ ] **Syntax** - Useful for dev tools
