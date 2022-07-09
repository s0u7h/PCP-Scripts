

--[[
 * ReaScript Name: Save ReaClip to FX Presets folder (selected items)
 * About: Edit the User Config Areas to make it work.
 * Author: PCP
 * Author URI: 
 * Licence: GPL v3
 * Version: 1.0
--]]

-- TODO: Could be cool to autoname these with the FX used. then could search thorugh the FX Presets folder/DB for .rpp spire to find all the spire presets saved.
-- ReaClip is clunky for this compared to using FX chains or Track Templates but the advantage is that you can 
-- easily browse through the presets in an NKS-style fashion in the MX.

-- USER CONFIG AREA 1/2 ------------------------------------------------------

-- Change the ReaClip path at the bottom of the script to your preferred ReaClips path. 
-- The directory will be created under your default save path.

-- Dependency Name
local script = "Save ReaClip (selected items) and view in Media Explorer.lua" -- 1. The target script path relative to this file. If no folder, then it means preset file is right to the target script.

-------------------------------------------------- END OF USER CONFIG AREA 1/2

-- PARENT SCRIPT CALL --------------------------------------------------------

-- Get Script Path
local script_folder = debug.getinfo(1).source:match("@?(.*[\\|/])")
local script_path = script_folder .. script -- This can be erased if you prefer enter absolute path value above.

-- Prevent Init() Execution
preset_file_init = true

-- Run the Script
if reaper.file_exists( script_path ) then
  dofile( script_path )
else
  reaper.MB("Missing parent script.\n" .. script_path, "Error", 0)
  return
end

---------------------------------------------------- END OF PARENT SCRIPT CALL

-- USER CONFIG AREA 2/2 ------------------------------------------------------

reaclips_path = "FX Presets"


-------------------------------------------------- END OF USER CONFIG AREA 2/2

-- RUN -------------------------------------------------------------------

SaveReaClipAndOpenMX() -- run the init function of the target script.
