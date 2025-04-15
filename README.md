Collection of widgets for [BAR (Beyond All Reason)](https://www.beyondallreason.info/).

Widgets are placed in `LuaUI/Widgets`. See **Open Install Directory** in the launcher for BAR's install directory.

Widgets:
* [Track Sabotage](#track-sabotage) ([`game_track_sabotage.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/game_track_sabotage.lua))
* [Eco Ledger](#eco-ledger) ([`gui_eco_ledger.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/gui_eco_ledger.lua))
* [Reclaim Selected](#reclaim-selected) ([`cmd_reclaim_selected.lua`](https://raw.githubusercontent.com/manshanko/bar-widgets/main/cmd_reclaim_selected.lua))



### Track Sabotage

Does a local ping when friendly fire destroys an economy building in PvE.



### Eco Ledger

Shows metal/energy going into economy buildings on the top bar.



### Reclaim Selected

Adds button to queue selected units for reclaim with nearby nano turrets.

Does not tell nano turrets to reclaim targets outside their range unlike area reclaim.

Reclaims are inserted first in nano turret order queues.

Supports shuffling reclaims to work around nano turret retarget delay.
Will shuffle if holding space when using UI button.

Keybinds:
* `reclaim_selected`
* `reclaim_selected_shuffle`
