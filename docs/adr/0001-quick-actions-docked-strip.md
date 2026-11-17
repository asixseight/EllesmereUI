# Quick Actions are a docked strip, not edits to the Unit Menu

Quick Actions render in our own frame docked beside Blizzard's Unit Menu instead of restyling or extending the menu's entries. Any insecure code in the menu's build (`Menu.ModifyMenu`, `AddMenuAcquiredCallback`, writes into the style mixin) taints it, and its protected entries (Set Focus, Follow, raid markers) then throw `ADDON_ACTION_FORBIDDEN`. While the menu is open its frames also refuse new textures and font strings, so icons or colored buttons inside it are impossible anyway. `EllesmereUI_MenuFallbacks.lua` already docks a frame (View Houses) beside the menu this way.

## Considered Options

- **Edit the Unit Menu**: blocked by taint and by the region lock above.
- **Replace the Unit Menu with our own**: every protected entry would need its own SecureActionButton with macrotext, and the menu would fall behind whenever Blizzard adds an entry.

## Consequences

Blizzard's own entries for Trade, Invite, Whisper and the rest stay in the menu, so each action appears twice: as a Quick Action button and as a menu entry. That's deliberate; don't try to hide the entries.
