ESX = nil
local spawnedPadi = 0
local padiPlants = {}
local isPickingUp = false

local PlayerData = {}



Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
	end
	
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

local CurrentCheckPointPadi = 0
local LastCheckPointPadi   = -1

local CheckPointsPadi = {
    {
        Pos = {x = 615.79, y = 6458.89, z = 29.53},
    },
    {
        Pos = {x = 663.53, y = 6458.77, z = 31.05},
    },
    {
        Pos = {x = 620.14, y = 6468.25, z = 29.49},
    },
    {
        Pos = {x = 663.89, y = 6480.31, z = 29.85},
    },
    {
        Pos = {x = 613.65, y = 6494.16, z = 29.18},
    },
}

local onDutyPadi = 0
local blippadi = nil
local countcabutpadi = 0


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local letSleep = true
        local coords = GetEntityCoords(PlayerPedId())
        
        if onDutyPadi == 2 then
		    if GetDistanceBetweenCoords(coords, Config.CircleZones.PadiField.coords, true) < 50 then
                if PlayerData.job.name == 'petani' then
                    letSleep = false
				    SpawnTanamanPadi()
                end
            end
        end

        if GetDistanceBetweenCoords(coords, 428.14, 6476.53, 28.32, true) < 3 then

            if PlayerData.job.name == 'petani' then
                letSleep = false
                DrawMarker(39, 428.14, 6476.53, 28.32, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
                ESX.ShowHelpNotification('E - Mengambil Traktor (Padi)')
                if IsControlJustReleased(0, 38) and onDutyPadi == 0 then 
                    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                        if skin.sex == 0 then
                            TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
                        elseif skin.sex == 1 then
                            TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
                        end
                    end)
                    Citizen.Wait(500)
                    ESX.Game.SpawnVehicle('tractor',{ x = 428.14, y = 6476.53, z = 28.32}, 138.74, function(callback_vehicle)
						onDutyPadi = 1
						TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
					end)
                end
            end
        end
		if letSleep then 
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(padiPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        local letSleep = true
		local playerPed      = PlayerPedId()
		local coords         = GetEntityCoords(playerPed)
		local nextCheckPoint = CurrentCheckPointPadi + 1

		if onDutyPadi == 1 then 
			if CheckPointsPadi[nextCheckPoint] == nil then
				if DoesBlipExist(blippadi) then
					RemoveBlip(blippadi)
				end

				vehicle = GetVehiclePedIsIn(playerPed, false)
				ESX.Game.DeleteVehicle(vehicle)
				onDutyPadi = 2
			else
				if CurrentCheckPointPadi ~= LastCheckPointPadi then
					if DoesBlipExist(blippadi) then
						RemoveBlip(blippadi)
					end

					blippadi = AddBlipForCoord(CheckPointsPadi[nextCheckPoint].Pos.x, CheckPointsPadi[nextCheckPoint].Pos.y, CheckPointsPadi[nextCheckPoint].Pos.z)
					SetBlipRoute(blippadi, 1)

					LastCheckPointPadi = CurrentCheckPointPadi
				end

				local distance = GetDistanceBetweenCoords(coords, CheckPointsPadi[nextCheckPoint].Pos.x, CheckPointsPadi[nextCheckPoint].Pos.y, CheckPointsPadi[nextCheckPoint].Pos.z, true)

				if distance <= 100.0 then
					DrawMarker(20, CheckPointsPadi[nextCheckPoint].Pos.x, CheckPointsPadi[nextCheckPoint].Pos.y, CheckPointsPadi[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
				end

				if distance <= 3 then
					vehicle = GetVehiclePedIsIn(playerPed, false)
					if GetHashKey('tractor') == GetEntityModel(vehicle) then
						CurrentCheckPointPadi = CurrentCheckPointPadi + 1
					end
				end
			end
			
		end
	end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        local letSleep = true
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID

		for i=1, #padiPlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(padiPlants[i]), false) < 1 then
				nearbyObject, nearbyID = padiPlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then

			if not isPickingUp  then
				ESX.ShowHelpNotification("E - Mengambil")
			end

			if IsControlJustReleased(0, Keys['E']) and not isPickingUp then
                if countcabutpadi >= 80 then 
                    onDutyPadi = 0
					countcabutpadi = 0
				else
					isPickingUp = true

					ESX.TriggerServerCallback('rw:canPickUp', function(canPickUp)

						if canPickUp then
							TriggerEvent("mythic_progbar:client:progress", {
								name = "stone_farm",
								duration = 2500,
								label = 'Mencabut Padi',
								useWhileDead = true,
								canCancel = false,
								controlDisables = {
									disableMovement = true,
									disableCarMovement = true,
									disableMouse = false,
									disableCombat = true,
								},
								animation = {
									animDict = "creatures@rottweiler@tricks@",
									anim = "petting_franklin",
									flags = 49,
								},
							}, function(status)
								if not status then
									-- Do Something If Event Wasn't Cancelled
								end
							end)

							Citizen.Wait(2500)
		
							ESX.Game.DeleteObject(nearbyObject)
		
							table.remove(padiPlants, nearbyID)
                            spawnedPadi = spawnedPadi - 1
                            countcabutpadi = countcabutpadi + 1
		
							TriggerServerEvent('rw:pickedUpPadi')
						else
							exports['mythic_notify']:SendAlert('error', 'Melebihi Batas', 10000)
						end

						isPickingUp = false

					end, 'padi')
				end
			end

		else
			Citizen.Wait(500)
		end

	end

end)

function SpawnTanamanPadi()
	while spawnedPadi < 20 do
		Citizen.Wait(0)
		local padiCoords = GeneratePadiCoords()

		ESX.Game.SpawnLocalObject('prop_veg_crop_05', padiCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(padiPlants, obj)
			spawnedPadi = spawnedPadi + 1
		end)
	end
end

function ValidatePadiCoord(plantCoord)
	if spawnedPadi > 0 then
		local validate = true

		for k, v in pairs(padiPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.CircleZones.PadiField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GeneratePadiCoords()
	while true do
		Citizen.Wait(1)

		local padiCoordX, padiCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-30, 30)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-20, 20)

		padiCoordX = Config.CircleZones.PadiField.coords.x + modX
		padiCoordY = Config.CircleZones.PadiField.coords.y + modY

		local coordZ = GetCoordZ(padiCoordX, padiCoordY)
		local coord = vector3(padiCoordX, padiCoordY, coordZ)

		if ValidatePadiCoord(coord) then
			return coord
		end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = { 30.0, 31.0, 32.0, 33.0, 34.0, 35.0, 36.0, 37.0, 38.0, 39.0, 40.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 43.0
end