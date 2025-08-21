Collection of [BAR (Beyond All Reason)](https://www.beyondallreason.info/) widgets I made for a friend.

Custom widgets are installed to `LuaUI/Widgets`.
See **Open Install Directory** in BAR's launcher.
Installed widgets are enabled ingame at *Settings* -> *Custom* -> *Widgets*.

See [resopmok's keybind guide](https://github.com/resopmok/BAR_uikeys_collections/blob/main/keybind-guide.md) for changing keybinds.

Widgets:
* [Reclaim Selected](#reclaim-selected) ([`cmd_reclaim_selected.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/cmd_reclaim_selected.lua))
* [Holo Place](#holo-place) ([`cmd_holo_place.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/cmd_holo_place.lua))
* [Track Sabotage](#track-sabotage) ([`game_track_sabotage.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/game_track_sabotage.lua))
* [Eco Ledger](#eco-ledger) ([`gui_eco_ledger.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/gui_eco_ledger.lua))



## Reclaim Selected

Adds a button to reclaim selected units with nearby nano turrets.

Unlike area reclaim in BAR it does not tell nano turrets to reclaim targets outside of range.

Reclaim orders are shuffled by default to minimize nano turret retarget delay.

Keybinds:
* `reclaim_selected` - orders selected units to reclaim targets one at a time
* `reclaim_selected_shuffle` -- (default) same as above but shuffles orders



## Holo Place

Adds a toggle button to builders.

While enabled builders will force a nano turret to target their current building and skip to next building as long as nano turrets are available.

Useful for building LRPC with an arm commander in NuttyB.

Keybinds:
* `holo_place` - toggles holo place on selected units



## Track Sabotage

Pings client-side (other players won't see) when friendly fire destroys an economy unit.

Logs to `userdata/<GAME_DATETIME>.json`.



## Eco Ledger

Adds a window in the top bar that shows metal/energy rate going into economy buildings.



&nbsp;

## Distribution

These widgets are not open source and redistribution is not permitted.
Link to [github.com/manshanko/bar-widgets](https://github.com/manshanko/bar-widgets) for sharing these widgets.
