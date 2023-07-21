local Vehicles = {}

lib.callback.register("garage:GetPlayerVehicles", function(source, garage)
    local player = Ox.GetPlayer(source)
    if player then 
        local vehicles = MySQL.scalar.await('SELECT * FROM vehicles WHERE owner = ? and stored = ?', { player.charid, garage })
        return vehicles
    else
        return false
    end
end)

lib.callback.register("garages:TakeOutCar", function(source, vehicle, garage, coords)
    local player = Ox.GetPlayer(source)
    if player then 
        local vehicle = Ox.CreateVehicle({
            model = "sultanrs",
            owner = player.charid,
        }, vector3(coords.x, coords.y + 1.0, coords.z) , coords.w)
    else
        return false
    end
end)

lib.callback.register("garages:Park", function (source, vehicle, garage)
    local player = Ox.GetPlayer(source)
    if player then 

    else
        return false
    end
end)