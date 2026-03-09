-- Advanced ESP Script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP = {}

function ESP:Add(player)

    if player == LocalPlayer then return end

    local function setup(character)

        if character:FindFirstChild("ESP_Highlight") then return end

        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(255,0,0)
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
        highlight.Parent = character

        -- Name + Distance GUI
        local head = character:WaitForChild("Head")

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_GUI"
        billboard.Size = UDim2.new(0,200,0,50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0,2,0)
        billboard.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.SourceSansBold
        label.TextScaled = true
        label.Parent = billboard

        RunService.RenderStepped:Connect(function()

            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

                local distance = (LocalPlayer.Character.HumanoidRootPart.Position -
                    player.Character.HumanoidRootPart.Position).Magnitude

                label.Text = player.Name.." | "..math.floor(distance).."m"

            end

        end)

    end

    if player.Character then
        setup(player.Character)
    end

    player.CharacterAdded:Connect(setup)

end


-- تطبيق ESP على اللاعبين
for _,player in pairs(Players:GetPlayers()) do
    ESP:Add(player)
end

-- تطبيق على اللاعبين الجدد
Players.PlayerAdded:Connect(function(player)
    ESP:Add(player)
end)

print("Advanced ESP Loaded")
