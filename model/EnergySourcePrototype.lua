require "model.Prototype"
-------------------------------------------------------------------------------
---Class Object
---@class EnergySourcePrototype
EnergySourcePrototype = newclass(Prototype,function(base, lua_prototype, factory)
  Prototype.init(base,lua_prototype)
  base.factory = factory
end)

-------------------------------------------------------------------------------
---Return usage priority
---@return string
function EnergySourcePrototype:getUsagePriority()
  if self.lua_prototype == nil then return nil end
  return "none"
end

-------------------------------------------------------------------------------
---Return type
---@return string
function EnergySourcePrototype:getType()
  return "none"
end

-------------------------------------------------------------------------------
---Return emissions
---@return number --default 0
function EnergySourcePrototype:getEmissions()
  if self.lua_prototype == nil then return 0 end
  return self.lua_prototype.emissions  or 2.7777777e-7
end

-------------------------------------------------------------------------------
---Return drain energy
---@return number --default 0
function EnergySourcePrototype:getDrain()
  return 0
end

-------------------------------------------------------------------------------
---Return effectivity
---@return number --default 0
function EnergySourcePrototype:getEffectivity()
  if self.lua_prototype == nil then return 0 end
  return self.lua_prototype.effectivity or 1
end

-------------------------------------------------------------------------------
---Return fuel count
---@return nil
function EnergySourcePrototype:getFuelCount()
  return nil
end

-------------------------------------------------------------------------------
---Return fuel fluid prototypes
---@return nil
function EnergySourcePrototype:getFuelPrototypes()
  return nil
end

-------------------------------------------------------------------------------
---Return first fuel fluid prototype
---@return nil
function EnergySourcePrototype:getFirstFuelPrototype()
  return nil
end

-------------------------------------------------------------------------------
---Return fuel prototype
---@return nil
function EnergySourcePrototype:getFuelPrototype()
  return nil
end

-------------------------------------------------------------------------------
---@class ElectricSourcePrototype
ElectricSourcePrototype = newclass(EnergySourcePrototype,function(base,lua_prototype)
  EnergySourcePrototype.init(base,lua_prototype)
end)

-------------------------------------------------------------------------------
---Return type
---@return string
function ElectricSourcePrototype:getType()
  return "electric"
end

-------------------------------------------------------------------------------
---Return usage priority
---@return string
function ElectricSourcePrototype:getUsagePriority()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.usage_priority
end

-------------------------------------------------------------------------------
---Return buffer capacity
---@return number --default 0
function ElectricSourcePrototype:getBufferCapacity()
  if self.lua_prototype == nil then return 0 end
  return self.lua_prototype.buffer_capacity or 0
end

-------------------------------------------------------------------------------
---Return  drain energy
---@return number --default 0
function ElectricSourcePrototype:getDrain()
  if self.lua_prototype == nil then return 0 end
  return (self.lua_prototype.drain or 0) * 60
end

-------------------------------------------------------------------------------
---Return input flow limit
---@return number --default 0
function ElectricSourcePrototype:getInputFlowLimit()
  if self.lua_prototype == nil then return 0 end
  return (self.lua_prototype.input_flow_limit or 0) * 60
end

-------------------------------------------------------------------------------
---Return output flow limit
---@return number --default 0
function ElectricSourcePrototype:getOutputFlowLimit()
  if self.lua_prototype == nil then return 0 end
  return (self.lua_prototype.output_flow_limit or 0) * 60
end

-------------------------------------------------------------------------------
---@class BurnerPrototype
BurnerPrototype = newclass(EnergySourcePrototype,function(base,lua_prototype, factory)
  EnergySourcePrototype.init(base, lua_prototype, factory)
end)

-------------------------------------------------------------------------------
---Return type
---@return string
function BurnerPrototype:getType()
  return "burner"
end

-------------------------------------------------------------------------------
---Return fuel categories
---@return table
function BurnerPrototype:getFuelCategories()
  if self.lua_prototype == nil then return {} end
  return self.lua_prototype.fuel_categories or {}
end

-------------------------------------------------------------------------------
---Return fuel item prototypes
---@return table
function BurnerPrototype:getFuelPrototypes()
  local filters = {}
  for fuel_category,_ in pairs(self:getFuelCategories()) do
    table.insert(filters, {filter="fuel-category", mode="or", invert=false,["fuel-category"]=fuel_category})
  end
  return Player.getItemPrototypes(filters)
end

-------------------------------------------------------------------------------
---Return first fuel item prototype
---@return LuaItemPrototype
function BurnerPrototype:getFirstFuelPrototype()
  local fuel_items = self:getFuelPrototypes()
  local first_fuel = nil
  for _,fuel_item in pairs(fuel_items) do
    if first_fuel == nil or fuel_item.name == "coal" then
      first_fuel = fuel_item
    end
  end
  return first_fuel
end

-------------------------------------------------------------------------------
---Return fuel prototype
---@return ItemPrototype
function BurnerPrototype:getFuelPrototype()
  local fuel = self.factory.fuel
  if fuel == nil then
    local first_fuel = self:getFirstFuelPrototype()
    fuel = first_fuel.name
  end
  return ItemPrototype(fuel)
end

-------------------------------------------------------------------------------
---Return fuel count
---@return table
function BurnerPrototype:getFuelCount()
  local factory_prototype = EntityPrototype(self.factory)
  local energy_consumption = factory_prototype:getEnergyConsumption()
  local factory_fuel = self:getFuelPrototype()
  if factory_fuel == nil then return nil end
  local burner_effectivity = self:getEffectivity()
  local fuel_value = factory_fuel:getFuelValue()
  local burner_count = energy_consumption/(fuel_value*burner_effectivity)
  return {type="item", name=factory_fuel:native().name, count=burner_count}
end

-------------------------------------------------------------------------------
---Return fuel count
---@return table
function BurnerPrototype:getJouleCount()
  local factory_prototype = EntityPrototype(self.factory)
  local energy_consumption = factory_prototype:getEnergyConsumption()
  local factory_fuel = self:getFuelPrototype()
  if factory_fuel == nil then return nil end
  local burner_effectivity = self:getEffectivity()
  ---1W/h = 3600J
  local joule_count = energy_consumption * burner_effectivity / 3600
  return {type="item", name=factory_fuel:native().name, count=joule_count, is_joule=true}
end

-------------------------------------------------------------------------------
---Return data
---@return table
function BurnerPrototype:toData()
  local data = {}
  data.emissions = self.lua_prototype.emissions
  data.effectivity = self.lua_prototype.effectivity
  data.fuel_inventory_size = self.lua_prototype.fuel_inventory_size
  data.burnt_inventory_size = self.lua_prototype.burnt_inventory_size
  data.fuel_categories = self.lua_prototype.fuel_categories
  data.valid = self.lua_prototype.valid
  return data
end

-------------------------------------------------------------------------------
---Return string
---@return string
function BurnerPrototype:toString()
  return game.table_to_json(self:toData())
end

-------------------------------------------------------------------------------
---@class FluidSourcePrototype
FluidSourcePrototype = newclass(EnergySourcePrototype,function(base, lua_prototype, factory)
  EnergySourcePrototype.init(base,lua_prototype, factory)
end)

-------------------------------------------------------------------------------
---Return type
---@return string
function FluidSourcePrototype:getType()
  return "fluid"
end

-------------------------------------------------------------------------------
---Return fuel fluid prototypes
---@return table
function FluidSourcePrototype:getFuelPrototypes()
  if self.lua_prototype ~= nil and self.lua_prototype.fluid_box ~= nil and self.lua_prototype.fluid_box.filter ~= nil then
    return {self.lua_prototype.fluid_box.filter}
  else
    local fuels = Player.getFluidFuelPrototypes()
    return fuels
  end
end

-------------------------------------------------------------------------------
---Return first fuel fluid prototype
---@return LuaFluidPrototype
function FluidSourcePrototype:getFirstFuelPrototype()
  local fuel_items = self:getFuelPrototypes()
  local first_fuel = nil
  for _,fuel_item in pairs(fuel_items) do
    if first_fuel == nil then
      first_fuel = fuel_item
    end
  end
  return first_fuel
end

-------------------------------------------------------------------------------
---Return fuel prototype
---@return FluidPrototype
function FluidSourcePrototype:getFuelPrototype()
  local fuel = self.factory.fuel
  if fuel == nil then
    local first_fuel = self:getFirstFuelPrototype()
    fuel = first_fuel.name
  end
  return FluidPrototype(fuel)
end

-------------------------------------------------------------------------------
---Return fluid usage per tick
---@return number --default 0
function FluidSourcePrototype:getFluidUsagePerTick()
  if self.lua_prototype == nil then return 0 end
  return self.lua_prototype.fluid_usage_per_tick or 0
end

-------------------------------------------------------------------------------
---Return fluid usage
---@return number --default 0
function FluidSourcePrototype:getFluidUsage()
  return self:getFluidUsagePerTick() * 60
end

-------------------------------------------------------------------------------
---Return burns fluid
---@return boolean
function FluidSourcePrototype:getBurnsFluid()
  if self.lua_prototype == nil then return false end
  return self.lua_prototype.burns_fluid or false
end

-------------------------------------------------------------------------------
---Return fluidbox
---@return table
function FluidSourcePrototype:getFluidbox()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.fluid_box
end

-------------------------------------------------------------------------------
---Return fuel count
---@return table
function FluidSourcePrototype:getFuelCount()
  local factory_prototype = EntityPrototype(self.factory)
  local energy_consumption = factory_prototype:getEnergyConsumption()
  local factory_fuel = self:getFuelPrototype()
  if factory_fuel == nil then return nil end
  local burner_effectivity = self:getEffectivity()
  if factory_prototype:getType() ~= "assembling-machine" and self.lua_prototype.fluid_usage_per_tick ~= nil and self.lua_prototype.fluid_usage_per_tick ~= 0 then
    local fluid_usage = self:getFluidUsagePerTick()*60
    local burner_count = fluid_usage
    local fuel_fluid = {type="fluid", name=factory_fuel:native().name, count=burner_count}
    return fuel_fluid
  elseif factory_prototype:getType() == "assembling-machine" then
    local fuel_value = factory_fuel:getFuelValue()
    local burner_count = energy_consumption*60/(fuel_value*burner_effectivity)
    local fuel_fluid = {type="fluid", name=factory_fuel:native().name, count=burner_count}
    return fuel_fluid
  else
    local fuel_value = factory_fuel:getFuelValue()
    local burner_count = energy_consumption/(fuel_value*burner_effectivity)
    local fuel_fluid = {type="fluid", name=factory_fuel:native().name, count=burner_count}
    return fuel_fluid
  end
end

-------------------------------------------------------------------------------
---@class VoidSourcePrototype
VoidSourcePrototype = newclass(EnergySourcePrototype,function(base, lua_prototype, factory)
  EnergySourcePrototype.init(base,lua_prototype, factory)
end)

-------------------------------------------------------------------------------
---Return type
---@return string
function VoidSourcePrototype:getType()
  return "void"
end

HeatSourcePrototype = newclass(EnergySourcePrototype,function(base, lua_prototype, factory)
  EnergySourcePrototype.init(base,lua_prototype, factory)
end)

-------------------------------------------------------------------------------
---Return type
---@return string
function HeatSourcePrototype:getType()
  return "heat"
end