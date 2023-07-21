local Vehicles = {}

lib.callback.register("garage:GetPlayerVehicles", function(source, garage)
    local player = Ox.GetPlayer(source)
    if player then
        local vehicles = MySQL.query.await('SELECT * FROM vehicles WHERE owner = ? and stored = ?', { player.charid, garage })
        return vehicles
    else
        return false
    end
end)

lib.callback.register("garages:TakeOutCar", function(source, id, garage, spot)
    local player = Ox.GetPlayer(source)
    if player then
        local spotCoords = Config.Garages[garage].spawnPoints[spot]
        if spotCoords then
            local vehicle = Ox.CreateVehicle(tonumber(id), vector3(spotCoords.x, spotCoords.y + 1.0, spotCoords.z) , spotCoords.w)
            vehicle.setOwner(player.charid)
            while not DoesEntityExist(vehicle.entity) do Wait(5) end
            --SetPedIntoVehicle(player.ped, vehicle.entity, -1)
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
        vehicle.setStored(garage, true)
    else
        return false
    end
end)