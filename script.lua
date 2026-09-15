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
local AimPart = "Head" 

-- НАСТРОЙКИ FOV
local FOV_Radius = 150 -- Радиус фова по умолчанию
local isAiming = false

----------------------------------------------------------------
-- 1. СОЗДАНИЕ КРУГА FOV (РИСОВАНИЕ)
----------------------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 60, 60)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = FOV_Radius
FOVCircle.Filled = false
FOVCircle.Visible = true

----------------------------------------------------------------
-- 2. СОЗДАНИЕ ИНТЕРФЕЙСА (GUI)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui") end
ScreenGui.Name = "AdminMenu_Roblox"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 260) -- Увеличил размер под FOV
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "  OWNER MENU (v1.2)"
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Функция для быстрой сборки кнопок
local function createButton(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = MainFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local ESPButton = createButton("ESP: ON", UDim2.new(0, 20, 0, 50), Color3.fromRGB(0, 150, 0))
local AimButton = createButton("AIMBOT: ON", UDim2.new(0, 20, 0, 95), Color3.fromRGB(0, 150, 0))
local TargetButton = createButton("TARGET: HEAD", UDim2.new(0, 20, 0, 140), Color3.fromRGB(45, 45, 45))
TargetButton.TextColor3 = Color3.fromRGB(255, 215, 0)

-- Новая кнопка регулировки FOV
local FOVButton = createButton("FOV RADIUS: 150", UDim2.new(0, 20, 0, 185), Color3.fromRGB(45, 45, 45))
FOVButton.TextColor3 = Color3.fromRGB(0, 200, 255)

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
-- 3. КНОПКИ И УПРАВЛЕНИЕ С КЛАВИАТУРЫ
----------------------------------------------------------------
local function clearAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("ESPHighlight") then
            p.Character.ESPHighlight:Destroy()
        end
    end
end

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

AimButton.MouseButton1Click:Connect(function()
    Aimbot_Enabled = not Aimbot_Enabled
    if Aimbot_Enabled then
        AimButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        AimButton.Text = "AIMBOT: ON"
        FOVCircle.Visible = true
    else
        AimButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        AimButton.Text = "AIMBOT: OFF"
        FOVCircle.Visible = false
        isAiming = false
    end
end)

TargetButton.MouseButton1Click:Connect(function()
    if AimPart == "Head" then
        AimPart = "Torso"
        TargetButton.Text = "TARGET: TORSO"
    else
        AimPart = "Head"
        TargetButton.Text = "TARGET: HEAD"
    end
end)

-- Переключение радиуса FOV по клику (100 -> 150 -> 200 -> 0/Off)
FOVButton.MouseButton1Click:Connect(function()
    if FOV_Radius == 100 then
        FOV_Radius = 150
    elseif FOV_Radius == 150 then
        FOV_Radius = 200
    elseif FOV_Radius == 200 then
        FOV_Radius = 100
    end
    FOVCircle.Radius = FOV_Radius
    FOVButton.Text = "FOV RADIUS: " .. tostring(FOV_Radius)
end)

-- Скрытие меню на Z
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        Menu_Open = not Menu_Open
        MainFrame.Visible = Menu_Open
        if Aimbot_Enabled then
            FOVCircle.Visible = Menu_Open -- Круг тоже скрывается вместе с меню
        end
    end
end)

----------------------------------------------------------------
-- 4. СКРИПТОВАЯ ЧАСТЬ (АИМ, ЖЕСТКИЙ TEAM CHECK И КРУГ)
----------------------------------------------------------------

-- Проверка: Враг ли это? (Жесткий фильтр команд)
local function isEnemy(player)
    if player == localPlayer then return false end
    
    -- Проверка по системе команд Roblox
    if localPlayer.Team ~= nil and player.Team ~= nil then
        if localPlayer.Team == player.Team then
            return false -- Одинаковая команда -> НЕ враг
        end
    end
    
    -- Дополнительная проверка, если в игре кастомные тимы через свойства TeamColor
    if localPlayer.TeamColor == player.TeamColor and localPlayer.TeamColor ~= BrickColor.new("White") then
        return false
    end

    return true
end

local function getTargetPart(character)
    if AimPart == "Head" then
        return character:FindFirstChild("Head")
    else
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end
end

-- Безопасный цикл для ESP (Обновление кадров)
RunService.RenderStepped:Connect(function()
    -- Обновляем позицию круга FOV за мышкой
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos

    if not ESP_Enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local highlight = character:FindFirstChild("ESPHighlight")
            
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
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

-- Поиск цели ТОЛЬКО внутри FOV
local function getClosestTargetInFOV()
    local closestPart = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local targetPart = getTargetPart(player.Character)
                
                if targetPart then
                    -- Переводим 3D координаты части тела врага в 2D координаты экрана
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        -- Считаем расстояние от курсора мыши до цели на экране
                        local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        -- Если цель находится внутри круга FOV
                        if magnitude <= FOV_Radius and magnitude < shortestDistance then
                            shortestDistance = magnitude
                            closestPart = targetPart
                        end
                    end
                end
            end
        end
    end
    return closestPart
end

-- Нажатие ПКМ
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

-- Доводка камеры
RunService.RenderStepped:Connect(function()
    if isAiming and Aimbot_Enabled then
        local target = getClosestTargetInFOV()
        if target then
