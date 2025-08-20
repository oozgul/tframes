-- Turtle Frames for Turtle WoW - Gliding Notifications with Tooltips
DEFAULT_CHAT_FRAME:AddMessage("Turtle Frames: loading...")

-- Anchor frame
TFramesAnchor = CreateFrame("Frame", "TFramesAnchor", UIParent)
TFramesAnchor:SetWidth(80)
TFramesAnchor:SetHeight(80)
TFramesAnchor:SetPoint("CENTER", UIParent, "CENTER", 300, -180)
TFramesAnchor:EnableMouse(true)
TFramesAnchor:SetMovable(true)
TFramesAnchor:RegisterForDrag("LeftButton")
TFramesAnchor:SetScript("OnDragStart", function() TFramesAnchor:StartMoving() end)
TFramesAnchor:SetScript("OnDragStop", function() TFramesAnchor:StopMovingOrSizing() end)
local tx = TFramesAnchor:CreateTexture(nil, "BACKGROUND")
tx:SetAllPoints(TFramesAnchor)
tx:SetTexture("Interface\\Buttons\\WHITE8X8")
tx:SetVertexColor(0,1,0,0.5)
TFramesAnchor:Hide()

-- Simple counter for stacking
local notifCount = 0

-- Settings
local TFramesSettings = {
  loot = true,
  xp = true,
  money = true,
}

-- Enhanced notification function with color customization
local function ShowNotifWithIcon(text, iconTexture, borderColor, itemLink, itemQuality)
  -- Ensure text is valid
  if not text or text == "" then
    text = "Unknown Item"
  end
  text = tostring(text)  -- Ensure it's a string
  
  local f = CreateFrame("Frame", nil, UIParent)
  f:SetWidth(245)
  f:SetHeight(45)
  
  -- Position notifications relative to the anchor
  local yOffset = 50 + (notifCount * 45)
  local finalX = 10  -- Final X position
  local startX = finalX - 60  -- Start 60 pixels to the left (more subtle)
  
  -- Position normally for now, we'll animate after show
  f:SetPoint("BOTTOMLEFT", TFramesAnchor, "BOTTOMRIGHT", finalX, yOffset)
  notifCount = notifCount + 1
  
  f:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = {left = 5, right = 5, top = 5, bottom = 5}
  })
  
  -- Set border color based on notification type
  if borderColor then
    f:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b)
  end
  -- No else clause - let it use the default frame border color
  f:SetBackdropColor(0, 0, 0, 0.8)
  
  -- Icon
  local icon = f:CreateTexture(nil, "ARTWORK")
  icon:SetWidth(30)
  icon:SetHeight(30)
  icon:SetPoint("LEFT", f, "LEFT", 8, 0)
  icon:SetTexture(iconTexture)
  
  -- Text
  local txt = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  txt:SetPoint("LEFT", icon, "RIGHT", 8, 0)
  txt:SetText(text)
  
    -- Apply item quality color if available
  if itemQuality then
    -- Special handling for quest items
    if itemQuality == "quest" or itemQuality == 7 then
      -- Quest items get teal color
      txt:SetTextColor(0, 0.8, 0.8)  -- Teal color
    else
      local r, g, b = GetItemQualityColor(itemQuality)
      txt:SetTextColor(r, g, b)
    end
  end

	  -- Enable mouse interaction for tooltips (only for items with valid links)
  if itemLink then
    f:EnableMouse(true)
    f:SetScript("OnEnter", function()
      GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
      
      -- Extract itemID from the itemString for 1.12 compatibility
      local hStart = string.find(itemLink, "|H", 1, true)
      local hEnd = string.find(itemLink, "|h", 1, true)
      
      if hStart and hEnd and hEnd > hStart then
        local itemString = string.sub(itemLink, hStart + 2, hEnd - 1)  -- Extract between |H and |h
        
        -- Extract itemID from itemString (format: item:12345:...)
        local colonPos = string.find(itemString, ":", 1, true)
        local itemID = nil
        if colonPos then
          local secondColonPos = string.find(itemString, ":", colonPos + 1, true)
          if secondColonPos then
            local itemIDStr = string.sub(itemString, colonPos + 1, secondColonPos - 1)
            itemID = tonumber(itemIDStr)
          end
        end
        if itemID then
          -- Use SetItemByID which works reliably in 1.12
          local ok = pcall(function()
            GameTooltip:SetItemByID(itemID)
            GameTooltip:Show()
          end)
          
          -- Fallback to itemString if SetItemByID fails
          if not ok then
            pcall(function()
              GameTooltip:SetHyperlink(itemString)
              GameTooltip:Show()
            end)
          end
        end
      end
    end)
    
    f:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
  end
    
  -- Start invisible and to the left, then animate in
  f:SetPoint("BOTTOMLEFT", TFramesAnchor, "BOTTOMRIGHT", startX, yOffset)
  f:SetAlpha(0)
  f:Show()
  
  -- Fast, smooth fade-in animation
  local fadeInTimer = CreateFrame("Frame")
  local fadeInStartTime = GetTime()
  local fadeInDuration = 0.25  -- Fast and snappy
  local animationActive = true
  
  fadeInTimer:SetScript("OnUpdate", function()
    if not animationActive then return end
    
    local elapsed = GetTime() - fadeInStartTime
    local progress = elapsed / fadeInDuration
    
    if progress >= 1 then
      -- Animation complete
      progress = 1
      animationActive = false
      fadeInTimer:SetScript("OnUpdate", nil)
    end
    
    -- Smooth ease-out curve for natural motion
    local easedProgress = 1 - (1 - progress) * (1 - progress) * (1 - progress)
    
    -- Interpolate position and alpha
    local currentX = startX + (finalX - startX) * easedProgress
    local alpha = progress  -- Linear fade looks more natural
    
    -- Apply smooth animation
    f:ClearAllPoints()
    f:SetPoint("BOTTOMLEFT", TFramesAnchor, "BOTTOMRIGHT", currentX, yOffset)
    f:SetAlpha(alpha)
  end)
  
	  -- Auto-hide timer with fade and slide effect
  local timer = CreateFrame("Frame")
  local startTime = GetTime()
  local showDuration = 4  -- Show for 4 seconds
  local fadeDuration = 1  -- Fade out over 1 second
  local slideDistance = 100  -- Slide 100 pixels to the right
  local originalX = finalX  -- Use finalX instead of hardcoded 10
  
  timer:SetScript("OnUpdate", function()
    local elapsed = GetTime() - startTime
    
    if elapsed < showDuration then
      -- During show phase, don't interfere with fade-in animation
      if not animationActive then
        -- Only set position/alpha if fade-in is complete
        f:SetAlpha(1)
        f:SetPoint("BOTTOMLEFT", TFramesAnchor, "BOTTOMRIGHT", originalX, yOffset)
      end
    elseif elapsed < showDuration + fadeDuration then
      -- Fade out and slide phase with smooth easing
      local fadeProgress = (elapsed - showDuration) / fadeDuration
      
      -- Smooth ease-out function for natural movement
      local easedProgress = 1 - (1 - fadeProgress) * (1 - fadeProgress) * (1 - fadeProgress)
      
      local alpha = 1 - fadeProgress  -- Linear fade (keeps fade smooth)
      local slideX = originalX + (slideDistance * easedProgress)  -- Smooth slide
      
      f:SetAlpha(alpha)
      f:SetPoint("BOTTOMLEFT", TFramesAnchor, "BOTTOMRIGHT", slideX, yOffset)
    else
      -- Completely faded out, hide the frame
      f:Hide()
      notifCount = notifCount - 1
      if notifCount < 0 then notifCount = 0 end
      timer:SetScript("OnUpdate", nil)
    end
    end)
end

-- Basic slash command
SLASH_TFRAMES1 = "/tframes"
SlashCmdList["TFRAMES"] = function(msg)
  local input = string.lower(tostring(msg or ""))
  
  if input == "anchor" then
    if TFramesAnchor:IsShown() then 
      TFramesAnchor:Hide() 
    else 
      TFramesAnchor:Show() 
    end
    return
  end

  -- Toggle settings
  local which, state = string.match(input, "^(loot|xp|money)%s+(on|off)$")
  if which and state then
    TFramesSettings[which] = (state == "on")
    DEFAULT_CHAT_FRAME:AddMessage("Turtle Frames: " .. which .. " " .. state)
    return
  end
  
  DEFAULT_CHAT_FRAME:AddMessage("Turtle Frames: /tframes anchor | loot/xp/money on/off")
end

-- Test command
SLASH_TFTEST1 = "/tftest"
SlashCmdList["TFTEST"] = function(msg)
  if msg == "xp" then
    if TFramesSettings.xp then 
      ShowNotifWithIcon("+250 XP", "Interface\\Icons\\INV_Misc_Note_01", {r = 0.8, g = 0.4, b = 1}, nil, nil)  -- Purple border
    end
  elseif msg == "money" then
    if TFramesSettings.money then 
      ShowNotifWithIcon("+12g 34s 56c", "Interface\\Icons\\INV_Misc_Coin_01", {r = 1, g = 0.8, b = 0}, nil, nil)  -- Gold border
    end
  elseif msg == "loot" then
    if TFramesSettings.loot then 
      -- Use a real uncommon item for testing - Silk Cloth (item ID 4306)
      local testItemID = 4306  -- Silk Cloth (Uncommon)
      local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfo(testItemID)
      
      if itemName and itemIcon then
        ShowNotifWithIcon(itemName, itemIcon, nil, itemLink, itemQuality)
      else
        -- Fallback if GetItemInfo fails
        ShowNotifWithIcon("Silk Cloth", "Interface\\Icons\\Trade_Tailoring", nil, nil, 2)  -- Uncommon quality
      end
    end
  else
    DEFAULT_CHAT_FRAME:AddMessage("Test: /tftest xp | money | loot")
    end
end

-- Chat event monitoring
local evtFrame = CreateFrame("Frame")
evtFrame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
evtFrame:RegisterEvent("CHAT_MSG_LOOT")
evtFrame:RegisterEvent("CHAT_MSG_MONEY")
evtFrame:RegisterEvent("ITEM_PUSH")
evtFrame:SetScript("OnEvent", function()
  -- Debug: Show all events we receive
  DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Event = " .. tostring(event) .. ", arg1 = " .. tostring(arg1 or "nil"))
  
  if event == "CHAT_MSG_COMBAT_XP_GAIN" then
    if arg1 and type(arg1) == "string" and arg1 ~= "" and TFramesSettings.xp then
      local msg = tostring(arg1)
      DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: XP message = '" .. msg .. "'")
      
      -- Extract XP amount from message like "You gain 140 experience"
      local xp = nil
      
      -- Look for "gain" in the message, then extract the number before "experience"
      local gainPos = string.find(msg, "gain", 1, true)
      if gainPos then
        -- Extract everything after "gain "
        local afterGain = string.sub(msg, gainPos + 5)  -- +5 to skip "gain "
        
        -- Extract digits from the start
        local xpStr = ""
        for i = 1, string.len(afterGain) do
          local char = string.sub(afterGain, i, i)
          if char >= "0" and char <= "9" then
            xpStr = xpStr .. char
          else
            break  -- Stop at first non-digit
          end
        end
        
        if xpStr ~= "" then
          xp = tonumber(xpStr)
          DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Extracted XP: " .. xp)
        end
      end
      
      if xp and xp > 0 then
        ShowNotifWithIcon("+" .. xp .. " XP", "Interface\\Icons\\INV_Misc_Note_01", {r = 0.8, g = 0.4, b = 1}, nil, nil)  -- Purple border
      else
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Could not extract XP from message")
      end
    end
  elseif event == "CHAT_MSG_LOOT" then
    -- Handle loot messages and use recent ITEM_PUSH icon
    -- Debug: Show what messages we're getting
    if arg1 then
      DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: CHAT_MSG_LOOT = '" .. tostring(arg1) .. "'")
    end
    
    if arg1 and type(arg1) == "string" and arg1 ~= "" and TFramesSettings.loot then
      local msg = tostring(arg1)
      local foundReceive, foundReceived = false, false
      
      -- Safely check for loot messages - check multiple patterns
      local foundLoot = false
      
      -- Pattern 1: "You receive item:" (vendor purchases, quest rewards)
      local success1, result1 = pcall(string.find, msg, "You receive item")
      if success1 and result1 then 
        foundLoot = true 
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Matched 'You receive item'")
      end
      
      -- Pattern 2: "You receive loot:" (mob drops)
      local success2, result2 = pcall(string.find, msg, "You receive loot")
      if success2 and result2 then 
        foundLoot = true 
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Matched 'You receive loot'")
      end
      
      -- Pattern 3: "Received item:" (quest completion)
      local success3, result3 = pcall(string.find, msg, "Received item") 
      if success3 and result3 then 
        foundLoot = true 
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Matched 'Received item'")
      end
      
      -- Pattern 4: Just "You loot" (alternative loot message)
      local success4, result4 = pcall(string.find, msg, "You loot")
      if success4 and result4 then 
        foundLoot = true 
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Matched 'You loot'")
      end
      
      if foundLoot then
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Processing loot message: " .. msg)
        
        -- Extract item name and quantity from chat (handle [Item]x200] format)
        local itemName = nil
        
        -- Debug: Show the exact message we're trying to parse
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Parsing message: '" .. msg .. "'")
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Message length: " .. string.len(msg))
        
        -- Use string.find instead of string.match (which doesn't exist in 1.12)
        local success, startPos, endPos = pcall(string.find, msg, "%[(.-)%]")  -- Find [ and ]
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Find success: " .. tostring(success) .. ", start: " .. tostring(startPos or "nil") .. ", end: " .. tostring(endPos or "nil"))
        
        if success and startPos then
          -- Extract the text between [ and ]
          local bracketStart = string.find(msg, "%[")
          local bracketEnd = string.find(msg, "%]")
          if bracketStart and bracketEnd and bracketEnd > bracketStart then
            local fullMatch = string.sub(msg, bracketStart + 1, bracketEnd - 1)  -- Get text between brackets
            DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Extracted from brackets: '" .. fullMatch .. "'")
            
            -- Remove quantity suffix if present (e.g., "Rough Arrowx200" -> "Rough Arrow")
            local nameEnd = string.find(fullMatch, "x%d+$")
            if nameEnd then
              itemName = string.sub(fullMatch, 1, nameEnd - 1)
            else
              itemName = fullMatch
            end
            DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Final item name: '" .. itemName .. "'")
          end
        else
          DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Could not find brackets in message")
        end
      
      if itemName then
        -- Extract quantity - simple approach: look for "x" + digits anywhere in message
        local quantity = 1
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Looking for 'x' + digits in: '" .. msg .. "'")
        
        -- Find any "x" in the message
        local xPos = string.find(msg, "x", 1, true)  -- Plain text search for x
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Found 'x' at position: " .. tostring(xPos or "nil"))
        
        if xPos then
          -- Extract everything after the "x"
          local afterX = string.sub(msg, xPos + 1)
          DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: After 'x': '" .. afterX .. "'")
          
          -- Extract only digits from the start
          local cleanNumber = ""
          for i = 1, string.len(afterX) do
            local char = string.sub(afterX, i, i)
            if char >= "0" and char <= "9" then
              cleanNumber = cleanNumber .. char
            else
              break  -- Stop at first non-digit
            end
          end
          
          DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Extracted digits: '" .. cleanNumber .. "'")
          
          if cleanNumber ~= "" then
            local numQuantity = tonumber(cleanNumber)
            if numQuantity and numQuantity > 1 then  -- Only use if > 1
              quantity = numQuantity
              DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Using quantity: " .. quantity)
            end
          end
        else
          DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: No 'x' found, using default quantity: 1")
        end
        
        -- Create display text with stack info
        local displayText = itemName
        if not displayText or displayText == "" then
          displayText = "Unknown Item"
        end
        
        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Before quantity check - displayText: '" .. displayText .. "', quantity: " .. tostring(quantity))
        
        if quantity and quantity > 1 then
          displayText = quantity .. "x " .. displayText
          DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: After quantity check - displayText: '" .. displayText .. "'")
        else
          DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Quantity check failed - quantity: " .. tostring(quantity) .. ", > 1: " .. tostring(quantity and quantity > 1))
        end
        
        -- Check if we have a recent ITEM_PUSH icon and stack info (within 2 seconds)
        local iconTexture = "Interface\\Icons\\INV_Misc_Bag_08"  -- Default
        local recentPush = getglobal("TFRAMES_RECENT_PUSH")

        
        if recentPush and (GetTime() - recentPush.time) < 2 then
          iconTexture = recentPush.icon
          -- Don't add stack info - keep display clean
          setglobal("TFRAMES_RECENT_PUSH", nil)  -- Clear it
        end
        
        -- Extract item link from the chat message using 1.12 format
        local itemLink = nil
        
        -- Look for item links in the message (they start with |c and contain |Hitem:)
        local linkStart = string.find(msg, "|c", 1, true)  -- Find color code start
        local linkEnd = string.find(msg, "|r", 1, true)    -- Find color code end
        
        if linkStart and linkEnd and linkEnd > linkStart then
          itemLink = string.sub(msg, linkStart, linkEnd + 1)  -- Extract full colored link
          DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Extracted item link: " .. itemLink)
        else
          -- Try without color codes - look for |Hitem: directly
          linkStart = string.find(msg, "|Hitem:", 1, true)
          if linkStart then
            linkEnd = string.find(msg, "|h", linkStart, true)  -- Find end of hyperlink
            if linkEnd then
              local linkEnd2 = string.find(msg, "|h", linkEnd + 2, true)  -- Find second |h (closing)
              if linkEnd2 then
                itemLink = string.sub(msg, linkStart, linkEnd2 + 1)
                DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Extracted simple item link: " .. itemLink)
              end
            end
          end
        end
        
		-- Extract item quality from the itemString
        local itemQuality = nil
        local isQuestItem = false
        if itemLink then
          -- Extract itemString from the link (between |H and |h)
          local hStart = string.find(itemLink, "|H", 1, true)
          local hEnd = string.find(itemLink, "|h", 1, true)
          
          if hStart and hEnd and hEnd > hStart then
            local itemString = string.sub(itemLink, hStart + 2, hEnd - 1)  -- Extract between |H and |h
            DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Extracted itemString: " .. itemString)
            
            -- Extract itemID from itemString (format: item:12345:...)
            local colonPos = string.find(itemString, ":", 1, true)
            if colonPos then
              local secondColonPos = string.find(itemString, ":", colonPos + 1, true)
              if secondColonPos then
                local itemIDStr = string.sub(itemString, colonPos + 1, secondColonPos - 1)
                local itemID = tonumber(itemIDStr)
                DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Extracted itemID: " .. tostring(itemID))
                
                if itemID then
                  local itemName, _, quality, _, _, itemType, itemSubType = GetItemInfo(itemID)
                  itemQuality = quality
                  
                  -- Check if it's a quest item by type or subtype
                  if itemType == "Quest" or itemSubType == "Quest" then
                    isQuestItem = true
                  end
                end
              end
            end
          end
        end
        
        -- Override quality for quest items
        if isQuestItem then
          itemQuality = "quest"  -- Custom identifier for quest items
        end

        DEFAULT_CHAT_FRAME:AddMessage("TFrames DEBUG: Creating notification: " .. displayText)
        ShowNotifWithIcon(displayText, iconTexture, nil, itemLink, itemQuality)
      end
      end
    end
  elseif event == "CHAT_MSG_MONEY" then
    if arg1 and type(arg1) == "string" and arg1 ~= "" and TFramesSettings.money then
      local msg = tostring(arg1)
      local foundYou = pcall(string.find, msg, "You")
      if foundYou then
      -- Simple approach: extract any number from the message
      local amount = nil
      
      -- Look for digits in the message
      for i = 1, string.len(msg) do
        local char = string.sub(msg, i, i)
        if char >= "0" and char <= "9" then
          -- Found start of a number, extract it
          local numStr = ""
          for j = i, string.len(msg) do
            local numChar = string.sub(msg, j, j)
            if numChar >= "0" and numChar <= "9" then
              numStr = numStr .. numChar
            else
              break
            end
          end
          if numStr ~= "" then
            amount = tonumber(numStr)
            break
          end
        end
      end
      local g, s, c = 0, 0, 0
      
      if amount then
        local foundGold = pcall(string.find, msg, "Gold") or pcall(string.find, msg, "gold")
        local foundSilver = pcall(string.find, msg, "Silver") or pcall(string.find, msg, "silver")
        local foundCopper = pcall(string.find, msg, "Copper") or pcall(string.find, msg, "copper")
        
        if foundGold then
          g = amount
        elseif foundSilver then
          s = amount
        elseif foundCopper then
          c = amount
        end
      end
      
      if (g > 0 or s > 0 or c > 0) then
        local parts = {}
        if g > 0 then parts[1] = g .. "g" end
        if s > 0 then parts[2] = s .. "s" end  
        if c > 0 then parts[3] = c .. "c" end
        local moneyText = ""
        for i = 1, 3 do
          if parts[i] then
            if moneyText == "" then
              moneyText = parts[i]
            else
              moneyText = moneyText .. " " .. parts[i]
            end
            end 
        end

        ShowNotifWithIcon("+" .. moneyText, "Interface\\Icons\\INV_Misc_Coin_01", {r = 1, g = 0.8, b = 0}, nil, nil)  -- Gold border
      end 
      end
    end
  elseif event == "ITEM_PUSH" then
    if TFramesSettings.loot then
      local stackSize = arg1 or 1
      local iconPath = arg2 or "Interface\\Icons\\INV_Misc_Bag_08"
      
      -- Store the icon and max stack size for CHAT_MSG_LOOT to use
      setglobal("TFRAMES_RECENT_PUSH", {
        icon = iconPath,
        maxStack = stackSize,
        time = GetTime()
      })
    end 
  end 
end) 

DEFAULT_CHAT_FRAME:AddMessage("Turtle Frames: ready!")
DEFAULT_CHAT_FRAME:AddMessage("Commands: /tframes anchor, /tftest xp/money/loot")
