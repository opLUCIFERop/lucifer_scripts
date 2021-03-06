QBCore = nil
Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}
local permissionlvl = "user"
local serverClosed = false

Citizen.CreateThread(function()
	while QBCore == nil do
		TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if (QBCore ~= nil) then
            QBCore.Functions.GetPlayerData(function(PlayerData)
                if PlayerData ~= nil then
                    --permissionlvl = PlayerData.permission
                    return false
                end
            end)
        end
    end
end)

_menuPool = NativeUI.CreatePool()

mainMenu = NativeUI.CreateMenu("Admin Menu", "Qbus Admin", 1400, 100)
_menuPool:Add(mainMenu)

function ServerOptions(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Server Options", "Edit server settings such as time, weather etc.", true)
    -- Setup Weathers
    local weathers = {"CLEAR","EXTRASUNNY","CLOUDS","OVERCAST","RAIN","CLEARING","THUNDER","SMOG","FOGGY","XMAS","SNOWLIGHT","BLIZZARD"}
    local weatherList = NativeUI.CreateListItem("Weather", weathers, 1, "Change current weather state")
    submenu:AddItem(weatherList)
    -- Setup Times
    local times = {}
    for i = 0, 23 do
        if i < 10 then
            table.insert(times, "0"..i..":00")
            table.insert(times, "0"..i..":15")
            table.insert(times, "0"..i..":30")
            table.insert(times, "0"..i..":45")
        else
            table.insert(times, i..":00")
            table.insert(times, i..":15")
            table.insert(times, i..":30")
            table.insert(times, i..":45")
        end
    end
    local timeList = NativeUI.CreateListItem("Time", times, 1, "Change current clock time")
    submenu:AddItem(timeList)

    -- Server join enable/disable
    local joinItem = NativeUI.CreateCheckboxItem("Server Closed", serverClosed, "Disable server joining (only admins can join)")
    submenu:AddItem(joinItem)

    submenu.OnListSelect = function(sender, item, index)
        if item == weatherList then
            local weather = item:IndexToItem(index)
            SetWeatherTypeOverTime(weather, 15.0)
        end
        if item == timeList then
            local time = item:IndexToItem(index)
            local hour, minute = timeStringToInts(time)
            NetworkOverrideClockTime(hour, minute, 0)
        end
    end

    submenu.OnCheckboxChange = function(sender, item, checked_)
        if item == joinItem then
            local isClosed = checked_
            if isClosed then
                DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 128 + 1)
				while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
					Citizen.Wait(7)
				end
                local reason = GetOnscreenKeyboardResult()
                TriggerServerEvent("QBCore:server:CloseServer", reason)
            else
                TriggerServerEvent("QBCore:server:OpenServer")
            end
        end
    end
end

function PlayerOptions(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Player Options", "Edit player settings/data such as money, items etc.", true)
    submenu:AddItem(NativeUI.CreateItem("PageFiller", "Filler desc"))
end

function VehicleMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, "Vehicle Menu", "Spawn vehicle, set vehicle modifications, upgrade vehicle etc.", true)

    local spawnItem = NativeUI.CreateItem("Spawn Vehicle", "Spawn a vehicle by vehicle model name")
    submenu:AddItem(spawnItem)
    submenu.OnItemSelect = function(sender, item, index)
        if item == spawnItem then
            DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 20)
				while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
					Citizen.Wait(7)
				end
            local model = GetOnscreenKeyboardResult()
            QBCore.Functions.SpawnVehicle(model, function(vehicle)
                TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
            end)
        end
    end
end

ServerOptions(mainMenu)
PlayerOptions(mainMenu)
VehicleMenu(mainMenu)

_menuPool:MouseControlsEnabled(false)
_menuPool:MouseEdgeEnabled(false)
_menuPool:ControlDisablingEnabled(false)

_menuPool:RefreshIndex()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
        if IsControlJustReleased(0, Keys["F5"]) and (permissionlvl == "moderator" or permissionlvl == "admin" or permissionlvl == "god") then
            mainMenu:Visible(not mainMenu:Visible())
        end
    end
end)

RegisterNetEvent("qbadmin:client:SetServerStatus")
AddEventHandler("qbadmin:client:SetServerStatus", function(isClosed)
    serverClosed = isClosed
end)

function timeStringToInts(time)
    if time ~= nil then
        local timeSplit = time:split(":", time)
        local hour = tonumber(timeSplit[1])
        local minute = tonumber(timeSplit[2])
        return hour, minute
    end
    return nil
end