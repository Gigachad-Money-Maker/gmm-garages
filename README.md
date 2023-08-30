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
![image](https://github.com/Gigachad-Money-Maker/gmm-garages/assets/70592880/4ec6aacd-87b8-4fa0-a483-0ef417dd5eff)

![image](https://github.com/Gigachad-Money-Maker/gmm-garages/assets/70592880/fc59a25f-5ec9-4493-a360-c36add2fcaf5)

![image](https://github.com/Gigachad-Money-Maker/gmm-garages/assets/70592880/7866829a-fa4d-4cb8-8f2c-efe0f40d06b6)

