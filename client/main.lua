local currentGarage = nil

local function createBlip(lot, name, blipIcon)
	local blip = AddBlipForCoord(lot.x, lot.y, lot.z)
	SetBlipSprite(blip, blipIcon)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, 22)
	SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringBlipName(name)
	EndTextCommandSetBlipName(blip)

	return blip
end

local function getClosestGarageSpot()
    local spot = nil
    local pedCoords = GetEntityCoords(cache.ped)
    for i=1, #Config.Garages[currentGarage].spawnPoints do
        local dist = #(pedCoords - Config.Garages[currentGarage].spawnPoints[i].xyz)
        if #(pedCoords - Config.Garages[currentGarage].spawnPoints[i].xyz) < 2.0 then
            spot = i
            break
        end
    end

    local vehArea = lib.getNearbyVehicles(Config.Garages[currentGarage].spawnPoints[spot].xyz, 2.0, false)
    local pedArea = lib.getNearbyPlayers(Config.Garages[currentGarage].spawnPoints[spot].xyz, 2.0, false)
    if #vehArea > 0 or #pedArea > 0 then
        lib.notify({
            title = 'Garage',
            description = 'Parking spot is blocked',
            type = 'error'
        })
        return nil
    end
    return spot
end

local function parkVehicle(garage)
    if garage == 'impound' then
        lib.notify({
            title = 'Garage',
            description = 'Cars can\'t be parked in Impound',
            type = 'error'
        })
        return
    end
end

local function takeOutVehicle(garage)
    local vehicles = lib.callback.await("gmm-garages:server:GetPlayerVehicles", false, garage)
    local registerMe = {
        id = 'gmm-garages:vehicles',
        title = 'Parked Vehicles - '.. Config.Garages[currentGarage].label,
        options = {}
    }
    local options = {}
    if #vehicles == 0 then
        options[#options+1] = {
            title = 'You don\'t have a vehicle in this garage',
        }
    else
        for k, v in pairs(vehicles) do
            options[#options+1] = {
                title = v.name,
                description = "Plate : " .. (v.plate or "12345678"),
                args = v.plate,
                onSelect = function()
                    local spot = getClosestGarageSpot()
                    local vehicleNet = lib.callback.await('gmm-garages:server:TakeOutCar', false, v.id, currentGarage, spot)
                    if not vehicleNet then return end
                    local attemptsCounter = 0
                    local attemptsLimit = 400 -- 400*5 = 2s
                    while not NetworkDoesEntityExistWithNetworkId(vehicleNet) and attemptsCounter < attemptsLimit do
                        Wait(5)
                    end
                    local vehicleEnt = NetworkGetEntityFromNetworkId(vehicleNet)
                    TaskWarpPedIntoVehicle(cache.ped, vehicleEnt, -1)
                    local attemptsCounter2 = 0
                    local attemptsLimit2 = 400 -- 400*5 = 2s
                    while not Entity(vehicleEnt).state.fakeplate and attemptsCounter2 < attemptsLimit2 do
                        Wait(5)
                    end
                    local fakePlate = Entity(vehicleEnt).state and Entity(vehicleEnt).state.fakeplate or nil
                    if fakePlate ~= nil then
                        SetVehicleNumberPlateText(vehicleEnt, fakePlate)
                    end
                end
            }
        end
    end
    registerMe["options"] = options
    lib.registerContext(registerMe)
    lib.showContext('gmm-garages:vehicles')

    return vehicles
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for key, garage in pairs(Config.Garages) do
        createBlip(garage.spawnPoints[1].xyz, garage.label, garage.blipIcon)
        for i=1, #garage.garagePolys do
            lib.zones.poly({
                points = garage.garagePolys[i],
                debug = Config.Debug,
                onEnter = function()
                    currentGarage = key
                    lib.showTextUI("[Parking]", {icon = 'fas fa-warehouse'})
                    lib.addRadialItem({
                        id = 'parking_access',
                        icon = 'warehouse',
                        label = 'Parking',
                        onSelect = function()
                            if not cache.vehicle then
                                takeOutVehicle(key)
                            else
                                parkVehicle(key)
                            end
                        end
                    })
                end,
                onExit = function()
                    currentGarage = nil
                    lib.hideTextUI()
                    lib.removeRadialItem('parking_access')
                end,
                inside = function()
                    
                end
            })
        end
    end
end)

local options = {
    {
        name = 'gmm-garages:stealPlate',
        icon = 'fa-solid fa-screwdriver-wrench',
        label = 'Steal Plate',
        items = 'license_plate_tool',
        bones = {
            "bonnet",
            "boot"
        },
        canInteract = function(entity, distance, coords, name, boneId)
            return not cache.vehicle and type(coords) ~= 'table' and #(coords - GetEntityCoords(entity)) < 5.0 or true
        end,
        onSelect = function(data)
            CreateThread(function()
                if lib.progressCircle({
                    duration = 2000,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                }) then
                    local vehEnt = data.entity
                    
                    local plate = GetVehicleNumberPlateText(vehEnt)
                    local removeFakePlate = Entity(vehEnt).state.fakeplate and true or false
                    local vehNetId = NetworkGetNetworkIdFromEntity(vehEnt)
                    lib.callback.await('gmm-garages:server:UsePlateTool', false, plate, vehNetId, removeFakePlate) -- need to make it remove a fake plate if statebag is present
                end
            end)
        end
    },
}

exports.ox_target:addGlobalVehicle(options)

exports.ox_inventory:displayMetadata({
    plate_number = 'Plate Number',
})

lib.callback.register('ox:getNearbyVehicles', function(plate)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)
    SetVehicleNumberPlateText(vehicle, plate)
end)

exports('UsePlate', function(data)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)
    local vehNetId = NetworkGetNetworkIdFromEntity(vehicle)
    local response = lib.callback.await('gmm-garages:server:UsePlate', false, vehNetId, data.slot)
    if response then
        SetVehicleNumberPlateText(vehicle, response)
    end
end)
