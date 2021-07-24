require "selector.AbstractSelector"
-------------------------------------------------------------------------------
---Class to build recipe selector
--
---@module RecipeSelector
---@extends #AbstractSelector
--

RecipeSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
---After initialization
--
---@function [parent=#RecipeSelector] afterInit
--
function RecipeSelector:afterInit()
  self.unlock_recipe = true
  self.disable_option = true
  self.hidden_option = true
  self.product_option = true
  self.hidden_player_crafting = true
end

-------------------------------------------------------------------------------
---Return caption
---@return table
function RecipeSelector:getCaption()
  return {"helmod_selector-panel.recipe-title"}
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function RecipeSelector:getPrototype(element, type)
  return RecipePrototype(element, type)
end

-------------------------------------------------------------------------------
---Append groups
---@param element string
---@param type string
---@param list_products table
---@param list_ingredients table
function RecipeSelector:appendGroups(element, type, list_products, list_ingredients)
  local prototype = self:getPrototype(element, type)

  local lua_prototype = prototype:native()
  local prototype_name = string.format("%s-%s",type , lua_prototype.name)
  for key, raw_product in pairs(prototype:getRawProducts()) do
    if list_products[raw_product.name] == nil then list_products[raw_product.name] = {} end
    list_products[raw_product.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
  end
  for key, raw_ingredient in pairs(prototype:getRawIngredients()) do
    if list_ingredients[raw_ingredient.name] == nil then list_ingredients[raw_ingredient.name] = {} end
    list_ingredients[raw_ingredient.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
  end
end

-------------------------------------------------------------------------------
---Update groups
---@param list_products table
---@param list_ingredients table
function RecipeSelector:updateGroups(list_products, list_ingredients)
  RecipeSelector:updateUnlockRecipesCache()
  for key, recipe in pairs(Player.getRecipePrototypes()) do
    self:appendGroups(recipe, "recipe", list_products, list_ingredients)
  end
  for key, resource in pairs(Player.getResources()) do
    self:appendGroups(resource, "resource", list_products, list_ingredients)
  end
  for key, item in pairs(Player.getItemPrototypes()) do
    if item.rocket_launch_products ~= nil and table.size(item.rocket_launch_products) > 0 then
      self:appendGroups(item, "rocket", list_products, list_ingredients)
    end
  end
  for key, entity in pairs(Player.getEnergyMachines()) do
    self:appendGroups(entity, "energy", list_products, list_ingredients)
  end
end

-------------------------------------------------------------------------------
---Update unlock recipes cache
function RecipeSelector:updateUnlockRecipesCache()
  local unlock_recipes = {}
  local filters = {{filter = "hidden", invert = true},{filter = "has-effects", mode = "and"}}
  local technology_prototypes = Player.getTechnologiePrototypes(filters)
  for _,technology in pairs(technology_prototypes) do
      local modifiers = technology.effects
      for _,modifier in pairs(modifiers) do
          if modifier.type == "unlock-recipe" and modifier.recipe ~= nil then
            unlock_recipes[modifier.recipe] = true
          end
      end
  end
  for _, recipe in pairs(Player.getRecipePrototypes()) do
    if recipe.enabled == true then
      unlock_recipes[recipe.name] = true
    end
  end
  Cache.setData("other", "unlock_recipes", unlock_recipes)
end


-------------------------------------------------------------------------------
---Build prototype tooltip
---@param prototype table
---@return table
function RecipeSelector:buildPrototypeTooltip(prototype)
  if prototype.type ~= "energy" then
    local tooltip = ""
    return tooltip
  end
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
---Create prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function RecipeSelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  if prototype.type == "energy" then 
    local button = GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "element-select", "energy"):choose("entity", prototype.name):color():tooltip(tooltip))
    button.locked = true
    GuiElement.infoRecipe(button, prototype)
    return
  end
  local model, block, recipe = self:getParameterObjects()
  local recipe_prototype = self:getPrototype(prototype)
  local color = nil
  if recipe_prototype:getCategory() == "crafting-handonly" then
    color = "yellow"
  elseif recipe_prototype:getEnabled() == false then
    color = "red"
  end
  local block_id = "new"
  if block ~= nil then block_id = block.id end
  local button_prototype = GuiButtonSelectSprite(self.classname, "element-select", prototype.type):choose(prototype.type, prototype.name):color(color)
  local button = GuiElement.add(gui_element, button_prototype)
  button.locked = true
  GuiElement.infoRecipe(button, prototype)
end

