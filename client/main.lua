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
        if #(pedCoords - Config.Garages[currentGarage].spawnPoints[i].xyz) < 2.0 then
            local area = lib.getNearbyVehicles(pedCoords, 2.0, false)
            if #area <= 0 then
                spot = i
                break
            end

        end
    end

    if spot == nil then
        lib.notify({
            title = 'Garage',
            description = 'Spot is full',
            type = 'error'
        })
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
    local vehicles = lib.callback.await("garages:ParkCar", false, garage)
end

local function takeOutVehicle(garage)
    local vehicles = lib.callback.await("garage:GetPlayerVehicles", false, garage)
    local resgisterMe = {
        id = 'garages_vehicles',
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
                serverEvent = 'qb-garages:server:PayDepotPrice',
                args = v.plate,
                onSelect = function()
                    local spot = getClosestGarageSpot()
                    print(spot)
                    local vehicleNet = lib.callback.await('garages:TakeOutCar', false, v.id, currentGarage, spot)
                    if not vehicleNet then return end
                    local attemptsCounter = 0
                    local attemptsLimit = 400 -- 400*5 = 2s
                    while not NetworkDoesEntityExistWithNetworkId(vehicleNet) and attemptsCounter < attemptsLimit do
                        Wait(5)
                    end
                    local vehicleEnt = NetworkGetEntityFromNetworkId(vehicleNet)
                    TaskWarpPedIntoVehicle(cache.ped, vehicleEnt, -1)
                    while not Entity(vehicleEnt).state.fakeplate do
                        Wait(5)
                    end
                    local fakePlate = Entity(vehicleEnt).state.fakeplate
                    SetVehicleNumberPlateText(vehicleEnt, fakePlate)
                end
            }
        end
    end
    resgisterMe["options"] = options
    lib.registerContext(resgisterMe)
    lib.showContext('garages_vehicles')

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
        icon = 'fa-solid fa-oil-can',
        label = 'Steal Plate',
        canInteract = function(entity, distance, coords, name, boneId)
            return type(coords) ~= 'table' and #(coords - GetEntityCoords(entity)) < 1.9 or true
        end,
        onSelect = function(data)
            CreateThread(function()
                lib.progressCircle({
                    duration = 2000,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                })
            end)
        end
    },
}

exports.ox_target:addGlobalVehicle(options)

function UsePlate()
    print("ASDF")
end

exports('UsePlate', UsePlate)

function UsePlateTool()
    print("ASDF2")
end

exports('UsePlateTool', UsePlateTool)