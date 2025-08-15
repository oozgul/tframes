if not pfUI then return end

pfUI:RegisterSkin("TFrames", "vanilla", function()
  if (pfUI_config["disabled"] and pfUI_config["disabled"]["skin_TFrames"] == "1") then
    return
  end
  
  if TFrames and TFrames.ApplyNotifStyles then
    TFrames.ApplyNotifStyles = function(frame, borderColor)
      local rawborder, border = GetBorderSize()
      local inset = 5 - border

      CreateBackdrop(frame, nil, nil, .85)
      CreateBackdropShadow(frame)

      frame.backdrop:SetPoint("TOPLEFT", inset, -inset)
      frame.backdrop:SetPoint("BOTTOMRIGHT", -inset, inset)

      -- Set border color based on notification type
      if borderColor then
        frame.backdrop:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b)
      end
    end
  end
end)
