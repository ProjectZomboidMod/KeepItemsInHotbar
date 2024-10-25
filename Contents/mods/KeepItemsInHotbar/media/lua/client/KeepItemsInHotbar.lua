local mod = {
    ItemHandlers = {},
    ItemHandlerEnabled = {},
    ItemHandlerOrderList = {},
}

function mod:registerItemHandler(name, defaultEnabled, order, handler)
    self.ItemHandlers[name] = handler
    self.ItemHandlerEnabled[name] = defaultEnabled
    local isNewEntry = true
    for _, entry in ipairs(self.ItemHandlerOrderList) do
        if entry.name == name then
            isNewEntry = false
            entry.order = order
        end
    end
    if isNewEntry then
        table.insert(self.ItemHandlerOrderList, { name = name, order = order })
    end
    table.sort(self.ItemHandlerOrderList, function(a, b) return a.order < b.order end)
end

function mod:findReplaceItem(item, player)
    for _, entry in ipairs(self.ItemHandlerOrderList) do
        local handler = self.ItemHandlers[entry.name]
        local replaceItem, stop = handler(self, item, player)
        if replaceItem then
            return self.ItemHandlerEnabled[entry.name] and replaceItem
        end
        if stop then
            return
        end
    end
end

function mod:getItem(itemType, player, reverseOrder)
    local array = player:getInventory():getItemsFromFullType(itemType)
    local bound = array:size() - 1
    for i = 0, bound do
        local item = reverseOrder and array:get(bound - i) or array:get(i)
        if item:getAttachedSlot() == -1 and not item:isBroken() then
            return item
        end
    end
end

function mod:itemIsDrainable(item)
    return instanceof(item, "DrainableComboItem")
end

mod:registerItemHandler("Flashlight", true, 200, function(self, item, player)
    if item:getLightStrength() > 0 and self:itemIsDrainable(item) then
        return self:getItem(item:getFullType(), player, true), true
    end
end)

mod:registerItemHandler("WaterContainer", true, 400, function(self, item, player)
    if item:canStoreWater() then
        local replaceType
        if not item:isWaterSource() then
            replaceType = item:getReplaceType("WaterSource")
        elseif self:itemIsDrainable(item) then
            replaceType = item:getReplaceOnDepleteFullType()
        end
        return replaceType and self:getItem(replaceType, player, true)
    end
end)

mod:registerItemHandler("Drainable", false, 600, function(self, item, player)
    if self:itemIsDrainable(item) then
        return self:getItem(item:getFullType(), player, true), true
    end
end)

mod:registerItemHandler("Weapon", false, 800, function(self, item, player)
    if item:IsWeapon() then
        return self:getItem(item:getFullType(), player, true), true
    end
end)

mod:registerItemHandler("Others", false, 1000, function(self, item, player)
    return self:getItem(item:getFullType(), player, true)
end)

return mod
