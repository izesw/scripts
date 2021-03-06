local values = {
    Macro = "template",
    MacroOn = false,
    AutoJoinMap = "Namek",
    AutoJoinLevel = "1",
    AutoJoinDifficulty = "Normal",
    AutoJoinOn = false
}

if not isfolder("Cranium") then
    makefolder("Cranium")
    makefolder("Cranium/Macros")
    writefile("Cranium/Macros/template.json", "")
    writefile("Cranium/settings.json", game:GetService("HttpService"):JSONEncode(values))
end

local isLobby =  workspace:WaitForChild("_MAP_CONFIG"):WaitForChild("IsLobby").Value
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage.endpoints.client_to_server
local remotes2 = ReplicatedStorage.endpoints.server_to_client

local RemoteFunction = remotes.request_join_lobby
local RemoteFunction2 = remotes.request_lock_level
local RemoteFunction3 = remotes.request_start_game
local RemoteFunction4 = remotes.spawn_unit
local RemoteFunction5 = remotes.upgrade_unit_ingame
local RemoteFunction6 = remotes.teleport_back_to_lobby
local RemoteFunction7 = remotes.sell_unit_ingame

local unitspawnedremote = remotes2.unit_spawned

if game.CoreGui:FindFirstChild("FinityUI") then
    game.CoreGui:FindFirstChild("FinityUI"):Destroy()
end

local Finity = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/UI-Librarys/main/Finity%20UI%20Lib"))()

local window = Finity.new(true)

local AutoJoinCategory = window:Category("Auto Join")
local MacroCategory = window:Category("Macros")

local InformationSector =  AutoJoinCategory:Sector("Information")
local GoSector =  AutoJoinCategory:Sector("Join")

local RecordSector = MacroCategory:Sector("Record")
local ExistSector = MacroCategory:Sector("Existing Macros")

values = game:GetService("HttpService"):JSONDecode(readfile("Cranium/settings.json"))

window.ChangeToggleKey(Enum.KeyCode.RightShift)

local updateValue = function(name, value)
    if values[name] ~= nil then
        values[name] = value
    end
    writefile("Cranium/settings.json", game:GetService("HttpService"):JSONEncode(values))
end

local GetMacro = function(macroName)
    return readfile("Cranium/Macros/"..macroName..".json")
end

local isRecording = false

local macros = {}

local getMacrosList = function()
    local macros2 = {}
    for i, val in pairs(listfiles("Cranium/Macros")) do
        table.insert(macros2, val:gsub('Cranium/Macros', ""):sub(2):split(".")[1]) 
     end
    return macros2
end

do
    macros = getMacrosList()
end

local RecordName = RecordSector:Cheat("Textbox", "New Macro Name", function(name)
    updateValue("Macro", name)
end, {
    placeholder = "Name Cannot Have '.' or '/'"
})

local ExistName = ExistSector:Cheat("Dropdown", "Macro Name", function(name)
    if GetMacro(name) then
        updateValue("Macro", name)
    end
end, {
	options = macros,
    default = values.Macro
})

local Recorder = RecordSector:Cheat("Button", "Record", function()
    isRecording = true
end, {
	text = "Start"
})



local Start = ExistSector:Cheat("Checkbox", "Macro On", function(State)
    if values.Macro then
        updateValue("MacroOn", State)
    end
end, {
    enabled = values.MacroOn
})

local AutoJoinCheck = GoSector:Cheat("Checkbox", "Auto Join", function(State)
    updateValue("AutoJoinOn", State)
end, {
    enabled = values.AutoJoinOn
})

local MapSelect = InformationSector:Cheat("Dropdown", "Map", function(Option)
    updateValue("AutoJoinMap", Option)
end, {
	options = {
		"Namek",
        "AOT",
        "Demonslayer",
        "Naruto"
	},
    default = values.AutoJoinMap
})

local LevelSelect = InformationSector:Cheat("Dropdown", "Level", function(Option)
    updateValue("AutoJoinLevel", Option)
end, {
	options = {
		"1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "Infinite"
	},
    default = values.AutoJoinLevel
})

local DiffSelect = InformationSector:Cheat("Checkbox", "Hard", function(State)
    if State then
        updateValue("AutoJoinDifficulty", "Hard")
    else
        updateValue("AutoJoinDifficulty", "Normal")
    end
end, {
    enabled = values.AutoJoinDifficulty == "Hard"
})

if isLobby then    
    repeat
        wait()
    until values.AutoJoinOn
    
        for _, teleport in pairs(workspace._LOBBIES.Story:GetChildren()) do
            if teleport:FindFirstChild("Owner") then
                if teleport:FindFirstChild("Owner").Value == nil then
                    RemoteFunction:InvokeServer(teleport.Name)
                    if values.AutoJoinLevel == "Infinite" then
                        RemoteFunction2:InvokeServer(teleport.Name, string.lower(values.AutoJoinMap).."_infinite", false, "Hard")
                    else
                        RemoteFunction2:InvokeServer(teleport.Name, string.lower(values.AutoJoinMap).."_level_"..values.AutoJoinLevel, true, values.AutoJoinDifficulty)
                    end
                    RemoteFunction3:InvokeServer(teleport.Name)
                    break
                end
            end
        end
else
    local Loader = require(game.ReplicatedStorage.src.Loader);
    local GUIService = Loader.load_client_service(script, "GUIService");
    
    repeat
        wait()
    until game:IsLoaded()
    
    game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MessageGui").Enabled = false
    ReplicatedStorage.packages.assets.ui_sfx:FindFirstChild("error").Volume = 0
    
    local moves = {}
    
    local units = {}
    
    local u1 = GUIService.units_spawn_ui
    
    local function spawnUnit(num, cf)
        RemoteFunction4:InvokeServer(u1.session.collection.equipped_units[tostring(num)], cf)
    end
    do
        unitspawnedremote.OnClientEvent:Connect(function(unit)
            if game:GetService("CollectionService"):HasTag(unit, "nonminion_units") then
                unit:WaitForChild("_stats");
                if unit._stats.player.Value == game:GetService("Players").LocalPlayer then
                    table.insert(units, unit)
                end
            end
        end)
    end
    
    local function convertToNum(uuid)
        local found = nil
        for index, value in pairs(u1.session.collection.equipped_units) do
            if value == uuid then
                found = index
                break
            end
        end
        return tonumber(found)
    end
    
    local function findUnit(unit)
        local found = nil
        for index, value in pairs(units) do
            if value == unit then
                found = index
                break
            end
        end
        return found
    end
    
    local function newMove(typeid, data)
        if typeid == "Place" then
            local id, cf = data[1], data[2]
            local num = convertToNum(id)
            local cfx, cfy, cfz = cf.Position.X, cf.Position.Y, cf.Position.Z
            table.insert(moves, {
                "Place",
                num,
                {cfx, cfy, cfz}
            })
        else
            table.insert(moves, {
                typeid,
                findUnit(data[1]),
            })
        end
        
    end
    
    do
        if isRecording then
            local OldNameCall_Place = nil
            OldNameCall_Place = hookmetamethod(RemoteFunction4, "__namecall", function(Self, ...)
                local Args = {...}
                local NamecallMethod = getnamecallmethod()
            
                if not checkcaller() and Self == RemoteFunction4 and NamecallMethod == "InvokeServer" then
                    newMove("Place", Args)
                end
            
                return OldNameCall_Place(Self, ...)
            end)
            
            local OldNameCall_Upgrade = nil
            
            OldNameCall_Upgrade = hookmetamethod(RemoteFunction5, "__namecall", function(Self, ...)
                local Args = {...}
                local NamecallMethod = getnamecallmethod()
            
                if not checkcaller() and Self == RemoteFunction5 and NamecallMethod == "InvokeServer" then
                    newMove("Upgrade", Args)
                end
            
                return OldNameCall_Upgrade(Self, ...)
            end)
        
            local OldNameCall_Sell = nil
            
            OldNameCall_Sell = hookmetamethod(RemoteFunction7, "__namecall", function(Self, ...)
                local Args = {...}
                local NamecallMethod = getnamecallmethod()
            
                if not checkcaller() and Self == RemoteFunction7 and NamecallMethod == "InvokeServer" then
                    newMove("Sell", Args)
                end
            
                return OldNameCall_Sell(Self, ...)
            end)
        
        else
            local file = GetMacro(values.Macro)
            repeat
                wait()
            until values.MacroOn
            local moves = game:GetService("HttpService"):JSONDecode(file)
            for index, data in pairs(moves) do
                if not values.MacroOn then break end
                local numberOfUnits = #units
                if data[1] == "Place" then
                    repeat
                        spawnUnit(data[2], CFrame.new(data[3][1], data[3][2], data[3][3]))
                    until #units ~= numberOfUnits or not values.MacroOn
                elseif data[1] == "Upgrade" then
                    repeat
                        wait()
                    until RemoteFunction5:InvokeServer(units[data[2]]) or not values.MacroOn
                elseif data[1] == "Sell" then
                    RemoteFunction7:InvokeServer(units[data[2]])
                end
            end
        end
    end
    
    
    spawn(function()
        repeat
            wait(5)
        until workspace._DATA.GameFinished.Value == true
        
        if isRecording then
            writefile("Cranium/Macros/"..values.Macro..".json", game:GetService("HttpService"):JSONEncode(moves))
        end
        wait(7)
        RemoteFunction6:InvokeServer()
    end)
    
end
