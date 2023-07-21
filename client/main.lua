local currentGarage = nil

local function getClosestGarageSpot()
    local spot = nil
    local pedCoords = GetEntityCoords(cache.ped)
    for i=1, #Config.Garages[currentGarage].spawnPoints do
        if #(pedCoords - Config.Garages[currentGarage].spawnPoints[i].xyz) < 2.0 then
            spot = i
        end
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
    if vehicles == nil then
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
                    local vehNet = lib.callback.await('garages:TakeOutCar', false, v.id, currentGarage, spot)
                    if not vehNet then return end
                    NetworkRequestControlOfNetworkId(vehNet) --TODO this needs to be improved
                    while not NetworkHasControlOfNetworkId(vehNet) do
                        NetworkRequestControlOfNetworkId(vehNet)
                        Wait(1)
                    end
                    SetPedIntoVehicle(cache.ped, NetworkGetEntityFromNetworkId(vehNet), -1)
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
        for i=1, #garage.garagePolys do
            lib.zones.poly({
                points = garage.garagePolys[i],
                debug = Config.Debug,
                onEnter = function()
                    currentGarage = key
                    lib.showTextUI("[Parking]")
                    lib.addRadialItem({
                        id = 'garage_access',
                        icon = 'warehouse',
                        label = 'Garage',
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
                    lib.removeRadialItem('garage_access')
                end,
                inside = function()
                    
                end
            })
        end
    end
end)
