--[[ Copyright (c) 2013 Mark (Mark L) Lawlor

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

--! Customise window used in the main menu and ingame.
class "UIFolder" (UIResizable)

---@type UIFolder
local UIFolder = _G["UIFolder"]

local col = {
   bg = Colours.PanelDefault,

   setting = Colours.Setting,
   title = Colours.Title,
   caption = Colours.Caption,
   button = Colours.PanelDefault
}

function UIFolder:UIFolder(ui, mode)
  self:UIResizable(ui, 420, 240, col.bg)

  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "folders"
  self.strings_ref = "folders_window"
  self.app = app
  self._current_option_index = 1
  self.btn_width = 240
  self.autoclip = true

  local built_in = app.gfx:loadMenuFont()
  self.built_in_font = built_in
  self.entry_list = {
    -- Location of original game
    { name = "theme_hospital_install", func = self.buttonBrowseForTHInstall, raised = true },
    -- Location of font file
    { name = "unicode_font", func = self.buttonBrowseForFont, raised = true,
        default_string = "not_specified" },
    -- Location saves alternative
    { name = "savegames", func = self.buttonBrowseForSavegames, raised = true, default_string = "not_specified",
        default_value = app:getDefaultSavegameDir(), reset_func = self.resetSavegameDir },
    -- location for screenshots
    { name = "screenshots", func = self.buttonBrowseForScreenshots, raised = true, default_string = "not_specified",
        default_value = app:getDefaultScreenshotsDir(), reset_func = self.resetScreenshotDir },
    -- location for music files
    { name = "audio_music", func = self.buttonBrowseForAudio_music, raised = true, default_string = "not_specified",
        reset_func = self.resetMusicDir },
  }

  self:buildDialog()
end

function UIFolder:resetSavegameDir()
  local app = TheApp
  local default_savegame_dir = app:getDefaultSavegameDir()
  local tooltip_saves = _S.tooltip.folders_window.browse_saves:format(default_savegame_dir)
  app.config.savegames = nil
  app:saveConfig()
  app:initSavegameDir()
  self.buttons.savegames:setLabel(default_savegame_dir, self.built_in_font)
  self.buttons.savegames:setTooltip(tooltip_saves)
end

function UIFolder:resetScreenshotDir()
  local app = TheApp
  local default_screenshots_dir = app:getDefaultScreenshotsDir()
  local tooltip_screenshots = _S.tooltip.folders_window.browse_screenshots:format(default_screenshots_dir)
  app.config.screenshots = nil
  app:saveConfig()
  app:initScreenshotsDir()
  self.buttons.screenshots:setLabel(default_screenshots_dir, self.built_in_font)
  self.buttons.screenshots:setTooltip(tooltip_screenshots)
end

function UIFolder:resetMusicDir()
  local app = TheApp
  local label_music = _S.tooltip.folders_window.not_specified
  local tooltip_music = _S.tooltip.folders_window.not_specified
  app.config.audio_music = nil
  app:saveConfig()
  app.audio:init()
  self.buttons.audio_music:setLabel(label_music, self.built_in_font)
  self.buttons.audio_music:setTooltip(tooltip_music)
end

function UIFolder:buttonBrowseForFont()
  local browser = UIChooseFont(self.ui, self.mode)
  self.ui:addWindow(browser)
end

function UIFolder:buttonBrowseForSavegames()
  local app = TheApp
  local old_path = app.config.savegames
  local function callback(path)
    if old_path ~= path then
      app.config.savegames = path
      app:saveConfig()
      app:initSavegameDir()
      self.saves_panel:setLabel(app.config.savegames, self.built_in_font)
    end
  end
  local browser = UIDirectoryBrowser(self.ui, self.mode, _S.folders_window.savegames_location, "DirTreeNode", callback)
  self.ui:addWindow(browser)
end

function UIFolder:buttonBrowseForTHInstall()
  local function callback(path)
    local app = TheApp
    app.config.theme_hospital_install = path
    app:saveConfig()
    app:reset()
  end
  local browser = UIDirectoryBrowser(self.ui, self.mode, _S.folders_window.th_data_browse, "InstallDirTreeNode", callback)
  self.ui:addWindow(browser)
end

function UIFolder:buttonBrowseForScreenshots()
  local app = TheApp
  local old_path = app.config.screenshots
  local function callback(path)
    if old_path ~= path then
      app.config.screenshots = path
      app:saveConfig()
      app:initScreenshotsDir()
      self.screenshots_panel:setLabel(app.config.screenshots, self.built_in_font)
    end
  end
  local browser = UIDirectoryBrowser(self.ui, self.mode, _S.folders_window.screenshots_location, "DirTreeNode", callback)
  self.ui:addWindow(browser)
end

function UIFolder:buttonBrowseForAudio_music()
  local function callback(path)
    local app = TheApp
    app.config.audio_music = path
    app:saveConfig()
    app.audio:init()
    self.music_panel:setLabel(app.config.audio_music, self.built_in_font)
  end
  local browser = UIDirectoryBrowser(self.ui, self.mode, _S.folders_window.music_location, "DirTreeNode", callback)
  self.ui:addWindow(browser)
end

function UIFolder:buttonBack()
  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIFolder:close()
  UIResizable.close(self)
  if self.mode == "menu"  then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end
