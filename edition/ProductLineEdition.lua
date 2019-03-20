-------------------------------------------------------------------------------
-- Class to build product edition dialog
--
-- @module ProductLineEdition
-- @extends #Dialog
--

ProductLineEdition = setclass("HMProductLineEdition", AbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#ProductLineEdition] onInit
--
-- @param #Controller parent parent controller
--
function ProductLineEdition.methods:onInit(parent)
  self.panelCaption = ({"helmod_result-panel.tab-title-production-line"})
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#ProductLineEdition] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function ProductLineEdition.methods:onOpen(event, action, item, item2, item3)
  local player_gui = Player.getGlobalGui()
  local close = true
  if player_gui.guiProductLast == nil or player_gui.guiProductLast ~= item then
    close = false
  end
  player_gui.guiProductLast = item
  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#ProductLineEdition] onClose
--
function ProductLineEdition.methods:onClose()
  local player_gui = Player.getGlobalGui()
  player_gui.guiProductLast = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#ProductLineEdition] getInfoPanel
--
function ProductLineEdition.methods:getInfoPanel()
  local panel = self:getPanel()
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  local info_panel = ElementGui.addGuiFrameV(panel, "info", helmod_frame_style.panel)
  info_panel.style.horizontally_stretchable = true
  return info_panel
end

-------------------------------------------------------------------------------
-- Get or create output panel
--
-- @function [parent=#ProductLineEdition] getOutputPanel
--
function ProductLineEdition.methods:getOutputPanel()
  local panel = self:getPanel()
  if panel["output"] ~= nil and panel["output"].valid then
    return panel["output"]
  end
  local info_panel = ElementGui.addGuiFrameV(panel, "output", helmod_frame_style.panel)
  info_panel.style.horizontally_stretchable = true
  return info_panel
end

-------------------------------------------------------------------------------
-- Get or create input panel
--
-- @function [parent=#ProductLineEdition] getInputPanel
--
function ProductLineEdition.methods:getInputPanel()
  local panel = self:getPanel()
  if panel["input"] ~= nil and panel["input"].valid then
    return panel["input"]
  end
  local info_panel = ElementGui.addGuiFrameV(panel, "input", helmod_frame_style.panel)
  info_panel.style.horizontally_stretchable = true
  return info_panel
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#ProductLineEdition] after_open
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:after_open(event, action, item, item2, item3)
  self:getInfoPanel()
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#ProductLineEdition] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:onUpdate(event, action, item, item2, item3)
  self:updateInfo(item, item2, item3)
  self:updateInput(item, item2, item3)
  self:updateOutput(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductLineEdition] updateInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:updateInfo(item, item2, item3)
  Logging:debug(self:classname(), "updateInfo", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug(self:classname(), "model:", model)
  -- data
  local info_panel = self:getInfoPanel()
  info_panel.clear()
  -- info panel
  local block_scroll = ElementGui.addGuiScrollPane(info_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(block_scroll, "scroll_block", "height")
  local block_table = ElementGui.addGuiTable(block_scroll,"output-table",2)

  ElementGui.addGuiLabel(block_table, "label-owner", ({"helmod_result-panel.owner"}))
  ElementGui.addGuiLabel(block_table, "value-owner", model.owner)

  ElementGui.addGuiLabel(block_table, "label-share", ({"helmod_result-panel.share"}))

  local tableAdminPanel = ElementGui.addGuiTable(block_table, "table" , 9)
  local model_read = false
  if model.share ~= nil and  bit32.band(model.share, 1) > 0 then model_read = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=read="..model.id, model_read, nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self:classname().."=share-model-read", "R", nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))

  local model_write = false
  if model.share ~= nil and  bit32.band(model.share, 2) > 0 then model_write = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=write="..model.id, model_write, nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self:classname().."=share-model-write", "W", nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))

  local model_delete = false
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=delete="..model.id, model_delete, nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self:classname().."=share-model-delete", "X", nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))

  local count_block = Model.countBlocks()
  if count_block > 0 then
    -- info panel
    ElementGui.addGuiLabel(block_table, "label-power", ({"helmod_label.electrical-consumption"}))
    if model.summary ~= nil then
      ElementGui.addGuiLabel(block_table, "power", Format.formatNumberKilo(model.summary.energy or 0, "W"))
    end
  end

end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductLineEdition] updateInput
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:updateInput(item, item2, item3)
  Logging:debug(self:classname(), "updateInput", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug("ProductionBlockTab", "model:", model)
  -- data
  local blockId = globalGui.currentBlock or "new"

  local countRecipes = Model.countBlockRecipes(blockId)

  local element_panel = self:getInputPanel()
  element_panel.clear()
  -- input panel
  local input_panel = ElementGui.addGuiFrameV(element_panel, "input", helmod_frame_style.panel, ({"helmod_common.input"}))
  ElementGui.setStyle(input_panel, "block_element", "height")
  local input_scroll = ElementGui.addGuiScrollPane(input_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(input_scroll, "scroll_block_element", "height")

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]
    -- input panel
    local input_table = ElementGui.addGuiTable(input_scroll,"input-table",6)
    if element.ingredients ~= nil then
      for r, lua_product in pairs(element.ingredients) do
        local ingredient = Product.load(lua_product).new()
        ingredient.count = lua_product.count
        if element.count > 1 then
          ingredient.limit_count = lua_product.count / element.count
        end
        ElementGui.addCellElement(input_table, ingredient, self:classname().."=product-selected=ID="..element.id.."="..ingredient.name.."=", false, "tooltip.ingredient", nil)
      end
    end

  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductLineEdition] updateOutput
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:updateOutput(item, item2, item3)
  Logging:debug(self:classname(), "updateOutput", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug("ProductionBlockTab", "model:", model)
  -- data
  local blockId = globalGui.currentBlock or "new"

  local countRecipes = Model.countBlockRecipes(blockId)

  local element_panel = self:getOutputPanel()
  element_panel.clear()
  -- ouput panel
  local output_panel = ElementGui.addGuiFrameV(element_panel, "output", helmod_frame_style.panel, ({"helmod_common.output"}))
  output_panel.style.horizontally_stretchable = true
  ElementGui.setStyle(output_panel, "block_element", "height")
  local output_scroll = ElementGui.addGuiScrollPane(output_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(output_scroll, "scroll_block_element", "height")

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]

    -- ouput panel
    local output_table = ElementGui.addGuiTable(output_scroll,"output-table",6)
    if element.products ~= nil then
      for r, lua_product in pairs(element.products) do
        local product = Product.load(lua_product).new()
        product.count = lua_product.count
        if element.count > 1 then
          product.limit_count = lua_product.count / element.count
        end
        if bit32.band(lua_product.state, 1) > 0 then
          if element.by_factory == true then
            ElementGui.addCellElement(output_table, product, self:classname().."=product-selected=ID="..element.id.."="..product.name.."=", false, "tooltip.product", nil)
          else
            ElementGui.addCellElement(output_table, product, self:classname().."=product-edition=ID="..element.id.."="..product.name.."=", true, "tooltip.edit-product", self.color_button_edit)
          end
        end
        if bit32.band(lua_product.state, 2) > 0 and bit32.band(lua_product.state, 1) == 0 then
          ElementGui.addCellElement(output_table, product, self:classname().."=product-selected=ID="..element.id.."="..product.name.."=", true, "tooltip.rest-product", self.color_button_rest)
        end
        if lua_product.state == 0 then
          ElementGui.addCellElement(output_table, product, self:classname().."=product-selected=ID="..element.id.."="..product.name.."=", false, "tooltip.other-product", nil)
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#ProductLineEdition] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  local model = Model.getModel()
  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "product-update" then
      local products = {}
      local input_panel = self:getInfoPanel()["table-header"]
      local quantity = ElementGui.getInputNumber(input_panel["quantity"])

      ModelBuilder.updateProduct(item, item2, quantity)
      ModelCompute.update()
      self:close()
    end
    if action == "product-reset" then
      local products = {}
      local inputPanel = self:getInfoPanel()["table-header"]

      ModelBuilder.updateProduct(item, item2, nil)
      ModelCompute.update()
      self:close()
    end
    if action == "element-select" then
      local input_panel = self:getToolPanel()["table-header"]
      local belt_count = ElementGui.getInputNumber(input_panel["quantity"])
      local belt_speed = EntityPrototype.load(item).getBeltSpeed()

      local output_panel = self:getInfoPanel()["table-header"]
      ElementGui.setInputNumber(output_panel["quantity"], belt_count * belt_speed * Product.belt_ratio)
    end
  end
end
