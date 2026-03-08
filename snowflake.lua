local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local webhook = "https://discord.com/api/webhooks/1394325159766396979/fuN_AZlhobPLeiciOaOvEl6EuBVknbC-IIMyn17tl0TUJP_jEr-v5fADnaM7S_BBSFU_"

local collected = {}

function sendWebhook()
    local data = {
        ["content"] = "❄️ Snowflake collected!"
    }

    local body = HttpService:JSONEncode(data)

    request({
        Url = webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = body
    })
end

function collect(token)
    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    root.CFrame = token.CFrame + Vector3.new(0,3,0)
end

while task.wait(0.5) do
    local collectibles = workspace:FindFirstChild("Collectibles")

    if collectibles then
        for _,v in pairs(collectibles:GetChildren()) do

            if v.Name == "Snowflake" and not collected[v] then

                -- chỉ lấy khi snowflake đã gần mặt đất
                if v.Position.Y < 20 then

                    collected[v] = true
                    collect(v)
                    sendWebhook()

                    task.wait(2)

                end
            end

        end
    end
end
