# gmm-garages
A very simple garage and impound script for the Ox framework, providing vehicle storage and retrieval from public parking spaces. This also provides "fake plate" functionality, including a tool to create a plate item and the ability to attach a plate to a vehicle. Script comes preloaded with 1 impound location, and 2 public garages lots.

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

## Special Thanks
Big thanks to DokaDoka and Linden for creating the Ox framework and resources; keep up the great work! Full disclosure, I used snippets and functions from [ox_property](https://github.com/overextended/ox_property). 

## Preview
![image](https://github.com/Gigachad-Money-Maker/gmm-garages/assets/70592880/0f92e503-7809-490c-83f5-276f6a431a93)
![image](https://github.com/Gigachad-Money-Maker/gmm-garages/assets/70592880/110c3894-e2ab-44c4-8716-c6e279709780)
![image](https://github.com/Gigachad-Money-Maker/gmm-garages/assets/70592880/1a8913a8-868a-43bd-951e-9572c49227e9)
