function widget:GetInfo()
    return {
        name    = "Holo Place",
        desc    = "Start next holo if assisted and force guarding nano turrets to assist",
        author  = "manshanko",
        date    = "2025-04-14",
        layer   = 2,
        enabled = false,
        handler = true,
    }
end

local echo = Spring.Echo
local i18n = Spring.I18N
local GetSelectedUnits = Spring.GetSelectedUnits
local GetUnitCommandCount = Spring.GetUnitCommandCount
local GetUnitDefID = Spring.GetUnitDefID
local GetUnitIsBeingBuilt = Spring.GetUnitIsBeingBuilt
local GetUnitIsBuilding = Spring.GetUnitIsBuilding
local GetUnitCommands = Spring.GetUnitCommands
local GetUnitCurrentCommand = Spring.GetUnitCurrentCommand
local GetUnitPosition = Spring.GetUnitPosition
local GetUnitSeparation = Spring.GetUnitSeparation
local GetUnitsInCylinder = Spring.GetUnitsInCylinder
local GiveOrderToUnit = Spring.GiveOrderToUnit
local UnitDefs = UnitDefs
local CMD_REPAIR = CMD.REPAIR
local CMD_REMOVE = CMD.REMOVE
local CMD_FIGHT = CMD.FIGHT

local CMD_HOLO_PLACE = 28339
local CMD_HOLO_PLACE_DESCRIPTION = {
    id = CMD_HOLO_PLACE,
    type = CMDTYPE.ICON_MODE,
    name = "Holo Place",
    cursor = nil,
    action = "holo_place",
    params = { 0, "holo_place_off", "holo_place_on" }
}

i18n.set("en.ui.orderMenu." .. CMD_HOLO_PLACE_DESCRIPTION.params[2], "Holo Place off")
i18n.set("en.ui.orderMenu." .. CMD_HOLO_PLACE_DESCRIPTION.params[3], "Holo Place on")
i18n.set("en.ui.orderMenu." .. CMD_HOLO_PLACE_DESCRIPTION.action .. "_tooltip", "Start next building if assisted")

local BUILDER_DEFS = {}
local NANO_DEFS = {}
local BT_DEFS = {}
local MAX_DISTANCE = 0
local HOLO_PLACERS = {}

for unit_def_id, unit_def in pairs(UnitDefs) do
    BT_DEFS[unit_def_id] = unit_def.buildTime
    if unit_def.isBuilder and not unit_def.isFactory then
        BUILDER_DEFS[unit_def_id] = unit_def.buildSpeed
        if not unit_def.canMove then
            NANO_DEFS[unit_def_id] = unit_def.buildDistance
            if unit_def.buildDistance > MAX_DISTANCE then
                MAX_DISTANCE = unit_def.buildDistance
            end
        end
    end
end

local function ntNearUnit(target_unit_id)
    local pos = {GetUnitPosition(target_unit_id)}
    local units_near = GetUnitsInCylinder(pos[1], pos[3], MAX_DISTANCE, -2)
    local unit_ids = {}
    for _, id in ipairs(units_near) do
        local dist = NANO_DEFS[GetUnitDefID(id)]
        if dist ~= nil and target_unit_id ~= id then
            if dist > GetUnitSeparation(target_unit_id, id, true) then
                unit_ids[#unit_ids + 1] = id
            end
        end
    end
    return unit_ids
end

local function checkUnits(update)
    local mode = 0
    local num_hp = 0
    local num_builders = 0

    local ids = GetSelectedUnits()
    for i=1, #ids do
        local def_id = GetUnitDefID(ids[i])

        if HOLO_PLACERS[ids[i]] then
            num_hp = num_hp + 1
        end

        if BUILDER_DEFS[def_id] then
            num_builders = num_builders + 1
        end
    end

    if num_builders > 0 then
        if update then
            if num_hp >= num_builders / 2 then
                for i=1, #ids do
                    HOLO_PLACERS[ids[i]] = nil
                end
                mode = 0
            else
                for i=1, #ids do
                    HOLO_PLACERS[ids[i]] = HOLO_PLACERS[ids[i]] or true
                end
            end
        else
            if num_hp >= num_builders / 2 then
                CMD_HOLO_PLACE_DESCRIPTION.params[1] = 1
            else
                CMD_HOLO_PLACE_DESCRIPTION.params[1] = 0
            end
        end

        return true
    end
end

local function handleHoloPlace()
    checkUnits(true)
end

local function ForgetUnit(self, unit_id)
    HOLO_PLACERS[unit_id] = nil
end

widget.UnitDestroyed = ForgetUnit
widget.UnitTaken = ForgetUnit

function widget:CommandsChanged()
    if checkUnits(false) then
        local cmds = widgetHandler.customCommands
        cmds[#cmds + 1] = CMD_HOLO_PLACE_DESCRIPTION
    end
end

function widget:CommandNotify(cmd_id, cmd_params, cmd_options)
    if cmd_id == CMD_HOLO_PLACE then
        checkUnits(true)
        return true
    end
end

function widget:GameFrame()
    for unit_id, target_id in pairs(HOLO_PLACERS) do
        if target_id == "delay_swap" then
            -- delay swap by a frame

            HOLO_PLACERS[unit_id] = true
            local _, _, tag = GetUnitCurrentCommand(unit_id)
            GiveOrderToUnit(unit_id, CMD_REMOVE, tag, 0)

        elseif type(target_id) ~= "number" then
            -- check if building

            local target_id = GetUnitIsBuilding(unit_id)
            if target_id then
                local being_built = GetUnitIsBeingBuilt(target_id)
                if being_built then
                    HOLO_PLACERS[unit_id] = target_id
                end
            end

        else
            -- check for nearby nano to pin holo

            local being_built = GetUnitIsBeingBuilt(target_id)
            if being_built then
                local nt_ids = ntNearUnit(target_id)
                for i=1, #nt_ids do
                    local nt_id = nt_ids[i]
                    local cmds = GetUnitCommands(nt_id, 2)

                    if (cmds[2] and cmds[2].id == CMD_FIGHT)
                        or (cmds[1] and cmds[1].id == CMD_FIGHT)
                    then
                        HOLO_PLACERS[unit_id] = "delay_swap"
                        GiveOrderToUnit(nt_id, CMD_REPAIR, target_id, 0)
                        break
                    elseif cmds[1]
                        and cmds[1].id == CMD_REPAIR
                        and cmds[1].params[1] == target_id
                        and not GetUnitIsBeingBuilt(nt_id)
                    then
                        HOLO_PLACERS[unit_id] = true
                        local _, _, tag = GetUnitCurrentCommand(unit_id)
                        GiveOrderToUnit(unit_id, CMD_REMOVE, tag, 0)
                        break
                    end
                end
            else
                HOLO_PLACERS[unit_id] = true
            end
        end
    end
end

function widget:Initialize()
    widgetHandler.actionHandler:AddAction(self, "holo_place", handleHoloPlace, nil, "p")
end

function widget:Shutdown()
    widgetHandler.actionHandler:RemoveAction(self, "holo_place", "p")
end
