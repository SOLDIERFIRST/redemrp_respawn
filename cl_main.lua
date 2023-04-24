
local newCharacter = false
local pressed = false
local code
local revived = false
RegisterCommand("kys", function(source, args, rawCommand) -- KILL YOURSELF COMMAND
    local _source = source
    if Config.kysCommand then
        local pl = Citizen.InvokeNative(0x217E9DC48139933D)
        local ped = Citizen.InvokeNative(0x275F255ED201B937, pl)
        Citizen.InvokeNative(0x697157CED63F18D4, ped, 500000, false, true, true)
    end
end, false)


RegisterNetEvent("redemrp_respawn:TransferCode")
AddEventHandler("redemrp_respawn:TransferCode", function(c)
    if code == nil then
        code = c
    end
end)

RegisterNetEvent("redemrp_respawn:gotRevive")
AddEventHandler("redemrp_respawn:gotRevive", function(c)
    if c ~= code then return end
    DoScreenFadeOut(500)
    Wait(500)
    revived = true
    Wait(1000)
    TriggerServerEvent('redemrp_status:AddAmount', 100, 100)
    RespawnCamera(GetEntityCoords(PlayerPedId()))
end)

RegisterCommand("revive", function(source, args, rawCommand)
    print(code)
    if args[1] ~= nil then
        TriggerServerEvent('redemrp_respawn:revive', tonumber(args[1]) , code)
    else
        TriggerServerEvent('redemrp_respawn:revive', source , code)
    end
end, false)

RegisterNetEvent("redemrp_respawn:KillPlayer")
AddEventHandler("redemrp_respawn:KillPlayer", function(c)
    if c ~= code then return end
    local pl = Citizen.InvokeNative(0x217E9DC48139933D)
    local ped = Citizen.InvokeNative(0x275F255ED201B937, pl)
    Citizen.InvokeNative(0x697157CED63F18D4, ped, 500000, false, true, true)
end)

function Button_Prompt()
	Citizen.CreateThread(function()
		local str = "Wake Up Nearby"
		newlife = Citizen.InvokeNative(0x04F97DE45A519419)
		PromptSetControlAction(newlife, 0xCEFD9220)
		str = CreateVarString(10, 'LITERAL_STRING', str)
		PromptSetText(newlife, str)
		PromptSetEnabled(newlife, false)
		PromptSetVisible(newlife, false)
		PromptSetHoldMode(newlife, true)
		PromptSetGroup(newlife, revive_prompt)
		PromptRegisterEnd(newlife)
	end)
end 

local onPlayerDead = false
Citizen.CreateThread(function()
    Button_Prompt()
    while true do
        Wait(0)
        while IsPlayerDead(PlayerId()) and not revived do
            Wait(1)
            local timer = GetGameTimer()+(Config.RespawnTime * 1000)
            while timer >= GetGameTimer() and not revived do
                if revived == false then

                    if onPlayerDead == false then
                        -- ON PLAYER DEAD STUFF
                        --
                        --
                        --

                        DisplayHud(false)
                        DisplayRadar(false)
                        exports.spawnmanager:setAutoSpawn(false)
                        Citizen.InvokeNative(0xFA08722A5EA82DA7, "FIRSTPERSON_glasses_dark")
                        Citizen.InvokeNative(0xFDB74C9CC54C3F37, 1.0)
                        TriggerServerEvent("redemrp_respawn:DeadTable", "add" , code)
                        StartDeathCam()
                        onPlayerDead = true
                    end

                    Wait(1)
                    ProcessCamControls()
                    DrawTxt("You will wake up in " .. tonumber(string.format("%.0f", (((GetGameTimer() - timer) * -1)/1000))) .. " seconds.", 0.895, 0.88, 0.0, 0.5, true, 255, 255, 255, 255, true)
                    PromptSetEnabled(newlife, false)
		            PromptSetVisible(newlife, true)
                    DisableControlAction(0, 0x4CC0E2FE, true)
                    DisableControlAction(0, 0xB238FE0B, true)
                else
                    break
                end
            end
            while true do
                Wait(0)
                ProcessCamControls()
                --DrawTxt("Pockets will be emptied of items.", 0.90, 0.962, 0.4, 0.4, true, 255, 255, 255, 255, true)
                PromptSetEnabled(newlife, true)
		        PromptSetVisible(newlife, true)
                DisableControlAction(0, 0x4CC0E2FE, true)
                DisableControlAction(0, 0xB238FE0B, true)               
                if PromptHasHoldModeCompleted(newlife) then
                    PromptSetEnabled(newlife, false)
                    PromptSetVisible(newlife, false)
                    DoScreenFadeOut(500)
                    presserespawn()
                end 
                if revived then
                    break
                end
            end
            respawn(not revived)
            revived = false
            onPlayerDead = false
            TriggerServerEvent("redemrp_respawn:DeadTable", "remove" , code)
            PromptSetEnabled(newlife, false)
            PromptSetVisible(newlife, false)
        end
    end
end)

function respawn(changetown)
    if changetown then
        SendNUIMessage({
            type = 1,
            showMap = true
        })
        SetNuiFocus(true, true)
    end
    EndDeathCam()
    AnimpostfxStop("DeathFailMP01")
    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    DestroyAllCams(true)

    local pl = Citizen.InvokeNative(0x217E9DC48139933D)
    local ped = Citizen.InvokeNative(0x275F255ED201B937, pl)
    local coords = GetEntityCoords(ped, false)
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    FreezeEntityPosition(ped, false)
    Citizen.InvokeNative(0x71BC8E838B9C6035, ped)
    Citizen.InvokeNative(0x0E3F4AF2D63491FB)
    Citizen.InvokeNative(0xFA08722A5EA82DA7, "FIRSTPERSON_glasses_dark")
    Citizen.InvokeNative(0xFDB74C9CC54C3F37, 0.0)
end

function presserespawn()
    revived = true
    onPlayerDead = false
    EndDeathCam()
    AnimpostfxStop("DeathFailMP01")
    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    DestroyAllCams(true)
    TriggerServerEvent('redemrp_status:AddAmount', 100, 100)
    
    local pl = Citizen.InvokeNative(0x217E9DC48139933D)
    local ped = Citizen.InvokeNative(0x275F255ED201B937, pl)
    local coords = GetEntityCoords(ped, false)
    local spawntown = Citizen.InvokeNative(0x43AD8FC02B429D33,coords.x,coords.y,coords.z,10)
-- west elizabeth
    if spawntown == 822658194 --[[(Big Valley)]] or spawntown == -120156735 --[[(Grizzlies East)]] then -- strawberry
        SetEntityCoords(ped, -1841.377, -405.8665, 165.8613)
        SetEntityHeading(ped, 231.1281)
    end 
    if spawntown == 476637847 --[[(Great Plains)]] or spawntown == 1684533001 --[[(Tall Trees)]] then -- blackwater
        SetEntityCoords(ped, -728.1979, -1243.248, 44.74409)
        SetEntityHeading(ped, 86.40054)
    end
-- new hanover
    if spawntown == 1835499550 --[[(Cumberland)]] or spawntown == 131399519 --[[(Heartlands)]] then -- valentine
        SetEntityCoords(ped, -168.2004, 628.075, 114.0421)
        SetEntityHeading(ped, 231.1281)
    end
    if spawntown == 178647645 --[[(Roanoke Ridge)]] or spawntown == 1645618177 --[[(Grizzlies West)]] then -- annesburg
        SetEntityCoords(ped, 2947.209, 1282.661, 44.67347)
        SetEntityHeading(ped, 260.2)
    end
-- lemoyne
    if spawntown == 2025841068 --[[(Bayou Nwa)]] or spawntown == 1308232528 --[[(Bluewater Marsh)]] then --saint denis
        SetEntityCoords(ped, 2873.945, -1347.046, 42.62447) 
        SetEntityHeading(ped, 49.80801)
    end
    if spawntown == -864275692 --[[(Scarlett Meadows)]] then -- rhodes
        SetEntityCoords(ped, 1241.947, -1310.389, 76.9493)
        SetEntityHeading(ped, 130.71)
    end
-- new austin
    if spawntown == 892930832 --[[(Hennigan's Stead)]] then -- armadillo
        SetEntityCoords(ped, -3742.364, -2601.25, -13.18227)
        SetEntityHeading(ped, 66.3)
    end
    if spawntown == -108848014 --[[(Cholla Springs)]] or spawntown == -2145992129 --[[(Rio Bravo)]] or spawntown == -2066240242 --[[(Gaptooth Ridge)]] then -- tumbleweed
        SetEntityCoords(ped, -3742.364, -2601.25, -13.18227)
        SetEntityHeading(ped, 16.25)
    end
-- special
    if spawntown == 613867492 --[[(Nuevo Paraiso)]] then -- mexico
        SetEntityCoords(ped, 0, 0, 0)
        SetEntityHeading(ped, 0.0)
    end
    if spawntown == 1935063277 --[[(Guarma)]] then -- guarma
        SetEntityCoords(ped, 0, 0, 0)
        SetEntityHeading(ped, 0.0)
    end
    if spawntown == 2147354003 --[[(Sisika)]] then -- sisika
        SetEntityCoords(ped, 3332.72, -671.4, 45.68)
        SetEntityHeading(ped, 0.0)
    end
-- end spawn zones ---
    FreezeEntityPosition(ped, false)
    Citizen.InvokeNative(0x71BC8E838B9C6035, ped)
    Citizen.InvokeNative(0x0E3F4AF2D63491FB)
    Citizen.InvokeNative(0xFA08722A5EA82DA7, "FIRSTPERSON_glasses_dark")
    Citizen.InvokeNative(0xFDB74C9CC54C3F37, 0.0)
    DoScreenFadeIn(2500)
    EnableControlAction(0, 0x4CC0E2FE, true)
    EnableControlAction(0, 0xB238FE0B, true)
    DisplayHud(true)
    DisplayRadar(true)
end
-----------------------------------------FIND DISTRICT COMMAND-----------------------------------
--[[ RegisterCommand("whereami", function(source, args)
	local pl = Citizen.InvokeNative(0x217E9DC48139933D)
    local ped = Citizen.InvokeNative(0x275F255ED201B937, pl)
	local coords = GetEntityCoords(ped, false)
	local state = Citizen.InvokeNative(0x43AD8FC02B429D33,coords.x,coords.y,coords.z,10)
	print(state)
end)  ]]

RegisterNetEvent("redemrp_respawn:respawn")
AddEventHandler("redemrp_respawn:respawn", function(new)
    newCharacter = new
    respawn(new)
end)

RegisterNetEvent("redemrp_respawn:respawnCoords")
AddEventHandler("redemrp_respawn:respawnCoords", function(coords , c)
    if c ~= code then return end
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 1,
        showMap = false
    })
    FreezeEntityPosition(ped, false)

    ShutdownLoadingScreen()
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 59.95, true, true, false)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    ClearPedTasksImmediately(ped)
    ClearPlayerWantedLevel(PlayerId())
    FreezeEntityPosition(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityVisible(ped, true)
    SetEntityCollision(ped, true)
    TriggerEvent('playerSpawned')
    Citizen.InvokeNative(0xF808475FA571D823, true)
    NetworkSetFriendlyFireOption(true)
    RespawnCamera(coords)
    TriggerServerEvent("redemrp_respawn:registerCoords", coords)
    SavePosition()
end)

RegisterNUICallback('select', function(spawn, cb)
    local coords = Config[spawn][math.random(#Config[spawn])]
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 1,
        showMap = false
    })
    FreezeEntityPosition(ped, false)

    ShutdownLoadingScreen()
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 59.95, true, true, false)
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    ClearPedTasksImmediately(ped)
    ClearPlayerWantedLevel(PlayerId())
    FreezeEntityPosition(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityVisible(ped, true)
    SetEntityCollision(ped, true)
    TriggerEvent('playerSpawned', spawn)
    Citizen.InvokeNative(0xF808475FA571D823, true)
    NetworkSetFriendlyFireOption(true)
	if newCharacter then
	   TriggerServerEvent("redemrp_skin:loadSkin")
	end
    RespawnCamera(coords)
    TriggerServerEvent("redemrp_respawn:registerCoords", coords)
    SavePosition()
end)

local saving = false
function SavePosition()
    if not saving then
        Citizen.CreateThread(function()
            while true do
                Wait(15000)
                local coords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("redemrp_respawn:registerCoords", {x = coords.x, y = coords.y, z = coords.z})
            end
        end)
        saving = true
    end
end

function RespawnCamera(_coords)
    DoScreenFadeIn(100)
    FreezeEntityPosition(PlayerPedId(), false)
    DisplayHud(true)
    DisplayRadar(true)
    Citizen.Wait(3000)

end
--=============================================================-- DRAW TEXT SECTION--=============================================================--
function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)


    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    Citizen.InvokeNative(0xADA9255D, 1);
	SetTextFontForCurrentCommand(7)
    DisplayText(str, x, y)
end

function CreateVarString(p0, p1, variadic)
    return Citizen.InvokeNative(0xFA925AC00EB830B9, p0, p1, variadic, Citizen.ResultAsLong())
end

--=============================================================-- CAMERA SECTION--=============================================================--

local cam = nil

local isDead = false

local angleY = 0.0
local angleZ = 0.0

function StartDeathCam()
    Citizen.CreateThread(function()
        ClearFocus()

        local playerPed = PlayerPedId()

        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayCamFov())
        ShakeCam(cam, "DRUNK_SHAKE", 0.5)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 1000, true, false)
    end)
end


function EndDeathCam()
    Citizen.CreateThread(function()
        ClearFocus()
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(cam, false)
        cam = nil
    end)
end


function ProcessCamControls()
    Citizen.CreateThread(function()

            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)


            DisableFirstPersonCamThisFrame()

            local newPos = ProcessNewPosition()

            SetCamCoord(cam, newPos.x, newPos.y, newPos.z)

            PointCamAtCoord(cam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
    end)
end

function ProcessNewPosition()
    local mouseX = 0.0
    local mouseY = 0.0


    -- keyboard
    if (IsInputDisabled(0)) then
        -- rotation
        mouseX = GetDisabledControlNormal(1, 0x4D8FB4C1) * 3.0
        mouseY = GetDisabledControlNormal(1, 0xFDA83190) * 3.0

        -- controller
    else
        -- rotation
        mouseX = GetDisabledControlNormal(1, 0x4D8FB4C1) * 1.0
        mouseY = GetDisabledControlNormal(1, 0xFDA83190) * 1.0
    end
    angleZ = angleZ - mouseX -- around Z axis (left / right)
    angleY = angleY + mouseY -- up / down
    -- limit up / down angle to 90°
    if (angleY > 89.0) then angleY = 89.0 elseif (angleY < -89.0) then angleY = -89.0 end

    local pCoords = GetEntityCoords(PlayerPedId())

    local behindCam = {
        x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (1.5 + 0.5),
        y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (1.5 + 0.5),
        z = pCoords.z + ((Sin(angleY))) * (1.5 + 0.5)
    }
    local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)
    local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    local maxRadius = 1.5
    if (hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords) < 1.5 + 0.5) then
        maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords)
    end

    local offset = {
        x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
        y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius,
        z = ((Sin(angleY))) * maxRadius
    }

    local pos = {
        x = pCoords.x + offset.x,
        y = pCoords.y + offset.y,
        z = pCoords.z + offset.z
    }

    return pos
end

exports("ReviveCheckIn", function()
    if not revived then
        revived = true
    end

    respawn(false, true)
end)

function GetClosestPlayer()
    local players, closestDistance, closestPlayer = GetActivePlayers(), -1, -1
    local playerPed = PlayerPedId()
    local playerId = PlayerId()
    local coords, usePlayerPed = coords, false
    
    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        usePlayerPed = true
        coords = GetEntityCoords(playerPed)
    end
    
    for i=1, #players, 1 do
        local tgt = GetPlayerPed(players[i])

        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then

            local targetCoords = GetEntityCoords(tgt)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function()
    Citizen.Wait(1000)
    Citizen.InvokeNative(0xC6258F41D86676E0, PlayerPedId(), 0, 100)
end)