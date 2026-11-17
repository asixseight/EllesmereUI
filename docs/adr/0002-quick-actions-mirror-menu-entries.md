# Quick Actions visibility mirrors the Unit Menu's entries

A Quick Action shows only when the open Unit Menu contains the matching entry, enabled. The match runs from our own timer after the menu opens and compares against Blizzard's localized global strings (`TRADE`, `WHISPER`, ...). We don't recompute leader, range, group, realm or Battle.net rules ourselves: Blizzard has already evaluated them, and in 12.x combat their inputs can be secret values we can't compare. Reading the menu doesn't taint it; only writing does.

## Considered Options

- **Our own rules from the context data**: duplicates Blizzard's logic and drifts from it, and it breaks on secret unit data. This is the fallback only if an in-game spike shows that entry labels can't be read.

## Consequences

Name-only menus (chat, friends list) never offer Trade or Inspect, because Blizzard leaves those entries out. A Quick Action that needs a unit token stays hidden when none resolves, even if the entry is present.
