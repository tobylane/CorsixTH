-- luacheck: ignore

---@meta
-- ^ This tells LuaLS to read this file ONLY for type definitions, not execution.

--- The global class builder utilized by CorsixTH.
--- It intercepts a base object or class definition and returns an instance constructor framework.
---@generic T
---@param parent? T
---@return T
function class(parent) end

-- App Class Profile
-- ============================================================================
-- Add the .config field definition to the global App blueprint layout
---@class App
---@field config table The core runtime configuration settings map.
local App = {}

---@diagnostic disable-next-line: missing-fields
---@type App
_G.TheApp = { config = {} }

---@type { [string]: any } | fun(...): any
_G._S = {}

---@type { [string]: any } | fun(...): any
_G._A = {}

---@meta
-- corsixth_defs.d.lua

-- ============================================================================
-- C++ Universal Class Fallback Shell
-- ============================================================================

-- This generic layout allows any class inheriting it to bypass rigid field/method checks.
---@class CXX_BaseClass
---@operator call: any
local CXX_BaseClass = {}
---@diagnostic disable-next-line: unknown-cast-variable
---@type fun(...): any
CXX_BaseClass[string] = nil

---@class lfs : CXX_BaseClass
lfs = {}
---@class rnc : CXX_BaseClass
rnc = {}
-- ============================================================================
-- Core CorsixTH C++ Engine Classes
-- ============================================================================

---@class Graphics : CXX_BaseClass
Graphics = {}

---@class Audio : CXX_BaseClass
Audio = {}

---@class MoviePlayer : CXX_BaseClass
MoviePlayer = {}

---@class Strings : CXX_BaseClass
Strings = {}

---@class AnimationManager : CXX_BaseClass
AnimationManager = {}

-- the bad idea section
---@class corsixth : CXX_BaseClass
corsixth = {}
--- Requires a dynamic sub-module file at execution runtime.
---@param module_name string
function corsixth.require(module_name) end
-- bad idea section end

-- ============================================================================
-- C++ Native Global Functions & Packages
-- ============================================================================
---@class gfx : CXX_BaseClass
---@class video : CXX_BaseClass
-- ============================================================================
-- 1. Native Windowing & Surface Infrastructure
-- ============================================================================
---@class THCanvas : CXX_BaseClass
---@class THSurface : CXX_BaseClass
---@class THWindow : CXX_BaseClass
---@class render_target : CXX_BaseClass

-- ============================================================================
-- 2. Map & Pathfinding Engines
-- ============================================================================
---@class THMap : CXX_BaseClass
---@class map_tile_iterator : CXX_BaseClass
---@class abstract_pathfinder : CXX_BaseClass
---@class basic_pathfinder : CXX_BaseClass
---@class hospital_finder : CXX_BaseClass
---@class idle_tile_finder : CXX_BaseClass
---@class object_visitor : CXX_BaseClass

-- ============================================================================
-- 3. Graphics, Animation & Rendering Lists
-- ============================================================================
---@class THSpriteSheet : CXX_BaseClass
---@class animation : CXX_BaseClass
---@class animation_manager : CXX_BaseClass
---@class sprite_render_list : CXX_BaseClass
---@class th_frame_properties : CXX_BaseClass
---@class th_sprite_properties : CXX_BaseClass
---@class th_element_properties : CXX_BaseClass

-- ============================================================================
-- 4. Audio, Sound & Video Subsystems
-- ============================================================================
---@class sound_player : CXX_BaseClass
---@class movie_player : CXX_BaseClass
---@class th_lua_midi_player : CXX_BaseClass

-- ============================================================================
-- 5. Data Buffers & Localised String Lists
-- ============================================================================
---@class THString : CXX_BaseClass
---@class th_string_list : CXX_BaseClass
---@class memory_buffer : CXX_BaseClass

-- ============================================================================
-- 6. Core Global Namespace Bindings
-- ============================================================================
---@class THModule : CXX_BaseClass
TH = {} ---@type THModule

