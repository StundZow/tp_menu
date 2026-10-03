local latestPlayers = {}
local blips = {}
local localHidden = {} -- [serverId] = true : blips que JE masque pour moi seul
local menuOpen = false

local KVP_SYNC_MODE = 'tpmenu_sync_mode'

-- Mode du bouton boussole, réglable dans le menu et mémorisé entre les sessions :
--   true  = masquer un joueur le masque pour TOUT LE MONDE (géré par le serveur)
--   false = masquer un joueur uniquement pour moi
local syncMode = Config.DefaultSyncMode
local savedMode = GetResourceKvpString(KVP_SYNC_MODE)
if savedMode then
    syncMode = savedMode == '1'
end

local function GetMyServerId()
    return GetPlayerServerId(PlayerId())
end

-- Un blip est affiché seulement s'il n'est masqué ni globalement ni par moi
local function IsBlipHidden(p)
    return p.hidden == true or localHidden[p.id] == true
end

local function BuildMenuList(players)
    local list = {}
    local myId = GetMyServerId()
    for _, p in ipairs(players) do
        if p.id ~= myId then
            list[#list + 1] = {
                id = p.id,
                name = p.name,
                -- l'icône reflète l'état du mode actuellement sélectionné
                blipHidden = syncMode and p.hidden == true or (not syncMode and localHidden[p.id] == true)
            }
        end
    end
    return list
end

local function PushMenu(action)
    SendNUIMessage({
        action = action,
        players = BuildMenuList(latestPlayers),
        sync = syncMode
    })
end

local function UpdateBlips(players)
    local myId = GetMyServerId()
    local seen = {}

    for _, p in ipairs(players) do
        if p.id ~= myId then
            seen[p.id] = true

            if IsBlipHidden(p) then
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
        PushMenu('updatePlayers')
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
    PushMenu('open')
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

-- Interrupteur du menu : "pour tout le monde" / "pour moi seulement"
RegisterNUICallback('setSyncMode', function(data, cb)
    syncMode = data.sync == true
    SetResourceKvp(KVP_SYNC_MODE, syncMode and '1' or '0')
    PushMenu('updatePlayers')
    cb('ok')
end)

RegisterNUICallback('toggleBlip', function(data, cb)
    if syncMode then
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
        PushMenu('updatePlayers')
    end
    cb('ok')
end)

-- Suggestion de commande dans le chat (si la ressource "chat" par défaut est présente)
CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Ouvrir le menu de téléportation')
end)
