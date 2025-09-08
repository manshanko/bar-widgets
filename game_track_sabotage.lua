function widget:GetInfo()
    return {
        name    = "Track Sabotage",
        desc    = "Track when players destroy eco buildings in PvE",
        author  = "manshanko",
        date    = "2025-04-04",
        home    = "https://github.com/manshanko/bar-widgets",
        layer   = 2,
    }
end

local echo = Spring.Echo
local format = string.format
local AreTeamsAllied = Spring.AreTeamsAllied
local MarkerAddPoint = Spring.MarkerAddPoint
local GetUnitPosition = Spring.GetUnitPosition
local GetGameSeconds = Spring.GetGameSeconds
local GetPlayerList = Spring.GetPlayerList
local GetPlayerInfo = Spring.GetPlayerInfo
local UnitDefs = UnitDefs

local EXPORT_DIR = "userdata"
local PLAYERS = {}
local LOG = {}
local FF_COUNT = {}
local ECO_DEFS = {}
local BUILDER_DEFS = {}
local MY_TEAM = Spring.GetMyTeamID()
local GAME_DATE

-- 30 game frames per second
local DEBOUNCE = 300
local GAME_FRAME = 0

for unit_def_id, unit_def in pairs(UnitDefs) do
    if (unit_def.energyMake > 0
        or unit_def.energyUpkeep < 0
        or unit_def.extractsMetal > 0
        or (unit_def.customParams and unit_def.customParams.energymultiplier)
        or (unit_def.customParams and unit_def.customParams.energyconv_efficiency))
            and not unit_def.isBuilder
    then
        ECO_DEFS[unit_def_id] = unit_def
    end

    if unit_def.isBuilder then
        BUILDER_DEFS[unit_def_id] = unit_def
    end
end

local LAST_FRAME = -DEBOUNCE
function widget:UnitDestroyed(unit_id, unit_def_id, unit_team, attacker_id, attacker_def_id, attacker_team)
    if attacker_team
        and attacker_team >= 0
        and unit_team ~= attacker_team
        and attacker_team ~= MY_TEAM
        and AreTeamsAllied(unit_team, attacker_team)
        and ECO_DEFS[unit_def_id]
        -- ignore builders since it could be reclaim
        and not BUILDER_DEFS[attacker_def_id]
    then
        local attacker_players = GetPlayerList(attacker_team)
        if #attacker_players == 0 then
            -- only AI
            return
        end

        if LAST_FRAME > (GAME_FRAME - DEBOUNCE) then
            return
        end
        LAST_FRAME = GAME_FRAME

        local attacker_name
        if #attacker_players == 1 then
            local name = GetPlayerInfo(attacker_players[1])
            FF_COUNT[name] = (FF_COUNT[name] and FF_COUNT[name] + 1) or 1
            attacker_name = name
        else
            attacker_name = "["
            local first = true
            for _, player_id in ipairs(attacker_players) do
                local name = GetPlayerInfo(player_id)
                FF_COUNT[name] = (FF_COUNT[name] and FF_COUNT[name] + 1) or 1
                if first then
                    first = false
                    attacker_name = attacker_name .. name
                else
                    attacker_name = attacker_name .. ", " .. name
                end
            end
            attacker_name = attacker_name .. "]"
        end

        local unit_name = UnitDefs[unit_def_id].translatedHumanName
        local attacker_unit_name = UnitDefs[attacker_def_id].translatedHumanName

        local text = format("%s killed by %s from %s",
            unit_name,
            attacker_unit_name,
            attacker_name)

        LOG[#LOG + 1] = {
            time = GetGameSeconds(),
            text = text,
        }

        local x, y, z = GetUnitPosition(unit_id)
        MarkerAddPoint(x, y, z, text, true)
    end
end

function widget:GameFrame(frame)
    GAME_FRAME = frame
end

function widget:Initialize()
    -- https://en.wikipedia.org/wiki/ISO_8601
    GAME_DATE = os.date("%Y%m%dT%H%M%S")
    for _, player_id in ipairs(GetPlayerList(-1)) do
        PLAYERS[#PLAYERS + 1] = GetPlayerInfo(player_id)
    end
end

function widget:Shutdown()
    if #LOG > 0 then
        if not VFS.FileExists(EXPORT_DIR) then
            Spring.CreateDir(EXPORT_DIR)
        end

        local name = format("%s/%s.json", EXPORT_DIR, GAME_DATE)
        local json = Json.encode({
            players = PLAYERS,
            counts = FF_COUNT,
            pings = LOG,
        })
        local file, err = io.open(name, "w")
        if err then
            echo("[game_track_sabotage][ERROR] Failed to open file: " .. err)
            return
        end
        --Spring.Log()
        --echo("[game_track_sabotage] Saving data to \"" .. name .. "\"")

        file:write(json)
        file:close()
    end
end
