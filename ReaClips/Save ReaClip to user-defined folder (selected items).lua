

--[[
 * ReaScript Name: Save ReaClip to user-defined folder (selected items)
 * About: Edit reaclips_path value in the User Config Area at the bottom of this script to define save folder.
 * Author: PCP
 * Author URI: 
 * Licence: GPL v3
 * Version: 1.0
--]]

-- USER CONFIG AREA 1/2 ------------------------------------------------------

-- Dependency Name
local script = "Save ReaClip (selected items) and view in Media Explorer.lua" -

-------------------------------------------------- END OF USER CONFIG AREA 1/2

-- PARENT SCRIPT CALL --------------------------------------------------------

-- Get Script Path
local script_folder = debug.getinfo(1).source:match("@?(.*[\\|/])")
local script_path = script_folder .. script 

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

reaclips_path = "ReaClips"

-------------------------------------------------- END OF USER CONFIG AREA 2/2

SaveReaClipAndOpenMX() -- run the init function of the target script.
