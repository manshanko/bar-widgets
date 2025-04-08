function widget:GetInfo()
    return {
        name    = "Eco Ledger",
        desc    = "Show resources going into economy buildings",
        author  = "manshanko",
        date    = "2025-04-03",
        layer   = 2,
        enabled = false,
    }
end

local CONFIG = {
    -- number of game frames between updates (1 second is 30 frames)
    update_rate = 15,

    font_file = "fonts/" .. Spring.GetConfigString("bar_font2", "Exo2-SemiBold.otf"),
}

local echo = Spring.Echo
local GetUnitIsBeingBuilt = Spring.GetUnitIsBeingBuilt
local GetTeamRulesParam = Spring.GetTeamRulesParam
local ValidUnitID = Spring.ValidUnitID
local GetMouseState = Spring.GetMouseState

local UnitDefs = UnitDefs

local fuiRectRound, fuiElement
local fui_ELEMENT_MARGIN
local FONT, WIDTH, HEIGHT
local DLIST_GUI

local MY_TEAM = Spring.GetLocalTeamID()
local ECO_DEFS = {}
local AREA = {0, 0, 0, 0}

local IN_PROGRESS_ECO = {}
local GAME_STARTED = false
local FRAME_COUNT = 0
local ECO_METAL = 0
local ECO_ENERGY = 0
local TICK_ECO_METAL = 0
local TICK_ECO_ENERGY = 0
local UPDATE_GUI = false
local CONVERTING = 0

for unit_def_id, unit_def in pairs(UnitDefs) do
    if unit_def.energyMake > 0
        or unit_def.energyUpkeep < 0
        or unit_def.extractsMetal > 0
        or (unit_def.customParams and unit_def.customParams.energymultiplier)
        or (unit_def.customParams and unit_def.customParams.energyconv_efficiency)
    then
        ECO_DEFS[unit_def_id] = unit_def
    end
end

local function updateGui()
    local free
    local topbar = WG["topbar"].GetFreeArea()
    if WG["converter_usage"] and (CONVERTING and CONVERTING > 0) then
        local cu = WG["converter_usage"].GetPosition()
        free = { fui_ELEMENT_MARGIN + cu[3], topbar[2], topbar[3], topbar[4], topbar[5] }
        if free[1] < topbar[1] then
            free[1] = topbar[1]
        end
    else
        free = topbar
    end
    local scale = free[5]
    AREA[1] = free[1]
    AREA[2] = free[2]
    AREA[3] = free[1] + math.floor(50 * scale)
    if AREA[3] > free[3] then
        AREA[3] = free[3]
    end
    AREA[4] = free[4]

    local font_size = (AREA[4] - AREA[2]) * 0.3

    -- special case values lower than 1.0 to avoid formatSI prefixes (millisecond, nanosecond, etc)
    local metal = TICK_ECO_METAL
    if metal > 0 and metal < 1 then
        metal = string.format("-%.2f", metal)
    else
        metal = string.formatSI(-metal)
    end

    local energy = TICK_ECO_ENERGY
    if energy > 0 and energy < 1 then
        energy = string.format("-%.2f", energy)
    else
        energy = string.formatSI(-energy)
    end

    if DLIST_GUI then
        gl.DeleteList(DLIST_GUI)
    end
    DLIST_GUI = gl.CreateList(function()
        fuiElement(AREA[1], AREA[2], AREA[3], AREA[4], 0, 0, 1, 1)

        FONT:Begin()

        -- metal used
        FONT:SetTextColor(1, 1, 1, 1)
        FONT:Print(metal,
            AREA[3] - (font_size * 0.5),
            AREA[2] + 2.8 * ((AREA[4] - AREA[2]) / 4) - (font_size / 5),
            font_size,
            "or")

        -- energy used
        FONT:SetTextColor(1, 1, 0, 1)
        FONT:Print(energy,
            AREA[3] - (font_size * 0.5),
            AREA[2] + 1.2 * ((AREA[4] - AREA[2]) / 4) - (font_size / 5),
            font_size,
            "or")

        FONT:End()
    end)
end

local function ForgetUnit(self, unit_id)
    IN_PROGRESS_ECO[unit_id] = nil
end

widget.UnitFinished = ForgetUnit
widget.UnitDestroyed = ForgetUnit
widget.UnitTaken = ForgetUnit

function widget:UnitCreated(unit_id, unit_def_id, unit_team, builder_id)
    if unit_team == MY_TEAM and ECO_DEFS[unit_def_id] then
        local unit_def = ECO_DEFS[unit_def_id]
        IN_PROGRESS_ECO[unit_id] = {
            progress = 0,
            metal_cost = unit_def.metalCost,
            energy_cost = unit_def.energyCost,
        }
    end
end

function widget:GameFrame()
    if not GAME_STARTED then
        GAME_STARTED = true
        UPDATE_GUI = true
    end

    for unit_id, info in pairs(IN_PROGRESS_ECO) do
        local being_built, build_progress = GetUnitIsBeingBuilt(unit_id)
        if being_built then
            local delta = build_progress - info.progress
            info.progress = build_progress

            ECO_METAL = ECO_METAL + delta * info.metal_cost
            ECO_ENERGY = ECO_ENERGY + delta * info.energy_cost
        else
            IN_PROGRESS_ECO[unit_id] = nil
        end
    end
    FRAME_COUNT = FRAME_COUNT + 1

    if FRAME_COUNT > CONFIG.update_rate then
        TICK_ECO_METAL = 30 * ECO_METAL / FRAME_COUNT
        TICK_ECO_ENERGY = 30 * ECO_ENERGY / FRAME_COUNT
        ECO_METAL = 0
        ECO_ENERGY = 0
        FRAME_COUNT = 0
    end

    -- update gui when converter usage is toggled
    if WG['converter_usage'] then
        local converting = GetTeamRulesParam(MY_TEAM, "mmCapacity")
        if CONVERTING ~= converting then
            CONVERTING = converting
            UPDATE_GUI = true
        end
    end
end

local TIME = 0
local DEBOUNCE = false
function widget:Update(dt)
    if not GAME_STARTED then
        return
    end

    if TIME < 1 and (DEBOUNCE or not UPDATE_GUI) then
        TIME = TIME + dt
        return
    end

    TIME = 0
    DEBOUNCE = UPDATE_GUI
    if UPDATE_GUI then
        UPDATE_GUI = false
    end

    updateGui()
end

function widget:ViewResize(width, height)
    WIDTH = width
    HEIGHT = height

    if not fuiRectRound then
        fuiRectRound = WG["FlowUI"].Draw.RectRound
        fuiElement = WG["FlowUI"].Draw.Element
        fui_ELEMENT_MARGIN = WG["FlowUI"].elementMargin

        FONT = WG["fonts"].getFont(CONFIG.font_file)
    end
end

function widget:DrawScreen()
    if DLIST_GUI then
        gl.CallList(DLIST_GUI)
    end

    local x, y = GetMouseState()
    if math.isInRect(x, y, AREA[1], AREA[2], AREA[3], AREA[4]) then
        Spring.SetMouseCursor("cursornormal")
    end
end

function widget:MousePress(x, y, _button)
    return math.isInRect(x, y, AREA[1], AREA[2], AREA[3], AREA[4])
end

function widget:Initialize()
    local width, height = gl.GetViewSizes()
    widget:ViewResize(width, height)
end

function widget:Shutdown()
    if DLIST_GUI then
        gl.DeleteList(DLIST_GUI)
    end
end
