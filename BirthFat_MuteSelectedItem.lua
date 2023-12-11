
console = true -- true/false: display debug messages in the console
-- Display a message in the console for debugging
function MsgConsole(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

-- UTILITIES -------------------------------------------------------------

-- Save item selection
function MuteSelectedItems ()
  count_sel_items = reaper.CountSelectedMediaItems(0)
  
  if(count_sel_items > 0) then
  
  
    for i = 0, count_sel_items - 1 do
      local entry = {}
      entry.item = reaper.GetSelectedMediaItem(0,i)
      b =  reaper.GetMediaItemInfo_Value(entry.item , "B_MUTE")
      --reaper.ShowConsoleMsg(tostring(b))
      if(b == 1.0) then
        reaper.SetMediaItemInfo_Value(entry.item ,"B_MUTE" , 0.0 )
      else
        reaper.SetMediaItemInfo_Value(entry.item ,"B_MUTE" , 1.0 )
      end
      --reaper.SetMediaItemInfo_Value(entry.item , "B_MUTE")
      
     
    end
  end
end

--================================== Main ========================================================================

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

reaper.ClearConsole()

MuteSelectedItems ()

reaper.Undo_EndBlock("Create regions from selected items notes and color", -1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)
