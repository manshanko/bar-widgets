Collection of widgets for [BAR (Beyond All Reason)](https://www.beyondallreason.info/).

Widgets are placed in `LuaUI/Widgets`. See **Open Install Directory** in the launcher for BAR's install directory.

See [resopmok's keybind guide](https://github.com/resopmok/BAR_uikeys_collections/blob/main/keybind-guide.md) for changing keybinds.

Widgets:
* [Track Sabotage](#track-sabotage) ([`game_track_sabotage.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/game_track_sabotage.lua))
* [Eco Ledger](#eco-ledger) ([`gui_eco_ledger.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/gui_eco_ledger.lua))
* [Reclaim Selected](#reclaim-selected) ([`cmd_reclaim_selected.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/cmd_reclaim_selected.lua))
* [Holo Place](#holo-place) ([`cmd_holo_place.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/cmd_holo_place.lua))



### Track Sabotage

Does a local ping when friendly fire destroys an economy building in PvE.



### Eco Ledger

Shows metal/energy going into economy buildings on the top bar.



### Reclaim Selected

Adds button to queue selected units for reclaim with nearby nano turrets.

Does not tell nano turrets to reclaim targets outside their range.

Reclaim orders are shuffled to work around nano turret retarget delay.

Keybinds:
* `reclaim_selected` - orders selected units to reclaim targets one at a time
* `reclaim_selected_shuffle` -- same as above but shuffles orders to avoid retarget delay



### Holo Place

Adds builder toggle button.

When enabled builders will skip current build command if another builder is helping.

If a nearby nano turret is available (on guard/auto assist) then a single nano turret will help build.

With holo place a builder can lay down a grid of holos in a single action (assuming enough nano turrets to assist).

Keybinds:
* `holo_place` - toggles holo place on selected units
