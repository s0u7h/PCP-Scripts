function cancel()
    reaper.ShowMessageBox("Cancelled", "Operation Cancelled", 0)
     end

function save_current_project()
local ok, rv_str = reaper.GetUserInputs("Save Current Project", 1, "Save Current Project?", "")

if not ok then cancel() end
if ok==true then
reaper.Main_OnCommand(40026, 0) --File: Save project // saves original project
  reaper.ShowMessageBox("Saved", "Save test", 0)
end
  
end

reaper.defer(save_current_project)
