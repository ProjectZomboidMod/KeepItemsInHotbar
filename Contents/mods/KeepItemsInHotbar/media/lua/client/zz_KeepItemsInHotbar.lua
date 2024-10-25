local mod = require("KeepItemsInHotbar")

local ISHotbar_attachItem = ISHotbar.attachItem
ISHotbar.attachItem = function(...)
    mod.isAttachingItem = true
    ISHotbar_attachItem(...)
    mod.isAttachingItem = false
end

local ISHotbar_removeItem = ISHotbar.removeItem
ISHotbar.removeItem = function(self, item, doAnim)
    local slotIndex, model
    if not doAnim then
        slotIndex = item:getAttachedSlot()
        model = item:getAttachedToModel()
    end
    ISHotbar_removeItem(self, item, doAnim)
    if doAnim or self.attachedItems[slotIndex] or mod.isAttachingItem then return end
    local newItem = mod:findReplaceItem(item, self.chr)
    if not newItem then return end
    local slot = self.availableSlot[slotIndex]
    if slot and self:canBeAttached(slot, newItem) then
        self:attachItem(newItem, model, slotIndex, slot.def, false)
    end
end

-- Mod Config Menu
if Mod.IsMCMInstalled_v1 then
    local optionTable = ModOptionTable:New("KeepItemsInHotbar", getText("UI_KIiH_Title"), false)
    for _, entry in ipairs(mod.ItemHandlerOrderList) do
        local name = entry.name
        local checkboxText = getTextOrNull("UI_KIiH_Option_" .. name)
        if checkboxText == nil or checkboxText == "" then checkboxText = name end
        local tooltipText = getTextOrNull("UI_KIiH_Tooltip_" .. name)
        if tooltipText == "" then tooltipText = nil end
        optionTable:AddModOption(name, "checkbox", mod.ItemHandlerEnabled[name], nil, checkboxText, tooltipText,
            function(value) mod.ItemHandlerEnabled[name] = value end)
    end
end
