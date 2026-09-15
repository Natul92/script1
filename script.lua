local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- НАСТРОЙКИ ФУНКЦИЙ
local ESP_Enabled = true
local Aimbot_Enabled = true
local Menu_Open = true
local AimPart = "Head" -- Варианты: "Head" или "UpperTorso" (для R15) / "Torso" (для R6)

local maxDistance = 500
local isAiming = false

----------------------------------------------------------------
-- 1. СОЗДАНИЕ ИНТЕРФЕЙСА (GUI)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui") end
ScreenGui.Name = "AdminMenu_Roblox"
ScreenGui.ResetOnSpawn = false

-- Главная панель (увеличил высоту до 220 для новой кнопки)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "  OWNER MENU (v1.1)"
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Кнопка ESP
local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(0, 180, 0, 35)
ESPButton.Position = UDim2.new(0, 20, 0, 50)
ESPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ESPButton.Text = "ESP: ON"
ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPButton.Font = Enum.Font.SourceSansBold
ESPButton.TextSize = 16
ESPButton.Parent = MainFrame

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 6)
BtnCorner1.Parent = ESPButton

-- Кнопка Аимбота
local AimButton = Instance.new("TextButton")
AimButton.Size = UDim2.new(0, 180, 0, 35)
AimButton.Position = UDim2.new(0, 20, 0, 95)
AimButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
AimButton.Text = "AIMBOT: ON"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.Font = Enum.Font.SourceSansBold
AimButton.TextSize = 16
AimButton.Parent = MainFrame

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 6)
BtnCorner2.Parent = AimButton

-- Кнопка выбора части тела (Цель)
local TargetButton = Instance.new("TextButton")
TargetButton.Size = UDim2.new(0, 180, 0, 35)
TargetButton.Position = UDim2.new(0, 20, 0, 140)
TargetButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TargetButton.Text = "TARGET: HEAD"
TargetButton.TextColor3 = Color3.fromRGB(255, 215, 0)
TargetButton.Font = Enum.Font.SourceSansBold
TargetButton.TextSize = 16
TargetButton.Parent = MainFrame

local BtnCorner3 = Instance.new("UICorner")
BtnCorner3.CornerRadius = UDim.new(0, 6)
BtnCorner3.Parent = TargetButton

-- Подсказка
local TipText = Instance.new("TextLabel")
TipText.Size = UDim2.new(1, 0, 0, 25)
TipText.Position = UDim2.new(0, 0, 1, -25)
TipText.BackgroundTransparency = 1
TipText.Text = "Нажми [Z] чтобы скрыть/показать"
TipText.TextColor3 = Color3.fromRGB(150, 150, 150)
TipText.Font = Enum.Font.SourceSansItalic
TipText.TextSize = 12
TipText.Parent = MainFrame

----------------------------------------------------------------
-- 2. ФУНКЦИИ И ОЧИСТКА ESP
----------------------------------------------------------------
local function clearAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local highlight = p.Character:FindFirstChild("ESPHighlight")
            if highlight then highlight:Destroy() end
        end
    end
end

-- Клик ESP
ESPButton.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    if ESP_Enabled then
        ESPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        ESPButton.Text = "ESP: ON"
    else
        ESPButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        ESPButton.Text = "ESP: OFF"
        clearAllESP()
    end
end)

-- Клик Аимбот
AimButton.MouseButton1Click:Connect(function()
    Aimbot_Enabled = not Aimbot_Enabled
    if Aimbot_Enabled then
        AimButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        AimButton.Text = "AIMBOT: ON"
    else
        AimButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        AimButton.Text = "AIMBOT: OFF"
        isAiming = false
    end
end)

-- Клик Выбор цели (Голова / Тело)
TargetButton.MouseButton1Click:Connect(function()
    if AimPart == "Head" then
        AimPart = "Torso"
        TargetButton.Text = "TARGET: TORSO"
    else
        AimPart = "Head"
        TargetButton.Text = "TARGET: HEAD"
    end
end)

-- Открытие на Z
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        Menu_Open = not Menu_Open
        MainFrame.Visible = Menu_Open
    end
end)

----------------------------------------------------------------
-- 3. СКРИПТОВАЯ ЧАСТЬ (TEAM CHECK + ФИКС КНОПОК)
----------------------------------------------------------------

-- Проверка на союзника
local function isEnemy(player)
    if player == localPlayer then return false end
    -- Если у игроков разные команды или команд в игре вообще нет — это враг
    if localPlayer.Team and player.Team and localPlayer.Team == player.Team then
        return false
    end
    return true
end

-- Поиск нужной кости/парт-объекта у персонажа
local function getTargetPart(character)
    if AimPart == "Head" then
        return character:FindFirstChild("Head")
    else
        -- Поддержка R15 (UpperTorso) и R6 (Torso)
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end
end

-- Логика постоянного обновления ESP (работает без багов при выключении)
RunService.RenderStepped:Connect(function()
    if not ESP_Enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local highlight = character:FindFirstChild("ESPHighlight")
            
            -- Показываем ESP только если это враг и он жив
            if isEnemy(player) and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = character
                    highlight.Parent = character
                end
            else
                -- Если сменил команду на союзника или умер — удаляем ESP
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

-- Поиск ближайшего врага для Аима
local function getClosestTarget()
    local closestPart = nil
    local shortestDistance = maxDistance

    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local targetPart = getTargetPart(player.Character)
                local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
                
                if targetPart and myHead then
                    local distance = (myHead.Position - targetPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPart = targetPart
                    end
                end
            end
        end
    end
    return closestPart
end

-- Зажатие мышки
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end 
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Aimbot_Enabled then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
    end
end)

-- Слежение камеры
RunService.RenderStepped:Connect(function()
    if isAiming and Aimbot_Enabled then
        local target = getClosestTarget()
        if target then
            local targetCFrame = CFrame.new(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.15)
        end
    end
end)
