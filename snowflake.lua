-- Snowflake Farmer + Discord Webhook (Stable)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")

local plr = Players.LocalPlayer

-- character loader
local function getChar()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, hrp
end

local char, hrp = getChar()

plr.CharacterAdded:Connect(function()
    char, hrp = getChar()
end)

-- CONFIG
local SnowflakeId = "rbxassetid://6087969886"

local webhook = "https://discord.com/api/webhooks/1394325159766396979/fuN_AZlhobPLeiciOaOvEl6EuBVknbC-IIMyn17tl0TUJP_jEr-v5fADnaM7S_BBSFU_"

local blacklist = {}
local collected = 0
local paused = false

local startTime = os.time()
local lastWebhook = 0

print("Snowflake script loaded")

-- UI
local gui = Instance.new("ScreenGui")
gui.Parent = plr:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local text = Instance.new("TextLabel", gui)
text.Size = UDim2.new(0,200,0,40)
text.Position = UDim2.new(0.5,-100,0,100)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.new(1,1,1)
text.TextScaled = true
text.Text = "Snowflakes: 0"

local pauseBtn = Instance.new("TextButton", gui)
pauseBtn.Size = UDim2.new(0,120,0,30)
pauseBtn.Position = UDim2.new(0.5,-60,0,140)
pauseBtn.Text = "Pause"
pauseBtn.BackgroundTransparency = 1
pauseBtn.TextColor3 = Color3.new(1,1,1)
pauseBtn.TextScaled = true

local function updateUI()
    text.Text = "Snowflakes: "..collected
end

pauseBtn.MouseButton1Click:Connect(function()
    paused = not paused
    pauseBtn.Text = paused and "Resume" or "Pause"
end)

-- snowflake/min
local function getRate()
    local elapsed = os.time() - startTime
    if elapsed <= 0 then return 0 end
    return math.floor((collected/elapsed)*60)
end

-- webhook sender
local function sendWebhook()

    if os.time() - lastWebhook < 10 then
        return
    end

    lastWebhook = os.time()

    local data = {
        ["embeds"] = {{
            ["title"] = "❄️ Snowflake Farmer",
            ["color"] = 5814783,
            ["fields"] = {

                {
                    ["name"] = "Player",
                    ["value"] = plr.Name,
                    ["inline"] = true
                },

                {
                    ["name"] = "Snowflakes",
                    ["value"] = tostring(collected),
                    ["inline"] = true
                },

                {
                    ["name"] = "Snowflakes/min",
                    ["value"] = tostring(getRate()),
                    ["inline"] = true
                },

                {
                    ["name"] = "Server",
                    ["value"] = game.JobId
                }

            }
        }}
    }

    local req = request or http_request or syn.request or fluxus.request

    if req then
        req({
            Url = webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end

end

-- blacklist check
local function IsBlacklisted(pos)
    for _,v in pairs(blacklist) do
        if (v - pos).Magnitude < 5 then
            return true
        end
    end
    return false
end

-- find effect
local function GetEffect()

    local folder = workspace:FindFirstChild("Particles")
    if not folder then return end

    local snow = folder:FindFirstChild("Snowflakes")
    if not snow then return end

    local closest
    local dist = math.huge

    for _,v in pairs(snow:GetChildren()) do

        if v:IsA("BasePart") and not IsBlacklisted(v.Position) then

            local mag = (v.Position - hrp.Position).Magnitude

            if mag < dist then
                dist = mag
                closest = v
            end

        end

    end

    return closest
end

-- find token
local function GetToken(pos)

    local col = workspace:FindFirstChild("Collectibles")
    if not col then return end

    for _,v in pairs(col:GetChildren()) do

        if v:FindFirstChild("FrontDecal")
        and v.FrontDecal.Texture == SnowflakeId then

            if (v.Position - pos).Magnitude < 15 then
                return v
            end

        end

    end

end

-- teleport
local function TP(pos)
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
    end
end

-- chat detect
TextChatService.OnIncomingMessage = function(msg)

    if msg.Text then

        local t = msg.Text:lower()

        if t:find("+1") and t:find("snowflake") then

            collected += 1
            updateUI()

            print("Snowflake collected:", collected)

            if collected % 5 == 0 then
                sendWebhook()
            end

        end

    end

end

-- main loop
while task.wait(0.1) do

    if paused then
        continue
    end

    local eff = GetEffect()

    if eff then

        local pos = eff.Position

        TP(pos)

        task.wait(0.15)

        local token = GetToken(pos)

        if token then

            TP(token.Position)

            task.wait(0.25)

            if token.Parent then
                table.insert(blacklist,pos)
            end

        else
            table.insert(blacklist,pos)
        end

    end

end
