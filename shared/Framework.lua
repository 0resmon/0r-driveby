function GetCore()
    local object = nil
    local Framework = Config.Framework

    if Config.Framework == "esx" then
        local counter = 0
        local status = pcall(function ()
            exports['es_extended']:getSharedObject()
        end)
        if status then        
            while not object do
                object = exports['es_extended']:getSharedObject()
                counter = counter + 1
                if counter == 3 then
                    break
                end
                Wait(1000)
            end
        end
    end

    if Config.Framework == "qb" then
        object = exports["qb-core"]:GetCoreObject()
    end
    return object, Framework
end