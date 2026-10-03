local latestPlayers = {}
local blips = {}
local menuOpen = false

local function GetMyServerId()
    return GetPlayerServerId(PlayerId())
end

local function BuildMenuList(players)
    local list = {}
    local myId = GetMyServerId()
    for _, p in ipairs(players) do
        if p.id ~= myId then
            list[#list + 1] = {
                id = p.id,
                name = p.name,
                blipHidden = p.hidden == true
            }
        end
    end
    return list
end

local function UpdateBlips(players)
    local myId = GetMyServerId()
    local seen = {}

    for _, p in ipairs(players) do
        if p.id ~= myId then
            seen[p.id] = true

            if p.hidden then
                if blips[p.id] then
                    RemoveBlip(blips[p.id])
                    blips[p.id] = nil
                end
            elseif not blips[p.id] then
                local blip = AddBlipForCoord(p.coords.x, p.coords.y, p.coords.z)
                SetBlipSprite(blip, Config.BlipSprite)
                SetBlipScale(blip, Config.BlipScale)
                SetBlipAsShortRange(blip, true)
                SetBlipColour(blip, p.color)

                if Config.ShowBlipName then
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentString(p.name)
                    EndTextCommandSetBlipName(blip)
                end

                blips[p.id] = blip
            else
                SetBlipCoords(blips[p.id], p.coords.x, p.coords.y, p.coords.z)
                SetBlipColour(blips[p.id], p.color)
            end
        end
    end

    -- retire les blips des joueurs déconnectés
    for id, blip in pairs(blips) do
        if not seen[id] then
            RemoveBlip(blip)
            blips[id] = nil
        end
    end
end

RegisterNetEvent('tpmenu:updatePlayers', function(players)
    latestPlayers = players
    UpdateBlips(players)

    if menuOpen then
        SendNUIMessage({
            action = 'updatePlayers',
            players = BuildMenuList(players)
        })
    end
end)

RegisterNetEvent('tpmenu:setCoords', function(x, y, z)
    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z, false, false, false, true)
end)

local function OpenMenu()
    if menuOpen then return end
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        players = BuildMenuList(latestPlayers)
    })
end

local function CloseMenu()
    if not menuOpen then return end
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterCommand(Config.Command, function()
    OpenMenu()
end, false)

RegisterKeyMapping(Config.Command, 'Ouvrir le menu de teleportation', 'keyboard', Config.MenuKey)

RegisterNUICallback('close', function(_, cb)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('tpToPlayer', function(data, cb)
    TriggerServerEvent('tpmenu:tpToPlayer', data.id)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('tpPlayerToMe', function(data, cb)
    TriggerServerEvent('tpmenu:tpPlayerToMe', data.id)
    CloseMenu()
    cb('ok')
end)

-- Le serveur gère l'état (global) et renvoie la liste à jour à tout le monde
RegisterNUICallback('toggleBlip', function(data, cb)
    TriggerServerEvent('tpmenu:toggleBlip', data.id)
    cb('ok')
end)

-- Suggestion de commande dans le chat (si la ressource "chat" par défaut est présente)
CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Ouvrir le menu de téléportation')
end)
