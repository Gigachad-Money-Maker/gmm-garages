# gmm-garages
A very simple garage and impound script for the Ox framework, providing vehicle storage and retrieval from public parking spaces. This also provides "fake plate" functionality, including a tool to create a plate item and the ability to attach a plate to a vehicle.

## Items
```
['license_plate'] = {
    label = 'License Plate',
    weight = 200,
    stack = false,
    client = {
        anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
        disable = { car = true },
        usetime = 3500,
        export = 'gmm-garages.UsePlate'
    }
    
},
['license_plate_tool'] = {
    label = 'Plate Removal Tool',
    weight = 200,
}
```