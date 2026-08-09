--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. --]]

--! Options window used in the main menu and ingame.
class "UIOptions" (UIResizable)

---@type UIOptions
local UIOptions = _G["UIOptions"]

-- Colour definitions
local col = {
  bg             = Colours.PanelDefault,
  button         = Colours.PanelDefault,
  setting        = Colours.Setting,
  setting_active = Colours.SettingActive,
  scrollbar      = Colours.Scrollbar,
  disabled       = Colours.Disabled,
  title          = Colours.Title,
  caption        = Colours.Caption,
  textbox        = Colours.Textbox,
}

-- Private functions

-- Generate predefined resolutions the player can choose from; as well as
-- including the custom option at the bottom. Where UI scaling prevents a
-- resolution option from being selected, grey it out instead and move to
-- the bottom of the list.
local available_resolutions = function()
  local suggested_resolutions = {
    {text = "640x480 (4:3)",     width = 640,  height = 480  },
    {text = "800x600 (4:3)",     width = 800,  height = 600  },
    {text = "1024x768 (4:3)",    width = 1024, height = 768  },
    {text = "1280x960 (4:3)",    width = 1280, height = 960  },
    {text = "1600x1200 (4:3)",   width = 1600, height = 1200 },
    {text = "1920x1440 (4:3)",   width = 1920, height = 1440 },
    {text = "1280x1024 (5:4)",   width = 1280, height = 1024 },
    {text = "1280x720 (16:9)",   width = 1280, height = 720  },
    {text = "1366x768 (16:9)",   width = 1366, height = 768  },
    {text = "1600x900 (16:9)",   width = 1600, height = 900  },
    {text = "1920x1080 (16:9)",  width = 1920, height = 1080 },
    {text = "2560x1440 (16:9)",  width = 2560, height = 1440 },
    {text = "3840x2160 (16:9)",  width = 3840, height = 2160 },
    {text = "1280x800 (16:10)",  width = 1280, height = 800  },
    {text = "1440x900 (16:10)",  width = 1440, height = 900  },
    {text = "1680x1050 (16:10)", width = 1680, height = 1050 },
    {text = "1920x1200 (16:10)", width = 1920, height = 1200 },
  }

  local s = TheApp.config.ui_scale
  local enable_list, disable_list = {}, {}
  for _, opt in ipairs(suggested_resolutions) do
    local enabled = App.MIN_WINDOW_WIDTH * s <= opt.width and
        App.MIN_WINDOW_HEIGHT * s <= opt.height
    opt.disabled = not enabled
    opt.tooltip = opt.disabled and { _S.tooltip.options_window.resolution_unavailable }
    if enabled then
      enable_list[#enable_list + 1] = opt
    else
      disable_list[#disable_list + 1] = opt
    end
  end

  local res = enable_list
  -- Show custom button before disabled items
  res[#res + 1] = {
    text = _S.options_window.custom_resolution, custom = true
  }

  for i = 1, #disable_list do
    res[#res + 1] = disable_list[i]
  end

  return res
end

local available_ui_scales = function()
  local res = {}
  local s = 1
  while s * App.MIN_WINDOW_WIDTH <= TheApp.config.width and
      s * App.MIN_WINDOW_HEIGHT <= TheApp.config.height do
    res[#res + 1] = { text = tostring(s * 100) .. '%', scale = s }
    s = s + 1
  end
  return res
end

local available_cursor_scales = function()
  local res = {}
  for s = 1, 4 do
    res[#res + 1] = { text = tostring(s * 100) .. '%', scale = s }
  end
  return res
end

local available_autosave_frequency = function()
  local options = {
    { text = _S.autosave_frequency.monthly, value = 1, tooltip = { _S.tooltip.autosave_frequency.monthly } },
    { text = _S.autosave_frequency.weekly, value = 2, tooltip = { _S.tooltip.autosave_frequency.weekly } },
    { text = _S.autosave_frequency.daily, value = 3, tooltip = { _S.tooltip.autosave_frequency.daily } },
  }
  return options
end

local current_autosave_frequency = function()
  local value = TheApp.config.autosave_frequency
  local options = available_autosave_frequency()
  for _, option in pairs(options) do
    if option.value == value then
      return option.text
    end
  end
  return ""
end

function UIOptions:UIOptions(ui, mode)
  local width = 620
  local height = 330
  self:UIResizable(ui, width, height, col.bg)

  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options"
  self.app = app
  self.strings_ref = "options_window"
  self.custom_back_button = true
  self.extra_height = 0

  -- Tracks the current position of the object
  self._current_option_index = 1
  self.column_count = 1

  self.entry_list = {
    { name = "fullscreen", func = self.buttonFullscreen },
    { name = "resolution", func = self.dropdownResolution, raised = true },
    { name = "ui_scale", func = self.dropdownUIScale, raised = true },
    { name = "cursor_scale", func = self.dropdownCursorScale, raised = true },
    { name = "capture_mouse", func = self.buttonMouseCapture },

    { name = "language", func = self.dropdownLanguage, raised = true, new_column = true },
    { name = "scroll_speed", func = self.buttonScrollSpeed, raised = true },
    { name = "shift_scroll_speed", func = self.buttonShiftScrollSpeed, raised = true },
    { name = "zoom_speed", func = self.buttonZoomSpeed, raised = true },
    { name = "autosave_frequency", func = self.dropdownAutosaveFrequency, raised = true },
  }
  if app:isUpdateCheckAvailable() then
    table.insert(self.entry_list, 1, { name = "check_for_updates", func = self.buttonUpdates })
  end
  self:buildDialog()

  -- Post dialog build
  if app:isUpdateCheckAvailable() then -- The first column is now longer than the second
    self:_getOptionYPos()
  end
  -- Now set the resolution button label and the ui scale button state
  self:processWindowResizeEvent()
  self.buttons.ui_scale:setLabel(app.config.ui_scale * 100 .. "%")
  self.buttons.cursor_scale:setLabel(app.config.cursor_scale * 100 .. "%")

  self:checkForAvailableLanguages()
  -- Get language name in the language to normalize display.
  -- If it doesn't exist, keep displaying the current config option.
  local lang = self.app.strings:getLanguageNames(app.config.language)
  if lang then
    self.buttons.language:setLabel(lang[1])
  end

  self.buttons.autosave_frequency:setLabel(current_autosave_frequency())

  local lower_row_y_pos = self:_getOptionYPos()
  -- "Customise" button
  self:addBevelPanel(self.x_pos[1], lower_row_y_pos, self.btn_width, self.big_button_height, col.button):setLabel(_S.options_window.customise)
    :makeButton(0, 0, self.btn_width, self.big_button_height, nil, self.buttonCustomise)
    :setTooltip(_S.tooltip.options_window.customise_button)

  -- "Folders" button
  self:addBevelPanel(self.x_pos[2], lower_row_y_pos, self.btn_width, self.big_button_height, col.button):setLabel(_S.options_window.folder)
    :makeButton(0, 0, self.btn_width, self.big_button_height, nil, self.buttonFolder)
    :setTooltip(_S.tooltip.options_window.folder_button)

  -- "Hotkeys" button
  self:addBevelPanel(self.x_pos[3], lower_row_y_pos, self.btn_width, self.big_button_height, col.button):setLabel(_S.options_window.hotkey)
    :makeButton(0, 0, self.btn_width, self.big_button_height, nil, self.buttonHotkey)
    :setTooltip(_S.tooltip.options_window.hotkey)

  -- "Sound Options" button
  self:addBevelPanel(self.x_pos[4], lower_row_y_pos, self.btn_width, self.big_button_height, col.button):setLabel(_S.options_window.sound)
    :makeButton(0, 0, self.btn_width, self.big_button_height, nil, self.buttonSound)
    :setTooltip(_S.tooltip.options_window.sound)

  -- "Back" button
  -- Give some extra space to back button. This is fine as long as it is the last button in the options menu
  local back_button_y_pos = self:_getOptionYPos() + 20
  local back_button_width = self.label_width + 25 + self.btn_width
  self:addBevelPanel(150, back_button_y_pos, back_button_width, self.big_button_height, col.button)
    :setLabel(_S.options_window.back)
    :makeButton(0, 0, back_button_width, self.big_button_height, nil, self.buttonBack)
    :setTooltip(_S.tooltip.options_window.back)
end

-- Stubs for backward compatibility
local --[[persistable:options_window_language_button]] function language_button() end
local --[[persistable:options_width_textbox_reset]] function width_textbox_reset() end
local --[[persistable:options_height_textbox_reset]] function height_textbox_reset() end

function UIOptions:checkForAvailableLanguages()
  local app = self.app
  -- Set up list of available languages
  local langs, c = {}, 1
  for _, lang in pairs(app.strings.languages) do
    local font = app.strings:getFont(lang)
    local eng_name = app.strings.languages_english[lang]
    c = c + 1
    -- If freetype support and a unicode font setting are not present then
    -- languages not supported by the builtin font are named in English and cannot be selected
    if app.gfx:hasLanguageFont(font) then
      font = font and app.gfx:loadLanguageFont(font, app.gfx:loadSpriteTable("QData", "Font01V"), { apply_ui_scale = true })
      langs[#langs + 1] = { text = lang, name = lang, font = font, disabled = false,
        tooltip = { _S.tooltip.options_window.language_dropdown_item:format(eng_name) }
      }
    else
      langs[#langs + 1] = { text = eng_name, name = lang, font = self.builtin_font, disabled = true,
        tooltip = { _S.tooltip.options_window.language_dropdown_no_font }
      }
    end
  end
  self.available_languages = langs
end

function UIOptions:dropdownLanguage(activate)
  if activate and not self.language_dropdown then
    self:dropdownResolution(false)
    self:dropdownUIScale(false)
    self:dropdownCursorScale(false)
    self:dropdownAutosaveFrequency(false)
    self.language_dropdown = UIDropdown(self.ui, self, self.buttons.language, self.available_languages, self.selectLanguage, col.setting_active, col.scrollbar, col.disabled)
    self:addWindow(self.language_dropdown)
  else
    self.buttons.language:setToggleState(false)
    if self.language_dropdown then
      self.language_dropdown:close()
      self.language_dropdown = nil
    end
  end
end

function UIOptions:selectLanguage(number)
  local lang = self.app.strings.languages_english[self.available_languages[number].name]
  local app = self.ui.app
  app.config.language = (lang)
  app:initLanguage()
  app:saveConfig()
end

function UIOptions:dropdownResolution(activate)
  if activate and not self.resolution_dropdown then
    self.available_resolutions = available_resolutions()
    self:dropdownLanguage(false)
    self:dropdownUIScale(false)
    self:dropdownCursorScale(false)
    self:dropdownAutosaveFrequency(false)
    self.resolution_dropdown = UIDropdown(self.ui, self, self.buttons.resolution, self.available_resolutions, self.selectResolution, col.setting_active, col.scrollbar, col.disabled)
    self:addWindow(self.resolution_dropdown)
  else
    self.buttons.resolution:setToggleState(false)
    if self.resolution_dropdown then
      self.resolution_dropdown:close()
      self.resolution_dropdown = nil
    end
  end
end

function UIOptions:selectResolution(number)
  local res = self.available_resolutions[number]

  local callback = --[[persistable:options_resolution_callback]] function(width, height)
    if not self.ui:changeResolution(width, height) then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err))
    end
  end

  if res.custom then
    self.buttons.resolution:setLabel(self.ui.app.config.width .. "x" .. self.ui.app.config.height)
    self.ui:addWindow(UIResolution(self.ui, callback))
  else
    callback(res.width, res.height)
  end
end

function UIOptions:dropdownUIScale(activate)
  if activate and not self.scale_ui_dropdown then
    self.available_ui_scales = available_ui_scales()
    self:dropdownLanguage(false)
    self:dropdownResolution(false)
    self:dropdownCursorScale(false)
    self:dropdownAutosaveFrequency(false)
    self.scale_ui_dropdown = UIDropdown(self.ui, self, self.buttons.ui_scale, self.available_ui_scales, self.selectUIScale, col.setting_active, col.scrollbar)
    self:addWindow(self.scale_ui_dropdown)
  else
    self.buttons.ui_scale:setToggleState(false)
    if self.scale_ui_dropdown then
      self.scale_ui_dropdown:close()
      self.scale_ui_dropdown = nil
    end
  end
end

function UIOptions:dropdownCursorScale(activate)
  if activate and not self.cursor_scale_dropdown then
    self.available_cursor_scales = available_cursor_scales()
    self:dropdownLanguage(false)
    self:dropdownResolution(false)
    self:dropdownUIScale(false)
    self:dropdownAutosaveFrequency(false)
    self.cursor_scale_dropdown = UIDropdown(self.ui, self, self.buttons.cursor_scale, self.available_cursor_scales, self.selectCursorScale, col.setting_active, col.scrollbar)
    self:addWindow(self.cursor_scale_dropdown)
  else
    self.buttons.cursor_scale:setToggleState(false)
    if self.cursor_scale_dropdown then
      self.cursor_scale_dropdown:close()
      self.cursor_scale_dropdown = nil
    end
  end
end

-- Check if UI scale scale button should be enabled, and update the tooltip.
function UIOptions:updateUIScaleAvailabilityState()
  local ui_scales_available = #available_ui_scales() > 1
  self.buttons.ui_scale:enable(ui_scales_available)
  self.buttons.ui_scale:setTooltip(ui_scales_available and
      _S.tooltip.options_window.select_ui_scale or
      _S.tooltip.options_window.ui_scale_unavailable)
end

function UIOptions:selectUIScale(number)
  local res = self.available_ui_scales[number]
  TheApp.config.ui_scale = res.scale
  TheApp:saveConfig()
  self.buttons.ui_scale:setLabel(res.text)
  self.ui:changeResolution(TheApp.config.width, TheApp.config.height)
  self.ui:onChangeResolution()
  TheApp.gfx:onChangeUIScale()
end

function UIOptions:selectCursorScale(number)
  local res = self.available_cursor_scales[number]
  TheApp.config.cursor_scale = res.scale
  TheApp:saveConfig()
  self.buttons.cursor_scale:setLabel(res.text)
end

function UIOptions:dropdownAutosaveFrequency(activate)
  if activate and not self.autosave_dropdown then
    self:dropdownLanguage(false)
    self:dropdownResolution(false)
    self:dropdownUIScale(false)
    self:dropdownCursorScale(false)
    self.autosave_dropdown = UIDropdown(self.ui, self, self.buttons.autosave_frequency, available_autosave_frequency(), self.selectAutosaveFrequency, col.setting_active, col.scrollbar)
    self:addWindow(self.autosave_dropdown)
  else
    self.buttons.autosave_frequency:setToggleState(false)
    if self.autosave_dropdown then
      self.autosave_dropdown:close()
      self.autosave_dropdown = nil
    end
  end
end

function UIOptions:selectAutosaveFrequency(number)
  local option = available_autosave_frequency()[number]
  self.buttons.autosave_frequency:setLabel(option.text)
  TheApp.config.autosave_frequency = option.value
  TheApp:saveConfig()
end

--! Changes check for update setting to on/of
function UIOptions:toggleUpdateCheck()
  self.ui.app.config.check_for_updates = not self.ui.app.config.check_for_updates
  self.ui.app:saveConfig()
end

--! Function handles button toggle of checking for updates
function UIOptions:buttonUpdates()
  self:toggleUpdateCheck()
  local new_updates_string = self.ui.app.config.check_for_updates and
      _S.options_window.option_enabled or _S.options_window.option_disabled
  self.buttons.check_for_updates:setLabel(new_updates_string)
end

function UIOptions:buttonFullscreen()
  if not self.ui:toggleFullscreen() then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err))
      self.buttons.fullscreen:toggle()
  end
  self.buttons.fullscreen:setLabel(self.ui.app.fullscreen and _S.options_window.option_on or _S.options_window.option_off)
end

function UIOptions:buttonMouseCapture()
  local app = self.ui.app
  app.config.capture_mouse = not app.config.capture_mouse
  app:saveConfig()
  self.buttons.capture_mouse:setLabel(app.config.capture_mouse and _S.options_window.option_on or _S.options_window.option_off)
end

function UIOptions:buttonCustomise()
  local window = UICustomise(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonFolder()
  local window = UIFolder(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonHotkey()
  local window = UIHotkeyAssign(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonSound()
  local window = UISoundSettings(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonScrollSpeed()
  local callback = function(scrollspeed_number)
    self.buttons.scroll_speed:setLabel(tostring(scrollspeed_number)):setToggleState(false)
  end

  self.ui:addWindow(UIScrollSpeed(self.ui, callback))
end

function UIOptions:buttonBack()
  self:close()
end

function UIOptions:buttonShiftScrollSpeed()
  local callback = function(shift_scrollspeed_number)
    self.buttons.shift_scroll_speed:setLabel(tostring(shift_scrollspeed_number)):setToggleState(false)
  end

  self.ui:addWindow(UIShiftScrollSpeed(self.ui, callback))
end

function UIOptions:buttonBack()
  self:close()
end

function UIOptions:buttonZoomSpeed()
  local callback = function(zoomspeed_number)
    self.buttons.zoom_speed:setLabel(tostring(zoomspeed_number)):setToggleState(false)
  end

  self.ui:addWindow( UIZoomSpeed(self.ui, callback) )
end

function UIOptions:onChangeResolution()
  self:processWindowResizeEvent()
  self:setDefaultPosition(0.5, 0.25)
end

-- Handle required button changes from a window resize event from the user (via UI
-- or adjusting window boundaries)
function UIOptions:processWindowResizeEvent()
  local config = self.ui.app.config
  self:updateUIScaleAvailabilityState()
  self.buttons.resolution:setLabel(config.width .. "x" ..
      self.ui.app.config.height)
end

function UIOptions:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end

--! A custom resolution selection window
class "UIResolution" (UIResizable)

---@type UIResolution
local UIResolution = _G["UIResolution"]

function UIResolution:UIResolution(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

  local app = ui.app
  self.modal_class = "resolution"
  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"

  self.callback = callback

  -- Window parts definition
  -- Title
  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.options_window.resolution)
    .lowered = true

  -- Textboxes
  self:addBevelPanel(20, 40, 80, 20, col.caption, col.bg, col.bg):setLabel(_S.options_window.width)
  self.width_textbox = self:addBevelPanel(100, 40, 80, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.options_window.width)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(app.config.width))

  self:addBevelPanel(20, 60, 80, 20, col.caption, col.bg, col.bg):setLabel(_S.options_window.height)
  self.height_textbox = self:addBevelPanel(100, 60, 80, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.options_window.height)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(app.config.height))

  -- Apply and cancel
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.options_window.cancel)
end

function UIResolution:cancel()
  self:close(false)
end

function UIResolution:ok()
  local width, height = tonumber(self.width_textbox.text) or 0, tonumber(self.height_textbox.text) or 0
  local s = TheApp.config.ui_scale
  local min_w = App.MIN_WINDOW_WIDTH * s
  local min_h = App.MIN_WINDOW_HEIGHT * s
  if width < min_w or height < min_h then
    local err = {_S.errors.minimum_screen_size:format(min_w, min_h)}
    self.ui:addWindow(UIInformation(self.ui, err))
  elseif width > 3000 or height > 2000 then
    self.ui:addWindow(UIConfirmDialog(self.ui, false,
      _S.confirmation.maximum_screen_size,
      --[[persistable:maximum_screen_size_confirm_dialog]]function()
      self:close(true)
      self:close(false)
      end
      ))
  else
    self:close(true)
  end
end

function UIResolution:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--! Closes the resolution dialog
--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
function UIResolution:close(ok)
  UIResizable.close(self)
  if ok and self.callback then
    self.callback(tonumber(self.width_textbox.text) or 0, tonumber(self.height_textbox.text) or 0)
  end
end

--! A window for setting the scroll speed of the camera.
class "UIScrollSpeed" (UIResizable)

---@type UIScrollSpeed
local UIScrollSpeed = _G["UIScrollSpeed"]

function UIScrollSpeed:UIScrollSpeed(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.scrollspeed_temp = 2

  self.callback = callback

  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.options_window.scroll_speed).lowered = true

  self:addBevelPanel(20, 50, 90, 20, col.caption, col.bg, col.bg):setLabel(_S.options_window.scroll_speed)
  --
  self.scrollspeed_textbox = self:addBevelPanel(110, 50, 70, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.options_window.scroll_speed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(self.ui.app.config.scroll_speed))

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply_scrollspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.options_window.cancel_scrollspeed)
end

function UIScrollSpeed:ok()
  self.scrollspeed_temp = tonumber(self.scrollspeed_textbox.text) or 2

  if self.scrollspeed_temp < 1 then
    self.scrollspeed_temp = 1
  elseif self.scrollspeed_temp > 10 then
    self.scrollspeed_temp = 10
  end

  self:close(true)
end

function UIScrollSpeed:cancel()
  self:close(false)
end

function UIScrollSpeed:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
function UIScrollSpeed:close(ok)
  UIResizable.close(self)

  if ok then
    self.scrollspeed_textbox.text = self.scrollspeed_temp or 2
    self.ui.app.config.scroll_speed = self.scrollspeed_textbox.text
    self.callback(self.scrollspeed_textbox.text)
  else
    self.callback(self.ui.app.config.scroll_speed)
  end
end


--! A window for setting the scroll speed of the camera while pressing the SHIFT key..
class "UIShiftScrollSpeed" (UIResizable)

---@type UIShiftScrollSpeed
local UIShiftScrollSpeed = _G["UIShiftScrollSpeed"]

function UIShiftScrollSpeed:UIShiftScrollSpeed(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.shift_scrollspeed_temp = 4

  self.callback = callback

  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.options_window.shift_scroll_speed).lowered = true

  self:addBevelPanel(20, 50, 120, 20, col.caption, col.bg, col.bg):setLabel(_S.options_window.shift_scroll_speed)
  --
  self.shift_scrollspeed_textbox = self:addBevelPanel(140, 50, 40, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.options_window.shift_scroll_speed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(self.ui.app.config.shift_scroll_speed))

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply_shift_scrollspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.options_window.cancel_shift_scrollspeed)
end

function UIShiftScrollSpeed:ok()
  self.shift_scrollspeed_temp = tonumber(self.shift_scrollspeed_textbox.text) or 4

  if self.shift_scrollspeed_temp < 1 then
    self.shift_scrollspeed_temp = 1
  elseif self.shift_scrollspeed_temp > 10 then
    self.shift_scrollspeed_temp = 10
  end

  self:close(true)
end

function UIShiftScrollSpeed:cancel()
  self:close(false)
end

function UIShiftScrollSpeed:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
function UIShiftScrollSpeed:close(ok)
  UIResizable.close(self)

  if ok then
    self.shift_scrollspeed_textbox.text = self.shift_scrollspeed_temp or 4
    self.ui.app.config.shift_scroll_speed = self.shift_scrollspeed_textbox.text
    self.callback(self.shift_scrollspeed_textbox.text)
  else
    self.callback(self.ui.app.config.shift_scroll_speed)
  end
end

--! Window to set the zoom speed of the scroll wheel while in-game.
class "UIZoomSpeed" (UIResizable)

---@type UIZoomSpeed
local UIZoomSpeed = _G["UIZoomSpeed"]

function UIZoomSpeed:UIZoomSpeed(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.zoomspeed_temp = 80

  self.callback = callback

  --
  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.options_window.zoom_speed).lowered = true

  --
  self:addBevelPanel(20, 50, 90, 20, col.caption, col.bg, col.bg):setLabel(_S.options_window.zoom_speed)

  --
  self.zoomspeed_textbox = self:addBevelPanel(110, 50, 70, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.options_window.zoom_speed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText( tostring(self.ui.app.config.zoom_speed) )

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply_zoomspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.options_window.cancel_zoomspeed)
end

function UIZoomSpeed:ok()
  self.zoomspeed_temp = tonumber( self.zoomspeed_textbox.text ) or 80

  if self.zoomspeed_temp < 10 then
    self.zoomspeed_temp = 10
  elseif self.zoomspeed_temp > 1000 then
    self.zoomspeed_temp = 1000
  end

  self:close(true)
end

function UIZoomSpeed:cancel()
  self:close(false)
end

function UIZoomSpeed:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
function UIZoomSpeed:close(ok)
  UIResizable.close(self)

  if ok then
    self.zoomspeed_textbox.text = self.zoomspeed_temp or 2
    self.ui.app.config.zoom_speed = self.zoomspeed_textbox.text
    self.callback(self.zoomspeed_textbox.text)
  else
    self.callback(self.ui.app.config.zoom_speed)
  end
end
