local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local webhook = "https://discord.com/api/webhooks/1394325159766396979/fuN_AZlhobPLeiciOaOvEl6EuBVknbC-IIMyn17tl0TUJP_jEr-v5fADnaM7S_BBSFU_"

local collected = {}

local function root()
    local char = player.Character
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart")
end

local function sendWebhook()

    if webhook == "" then return end

    local data = {
        ["content"] = "❄️ Snowflake collected"
    }

    pcall(function()
        request({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"]="application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)

end

local function teleport(token)

    local r = root()
    if not r then return end

    r.CFrame = token.CFrame + Vector3.new(0,3,0)

end

local function tokenFolder()
    return workspace:FindFirstChild("Collectibles") or workspace:FindFirstChild("Tokens")
end


while task.wait(0.3) do

    local folder = tokenFolder()
    if not folder then continue end

    for _,v in pairs(folder:GetChildren()) do

        if v:IsA("BasePart") and v.Name:find("Snowflake") and not collected[v] then

            collected[v] = true

            -- chờ snowflake rơi xong
            task.wait(1.2)

            teleport(v)
            sendWebhook()

        end

    end

end
