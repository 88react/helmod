require "selector.AbstractSelector"
-------------------------------------------------------------------------------
---Class to build container selector
--
---@module EnergySelector
---@extends #AbstractSelector
--

EnergySelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
---After initialization
--
---@function [parent=#EnergySelector] afterInit
--
function EnergySelector:afterInit()
  self.disable_option = true
  self.hidden_option = true
  self.product_option = true
end

-------------------------------------------------------------------------------
---Return caption
---@return table
function EnergySelector:getCaption()
  return {"helmod_selector-panel.energy-title"}
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function EnergySelector:getPrototype(element, type)
  return RecipePrototype(element, type)
end

-------------------------------------------------------------------------------
---Append groups
---@param element string
---@param type string
---@param list_products table
---@param list_ingredients table
function EnergySelector:appendGroups(element, type, list_products, list_ingredients)
  local prototype = self:getPrototype(element, type)

  local lua_prototype = prototype:native()
  local prototype_name = string.format("%s-%s",type , lua_prototype.name)
  for key, element in pairs(prototype:getRawProducts()) do
    if list_products[element.name] == nil then list_products[element.name] = {} end
    list_products[element.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
  end
  for key, element in pairs(prototype:getRawIngredients()) do
    if list_ingredients[element.name] == nil then list_ingredients[element.name] = {} end
    list_ingredients[element.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
  end

end

-------------------------------------------------------------------------------
---Update groups
---@param list_products table
---@param list_ingredients table
function EnergySelector:updateGroups(list_products, list_ingredients)
  for key, entity in pairs(Player.getEnergyMachines()) do
    self:appendGroups(entity, "energy", list_products, list_ingredients)
  end
end

-------------------------------------------------------------------------------
---Build prototype tooltip
---@param prototype table
---@return table
function EnergySelector:buildPrototypeTooltip(prototype)
  ---initalize tooltip
  local recipe_prototype = RecipePrototype(prototype.name, "energy")
  local entity_prototype = EntityPrototype(prototype)
  local energy_name = entity_prototype:getLocalisedName()
  local tooltip = {""}
  table.insert(tooltip, energy_name)
  --table.insert(tooltip, {"", "\n",entity_prototype:getType()})
  ---products
  if table.size(recipe_prototype:getProducts()) > 0 then
    table.insert(tooltip, {"", "\n", helmod_tag.font.default_bold, helmod_tag.color.gold, {"helmod_common.products"}, ":", helmod_tag.color.close, helmod_tag.font.close})
    for _,product in pairs(recipe_prototype:getProducts()) do
      if product.type == "energy" and product.name == "energy" then
          table.insert(tooltip, {"", "\n", "[img=helmod-energy-white]", helmod_tag.font.default_bold, " x ", Format.formatNumberKilo(product.amount,"W"), helmod_tag.font.close})
      elseif product.type == "energy" and product.name == "steam-heat" then
          table.insert(tooltip, {"", "\n", "[img=helmod-steam-heat-white]", helmod_tag.font.default_bold, " x ", Format.formatNumberKilo(product.amount,"W"), helmod_tag.font.close})
      else
        table.insert(tooltip, {"", "\n", string.format("[%s=%s]", product.type, product.name), helmod_tag.font.default_bold, " x ", Format.formatNumberElement(product.amount), helmod_tag.font.close})
      end
    end
  end
  ---ingredients
  if table.size(recipe_prototype:getIngredients()) > 0 then
    table.insert(tooltip, {"", "\n", helmod_tag.font.default_bold, helmod_tag.color.gold, {"helmod_common.ingredients"}, ":", helmod_tag.color.close, helmod_tag.font.close})
    for _,ingredient in pairs(recipe_prototype:getIngredients()) do
      if ingredient.type == "energy" and ingredient.name == "energy" then
        table.insert(tooltip, {"", "\n", "[img=helmod-energy-white]", helmod_tag.font.default_bold, " x ", Format.formatNumberKilo(ingredient.amount,"W"), helmod_tag.font.close})
      elseif ingredient.type == "energy" and ingredient.name == "steam-heat" then
        table.insert(tooltip, {"", "\n", "[img=helmod-steam-heat-white]", helmod_tag.font.default_bold, " x ", Format.formatNumberKilo(ingredient.amount,"W"), helmod_tag.font.close})
      else
        table.insert(tooltip, {"", "\n", string.format("[%s=%s]", ingredient.type, ingredient.name), helmod_tag.font.default_bold, " x ", Format.formatNumberElement(ingredient.amount), helmod_tag.font.close})
      end
    end
  end
  return tooltip
end

-------------------------------------------------------------------------------
---Build prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function EnergySelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  local button = GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "element-select", "energy"):choose("entity", prototype.name):color():tooltip(tooltip))
  button.locked = true
end
