Core, FW = GetCore()

RegisterServerEvent('0r-driveby-check', function(id, level)
    local target = GetPlayer(id)

    local me = GetPlayer(source)
    if target and me then
        if GetMoney(me, 'cash') >= Config.Levels[level].price then
            RemoveMoney(me, 'cash', Config.Levels[level].price)
            Config.Notify("Driveby will start in half minute!", 'success', true, source)
            TriggerClientEvent('0r-driveby-attach', id, level)
        else
            Config.Notify("You don't have enough money!", 'error', true, source)
        end
    else
        Config.Notify('Player is offline', 'error', true, source)
    end
end)

function GetPlayer(src)
    if FW == 'qb' then
        return Core.Functions.GetPlayer(src)
    elseif FW == 'esx' then
        return Core.GetPlayerFromId(src)
    end
end

function GetMoney(user, type)
    if FW == 'qb' then
        return user.Functions.GetMoney(type)
    elseif FW == 'esx' then
        if type == 'cash' then
            return user.getAccount('money').money
        else

            return user.getAccount('bank').money
        end
    end
end

function RemoveMoney(user, type, amount)
    if FW == 'qb' then
        user.Functions.RemoveMoney(type, amount)
    elseif FW == 'esx' then
        if type == 'cash' then
            return user.removeAccountMoney('money', amount)
        else
            return user.removeAccountMoney('bank', amount)
        end
    end
end