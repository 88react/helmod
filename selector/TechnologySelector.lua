require "selector.AbstractSelector"
-------------------------------------------------------------------------------
---Class to build technology selector
---@class TechnologySelector
TechnologySelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
---After initialization
function TechnologySelector:afterInit()
  self.disable_option = true
  self.sprite_type = nil
end

-------------------------------------------------------------------------------
---Return caption
---@return table
function TechnologySelector:getCaption()
  return {"helmod_selector-panel.technology-title"}
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function TechnologySelector:getPrototype(element, type)
  return Technology(element, type)
end

-------------------------------------------------------------------------------
---Update groups
---@param list_products table
---@param list_ingredients table
function TechnologySelector:updateGroups(list_products, list_ingredients)
  for key, technology in pairs(Player.getTechnologiePrototypes()) do
    self:appendGroups(technology, "technology", list_products, list_ingredients)
  end
end

-------------------------------------------------------------------------------
---Build prototype icon
function TechnologySelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  local button = GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select", "technology"):choose(prototype.type, prototype.name))
  button.locked = true
end
