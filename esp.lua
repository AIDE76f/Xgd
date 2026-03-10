-- ESP Script + Aimbot خارق
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== إعدادات aimbot ==========
local AimbotEnabled = true          -- تشغيل الـ aimbot
local AimbotKey = Enum.KeyCode.LeftShift   -- زر التفعيل (يمكن تغييره)
local TargetPart = "Head"            -- الجزء المستهدف: "Head" أو "HumanoidRootPart"
local Smoothness = 0.5                -- 0 = فوري، 1 = بطيء جداً (يُفضل 0.2 إلى 0.5)
local MaxDistance = 1000               -- أقصى مسافة للتصويب
local ShowFOV = true                   -- عرض دائرة مجال الرؤية
local FOVSize = 150                     -- حجم دائرة FOV (بالعرض)

-- متغيرات داخلية
local aimbotActive = false
local currentTarget = nil

-- ========== دوال الـ ESP ==========
local function createESP(player)
    if player ~= LocalPlayer and player.Character then
        -- إضافة Highlight (إطار)
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.FillColor = Color3.new(1, 0, 0)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Adornee = player.Character
        -- إضافة Billboard لعرض الاسم والمسافة
        local head = player.Character:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP_GUI"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Parent = head

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
            label.TextScaled = true
            label.Parent = billboard

            -- تحديث النص بالمسافة
            local function updateDistance()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    label.Text = player.Name .. " [" .. math.floor(dist) .. "m]"
                end
            end
            RunService.RenderStepped:Connect(updateDistance)
        end
    end
end

-- تطبيق ESP على اللاعبين الحاليين والجدد
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)

-- تحديث الـ ESP عند تغيير الشخصية
local function onCharacterAdded(character)
    wait(0.5) -- انتظار حتى تكتمل الشخصية
    createESP(Players:GetPlayerFromCharacter(character))
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- ========== دوال الـ Aimbot ==========
-- دالة لجلب أقرب لاعب إلى نقطة التصويب
local function getClosestPlayer()
    local closestDistance = math.huge
    local closestPlayer = nil
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TargetPart) then
            local part = player.Character[TargetPart]
            local partPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local screenPos = Vector2.new(partPos.X, partPos.Y)
                local dist = (screenPos - mousePos).Magnitude
                if dist < closestDistance and dist <= FOVSize then
                    closestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- دالة التصويب السلس
local function smoothAim(target)
    if target and target.Character and target.Character:FindFirstChild(TargetPart) then
        local targetPos = target.Character[TargetPart].Position
        local targetScreenPos = Camera:WorldToViewportPoint(targetPos)
        local currentMousePos = UserInputService:GetMouseLocation()
        
        -- حساب الاتجاه الجديد (smooth)
        local delta = Vector2.new(targetScreenPos.X, targetScreenPos.Y) - currentMousePos
        local newPos = currentMousePos + delta * (1 - Smoothness)
        
        -- تحريك الماوس
        mousemoverel and mousemoverel(newPos.X - currentMousePos.X, newPos.Y - currentMousePos.Y)
    end
end

-- كشف الضغط على زر التفعيل
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == AimbotKey then
        aimbotActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == AimbotKey then
        aimbotActive = false
        currentTarget = nil
    end
end)

-- حلقة الـ aimbot الرئيسية
RunService.RenderStepped:Connect(function()
    if AimbotEnabled and aimbotActive then
        currentTarget = getClosestPlayer()
        if currentTarget then
            smoothAim(currentTarget)
        end
    end
end)

-- رسم دائرة FOV على الشاشة (إذا كان ShowFOV مفعلاً)
if ShowFOV then
    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = true
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.new(0, 1, 0)
    fovCircle.Filled = false
    fovCircle.Radius = FOVSize
    fovCircle.Position = UserInputService:GetMouseLocation()
    
    RunService.RenderStepped:Connect(function()
        fovCircle.Position = UserInputService:GetMouseLocation()
    end)
end

print("ESP + Aimbot loaded!")
