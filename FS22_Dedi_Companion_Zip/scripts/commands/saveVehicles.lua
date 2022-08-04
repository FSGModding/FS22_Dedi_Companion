dcDebug("VehicleStuff Class")

VehicleStuff = {}
local VehicleStuff_mt = Class(VehicleStuff, Event)

function VehicleStuff.save()
    dcDebug("*** Dedi Companion Debug *** Forget Me Command Start")

    local allVehicles = g_currentMission.vehicles

    for _, vehicle in pairs(allVehicles) do
        dcDebug("Vehicle ID: " .. vehicle.id)
        
        dcDebug(rootVehicle, "Table")

        
        --dcDebug("Vehicle Word Position: " .. vehicle.)
    end

end