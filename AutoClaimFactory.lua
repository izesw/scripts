local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClaimFactoryCraft = ReplicatedStorage.Events.ClaimFactoryCraft
local StartFactoryCraft = ReplicatedStorage.Events.StartFactoryCraft

local ToggleOn = false

print("Opened")

game:GetService("UserInputService").InputBegan:Connect(function(inputKey)
    if inputKey.KeyCode == _G.ToggleKey then
        ToggleOn = not ToggleOn
    end
end)

local function claimFactory(number)
    ClaimFactoryCraft:FireServer(number)
end

local StarterPlayer = game:GetService("StarterPlayer")
local item = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Factory.Frame.Container

local NameOfTimer = _G.FactorySettings.Currency.." ".._G.FactorySettings.Number

local v2 = require(game:GetService("ReplicatedStorage").LoadModule);
local v3 = v2("LocalData");
local v7 = v2("FactoryRecipes");

local function startFactory(number)
    StartFactoryCraft:FireServer(NameOfTimer, number)
end

local function u6()
	local v32 = v3:GetData("Factory");
	local v33 = {};
	for v34 = 1, 3 do
		local v36 = nil;
		for v37, v38 in ipairs(v32) do
			if v38.Slot == v34 then
				v36 = v38;
				break;
			end;
		end;
		v33[v34] = v36 and "empty";
	end;
	return v33;
end;

for _, slot in pairs(item:GetChildren()) do
    if slot:IsA("Frame") then
        local number = tonumber(slot.Name:sub(-1))
        if number then
            coroutine.resume(coroutine.create(function()
               while true do
                   if ToggleOn then
                        claimFactory(number)
                        startFactory(number)
                    end
                    wait()
               end
            end))
        end
    end
end
