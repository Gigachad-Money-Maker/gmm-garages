local currentGarage = nil

local function getVehicles(garage)
    print(garage)
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
        options[#options+1] = {
            title = 'Dicks',
            description = "Plate : 12345678",
            args = "12345678",
            onSelect = function()
                lib.callback.await('garages:TakeOutCar', false, nil, nil, GetEntityCoords(cache.ped))
            end
        }
    else
        for k, v in pairs(vehicles) do
            options[#options+1] = {
                title = 'Dicks',
                description = "Plate : " .. (v.plate or "12345678"),
                serverEvent = 'qb-garages:server:PayDepotPrice',
                args = v.plate,
                onSelect = function()
                    lib.callback.await('garages:TakeOutCar', false, nil, nil, GetEntityCoords(cache.ped))
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
        for _, garageRow in pairs(garage.garagePoints) do
            lib.zones.poly({
                points = garageRow,
                debug = Config.Debug,
                onEnter = function()
                    currentGarage = key
                    lib.showTextUI("[Parking]")
                    -- lib.addRadialItem({
                    --     id = 'garage_access',
                    --     icon = 'warehouse',
                    --     label = 'Garage',
                    --     onSelect = function()
                    --         print('Garage')
                    --     end
                    -- })
                    getVehicles(key)
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
