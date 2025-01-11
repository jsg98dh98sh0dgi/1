-- Extracted and reformatted functions from message.txt to match the style of library2.txt

-- // Utility Functions
local utility = {}

-- Logging functionality
function utility:Log(...)
    local temp = ""
    for i, v in pairs({...}) do
        temp = temp .. tostring(v) .. " "
    end
    log = log .. temp .. "\n"
    dx9.DrawString({1500, 0}, {255, 255, 255}, log)
end

-- Mouse Area Checking
function utility:MouseInArea(area, deadzone)
    assert(type(area) == "table" and #area == 4, "[Error] MouseInArea: First Argument needs to be a table with 4 values!")

    if deadzone then
        if dx9.GetMouse().x > area[1] and dx9.GetMouse().y > area[2] and dx9.GetMouse().x < area[3] and dx9.GetMouse().y < area[4] then
            if dx9.GetMouse().x > deadzone[1] and dx9.GetMouse().y > deadzone[2] and dx9.GetMouse().x < deadzone[3] and dx9.GetMouse().y < deadzone[4] then
                return false
            else
                return true
            end
        else
            return false
        end
    else
        return dx9.GetMouse().x > area[1] and dx9.GetMouse().y > area[2] and dx9.GetMouse().x < area[3] and dx9.GetMouse().y < area[4]
    end
end

-- Convert RGB to Hexadecimal
function utility:rgbToHex(rgb)
    local hexadecimal = "#"
    for _, value in pairs(rgb) do
        local hex = ""
        while value > 0 do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub("0123456789ABCDEF", index, index) .. hex
        end
        if string.len(hex) == 0 then
            hex = "00"
        elseif string.len(hex) == 1 then
            hex = "0" .. hex
        end
        hexadecimal = hexadecimal .. hex
    end
    return hexadecimal
end

-- Get Index from RGB Color
function utility:GetIndex(clr)
    local FirstBarHue = 0
    local CurrentRainbowColor
    for i = 1, 205 do
        if FirstBarHue > 1530 then
            FirstBarHue = 0
        end
        if FirstBarHue <= 255 then
            CurrentRainbowColor = {255, FirstBarHue, 0}
        elseif FirstBarHue <= 510 then
            CurrentRainbowColor = {510 - FirstBarHue, 255, 0}
        elseif FirstBarHue <= 765 then
            CurrentRainbowColor = {0, 255, FirstBarHue - 510}
        elseif FirstBarHue <= 1020 then
            CurrentRainbowColor = {0, 1020 - FirstBarHue, 255}
        elseif FirstBarHue <= 1275 then
            CurrentRainbowColor = {FirstBarHue - 1020, 0, 255}
        elseif FirstBarHue <= 1530 then
            CurrentRainbowColor = {255, 0, 1530 - FirstBarHue}
        end
        FirstBarHue = FirstBarHue + 7.5
        local SecondBarHue = 0
        for v = 1, 205 do
            local Color = {0, 0, 0}
            if SecondBarHue > 765 then
                SecondBarHue = 0
            end
            if SecondBarHue < 255 then
                Color = {
                    CurrentRainbowColor[1] * (SecondBarHue / 255),
                    CurrentRainbowColor[2] * (SecondBarHue / 255),
                    CurrentRainbowColor[3] * (SecondBarHue / 255)
                }
            elseif SecondBarHue < 510 then
                Color = {
                    CurrentRainbowColor[1] + (SecondBarHue - 255),
                    CurrentRainbowColor[2] + (SecondBarHue - 255),
                    CurrentRainbowColor[3] + (SecondBarHue - 255)
                }
            else
                Color = {
                    255 - (SecondBarHue - 510),
                    255 - (SecondBarHue - 510),
                    255 - (SecondBarHue - 510)
                }
            end
            SecondBarHue = SecondBarHue + 3.75
            for j = 1, 3 do
                if Color[j] > 255 then
                    Color[j] = 255
                end
            end
            if Color[1] > (clr[1] - 2) and Color[1] < (clr[1] + 2) and
               Color[2] > (clr[2] - 2) and Color[2] < (clr[2] + 2) and
               Color[3] > (clr[3] - 2) and Color[3] < (clr[3] + 2) then
                return {v, i}
            end
        end
    end
end

-- Dynamic Window Management
local library = {}
function library:CreateWindow(params)
    assert(type(params) == "table", "[Error] CreateWindow: Parameter must be a table!")
    local WindowName = params.Name or params.Title
    local StartRainbow = params.Rainbow or params.RGB or false
    local ToggleKeyPreset = "[ESCAPE]"
    if params.ToggleKey and type(params.ToggleKey) == "string" then
        ToggleKeyPreset = string.upper(params.ToggleKey)
    end
    local resizable = params.Resizable or false
    assert(type(WindowName) == "string" or type(WindowName) == "number", "[ERROR] CreateWindow: Window name parameter must be a string or number!")
    assert(type(StartRainbow) == "boolean", "[ERROR] CreateWindow: Rainbow parameter must be a boolean!")
    assert(type(ToggleKeyPreset) == "string" and string.sub(ToggleKeyPreset, 1, 1) == "[", "[ERROR] CreateWindow: ToggleKey needs to have this format: [KEY]!")
    if library.Windows[WindowName] == nil then
        library.Windows[WindowName] = {
            Location = params.StartLocation or {100, 100},
            Size = params.Size or {600, 500},
            Rainbow = StartRainbow,
            Title = WindowName,
            WinMouseOffset = nil,
            WindowNum = library.WindowCount + 1,
            ID = params.Index or WindowName,
            Tabs = {},
            CurrentTab = nil,
            TabMargin = 0,
            Dragging = false,
            Resizing = false,
            ToggleKeyHolding = false,
            ToggleKeyHovering = false,
            ToggleKey = ToggleKeyPreset,
            ToggleReading = false,
            RGBKeyHolding = false,
            RGBKeyHovering = false,
            Active = true,
            FooterToggle = true,
            FooterRGB = true,
            FooterMouseCoords = true,
            Restraint = {160, 200},
            InitIndex = 0,
            DeadZone = nil,
            OpenTool = nil,
            FontColor = params.FontColor or library.FontColor,
            MainColor = params.MainColor or library.MainColor,
            BackgroundColor = params.BackgroundColor or library.BackgroundColor,
            AccentColor = params.AccentColor or library.AccentColor,
            OutlineColor = params.OutlineColor or library.OutlineColor
        }
        library.WindowCount = library.WindowCount + 1
    end
    local Win = library.Windows[WindowName]
    -- Additional logic to manage window rendering can be added here
end

-- Add more features and extracted components to extend functionality!
