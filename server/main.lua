local Vehicles = {}

lib.callback.register("garage:GetPlayerVehicles", function(source, garage)
    local player = Ox.GetPlayer(source)
    if player then
        local vehicles = MySQL.query.await('SELECT * FROM vehicles WHERE owner = ? and stored = ?', { player.charid, garage })
        for i=1, #vehicles do
            local vehicle = vehicles[i]
            local modelData = Ox.GetVehicleData(vehicle.model)
            vehicles[i].name = modelData.name
        end
        return vehicles
    else
        return false
    end
end)

lib.callback.register("garages:TakeOutCar", function(source, id, garage, spot)
    local src = source
    local player = Ox.GetPlayer(src)
    if player then

        if garage == 'impound' then
            local success = exports.ox_inventory:RemoveItem(player.source, 'money', Config.ImpoundFee)
            if not success then
                TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Not enough money' })
                return
            end
        end
        local spotCoords = Config.Garages[garage].spawnPoints[spot]
        if spotCoords then
            local vehicle = Ox.CreateVehicle(tonumber(id), vector3(spotCoords.x, spotCoords.y + 1.0, spotCoords.z) , spotCoords.w)
            local attemptsCounter = 0
            local attemptsLimit = 400 -- 400*5 = 2s
            while not DoesEntityExist(vehicle.entity) do
                Wait(5)
                attemptsCounter = attemptsCounter + 1
                if attemptsCounter > attemptsLimit then
                    return
                end
            end
            vehicle.setOwner(player.charid)
            
            local fakePlate = vehicle.get('fakeplate')
            print('fakeplate', fakePlate)
            Entity(vehicle.entity).state.fakeplate = fakePlate
            
            return vehicle.netid
        else
            return false
        end
    else
        return false
    end
end)

lib.callback.register("garages:ParkCar", function (source, garage)
    local player = Ox.GetPlayer(source)
    if player then 
        local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(player.ped, false))
        vehicle.set('fakeplate', 'ASDF1234')
        vehicle.setStored(garage, true)
    else
        return false
    end
end)

local hookId = exports.ox_inventory:registerHook('createItem', function(payload)
    print(json.encode(payload, { indent = true }))
    local metadata = payload.metadata
    metadata.label = 'License Plate'
    return metadata
end, {
    print = true,
    itemFilter = {
        license_plate = true
    }
})