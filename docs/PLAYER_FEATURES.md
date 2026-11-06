# Player view

The server window's **Players** tab reads player UUIDs from the server's
`ops.json` and `playerdata` files. World directories are discovered by their
`playerdata` folders, so renaming the world does not break discovery. Console
output is used only by the terminal view and is not parsed for player changes.
The list can be filtered by name without affecting the server process.

## Planned features

These are intentionally separate from the current read-only view:

- player actions such as kick, ban, pardon, and whitelist changes
- player UUID and skin/avatar metadata
- first-seen and last-seen timestamps
- session duration and join/leave history
- sorting by online state, name, or recent activity
- player notes and moderation history
- permission-aware controls for servers that expose a supported command interface

Player actions should be implemented as explicit server commands with clear
feedback and should not be inferred from local UI state alone.
