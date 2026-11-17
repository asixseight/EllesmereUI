if EUI_CLIENT_BLOCKED then return end -- throwaway spike, not shipped
-------------------------------------------------------------------------------
--  EUIMenuSpike: answers one question for Quick Actions (docs/adr/0002):
--  after a Unit Menu opens, can insecure code READ its entries (text and
--  enabled state) without getting secret values or tainting the menu?
--
--  Reads only. Never writes to the menu, its descriptions or the mixins.
--  Prints to chat:
--    [open]  which menu, and the context fields (unit / name / bnet)
--    [desc]  channel A: element descriptions -> MenuUtil.GetElementText
--    [frame] channel B: the open menu frame's buttons -> FontString text
--  "SECRET" marks a value issecretvalue() flags.
-------------------------------------------------------------------------------

local P = "|cff0cd29f[Spike]|r "
local isSecret = issecretvalue or function() return false end

local function show(v)
    if isSecret(v) then return "SECRET" end
    if v == nil then return "nil" end
    return tostring(v)
end

local function dumpDescriptions(desc)
    if not (desc and desc.EnumerateElementDescriptions and MenuUtil and MenuUtil.GetElementText) then
        print(P .. "[desc] not available")
        return
    end
    local n = 0
    for _, d in desc:EnumerateElementDescriptions() do
        n = n + 1
        local ok, text = pcall(MenuUtil.GetElementText, d)
        print(P .. "[desc] " .. n .. ": " .. (ok and show(text) or ("ERROR " .. tostring(text))))
    end
    if n == 0 then print(P .. "[desc] no elements") end
end

local function collectButtons(frame, out, depth)
    if depth > 6 or not frame or frame:IsForbidden() then return end
    for _, child in ipairs({ frame:GetChildren() }) do
        if not child:IsForbidden() then
            if child:IsObjectType("Button") and child:IsShown() then
                out[#out + 1] = child
            end
            collectButtons(child, out, depth + 1)
        end
    end
end

local function buttonText(btn)
    local fs = btn.GetFontString and btn:GetFontString()
    if fs then return fs:GetText() end
    for _, r in ipairs({ btn:GetRegions() }) do
        if r:IsObjectType("FontString") then return r:GetText() end
    end
end

local function dumpFrame(manager)
    local menu = manager.GetOpenMenu and manager:GetOpenMenu()
    if not menu then print(P .. "[frame] no open menu") return end
    local btns = {}
    collectButtons(menu, btns, 0)
    for i, b in ipairs(btns) do
        local okT, text = pcall(buttonText, b)
        local okE, en = pcall(b.IsEnabled, b)
        print(P .. "[frame] " .. i .. ": " .. (okT and show(text) or "ERROR")
            .. "  enabled=" .. (okE and show(en) or "ERROR"))
    end
    if #btns == 0 then print(P .. "[frame] no buttons found") end
end

local function onOpen(manager, _, desc)
    -- Defer out of Blizzard's execution, as the real feature will.
    C_Timer.After(0, function()
        print(P .. "---- menu opened ----")
        dumpDescriptions(desc)
        dumpFrame(manager)
    end)
end

if type(UnitPopup_OpenMenu) == "function" then
    hooksecurefunc("UnitPopup_OpenMenu", function(which, ctx)
        ctx = ctx or {}
        local unit, name, bnet = ctx.unit, ctx.name, ctx.bnetIDAccount
        C_Timer.After(0, function()
            print(P .. "[open] which=" .. show(which) .. " unit=" .. show(unit)
                .. " name=" .. show(name) .. " bnet=" .. show(bnet))
        end)
    end)
end

local mgr = Menu and Menu.GetManager and Menu.GetManager()
if mgr then
    hooksecurefunc(mgr, "OpenMenu", onOpen)
    hooksecurefunc(mgr, "OpenContextMenu", onOpen)
    print(P .. "loaded. Right-click a unit, then report the chat output.")
else
    print(P .. "Menu manager missing; spike cannot run.")
end
