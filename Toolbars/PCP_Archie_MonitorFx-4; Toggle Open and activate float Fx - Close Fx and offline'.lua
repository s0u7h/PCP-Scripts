--[[
   * Description: Archie_MonitorFx; Toggle Open and activate float Fx - Close Fx and offline'Fx-3.lua
   * Author:      Archie
   * Website:     http://forum.cockos.com/showthread.php?t=212819 
   *              http://rmmedia.ru/threads/134701/ 
   * DONATION:    http://money.yandex.ru/to/410018003906628 
   * Customer:    Maestro Sound[RMM]
   * Gave idea:   Maestro Sound[RMM]
--]]






    -----------------------------------------------------------------------------
    local function No_Undo()end; local function no_undo()reaper.defer(No_Undo)end
    -----------------------------------------------------------------------------


    local Num_Fx = {4};
    local Close_NoBypassOffline = {2};

    local mastTrack = reaper.GetMasterTrack();
    local mon,OpenFloat = (0x1000000)-1;

    for i = 1, #Num_Fx do;
        OpenFloat = reaper.TrackFX_GetFloatingWindow(mastTrack,mon+Num_Fx[i]);
        if OpenFloat then break end;
    end;


    for i = 1, #Num_Fx do;
        if not OpenFloat then;
            local Offline = reaper.TrackFX_GetOffline(mastTrack,mon+Num_Fx[i]);
            local bypass = reaper.TrackFX_GetEnabled(mastTrack,mon+Num_Fx[i]);
            if Offline then;
                reaper.TrackFX_SetOffline(mastTrack,mon+Num_Fx[i],0);
            end;
            if not bypass then;
                reaper.TrackFX_SetEnabled(mastTrack,mon+Num_Fx[i],1);
            end;
            reaper.TrackFX_Show(mastTrack,mon+Num_Fx[i],3);
        else;
            if Close_NoBypassOffline[i] == 1 then;
                reaper.TrackFX_SetEnabled(mastTrack,mon+Num_Fx[i],0);
            elseif Close_NoBypassOffline[i] == 2 then;
                reaper.TrackFX_SetOffline(mastTrack,mon+Num_Fx[i],1);
            end;
            reaper.TrackFX_Show(mastTrack,mon+Num_Fx[i],2);
        end;
    end;
    no_undo();



