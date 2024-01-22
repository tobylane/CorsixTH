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
kind_names = { topic = 'Manual', module = 'Libraries' }
readme = 'Readme.md'
icon = 'scripts/logo.png'
sort = true
favicon = '../CorsixTH/CorsixTH.ico'
one = true
unqualified = true
--template = scripts
