QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

local GeneratedPlates = {}

local callId = 501

local Adverts = {}

Citizen.CreateThread(function()
    QBCore.Functions.ExecuteSql(false, 'DELETE FROM `phone_tweets`')
    print('Tweets have been cleared')
end)

RegisterServerEvent('qb-phone:server:setPhoneMeta')
AddEventHandler('qb-phone:server:setPhoneMeta', function(phoneMeta)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.SetMetaData("phone", phoneMeta)
end)

RegisterServerEvent('qb-phone:server:transferBank')
AddEventHandler('qb-phone:server:transferBank', function(amount, iban)
    local src = source
    local sender = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..iban.."%'", function(result)
        if result[1] ~= nil then
            local recieverSteam = QBCore.Functions.GetPlayerByCitizenId(result[1].citizenid)

            if recieverSteam ~= nil then
                recieverSteam.Functions.AddMoney('bank', amount, "phone-transfered-from-"..sender.PlayerData.citizenid)
                sender.Functions.RemoveMoney('bank', amount, "phone-transfered-money-to-"..recieverSteam.PlayerData.citizenid)
                TriggerClientEvent('qb-phone:client:RecievedBankNotify', recieverSteam.PlayerData.source, amount, sender.PlayerData.charinfo.account)
            else
                local moneyInfo = json.decode(result[1].money)
                moneyInfo.bank = round((moneyInfo.bank + amount))
                QBCore.Functions.ExecuteSql(false, "UPDATE `players` SET `money` = '"..json.encode(moneyInfo).."' WHERE `citizenid` = '"..result[1].citizenid.."'")
                sender.Functions.RemoveMoney('bank', amount, "phone-transfered-money")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "Dit rekeningnummer bestaat niet!", "error")
        end
    end)
end)

function round(number)
    return number - (number % 1)
end

QBCore.Functions.CreateCallback('qb-phone:server:getUserContacts', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerContacts = {}
    if Player ~= nil then 
        QBCore.Functions.ExecuteSql(false, "SELECT * FROM `player_contacts` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' ORDER BY `name` ASC", function(result)
            if result[1] ~= nil then
                for i = 1, (#result), 1 do
                    local status = false
                    QBCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..result[i].number.."%'", function(player)
                        for i=1, (#player), 1 do
                            local ply = QBCore.Functions.GetPlayerByCitizenId(player[i].citizenid)
                            if ply then
                                status = true
                            end
                        end
                        table.insert(playerContacts, {
                            name = result[i].name,
                            number = result[i].number,
                            status = status,
                        })
                    end)
                end
            end
            cb(playerContacts)
        end)
    end
end)

RegisterServerEvent('qb-phone:server:addContact')
AddEventHandler('qb-phone:server:addContact', function(name, number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_contacts` (`citizenid`, `name`, `number`) VALUES ('"..Player.PlayerData.citizenid.."', '"..name.."', '"..number.."')")
end)

RegisterServerEvent('qb-phone:server:editContact')
AddEventHandler('qb-phone:server:editContact', function(oName, oNum, nName, nNum)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, "UPDATE `player_contacts` SET `name` = '"..nName.."', `number` = '"..nNum.."' WHERE `name` = '"..oName.."' AND `number` = '"..oNum.."'")
end)

QBCore.Functions.CreateCallback("qb-phone:server:GetAllUserVehicles", function(source, cb, garage)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)

    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE citizenid = @citizenid', {['@citizenid'] = pData.PlayerData.citizenid}, function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback("qb-phone:server:GetUserMails", function(source, cb)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..pData.PlayerData.citizenid..'" ORDER BY `date` DESC', function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                if result[k].button ~= nil then
                    result[k].button = json.decode(result[k].button)
                end
            end
            cb(result)
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback("qb-phone:server:getPhoneAds", function(source, cb)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)

    if Adverts ~= nil and next(Adverts) then
        cb(Adverts)
    else
        cb(nil)
    end
end)

QBCore.Functions.CreateCallback("qb-phone:server:getPhoneTweets", function(source, cb)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, 'SELECT * FROM `phone_tweets` ORDER BY `date` DESC', function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('qb-phone:server:setEmailRead')
AddEventHandler('qb-phone:server:setEmailRead', function(mailId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    print(mailId)

    QBCore.Functions.ExecuteSql(false, 'UPDATE `player_mails` SET `read` = "1" WHERE `mailid` = "'..mailId..'" AND `citizenid` = "'..Player.PlayerData.citizenid..'"')
end)

RegisterServerEvent('qb-phone:server:clearButtonData')
AddEventHandler('qb-phone:server:clearButtonData', function(mailId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, 'UPDATE `player_mails` SET `button` = "" WHERE `mailid` = "'..mailId..'" AND `citizenid` = "'..Player.PlayerData.citizenid..'"')
end)

RegisterServerEvent('qb-phone:server:removeMail')
AddEventHandler('qb-phone:server:removeMail', function(mailId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, 'DELETE FROM `player_mails` WHERE `mailid` = "'..mailId..'" AND `citizenid` = "'..Player.PlayerData.citizenid..'"')
end)

RegisterServerEvent('qb-phone:server:sendNewMail')
AddEventHandler('qb-phone:server:sendNewMail', function(mailData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if mailData.button == nil then
        QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
        TriggerClientEvent('qb-phone:client:newMailNotify', src, mailData)
    else
        QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
        TriggerClientEvent('qb-phone:client:newMailNotify', src, mailData)
    end
end)

RegisterServerEvent('qb-phone:server:sendNewMailToOffline')
AddEventHandler('qb-phone:server:sendNewMailToOffline', function(citizenid, mailData)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)

    if Player ~= nil then
        local src = Player.PlayerData.source

        if mailData.button == nil then
            QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
            TriggerClientEvent('qb-phone:client:newMailNotify', src, mailData)
        else
            QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
            TriggerClientEvent('qb-phone:client:newMailNotify', src, mailData)
        end
    else
        if mailData.button == nil then
            QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
        else
            QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..Player.PlayerData.citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
        end
    end
end)

RegisterServerEvent('qb-phone:server:sendNewEventMail')
AddEventHandler('qb-phone:server:sendNewEventMail', function(citizenid, mailData)
    if mailData.button == nil then
        QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
        --TriggerClientEvent('qb-phone:client:newMailNotify', src, mailData)
    else
        QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
        --TriggerClientEvent('qb-phone:client:newMailNotify', src, mailData)
    end
end)

RegisterServerEvent('qb-phone:server:postTweet')
AddEventHandler('qb-phone:server:postTweet', function(message)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    QBCore.Functions.ExecuteSql(false, "INSERT INTO `phone_tweets` (`citizenid`, `sender`, `message`) VALUES ('"..Player.PlayerData.citizenid.."', '"..Player.PlayerData.charinfo.firstname.." "..string.sub(Player.PlayerData.charinfo.lastname, 1, 1):upper()..".', '"..message.."')")
    TriggerClientEvent('qb-phone:client:newTweet', -1, Player.PlayerData.charinfo.firstname.." "..string.sub(Player.PlayerData.charinfo.lastname, 1, 1):upper()..".", message)
end)

RegisterServerEvent('qb-phone:server:postAdvert')
AddEventHandler('qb-phone:server:postAdvert', function(message)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Adverts[Player.PlayerData.citizenid] = {
        message = message,
        phone = Player.PlayerData.charinfo.phone,
        name = Player.PlayerData.charinfo.firstname .." "..Player.PlayerData.charinfo.lastname,
    }
    TriggerClientEvent('qb-phone:client:newAd', -1, Player.PlayerData.charinfo.firstname .." "..Player.PlayerData.charinfo.lastname, message)
end)

function GenerateMailId()
    return math.random(111111, 999999)
end

function convertDate(vardate)
    local y,m,d,h,i,s = string.match(vardate, '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)')
    return string.format('%s/%s/%s %s:%s:%s', d,m,y,h,i,s)
end

QBCore.Functions.CreateCallback('qb-phone:server:getContactName', function(source, cb, number)
    local src = source
    local plyCid = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, 'SELECT `name` FROM `player_contacts` WHERE `citizenid` = "'..plyCid.PlayerData.citizenid..'" AND `number` = "'..number..'"', function(result)
        if result[1] ~= nil then
            cb(result[1].name)
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback('qb-phone:server:getSearchData', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    QBCore.Functions.ExecuteSql(false, 'SELECT * FROM `players` WHERE `citizenid` = "'..search..'" OR `charinfo` LIKE "%'..search..'%"', function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                local charinfo = json.decode(v.charinfo)
                local metadata = json.decode(v.metadata)
                table.insert(searchData, {
                    citizenid = v.citizenid,
                    firstname = charinfo.firstname,
                    lastname = charinfo.lastname,
                    birthdate = charinfo.birthdate,
                    phone = charinfo.phone,
                    nationality = charinfo.nationality,
                    gender = charinfo.gender,
                    warrant = false,
                    driverlicense = metadata["licences"]["driver"]
                })
            end
            cb(searchData)
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback('qb-phone:server:getVehicleSearch', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    QBCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_vehicles` WHERE `plate` LIKE "%'..search..'%" OR `citizenid` = "'..search..'"', function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                QBCore.Functions.ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[k].citizenid..'"', function(player)
                    if player[1] ~= nil then 
                        local charinfo = json.decode(player[1].charinfo)
                        local vehicleInfo = QBCore.Shared.VehicleModels[GetHashKey(result[k].vehicle)]
                        if vehicleInfo ~= nil then 
                            table.insert(searchData, {
                                plate = result[k].plate,
                                status = true,
                                owner = charinfo.firstname .. " " .. charinfo.lastname,
                                citizenid = result[k].citizenid,
                                label = vehicleInfo["brand"] .. " " .. vehicleInfo["name"]
                            })
                        else
                            table.insert(searchData, {
                                plate = result[k].plate,
                                status = true,
                                owner = charinfo.firstname .. " " .. charinfo.lastname,
                                citizenid = result[k].citizenid,
                                label = "Naam niet gevonden.."
                            })
                        end
                    end
                end)
            end
        else
            if GeneratedPlates[search] ~= nil then
                table.insert(searchData, {
                    plate = GeneratedPlates[search].plate,
                    status = GeneratedPlates[search].status,
                    owner = GeneratedPlates[search].owner,
                    citizenid = GeneratedPlates[search].citizenid,
                    label = "Merk niet bekend.."
                })
            else
                local ownerInfo = GenerateOwnerName()
                GeneratedPlates[search] = {
                    plate = search,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
                table.insert(searchData, {
                    plate = search,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                    label = "Merk niet bekend.."
                })
            end
        end
        cb(searchData)
    end)
end)

QBCore.Functions.CreateCallback('qb-phone:server:getVehicleData', function(source, cb, plate)
    local src = source
    local vehicleData = {}
    if plate ~= nil then 
        QBCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_vehicles` WHERE `plate` = "'..plate..'"', function(result)
            if result[1] ~= nil then
                QBCore.Functions.ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[1].citizenid..'"', function(player)
                    local charinfo = json.decode(player[1].charinfo)
                    vehicleData = {
                        plate = plate,
                        status = true,
                        owner = charinfo.firstname .. " " .. charinfo.lastname,
                        citizenid = result[1].citizenid,
                    }
                end)
            elseif GeneratedPlates ~= nil and GeneratedPlates[plate] ~= nil then 
                vehicleData = GeneratedPlates[plate]
            else
                local ownerInfo = GenerateOwnerName()
                GeneratedPlates[plate] = {
                    plate = plate,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
                vehicleData = {
                    plate = plate,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
            end
            cb(vehicleData)
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, "Geen voertuig in de buurt..", "error")
        cb(nil)
    end
end)

function GenerateOwnerName()
    local names = {
        [1] = { name = "Jan Bloksteen", citizenid = "DSH091G93" },
        [2] = { name = "Jay Dendam", citizenid = "AVH09M193" },
        [3] = { name = "Ben Klaariskees", citizenid = "DVH091T93" },
        [4] = { name = "Karel Bakker", citizenid = "GZP091G93" },
        [5] = { name = "Klaas Adriaan", citizenid = "DRH09Z193" },
        [6] = { name = "Nico Wolters", citizenid = "KGV091J93" },
        [7] = { name = "Mark Hendrickx", citizenid = "ODF09S193" },
        [8] = { name = "Bert Johannes", citizenid = "KSD0919H3" },
        [9] = { name = "Karel de Grote", citizenid = "NDX091D93" },
        [10] = { name = "Jan Pieter", citizenid = "ZAL0919X3" },
        [11] = { name = "Huig Roelink", citizenid = "ZAK09D193" },
        [12] = { name = "Corneel Boerselman", citizenid = "POL09F193" },
        [13] = { name = "Hermen Klein Overmeen", citizenid = "TEW0J9193" },
        [14] = { name = "Bart Rielink", citizenid = "YOO09H193" },
        [15] = { name = "Antoon Henselijn", citizenid = "QBC091H93" },
        [16] = { name = "Aad Keizer", citizenid = "YDN091H93" },
        [17] = { name = "Thijn Kiel", citizenid = "PJD09D193" },
        [18] = { name = "Henkie Krikhaar", citizenid = "RND091D93" },
        [19] = { name = "Teun Blaauwkamp", citizenid = "QWE091A93" },
        [20] = { name = "Dries Stielstra", citizenid = "KJH0919M3" },
        [21] = { name = "Karlijn Hensbergen", citizenid = "ZXC09D193" },
        [22] = { name = "Aafke van Daalen", citizenid = "XYZ0919C3" },
        [23] = { name = "Door Leeferds", citizenid = "ZYX0919F3" },
        [24] = { name = "Nelleke Broedersen", citizenid = "IOP091O93" },
        [25] = { name = "Renske de Raaf", citizenid = "PIO091R93" },
        [26] = { name = "Krisje Moltman", citizenid = "LEK091X93" },
        [27] = { name = "Mirre Steevens", citizenid = "ALG091Y93" },
        [28] = { name = "Joosje Kalvenhaar", citizenid = "YUR09E193" },
        [29] = { name = "Mirte Ellenbroek", citizenid = "SOM091W93" },
        [30] = { name = "Marlieke Meilink", citizenid = "KAS09193" },
    }
    return names[math.random(1, #names)]
end

function escape_sqli(source)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return source:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end

QBCore.Functions.CreateCallback('qb-phone:server:getContactStatus', function(source, cb, number)
    local src = source
    local plyCid = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, 'SELECT * FROM `players` WHERE `charinfo` LIKE "%'..number..'%"', function(result)
        local target = result[1]

        if target ~= nil then
            local trgt = QBCore.Functions.GetPlayerByCitizenId(target.citizenid)
            if trgt ~= nil then
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('qb-phone:server:createChat')
AddEventHandler('qb-phone:server:createChat', function(messages)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(true, "INSERT INTO `phone_messages` (`citizenid`, `number`, `messages`) VALUES ('"..ply.PlayerData.citizenid.."', '"..messages.number.."', '"..json.encode(messages.messages).."')")

    if messages.number ~= ply.PlayerData.charinfo.phone then
        QBCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..messages.number.."%'", function(target)
            local targetPly = QBCore.Functions.GetPlayerByCitizenId(target[1].citizenid)

            if targetPly ~= nil then
                TriggerClientEvent('qb-phone:client:createChatOther', targetPly.PlayerData.source, messages, ply.PlayerData.charinfo.phone)
            else
                QBCore.Functions.ExecuteSql(true, "INSERT INTO `phone_messages` (`citizenid`, `number`, `messages`) VALUES ('"..target[1].citizenid.."', '"..ply.PlayerData.charinfo.phone.."', '"..json.encode(messages.messages).."')")
            end
        end)
    end
end)


RegisterServerEvent('qb-phone:server:giveNumber')
AddEventHandler('qb-phone:server:giveNumber', function(targetId, playerData)
    TriggerClientEvent('qb-phone:server:newContactNotify', targetId, playerData.charinfo.phone)
end)

RegisterServerEvent('qb-phone:server:giveBankAccount')
AddEventHandler('qb-phone:server:giveBankAccount', function(targetId, playerData)
    TriggerClientEvent('qb-phone:server:newBankNotify', targetId, playerData.charinfo.account)
end)

RegisterServerEvent('qb-phone:server:createChatOther')
AddEventHandler('qb-phone:server:createChatOther', function(chatData, senderPhone)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, "INSERT INTO `phone_messages` (`citizenid`, `number`, `messages`) VALUES ('"..ply.PlayerData.citizenid.."', '"..senderPhone.."', '"..json.encode(chatData.messages).."')")
    
    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `player_contacts` WHERE `citizenid` = '"..ply.PlayerData.citizenid.."' AND `number` = '"..senderPhone.."'", function(result)
        if result[1] ~= nil then
            TriggerClientEvent('qb-phone:client:msgNotify', src, 'Je hebt een bericht ontvangen van '..result[1].name, result[1].name)
        else
            TriggerClientEvent('qb-phone:client:msgNotify', src, 'Je hebt een bericht ontvangen van '..senderPhone, senderPhone)
        end
    end)
end)

RegisterServerEvent('qb-phone:server:sendMessage')
AddEventHandler('qb-phone:server:sendMessage', function(chatData)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)
    QBCore.Functions.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(chatData.messages).."' WHERE `citizenid` = '"..ply.PlayerData.citizenid.."' AND `number` = '"..chatData.number.."'")
    
    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..chatData.number.."%'", function(target)
        local targetPly = QBCore.Functions.GetPlayerByCitizenId(target[1].citizenid)

        if targetPly ~= nil then
            TriggerClientEvent('qb-phone:client:recieveMessage', targetPly.PlayerData.source, chatData, ply.PlayerData.charinfo.phone)
        else
            QBCore.Functions.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(chatData.messages).."' WHERE `citizenid` = '"..target[1].citizenid.."' AND `number` = '"..ply.PlayerData.charinfo.phone.."'")
        end
    end)
end)

RegisterServerEvent('qb-phone:server:recieveMessage')
AddEventHandler('qb-phone:server:recieveMessage', function(chatData, senderPhone)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, "UPDATE `phone_messages` SET `messages` = '"..json.encode(chatData.messages).."' WHERE `citizenid` = '"..ply.PlayerData.citizenid.."' AND `number` = '"..senderPhone.."'")

    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `player_contacts` WHERE `citizenid` = '"..ply.PlayerData.citizenid.."' AND `number` = '"..senderPhone.."'", function(result)
        if result[1] ~= nil then
            TriggerClientEvent('qb-phone:client:msgNotify', src, 'Je hebt een bericht ontvangen van '..result[1].name, result[1].name)
        else
            TriggerClientEvent('qb-phone:client:msgNotify', src, 'Je hebt een bericht ontvangen van '..senderPhone, senderPhone)
        end
    end)
end)

RegisterServerEvent('qb-phone:server:removeContact')
AddEventHandler('qb-phone:server:removeContact', function(name, number)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, "DELETE FROM `player_contacts` WHERE `name` = '"..name.."' AND `number` = '"..number.."'")
end)

QBCore.Functions.CreateCallback('qb-phone:server:getPlayerMessages', function(source, cb)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `phone_messages` WHERE `citizenid` = '"..ply.PlayerData.citizenid.."'", function(result)
        for k, v in pairs(result) do
            result[k].messages = json.decode(result[k].messages)
        end
        cb(result)
    end)
end)

RegisterServerEvent('qb-phone:server:CallContact')
AddEventHandler('qb-phone:server:CallContact', function(callData, caller, anonymous)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..callData.number.."%'", function(result)
        if result[1] ~= nil then
            local target = result[1]
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(target.citizenid)

            if targetPlayer ~= nil then
                if anonymous then
                    TriggerClientEvent('qb-phone:client:IncomingCall', targetPlayer.PlayerData.source, callData, "Anoniem")
                else
                    TriggerClientEvent('qb-phone:client:IncomingCall', targetPlayer.PlayerData.source, callData, caller)
                end
            end
        end
    end)
end)

RegisterServerEvent('qb-phone:server:addPoliceAlert')
AddEventHandler('qb-phone:server:addPoliceAlert', function(alertData)
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                TriggerClientEvent("qb-phone:client:addPoliceAlert", Player.PlayerData.source, alertData)
            end
        end
	end
end)

QBCore.Commands.Add("opnemen", "Inkomend oproep beantwoorden", {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
	TriggerClientEvent('qb-phone:client:AnswerCall', source)
end)


RegisterServerEvent('qb-phone:server:AnswerCall')
AddEventHandler('qb-phone:server:AnswerCall', function(callData)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..callData.number.."%'", function(result)
        if result[1] ~= nil then
            local target = result[1]
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(target.citizenid)

            print(targetPlayer.PlayerData.source)

            if targetPlayer ~= nil then
                TriggerClientEvent('qb-phone:client:AnswerCallOther', targetPlayer.PlayerData.source)
            end
        end
    end)
end)

RegisterServerEvent('qb-phone:server:HangupCall')
AddEventHandler('qb-phone:server:HangupCall', function(callData)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)
    if callData ~= nil and callData.number ~= nil then 
        QBCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..callData.number.."%'", function(result)
            if result[1] ~= nil then
                local target = result[1]
                local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(target.citizenid)
    
                if targetPlayer ~= nil then
                    TriggerClientEvent('qb-phone:client:HangupCallOther', targetPlayer.PlayerData.source, callData)
                end
            end
        end)
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:doesChatExists', function(source, cb, number)
    local ply = QBCore.Functions.GetPlayer(source)
    QBCore.Functions.ExecuteSql(false, 'SELECT * FROM `phone_messages` WHERE `citizenid` = "'..ply.PlayerData.citizenid..'" AND `number` = "'..number..'"', function(result)
        if result[1] ~= nil then
            cb(result[1])
        else
            cb(nil)
        end
    end)
end)

QBCore.Commands.Add("ophangen", "Oproep beeindigen", {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
	TriggerClientEvent('qb-phone:client:HangupCall', source)
end)

QBCore.Commands.Add("bel", "Oproep starten", {}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if args[1] ~= nil then
        TriggerClientEvent('qb-phone:client:CallNumber', source, args[1])
    end
end)

QBCore.Commands.Add("payphone", "Oproep starten", {}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if args[1] ~= nil then
        TriggerClientEvent('qb-phone:client:CallPayPhone', source, args[1])
    end
end)

RegisterServerEvent('qb-phone:server:PayPayPhone')
AddEventHandler('qb-phone:server:PayPayPhone', function(amount, number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player ~= nil then
        if Player.Functions.RemoveMoney('cash', amount) then
            TriggerClientEvent('qb-phone:client:CallPayPhoneYes', src, number)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Je hebt niet voldoende cash op zak..', 'error')
        end
    end
end)