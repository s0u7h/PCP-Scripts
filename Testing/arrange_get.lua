



function SaveView()
  start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end



function RestoreView()
  reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end

SaveView()

reaper.Main_OnCommand(40727, 0)
RestoreView()
