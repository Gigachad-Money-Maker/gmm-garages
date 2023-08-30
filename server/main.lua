lib.callback.register("gmm-garages:server:GetPlayerVehicles", function(source, garage)
    local player = Ox.GetPlayer(source)
    if player then
        local vehicles = MySQL.query.await('SELECT * FROM vehicles WHERE owner = ? and stored = ?', { player.charid, garage })
        for i=1, #vehicles do
            local vehicle = vehicles[i]
            local modelData = Ox.GetVehicleData(vehicle.model)
            vehicles[i].name = modelData.name
            vehicles[i].plate = vehicles[i].data?.fakeplate or vehicles[i].plate
        end
        return vehicles
    else
        return false
    end
end)

lib.callback.register("gmm-garages:server:TakeOutCar", function(source, id, garage, spot)
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
            if fakePlate and type(fakePlate) ~= 'table' or nil then
                Entity(vehicle.entity).state.fakeplate = fakePlate
            end
            
            return vehicle.netid
        else
            return false
        end
    else
        return false
    end
end)

local function pedsLeaveVehicle(seats, vehiceleEntity)
    local passengers = {}
    for i = -1, seats - 1 do
        local ped = GetPedInVehicleSeat(vehiceleEntity, i)
        if ped ~= 0 then
            passengers[#passengers + 1] = ped
            TaskLeaveVehicle(ped, vehiceleEntity, 0)
        end
    end

    if next(passengers) then
        local empty
        while not empty do
            Wait(100)
            empty = true
            for i = 1, #passengers do
                local passenger = passengers[i]
                if GetVehiclePedIsIn(passenger) == vehiceleEntity then
                    empty = false
                end
            end
        end

        Wait(300)
    end
end

lib.callback.register("gmm-garages:server:ParkCar", function (source, garage)
    local player = Ox.GetPlayer(source)
    if player then 
        local vehicle = Ox.GetVehicle(GetVehiclePedIsIn(player.ped, false))
        if player.charid == vehicle.owner then
            local vehicleData = Ox.GetVehicleData(vehicle.model)
            pedsLeaveVehicle(vehicleData.seats, vehicle.entity)
            local plate = GetVehicleNumberPlateText(vehicle.entity)
            vehicle.set('fakeplate', plate)
            vehicle.setStored(garage, true)
        else
            
        end
    else
        return false
    end
end)

exports.ox_inventory:registerHook('createItem', function(payload)
    local metadata = payload.metadata
    metadata.label = 'License Plate'
    return metadata
end, {
    itemFilter = {
        license_plate = true
    }
})

lib.callback.register('gmm-garages:server:UsePlateTool', function(source, plate, netId, removeFakePlate)
    local src = source
    local success = exports.ox_inventory:RemoveItem(src, 'license_plate_tool', 1)
    if success then
        local metadata = {
            plate_number = plate
        }
        exports.ox_inventory:AddItem(src, 'license_plate', 1, metadata)
        if removeFakePlate then
            local vehEnt = NetworkGetEntityFromNetworkId(netId)
            local vehicle = Ox.GetVehicle(vehEnt)
            vehicle.set('fakeplate', nil)
            local properties = vehicle.get('properties')
            local newPlate = properties.plate
            SetVehicleNumberPlateText(vehicle.entity, newPlate)
        end
    end
end)

lib.callback.register('gmm-garages:server:UsePlate', function(source, netId, slot)
    local src = source
    local itemData = exports.ox_inventory:GetSlot(src, slot)
    if exports.ox_inventory:RemoveItem(src, 'license_plate', 1, nil, slot) then
        local vehEnt = NetworkGetEntityFromNetworkId(netId)
        local vehicle = Ox.GetVehicle(vehEnt)
        if vehicle ~= nil then
            vehicle.set('fakeplate', itemData.metadata.plate_number)
            Entity(vehicle.entity).state.fakeplate = itemData.metadata.plate_number
            SetVehicleNumberPlateText(vehicle.entity, itemData.metadata.plate_number)
            return true
        else
            return false
        end
    else
        return false
    end
end)