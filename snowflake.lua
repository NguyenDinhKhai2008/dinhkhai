-- Snowflake Farmer + Discord Webhook

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")

local SnowflakeId = "rbxassetid://6087969886"

-- WEBHOOK
local webhook = "PUT_YOUR_WEBHOOK_HERE"

local blacklist = {}
local collected = 0
local paused = false

local startTime = os.time()
local lastWebhook = 0

-- UI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
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

-- UI update
local function updateUI()
    text.Text = "Snowflakes: "..collected
end

-- pause
pauseBtn.MouseButton1Click:Connect(function()

    paused = not paused

    if paused then
        pauseBtn.Text = "Resume"
    else
        pauseBtn.Text = "Pause"
    end

end)

-- rate
local function getRate()

    local elapsed = os.time() - startTime

    if elapsed <= 0 then
        return 0
    end

    return math.floor((collected/elapsed)*60)

end

-- webhook
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
                    ["name"] = "Rate/min",
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

-- blacklist
local function IsBlacklisted(pos)

    for _,v in pairs(blacklist) do

        if (v-pos).Magnitude < 5 then
            return true
        end

    end

end

-- effect
local function GetEffect()

    local closest
    local dist = math.huge

    for _,v in pairs(workspace.Particles.Snowflakes:GetChildren()) do

        if not IsBlacklisted(v.Position) then

            local mag = (v.Position - hrp.Position).Magnitude

            if mag < dist then

                dist = mag
                closest = v

            end

        end

    end

    return closest

end

-- token
local function GetToken(pos)

    for _,v in pairs(workspace.Collectibles:GetChildren()) do

        if v:FindFirstChild("FrontDecal")
        and v.FrontDecal.Texture == SnowflakeId then

            if (v.Position-pos).Magnitude < 15 then
                return v
            end

        end

    end

end

-- teleport
local function TP(pos)
    hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
end

-- chat detect
TextChatService.OnIncomingMessage = function(msg)

    if msg.Text then

        local t = msg.Text:lower()

        if t:find("+1") and t:find("snowflake") then

            collected += 1
            updateUI()

            if collected % 5 == 0 then
                sendWebhook()
            end

        end

    end

end

-- main
while task.wait(0.1) do

    if paused then
        continue
    end

    local eff = GetEffect()

    if eff then

        local pos = eff.Position

        TP(pos)

        task.wait(0.1)

        local token = GetToken(pos)

        if token then

            TP(token.Position)

            task.wait(0.2)

            if token.Parent then
                table.insert(blacklist,pos)
            end

        else

            table.insert(blacklist,pos)

        end

    end

end
