
--## if there has item selected ,then play selected items once , else then play or stop  
reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

reaper.ClearConsole()

--reaper.ShowConsoleMsg(reaper.NamedCommandLookup("40044").." " ..tostring(reaper.Audio_IsRunning()))
count_sel_items = reaper.CountSelectedMediaItems(0)
if count_sel_items > 0 then
  isRunning = reaper.Audio_IsRunning()
  --reaper.ShowConsoleMsg(isRunning)
  if isRunning == 1.0 then
    reaper.Main_OnCommand(reaper.NamedCommandLookup("40044"), 0)
  else 
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_TIMERTEST1"), 1)
  end
  -- reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_TIMERTEST1") , 0)
else 
  isRunning = reaper.Audio_IsRunning()
  --reaper.ShowConsoleMsg(isRunning)
  if isRunning == 1.0 then
    reaper.Main_OnCommand(reaper.NamedCommandLookup("40044"), 0)
  else 
    reaper.Main_OnCommand(reaper.NamedCommandLookup("40044"), 1)
  end

end 

reaper.Undo_EndBlock("space play", -1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)

