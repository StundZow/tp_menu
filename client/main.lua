local latestPlayers = {}
local blips = {}
local localHidden = {} -- [serverId] = true, utilisé seulement si Config.SyncBlipToggle = false
local menuOpen = false

local function GetMyServerId()
    return GetPlayerServerId(PlayerId())
end

-- Synchro activée : l'état vient du serveur (identique pour tous).
-- Synchro désactivée : chacun masque les blips pour soi uniquement.
local function IsHidden(p)
    if Config.SyncBlipToggle then
        return p.hidden == true
    end
    return localHidden[p.id] == true
end

local function BuildMenuList(players)
    local list = {}
    local myId = GetMyServerId()
    for _, p in ipairs(players) do
        if p.id ~= myId then
            list[#list + 1] = {
                id = p.id,
                name = p.name,
                blipHidden = IsHidden(p),
                sync = Config.SyncBlipToggle == true
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

            if IsHidden(p) then
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

    -- oublie les masquages locaux des joueurs partis (les IDs peuvent être réutilisés)
    for id in pairs(localHidden) do
        if not seen[id] then
            localHidden[id] = nil
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

RegisterNUICallback('toggleBlip', function(data, cb)
    if Config.SyncBlipToggle then
        -- Le serveur gère l'état et renvoie la liste à jour à tout le monde
        TriggerServerEvent('tpmenu:toggleBlip', data.id)
    else
        local id = tonumber(data.id)
        if localHidden[id] then
            localHidden[id] = nil
        else
            localHidden[id] = true
        end
        UpdateBlips(latestPlayers)
        SendNUIMessage({
            action = 'updatePlayers',
            players = BuildMenuList(latestPlayers)
        })
    end
    cb('ok')
end)

-- Suggestion de commande dans le chat (si la ressource "chat" par défaut est présente)
CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Ouvrir le menu de téléportation')
end)
