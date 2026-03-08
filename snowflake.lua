local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local webhook = "https://discord.com/api/webhooks/1394325159766396979/fuN_AZlhobPLeiciOaOvEl6EuBVknbC-IIMyn17tl0TUJP_jEr-v5fADnaM7S_BBSFU_"

local collected = {}

local function getRoot()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function sendWebhook(msg)

    local data = {
        ["content"] = msg
    }

    local body = HttpService:JSONEncode(data)

    pcall(function()
        request({
            Url = webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = body
        })
    end)

end

local function getTokenFolder()
    return workspace:FindFirstChild("Collectibles") or workspace:FindFirstChild("Tokens")
end

local function teleport(token)

    local root = getRoot()
    if not root then return end

    root.CFrame = token.CFrame + Vector3.new(0,3,0)

end

while task.wait(0.2) do

    local folder = getTokenFolder()
    if not folder then continue end

    for _,token in pairs(folder:GetChildren()) do

        if token:IsA("BasePart") then

            if token.Name:find("Snowflake") and not collected[token] then

                if token.Position.Y < 25 then

                    collected[token] = true

                    teleport(token)

                    sendWebhook("❄️ Snowflake collected!")

                    task.wait(1)

                end

            end

        end

    end

end
