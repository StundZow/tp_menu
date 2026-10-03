local playerColors = {}
local hiddenPlayers = {} -- [serverId] = true si le blip est masqué pour TOUT LE MONDE
local nextColorIndex = 1

-- Attribue (une seule fois) une couleur à un joueur. Se fait à la demande pour
-- couvrir aussi les joueurs déjà connectés lors d'un restart de la ressource.
local function GetColor(id)
    if not playerColors[id] then
        playerColors[id] = Config.BlipColors[((nextColorIndex - 1) % #Config.BlipColors) + 1]
        nextColorIndex = nextColorIndex + 1
    end
    return playerColors[id]
end

local function HasPermission(src, ace)
    if not ace then
        return true
    end
    return IsPlayerAceAllowed(src, ace)
end

local function Notify(src, message)
    TriggerClientEvent('chat:addMessage', src, {
        color = { 255, 140, 0 },
        args = { '[TP]', message }
    })
end

AddEventHandler('playerDropped', function()
    local src = tonumber(source)
    playerColors[src] = nil
    hiddenPlayers[src] = nil
end)

-- Diffuse la liste des joueurs à tout le monde : sert à la fois pour peupler
-- le menu et pour les blips. Les joueurs masqués sont envoyés SANS coordonnées,
-- ce qui garantit que personne ne peut les voir sur la carte.
local function BroadcastPlayers()
    local players = {}

    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        local ped = GetPlayerPed(playerId)

        if ped ~= 0 then
            local entry = {
                id = id,
                name = GetPlayerName(playerId),
                color = GetColor(id),
                hidden = hiddenPlayers[id] == true
            }

            if not entry.hidden then
                local coords = GetEntityCoords(ped)
                entry.coords = { x = coords.x, y = coords.y, z = coords.z }
            end

            players[#players + 1] = entry
        end
    end

    TriggerClientEvent('tpmenu:updatePlayers', -1, players)
end

CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)
        BroadcastPlayers()
    end
end)

-- Affiche/masque le blip d'un joueur pour tous les joueurs du serveur
RegisterNetEvent('tpmenu:toggleBlip', function(targetId)
    local src = source
    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return
    end

    if not HasPermission(src, Config.BlipTogglePermission) then
        Notify(src, 'Vous n\'êtes pas autorisé à masquer/afficher les blips.')
        return
    end

    if hiddenPlayers[targetId] then
        hiddenPlayers[targetId] = nil
    else
        hiddenPlayers[targetId] = true
    end

    BroadcastPlayers()
end)

-- Téléporte le joueur qui demande vers la cible
RegisterNetEvent('tpmenu:tpToPlayer', function(targetId)
    local src = source
    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return
    end

    if not HasPermission(src, Config.AcePermission) then
        Notify(src, 'Vous n\'êtes pas autorisé à utiliser la téléportation.')
        return
    end

    local targetPed = GetPlayerPed(targetId)
    if targetPed == 0 then
        return
    end

    local coords = GetEntityCoords(targetPed)
    TriggerClientEvent('tpmenu:setCoords', src, coords.x, coords.y, coords.z)
end)

-- Téléporte la cible vers le joueur qui demande
RegisterNetEvent('tpmenu:tpPlayerToMe', function(targetId)
    local src = source
    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return
    end

    if not HasPermission(src, Config.AcePermission) then
        Notify(src, 'Vous n\'êtes pas autorisé à utiliser la téléportation.')
        return
    end

    local srcPed = GetPlayerPed(src)
    if srcPed == 0 then
        return
    end

    local coords = GetEntityCoords(srcPed)
    TriggerClientEvent('tpmenu:setCoords', targetId, coords.x, coords.y, coords.z)
    Notify(targetId, ('Vous avez été téléporté par %s.'):format(GetPlayerName(src)))
end)
