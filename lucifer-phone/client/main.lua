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

QBCore = nil


local phoneMeta = {}
local isLoggedIn = false
local PlayerJob = {}

local callData = {
    number = nil,
    name = nil,
    callId = 0,
    inCall = false,
    incomingCall = false,
    outgoingCall = false
}

local defaultPhoneMeta = {
    ["settings"] = {
        notifications = true,
        background = "bg-1",
    }
}

local inPhone = false
local allowNotifys = true

local playerContacts = {}

local messages = {}

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        if callData.inCall then 
            if not (IsEntityPlayingAnim(GetPlayerPed(-1), "cellphone@", "cellphone_call_listen_base", 3)) then 
                PhonePlayAnim('call', false, true)
                if phoneProp == 0 then
                    newPhoneProp()
                end
            end
        else
            Citizen.Wait(2500)
        end
    end
end)

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)    
            Citizen.Wait(200)
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

local inPayPhoneRange = false

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
    while true do
        local ply = GetPlayerPed(-1)
        local plyCoords = GetEntityCoords(ply, 0)
        inPayPhoneRange = false

        for k, v in pairs(Config.PhoneCells) do
            local closestObj = GetClosestObjectOfType(plyCoords.x, plyCoords.y, plyCoords.z, 3.0, v, false, 0, 0)
            local objCoords = GetEntityCoords(closestObj)
            if closestObj ~= 0 then
                local dist = GetDistanceBetweenCoords(plyCoords.x, plyCoords.y, plyCoords.z, objCoords.x, objCoords.y, objCoords.z, true)
                if dist <= 10 then
                    if not IsPedInAnyVehicle(ply) then
                        inPayPhoneRange = true
                        local objHealth = GetObjectFragmentDamageHealth(closestObj, true)
                        if objHealth > 0.95 then
                            if dist <= 1.5 then
                                DrawText3D(objCoords.x, objCoords.y, objCoords.z + 0.98, '~g~E~w~ Om telefooncel te gebruiken')
                                DrawText3D(objCoords.x, objCoords.y, objCoords.z + 0.78, '/payphone ~b~nummer~w~')
                                if IsControlJustPressed(0, Keys["E"]) then
                                    SendNUIMessage({
                                        task = "OpenPayPhone"
                                    })
                                    SetNuiFocus(true, true)
                                end
                            end
                        end
                    end
                end
            end
        end

        if not inPayPhoneRange then
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

RegisterNUICallback('closePayPhone', function()
    SetNuiFocus(false, false)
end)

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end

RegisterNetEvent('qb-phone:client:CallPayPhone')
AddEventHandler('qb-phone:client:CallPayPhone', function(num)
    TriggerServerEvent('qb-phone:server:PayPayPhone', 20, num)
end)

RegisterNetEvent('qb-phone:client:CallPayPhoneYes')
AddEventHandler('qb-phone:client:CallPayPhoneYes', function(num)
    if inPayPhoneRange then
        local number = tostring(num)
        local lib = "cellphone@str"
        local anim = "cellphone_call_listen_a"
        local myPedId = GetPlayerPed(-1)
        SetNuiFocus(false, false)

        local callTime = 0
        
        local pData = QBCore.Functions.GetPlayerData()

        callData.number = number
        callData.name = number
        callData.callId = math.random(500, 1000) + math.random(1, 120)
        callData.inCall = false
        callData.incomingCall = false
        callData.outgoingCall = true

        QBCore.Functions.Notify('Oproep gestart met '..callData.name, 'primary', 2500)

        PhonePlayAnim('call', true, true)

        Citizen.CreateThread(function()
            for i = 1, 10, 1 do
                if callData.outgoingCall then
                    Citizen.Wait(3000)
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
                    QBCore.Functions.Notify('Oproep is bezig, /ophangen om gesprek te stoppen', 'primary', 2000)
                    callTime = i
                    if callTime == 10 then
                        Citizen.Wait(3000)
                        QBCore.Functions.Notify('Er word niet opgenomen..', 'error', 3500)
                        callData.number = nil
                        callData.name = nil
                        callData.callId = 0
                        callData.inCall = false
                        callData.incomingCall = false
                        callData.outgoingCall = false

                        PhonePlayAnim('out', false, true)
                        break
                    end
                else
                    break
                end
            end
        end)

        TriggerServerEvent('qb-phone:server:CallContact', callData, "06"..math.random(11111111, 99999999), true)
    else
        QBCore.Functions.Notify('Je bent niet bij een telefooncel in de buurt', 'error', 2500)
    end
end)

RegisterNUICallback('CallPayPhone', function(data)
    TriggerEvent('qb-phone:client:CallPayPhone', tostring(data.number))
end)

RegisterNUICallback('getMessages', function(data, cb)
    local chats = {}
    for k, v in pairs(messages) do
        local contactName = v.number
        for _, contact in pairs(playerContacts) do
            if v.number == contact.number then
                contactName = contact.name
            end
        end

        table.insert(chats, {
            number = v.number,
            name = contactName,
            messages = v.messages,
        })
    end
    cb(chats)
end)

RegisterNUICallback('getCharacterData', function(data, cb)
    cb(QBCore.Functions.GetPlayerData().charinfo)
end)

RegisterNUICallback('policeSearchPerson', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:getSearchData', function(result)
        cb(result)
    end, data.search)
end)

RegisterNUICallback('policeSearchVehicle', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:getVehicleSearch', function(result)
        if result ~= nil then 
            for k, v in pairs(result) do
                QBCore.Functions.TriggerCallback('police:IsPlateFlagged', function(flagged)
                    result[k].isFlagged = flagged
                end, result[k].plate)
                Citizen.Wait(50)
            end
        end
        cb(result)
    end, data.search)
end)

RegisterNUICallback('scanVehiclePlate', function(data, cb)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)
    QBCore.Functions.TriggerCallback('qb-phone:server:getVehicleData', function(result)
        QBCore.Functions.TriggerCallback('police:IsPlateFlagged', function(flagged)
            result.isFlagged = flagged
            local vehicleInfo = QBCore.Shared.VehicleModels[model] ~= nil and QBCore.Shared.VehicleModels[model] or {["brand"] = "Onbekend merk..", ["name"] = ""}
            result.label = vehicleInfo["brand"] .. " " .. vehicleInfo["name"]
            cb(result)
        end, plate)
    end, plate)
end)

function GetClosestPlayer()
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(GetPlayerPed(-1))

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end

	return closestPlayer, closestDistance
end

RegisterNetEvent('qb-phone:client:giveNumber')
AddEventHandler('qb-phone:client:giveNumber', function(data)
    local ped = GetPlayerPed(-1)
    local PlayerData = QBCore.Functions.GetPlayerData()

    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent('qb-phone:server:giveNumber', playerId, PlayerData)
    else
        QBCore.Functions.Notify("Niemand in de buurt!", "error")
    end
end)

RegisterNetEvent('qb-phone:client:giveBankAccount')
AddEventHandler('qb-phone:client:giveBankAccount', function(data)
    local ped = GetPlayerPed(-1)
    local PlayerData = QBCore.Functions.GetPlayerData()

    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent('qb-phone:server:giveBankAccount', playerId, PlayerData)
    else
        QBCore.Functions.Notify("Niemand in de buurt!", "error")
    end
end)

RegisterNetEvent('qb-phone:server:newContactNotify')
AddEventHandler('qb-phone:server:newContactNotify', function(number)
    QBCore.Functions.Notify('[M] Je hebt een nieuw voorgesteld contactpersoon!')
    SendNUIMessage({
        task = "suggestedNumberNotify",
        number = number
    })
end)

RegisterNetEvent('qb-phone:server:newBankNotify')
AddEventHandler('qb-phone:server:newBankNotify', function(nr)
    QBCore.Functions.Notify('[M] Je hebt een nieuw voorgesteld bankrekening nr.!')
    SendNUIMessage({
        task = "suggestedBankAccountNotify",
        nr = nr
    })
end)

RegisterNUICallback('doesChatExists', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:doesChatExists', function(result)
        local cbData = {}
        if result ~= nil then
            contactName = nil
            cbData = {
                number = data.cData.number,
                name = data.cData.name,
                messages = json.decode(result.messages)
            }
        end
        cb(cbData)
    end, data.cData.number)
end)

RegisterNUICallback('sendMessage', function(data, cb)
    local cur = nil
    local exist = false
    local type = "normal"
    for k, v in pairs(messages) do
        if messages[k].number == data.number then
            exist = true
            cur = k
        end
    end

    if data.type == "gps" then 
        type = "gps" 
    end 

    if exist then
        if type == "normal" then
            table.insert(messages[cur].messages, {
                sender = QBCore.Functions.GetPlayerData().citizenid,
                message = data.message,
                type = type
            })
        else
            table.insert(messages[cur].messages, {
                sender = QBCore.Functions.GetPlayerData().citizenid,
                message = "Gedeelde Locatie",
                coords = {
                    x = GetEntityCoords(GetPlayerPed(-1)).x,
                    y = GetEntityCoords(GetPlayerPed(-1)).y,
                },
                type = type
            })
        end
        TriggerServerEvent('qb-phone:server:sendMessage', messages[cur])
        QBCore.Functions.Notify('Bericht verstuurd!', 'success', 2500)
    else
        if type == "normal" then
            table.insert(messages, {
                number = data.number,
                name = data.name,
                messages = {
                    [1] = {
                        sender = QBCore.Functions.GetPlayerData().citizenid,
                        message = data.message,
                        type = type
                    }
                }
            })
        else
            table.insert(messages, {
                number = data.number,
                name = data.name,
                messages = {
                    [1] = {
                        sender = QBCore.Functions.GetPlayerData().citizenid,
                        message = "Gedeelde Locatie",
                        coords = {
                            x = GetEntityCoords(GetPlayerPed(-1)).x,
                            y = GetEntityCoords(GetPlayerPed(-1)).y,
                        },
                        type = type
                    }
                }
            })
        end
        QBCore.Functions.Notify('Bericht verstuurd!', 'success', 2500)
        for k, v in pairs(messages) do
            if messages[k].number == data.number then
                cur = k
            end
        end
        TriggerServerEvent('qb-phone:server:createChat', messages[cur])
    end

    cb(messages[cur].messages)
end)

RegisterNUICallback('setMessageLocation', function(data)
    local msgCoords = data.msgCoords

    QBCore.Functions.Notify('GPS Locatie ingesteld!', 'success')
    SetNewWaypoint(msgCoords.x, msgCoords.y)
end)

RegisterNetEvent('qb-phone:client:addPoliceAlert')
AddEventHandler('qb-phone:client:addPoliceAlert', function(alertData)
    if PlayerJob.name == 'police' and PlayerJob.onduty then
        SendNUIMessage({
            task = "newPoliceAlert",
            alert = alertData,
        })
    end
end)

RegisterNUICallback('setAlertWaypoint', function(data)
    local coords = data.alert.coords

    QBCore.Functions.Notify('GPS Locatie ingesteld: '..data.alert.title)
    SetNewWaypoint(coords.x, coords.y)
end)

RegisterNetEvent('qb-phone:client:createChatOther')
AddEventHandler('qb-phone:client:createChatOther', function(chatData, senderPhone)
    table.insert(messages, {
        number = senderPhone,
        name = contactName,
        messages = chatData.messages
    })
    if inPhone then
       
    end
    TriggerServerEvent('qb-phone:server:createChatOther', chatData, senderPhone)
end)

RegisterNetEvent('qb-phone:client:recieveMessage')
AddEventHandler('qb-phone:client:recieveMessage', function(chatData, senderPhone)
    for _, chat in pairs(messages) do
        if chat.number == senderPhone then
            chat.messages = chatData.messages
        end
    end
    TriggerServerEvent('qb-phone:server:recieveMessage', chatData, senderPhone)
    SendNUIMessage({
        task = "updateChat",
        messages = chatData.messages,
        number = senderPhone
    })
end)

RegisterNetEvent('qb-phone:client:msgNotify')
AddEventHandler('qb-phone:client:msgNotify', function(msg, contact)
    if not inPhone then
        QBCore.Functions.Notify(msg)
        PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default" ,0 ,0 ,1)
    else
        SendNUIMessage({
            task = "newMessage",
            sender = contact
        })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60 * 1000 * 5)
        if isLoggedIn then
            QBCore.Functions.TriggerCallback('qb-phone:server:getUserContacts', function(result)
                playerContacts = result
            end)
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    setPhoneMeta()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    QBCore.Functions.TriggerCallback('qb-phone:server:getUserContacts', function(result)
        playerContacts = result
    end)
    QBCore.Functions.TriggerCallback('qb-phone:server:getPlayerMessages', function(result)
        messages = result
    end)
end)

--[[Citizen.CreateThread(function()
    Citizen.Wait(250)
    isLoggedIn = true
    setPhoneMeta()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    QBCore.Functions.TriggerCallback('qb-phone:server:getUserContacts', function(result)
        playerContacts = result
    end)
    QBCore.Functions.TriggerCallback('qb-phone:server:getPlayerMessages', function(result)
        messages = result
    end)
end)]]--

function setPhoneMeta()
    phoneMeta = QBCore.Functions.GetPlayerData().metadata["phone"]

    if next(phoneMeta) == nil then
        phoneMeta = defaultPhoneMeta
        TriggerServerEvent('qb-phone:server:setPhoneMeta', defaultPhoneMeta)
    end

    SendNUIMessage({
        task = "setPhoneMeta",
        pMeta = phoneMeta,
        pData = QBCore.Functions.GetPlayerData(),
    })
    
    TriggerServerEvent('qb-phone:server:getContacts')
end

RegisterNUICallback('setupContacts', function()
    setupContacts()
end)

function setupContacts()
    SendNUIMessage({
        task = "setUserContacts",
        pContacts = playerContacts,
        pData = QBCore.Functions.GetPlayerData(),
    })
end

RegisterNUICallback('getBankData', function()
    SendNUIMessage({
        task = "setupBankData",
        pData = QBCore.Functions.GetPlayerData(),
    })
end)

RegisterNUICallback('getVehicles', function()
    QBCore.Functions.TriggerCallback('qb-phone:server:GetAllUserVehicles', function(vehicles)
        local myVehicles = {}

        for k, v in pairs(vehicles) do
            local garage
            local state = "Binnen"
            if vehicles[k].garage ~= nil then garage = Config.Garages[vehicles[k].garage].label else garage = "Depot" end
            if vehicles[k].state == 0 then state = "Uit" elseif vehicles[k].state == 2 then state = "In Beslag" end
            table.insert(myVehicles, {name = QBCore.Shared.Vehicles[vehicles[k].vehicle]["name"], plate = vehicles[k].plate, garage = garage, state = state, engine = vehicles[k].engine, body = vehicles[k].body, fuel = vehicles[k].fuel, image = QBCore.Shared.Vehicles[vehicles[k].vehicle]["image"]})
        end

        SendNUIMessage({
            task = "getVehicles",
            vehicles = myVehicles,
        })
    end)
end)

RegisterNUICallback('addToContact', function(data)
    local contactName = data.contactName
    local contactNum = data.contactNum

    QBCore.Functions.TriggerCallback('qb-phone:server:getContactStatus', function(stat)
        table.insert(playerContacts, {
            name = contactName,
            number = contactNum,
            status = stat,
        })
        print(stat)
    end, contactNum)
    Citizen.Wait(250)
    setupContacts()

    TriggerServerEvent('qb-phone:server:addContact', contactName, contactNum)
    QBCore.Functions.Notify(contactNum..' is toegevoegd aan je contacten!', 'success', 3500)
end)

RegisterNUICallback('editContact', function(data)
    local oldContactName = data.oldContactName
    local oldContactNum = data.oldContactNum
    local newContactName = data.newContactName
    local newContactNum = data.newContactNum

    for k, v in pairs(playerContacts) do
        if playerContacts[k].name == oldContactName and playerContacts[k].number == oldContactNum then
            playerContacts[k].name = newContactName
            playerContacts[k].number = newContactNum
        end
    end
    setupContacts()

    TriggerServerEvent('qb-phone:server:editContact', oldContactName, oldContactNum, newContactName, newContactNum)
    QBCore.Functions.Notify(oldContactNum..' is aangepast!', 'success', 3500)
end)

RegisterNUICallback('removeContact', function(data)
    local cName = data.oldContactName
    local cNumb = data.oldContactNum
    
    for k, v in pairs(playerContacts) do
        if playerContacts[k].name == cName and playerContacts[k].number == cNumb then
            table.remove(playerContacts, k)
        end
    end
    TriggerServerEvent('qb-phone:server:removeContact', cName, cNumb)
    QBCore.Functions.Notify(cName..' is verwijderd!', 'success', 3500)

    setupContacts()
end)

RegisterNUICallback('transferMoney', function(data)
    if data.amount > 0 then
        TriggerServerEvent('qb-phone:server:transferBank', data.amount, data.iban)
    else
        QBCore.Functions.Notify('Bedrag moet hoger zijn dan 0', 'error')
    end
end)

RegisterNUICallback('getUserMails', function()
    QBCore.Functions.TriggerCallback('qb-phone:server:GetUserMails', function(mails)
        SendNUIMessage({
            task = "setupMail",
            mails = mails
        })
    end)
end)

RegisterNUICallback('setEmailRead', function(data)
    TriggerServerEvent('qb-phone:server:setEmailRead', data.mailId)
    SetTimeout(500, function()
        QBCore.Functions.TriggerCallback('qb-phone:server:GetUserMails', function(mails)
            SendNUIMessage({
                task = "setupMail",
                mails = mails
            })
        end)
    end)
end)

RegisterNetEvent('qb-phone:client:newMailNotify')
AddEventHandler('qb-phone:client:newMailNotify', function(mailData)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if result then
            SendNUIMessage({
                task = "phoneNotification",
                message = {
                    title = '<i class="fas fa-envelope"></i> Mail',
                    message = "@"..mailData.sender..", "..mailData.message
                }
            })
        end
    end, "phone")
end)

RegisterNetEvent('qb-phone:client:RecievedBankNotify')
AddEventHandler('qb-phone:client:RecievedBankNotify', function(amount, iban)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if result then
            SendNUIMessage({
                task = "phoneNotification",
                message = {
                    title = '<i class="fas fa-university"></i> QBank',
                    message = "Je hebt &euro; "..amount..",- ontvangen van "..iban.."!"
                }
            })
        end
    end, "phone")
end)

RegisterNUICallback('removeMail', function(data)
    TriggerServerEvent('qb-phone:server:removeMail', data.mailId)
end)

RegisterNUICallback('getTweets', function()
    QBCore.Functions.TriggerCallback('qb-phone:server:getPhoneTweets', function(tweets)
        SendNUIMessage({
            task = "setupTweets",
            tweets = tweets
        })
    end)
end)

RegisterNetEvent('qb-phone:client:InPhoneNotify')
AddEventHandler('qb-phone:client:InPhoneNotify', function(title, type, text)
    SendNUIMessage({
        task = "phoneNotify",
        title = title,
        type = type, 
        text = text,
    })
end)

RegisterNetEvent('qb-phone:client:setupCompanies')
AddEventHandler('qb-phone:client:setupCompanies', function()
    SendNUIMessage({
        task = "setupCompanies",
        companies = exports['qb-companies']:GetCompanies()
    })
end)

RegisterNUICallback('getCompanies', function()
    SendNUIMessage({
        task = "setupCompanies",
        companies = exports['qb-companies']:GetCompanies()
    })
end)

RegisterNUICallback('removeCompany', function(data)
    TriggerServerEvent("qb-companies:server:removeCompany", data.name)
end)

RegisterNUICallback('quitCompany', function(data)
    TriggerServerEvent("qb-companies:server:quitCompany", data.name)
end)

RegisterNUICallback('getAds', function()
    QBCore.Functions.TriggerCallback('qb-phone:server:getPhoneAds', function(ads)
        SendNUIMessage({
            task = "setupAds",
            ads = ads
        })
    end)
end)

RegisterNUICallback('postTweet', function(data)
    TriggerServerEvent('qb-phone:server:postTweet', data.message)
end)

RegisterNUICallback('postAdvert', function(data)
    TriggerServerEvent('qb-phone:server:postAdvert', data.message)
end)

RegisterNetEvent('qb-phone:client:newTweet')
AddEventHandler('qb-phone:client:newTweet', function(sender, message)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if result then
            if inPhone then
                QBCore.Functions.TriggerCallback('qb-phone:server:getPhoneTweets', function(tweets)
                    SendNUIMessage({
                        task = "newTweet",
                        tweets = tweets,
                        sender = sender
                    })
                end)
            else
                SendNUIMessage({
                    task = "phoneNotification",
                    message = {
                        title = '<i class="fab fa-twitter"></i> <b>Twitter</b>',
                        message = "@"..sender.." : "..message,
                        color = {
                            r = 0,
                            g = 138,
                            b = 190,
                            a = 155,
                        }
                    }
                })
            end
        end
    end, "phone")
end)

RegisterNetEvent('qb-phone:client:newAd')
AddEventHandler('qb-phone:client:newAd', function(sender, message)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if result then
            if inPhone then
                QBCore.Functions.TriggerCallback('qb-phone:server:getPhoneAds', function(ads)
                    SendNUIMessage({
                        task = "newAd",
                        ads = ads,
                        sender = sender
                    })
                end)
            else
                SendNUIMessage({
                    task = "phoneNotification",
                    message = {
                        title = '<i class="fas fa-ad"></i> Advertentie',
                        message = "@"..sender.." : "..message,
                        color = {
                            r = 255,
                            g = 143,
                            b = 26,
                            a = 155,
                        }
                    }
                })
            end
        end
    end, "phone")
end)

--- CODE

function openPhone(bool)
    SetNuiFocus(bool, bool)
    SetCursorLocation(0.87, 0.5)
    inPhone = bool
    if bool then
        SendNUIMessage({
            action = "phone",
            open = bool,
            apps = GetPhoneApps(),
            cid = QBCore.Functions.GetPlayerData().citizenid
        })

        if callData.inCall or callData.outgoingCall or callData.incomingCall then
            SendNUIMessage({
                task = "callScreen",
                callData = callData
            })
        end

        PhonePlayIn()
    else
        PhonePlayOut()
    end
end

function GetPhoneApps()
    local apps = {}
    for k, v in pairs(Config.PhoneApps) do
        if Config.PhoneApps[k].job == nil then 
            apps[k] = v
        elseif (Config.PhoneApps[k].job == QBCore.Functions.GetPlayerData().job.name) and QBCore.Functions.GetPlayerData().job.onduty then
            apps[k] = v
        end
    end
    return apps
end

Citizen.CreateThread(function()
    while true do

        if IsControlJustPressed(0, Keys["M"]) then
            local isHandcuffed = QBCore.Functions.GetPlayerData().metadata["ishandcuffed"]

            if not isHandcuffed then
                QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
                    if result then
                        openPhone(true)
                    else
                        QBCore.Functions.Notify('Je hebt geen Telefoon', 'error')
                    end
                end, "phone")
            end
        end

        Citizen.Wait(5)
    end
end)

function CalculateTimeToDisplay()
	hour = GetClockHours()
    minute = GetClockMinutes()
    
    local obj = {}
    
	if minute <= 9 then
		minute = "0" .. minute
    end

    if hour <= 9 then
        hour = "0" .. hour
    end
    
    obj.hour = hour
    obj.minute = minute

    return obj
end

Citizen.CreateThread(function()
    while true do
        if inPhone then
            local currentTime = CalculateTimeToDisplay()

            SendNUIMessage({
                task = "updateTime",
                time = currentTime,
            })
        end
        Citizen.Wait(1000)
    end
end)

RegisterNUICallback('setNotifications', function(data)
    local allow = data.allow
    if allow then
        QBCore.Functions.Notify('Telefoon notificaties zijn ingeschakeld...', 'primary', 3500) 
    else
        QBCore.Functions.Notify('Telefoon notificaties zijn uitgeschakeld...', 'primary', 3500)
    end
    phoneMeta["settings"].notifications = allow
    print(allow)
end)

RegisterNUICallback('closePhone', function()
    openPhone(false)
    inPhone = false
    TriggerServerEvent('qb-phone:server:setPhoneMeta', phoneMeta)
end)

RegisterNUICallback('setPlayersBackground', function(data)
    phoneMeta["settings"].background = data.background
end)

RegisterNUICallback("succesSound", function(data, cb)
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
end)

RegisterNUICallback("errorSound", function(data, cb)
    PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
end)

RegisterNUICallback('clickMailButton', function(data)
    TriggerEvent(data.buttonEvent, data.buttonData)

    TriggerServerEvent('qb-phone:server:clearButtonData', data.mailId)
end)

------------------------------
---- Call Phone Part YEET ----
------------------------------

RegisterNUICallback('CallContact', function(data)
    local contactData = data.contactData

    local callTime = 0
    
    local pData = QBCore.Functions.GetPlayerData()

    callData.number = contactData.number
    callData.name = contactData.name
    callData.callId = math.random(500, 1000) + math.random(1, 120)
    callData.inCall = false
    callData.incomingCall = false
    callData.outgoingCall = true

    QBCore.Functions.Notify('Oproep gestart met '..callData.name, 'primary', 2500)

    PhonePlayAnim('call')

    Citizen.CreateThread(function()
        for i = 1, 10, 1 do
            if callData.outgoingCall then
                Citizen.Wait(3000)
                TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
                QBCore.Functions.Notify('Oproep is bezig, /ophangen om gesprek te stoppen', 'primary', 2000)
                callTime = i
                if callTime == 10 then
                    Citizen.Wait(3000)
                    QBCore.Functions.Notify('Er word niet opgenomen..', 'error', 3500)
                    callData.number = nil
                    callData.name = nil
                    callData.callId = 0
                    callData.inCall = false
                    callData.incomingCall = false
                    callData.outgoingCall = false

                    PhonePlayOut()
                    break
                end
            else
                break
            end
        end
    end)

    TriggerServerEvent('qb-phone:server:CallContact', callData, pData.charinfo.phone)
end)

RegisterNetEvent('qb-phone:client:CallNumber')
AddEventHandler('qb-phone:client:CallNumber', function(number)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if result then
            if not callData.outgoingCall or not callData.inComingCall or not callData.inCall then
                local callTime = 0
                
                local pData = QBCore.Functions.GetPlayerData()
        
                callData.number = number
                callData.name = nil
                callData.callId = math.random(500, 1000) + math.random(1, 120)
                callData.inCall = false
                callData.incomingCall = false
                callData.outgoingCall = true
        
                QBCore.Functions.Notify('Oproep gestart met '..callData.number, 'primary', 2500)
        
                PhonePlayAnim('call')
        
                if inPhone then
                    SendNUIMessage({
                        task = "callScreen",
                        callData = callData
                    })
                end
        
                Citizen.CreateThread(function()
                    for i = 1, 10, 1 do
                        if callData.outgoingCall then
                            TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
                            QBCore.Functions.Notify('Oproep is bezig, /ophangen om gesprek te stoppen', 'primary', 2000)
                            callTime = i
                            if callTime == 5 then
                                Citizen.Wait(3000)
                                QBCore.Functions.Notify('Er word niet opgenomen..', 'error', 3500)
                                callData.number = nil
                                callData.name = nil
                                callData.callId = 0
                                callData.inCall = false
                                callData.incomingCall = false
                                callData.outgoingCall = false
        
                                PhonePlayOut()
                            end
                        else
                            break
                        end
                        Citizen.Wait(3000)
                    end
                end)
        
                TriggerServerEvent('qb-phone:server:CallContact', callData, pData.charinfo.phone)
            end
        end
    end, "phone")
end)

RegisterNetEvent('qb-phone:client:IncomingCall')
AddEventHandler('qb-phone:client:IncomingCall', function(cData, caller)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if result then
            if not callData.inCall or not callData.incomingCall then
                callData.number = caller
                callData.callId = cData.callId
                callData.incomingCall = true
        
                if inPhone then
                    SendNUIMessage({
                        task = "callScreen",
                        callData = callData
                    })
                end
                
                inComingCall()
            end
        end
    end, "phone")
end)

function inComingCall()
    QBCore.Functions.TriggerCallback('qb-phone:server:getContactName', function(name)
        callData.name = name

        local number = callData.number
        if callData.number ~= "Anoniem" then
            if callData.name ~= nil then number = callData.name end
        end
        Citizen.CreateThread(function()
            for i = 1, 10, 1 do
                if callData.incomingCall then
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
                    QBCore.Functions.Notify('Inkomend gesprek van '..number..', /opnemen of /ophangen', 'primary', 2000)
                else
                    break
                end
                Citizen.Wait(3000)
            end
        end)
    end, callData.number)
end

RegisterNUICallback('AnswerCall', function()
    TriggerEvent('qb-phone:client:AnswerCall')
end)

RegisterNUICallback('DenyCall', function()
    TriggerEvent('qb-phone:client:HangupCall')
end)

RegisterNetEvent('qb-phone:client:AnswerCall')
AddEventHandler('qb-phone:client:AnswerCall', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if result then
            if callData.incomingCall then
                if not callData.inCall then
                    callData.inCall = true
                    callData.incomingCall = false
        
                    exports.tokovoip_script:addPlayerToRadio(callData.callId, 'Telefoon')
                    TriggerServerEvent('qb-phone:server:AnswerCall', callData)
        
                    if inPhone then
                        SendNUIMessage({
                            task = "callScreen",
                            callData = callData
                        })
                    end
                else
                    QBCore.Functions.Notify('Je bent al in gesprek..', 'error')
                end
            else
                QBCore.Functions.Notify('Je hebt geen inkomend oproep..', 'error')
            end
        end
    end, "phone")
end)

RegisterNetEvent('qb-phone:client:AnswerCallOther')
AddEventHandler('qb-phone:client:AnswerCallOther', function()
    callData.inCall = true
    callData.outgoingCall = false

    if inPhone then
        SendNUIMessage({
            task = "callScreen",
            callData = callData
        })
    end

    exports.tokovoip_script:addPlayerToRadio(callData.callId, 'Telefoon')
end)

RegisterNetEvent('qb-phone:client:HangupCallOther')
AddEventHandler('qb-phone:client:HangupCallOther', function(cData)
    if cData.callId == callData.callId then
        exports.tokovoip_script:removePlayerFromRadio(callData.callId)
        QBCore.Functions.Notify('Het gesprek is beëindigd')

        callData.number = nil
        callData.name = nil
        callData.callId = 0
        callData.inCall = false
        callData.incomingCall = false
        callData.outgoingCall = false

        if inPhone then
            SendNUIMessage({
                task = "callScreen",
                callData = callData
            })
        end

        Citizen.Wait(500)
        PhonePlayOut()
    end
end)

RegisterNetEvent('qb-phone:client:HangupCall')
AddEventHandler('qb-phone:client:HangupCall', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if result then
            if callData.inCall then
                exports.tokovoip_script:removePlayerFromRadio(callData.callId)
            else
                QBCore.Functions.Notify('Je zit niet in een gesprek..', 'error')
            end

            TriggerServerEvent('qb-phone:server:HangupCall', callData)
            QBCore.Functions.Notify('Het gesprek is beëindigd')
    
            callData.number = nil
            callData.name = nil
            callData.callId = 0
            callData.inCall = false
            callData.incomingCall = false
            callData.outgoingCall = false
            PhonePlayOut()
        
            if inPhone then
                SendNUIMessage({
                    task = "callScreen",
                    callData = callData
                })
            end
        end
    end, "phone")
end)