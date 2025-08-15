if not pfUI then return end

pfUI:RegisterSkin("TFrames", "vanilla", function()
  if (pfUI_config["disabled"] and pfUI_config["disabled"]["skin_TFrames"] == "1") then
    return
  end
  
  if TFrames and TFrames.ApplyNotifStyles then
    TFrames.ApplyNotifStyles = function(frame, borderColor)
      CreateBackdrop(frame, 5, true, .75)
      CreateBackdropShadow(frame)

      -- Set border color based on notification type
      if borderColor then
        frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b)
      end
    end
  end
end)
