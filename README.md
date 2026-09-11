# Forage Tags

A Project Zomboid **Build 42** mod. Tag the forageable items you care about and
they get a gold star on their pin in search mode, plus a gold homing arrow
instead of the usual white one.

![Forage Tags](ForageTags/42/poster.png)

## What it does

- Tag any forageable item and its pin gets a star
- Tag a whole category (Berries, Mushrooms, Firewood…) in one click
- Right-click any pin you've found to tag or untag it on the spot
- Browse and search all 700+ forageable items in one window
- Tagged items get a gold homing arrow, so you can tell what's worth walking toward
- Tags save per character
- English, Russian and Ukrainian

Nothing is revealed that the base game hides — tags only appear on items you've
already spotted and identified.

## Install

Not on the Steam Workshop yet, so install manually.

1. Download or clone this repository
2. Rename the folder to `ForageTags`
3. Move it into `%UserProfile%/Zomboid/mods/`
4. Enable **Forage Tags** in the mod list when starting or loading a save

The final path should look like: Zomboid/mods/ForageTags/common/42/mod.info/media/...

The empty `common` folder must be there — Build 42 won't list the mod without it.

## Usage

**Tag from a pin.** Right-click any forage pin you've spotted and choose
"Tag this item".

**Tag from the window.** Right-click a pin and choose "Forage Tags…", or use the
same option from any pin. Tick a category to tag everything in it, or click the
category name to expand it and pick individual items.

**Search.** Type in the box at the top to filter by item name.

**All categories.** Off by default, showing only the categories the game uses for
search focus. Turn it on to reach everything else — Fish Bait, Bones, Forest
Goods and so on.

**Homing arrow.** On by default. Turn it off if you'd rather only have the stars.

## Compatibility

Client-side only. Safe to add or remove mid-save; removing it just leaves your
tags unread in the character's data.

Hooks `renderPinIcon` and `updateWorldMarker` on `ISForageIcon` by wrapping
rather than replacing, so it should coexist with other foraging mods. If you hit
a conflict, please open an issue.

## Credits

Star icon from [cliparts.co](https://cliparts.co/clipart/8332).

Built with AI assistance (Claude). The design decisions, testing and debugging
are mine; a good deal of the Lua was written collaboratively. Flagging it
because I'd rather say so than not.

## Licence

MIT — see `LICENSE`. This covers the code only; the star icon is subject to
cliparts.co's own terms.
