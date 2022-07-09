

--[[
 * ReaScript Name: Save ReaClip to Melodyned Clips folder (selected items)
 * About: Edit the User Config Areas to make it work.
 * Author: PCP
 * Author URI: 
 * Licence: GPL v3
 * Version: 1.0
--]]

-- TODO: alternatively save this in the project folder itself? 
-- prob  useful to keep melodyned stuff with the associated project.

-- USER CONFIG AREA 1/2 ------------------------------------------------------

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

reaclips_path = "Melodyned Clips"


-------------------------------------------------- END OF USER CONFIG AREA 2/2

-- RUN -------------------------------------------------------------------

SaveReaClipAndOpenMX() -- run the init function of the target script.
