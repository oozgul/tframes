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
  local f = CreateFrame("Frame", nil, UIParent)
  f:SetWidth(245)
  f:SetHeight(45)
  
  -- Position notifications relative to the anchor
  local yOffset = 50 + (notifCount * 45)
  f:SetPoint("BOTTOMLEFT", TFramesAnchor, "BOTTOMRIGHT", 10, yOffset)
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
      local found, _, itemString = string.find(itemLink, "^|%x+|H(.+)|h%[.+%]")
      if itemString then
        local itemID = tonumber(string.match(itemString, "item:(%d+)"))
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
    
  f:Show()
  
	  -- Auto-hide timer with fade and slide effect
  local timer = CreateFrame("Frame")
  local startTime = GetTime()
  local showDuration = 4  -- Show for 4 seconds
  local fadeDuration = 1  -- Fade out over 1 second
  local slideDistance = 100  -- Slide 100 pixels to the right
  local originalX = 10  -- Original X offset from anchor
  
  timer:SetScript("OnUpdate", function()
    local elapsed = GetTime() - startTime
    
    if elapsed < showDuration then
      -- Full opacity during show phase
      f:SetAlpha(1)
      f:SetPoint("BOTTOMLEFT", TFramesAnchor, "BOTTOMRIGHT", originalX, yOffset)
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
  if event == "CHAT_MSG_COMBAT_XP_GAIN" then
    local msg = arg1 or ""
    local xp = tonumber(string.match(msg, "(%d+)%s+experience"))
    if xp and TFramesSettings.xp then
      ShowNotifWithIcon("+" .. xp .. " XP", "Interface\\Icons\\INV_Misc_Note_01", {r = 0.8, g = 0.4, b = 1}, nil, nil)  -- Purple border
    end
  elseif event == "CHAT_MSG_LOOT" then
    -- Handle loot messages and use recent ITEM_PUSH icon
    local msg = arg1 or ""

    
    if (string.find(msg, "You receive") or string.find(msg, "Received item")) and TFramesSettings.loot then
      -- Extract item name and quantity from chat (handle [Item]x200] format)
      local itemName = string.match(msg, "You receive loot:%s*%[(.-)%]")  -- Non-greedy match
      if not itemName then
        itemName = string.match(msg, "You receive item:%s*%[(.-)%]")  -- Non-greedy for vendor
      end
      if not itemName then
        itemName = string.match(msg, "Received item:%s*%[(.-)%]")  -- Non-greedy for quest rewards
      end
      if not itemName then
        itemName = string.match(msg, "%[(.-)%]")  -- Non-greedy fallback
      end
      
      if itemName then
        -- Extract quantity - try simple pattern from green chat: [Item]x200
        local quantity = 1
        -- Try the simple green chat format first
        local quantityMatch = string.match(msg, "%[.-%]x(%d+)")  -- [Rough Arrow]x200
        if not quantityMatch then
          quantityMatch = string.match(msg, "%]x(%d+)")  -- ]x200
        end
        if not quantityMatch then
          quantityMatch = string.match(msg, "x(%d+)")  -- x200
        end
        if quantityMatch then
          quantity = tonumber(quantityMatch)
        end
        
        -- Create display text with stack info
        local displayText = itemName
        if quantity > 1 then
          displayText = quantity .. "x " .. itemName
        end
        
        -- Check if we have a recent ITEM_PUSH icon and stack info (within 2 seconds)
        local iconTexture = "Interface\\Icons\\INV_Misc_Bag_08"  -- Default
        local recentPush = _G.TFRAMES_RECENT_PUSH

        
        if recentPush and (GetTime() - recentPush.time) < 2 then
          iconTexture = recentPush.icon
          -- Add stack info for items with quantity > 1, or show the maxStack if it's meaningful
          if quantity > 1 and recentPush.maxStack and recentPush.maxStack > 1 and recentPush.maxStack ~= quantity then
            displayText = displayText .. " (/" .. recentPush.maxStack .. ")"
          end
          _G.TFRAMES_RECENT_PUSH = nil  -- Clear it
        end
        
        -- Extract item link from the chat message using 1.12 format
        local itemLink = string.match(msg, "(\124c%x+\124Hitem:[^\124]+\124h%[[^\]]+%]\124h\124r)")
        if not itemLink then
          -- Try without color codes
          itemLink = string.match(msg, "(\124Hitem:[^\124]+\124h%[[^\]]+%]\124h)")
        end
        
		-- Extract item quality from the itemString
        local itemQuality = nil
        local isQuestItem = false
        if itemLink then
          local found, _, itemString = string.find(itemLink, "^|%x+|H(.+)|h%[.+%]")
          if itemString then
            -- ItemString format: "item:itemID:enchant:gem1:gem2:gem3:gem4:suffix:unique:level:reforging:upgradeId:instance:bonus:quality"
            -- For 1.12, it's simpler: "item:itemID:enchant:gem1:gem2:gem3:gem4:suffix:unique"
            -- Quality is usually determined by itemID, but let's try to get it from GetItemInfo
            local itemID = tonumber(string.match(itemString, "item:(%d+)"))
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
        
        -- Override quality for quest items
        if isQuestItem then
          itemQuality = "quest"  -- Custom identifier for quest items
        end

        ShowNotifWithIcon(displayText, iconTexture, nil, itemLink, itemQuality)
      end
    end
  elseif event == "CHAT_MSG_MONEY" then
    local msg = arg1 or ""
    if string.find(msg, "You") and TFramesSettings.money then
      -- Simple approach: extract any number and check what type of money it is
      local amount = tonumber(string.match(msg, "(%d+)"))
      local g, s, c = 0, 0, 0
      
      if amount then
        if string.find(msg, "Gold") or string.find(msg, "gold") then
          g = amount
        elseif string.find(msg, "Silver") or string.find(msg, "silver") then
          s = amount
        elseif string.find(msg, "Copper") or string.find(msg, "copper") then
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
  elseif event == "ITEM_PUSH" then
    if TFramesSettings.loot then
      local stackSize = arg1 or 1
      local iconPath = arg2 or "Interface\\Icons\\INV_Misc_Bag_08"
      
      -- Store the icon and max stack size for CHAT_MSG_LOOT to use
      _G.TFRAMES_RECENT_PUSH = {
        icon = iconPath,
        maxStack = stackSize,
        time = GetTime()
      }
    end 
  end 
end) 

DEFAULT_CHAT_FRAME:AddMessage("Turtle Frames: ready!")
DEFAULT_CHAT_FRAME:AddMessage("Commands: /tframes anchor, /tftest xp/money/loot")
