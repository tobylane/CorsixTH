-- ldoc --testing --unqualified --config scripts/config.ld ..
-- -l scripts/ will use the template scripts/ldoc.ltp
-- testing = No timestamp, unqualified = no folder/package names in sidebar
-- https://lunarmodules.github.io/ldoc/manual/manual.md.html
project = 'CorsixTH'
description = 'The lua files of the CorsixTH game'
full_description = 'A reimplementation of the 1997 Bullfrog business sim Theme Hospital. ' ..
  'As well as faithfully recreating the original, CorsixTH adds support for modern ' ..
  'operating systems (Windows, macOS, Linux and BSD), high resolutions and much more.'
ignore = true
file = { 'CorsixTH/Lua/', 'CorsixTH/CorsixTH.lua',
  exclude = { 'CorsixTH/Lua/languages', 'CorsixTH/Lua/config_finder.lua', 'CorsixTH/Lua/debug_script.lua' } }
kind_names = { topic = 'Manual', module = 'Files' }
readme = 'Readme.md'
format = 'markdown'
icon = 'scripts/logo.png'
sort = true -- Alphabetical order
favicon = '../CorsixTH/CorsixTH.ico'
one = true -- use a one-column layout
unqualified = true
template = true -- style and template in config folder
wrap = true
function custom_display_name_handler(item, default_handler)
  item.package = 'CorsixTH'
  item.display_name = item.name:sub(23,-1)
  return default_handler(item)
end
-- Ldoc puts CorsixTH/Lua in all links and names, postprocess_html needed
-- only used here? https://github.com/mooffie/mc/blob/luatip/src/lua/doc/ldoc/config.ld#L430
function postprocess_html(source, item)
  if item and item.display_name then
    source:gsub(item.name, item.display_name) end
  return source
end