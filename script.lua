local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- НАСТРОЙКИ ФУНКЦИЙ
local ESP_Enabled = true
local Aimbot_Enabled = true
local Menu_Open = true
local AimPart = "Head" 

-- НАСТРОЙКИ FOV
local FOV_Radius = 150 
local isAiming = false

----------------------------------------------------------------
-- 1. СОЗДАНИЕ ИНТЕРФЕЙСА И КРУГА FOV НА СТАНДАРТНОМ UI
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminMenu_Roblox"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Создаем легитимный круг FOV через ImageLabel
local FOVCircle = Instance.new("ImageLabel")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Size = UDim2.new(0, FOV_Radius * 2, 0, FOV_Radius * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Image = "rbxassetid://12321451515" -- ID текстуры чистого круга (контур)
FOVCircle.ImageColor3 = Color3.fromRGB(255, 60, 60)
FOVCircle.Visible = true
FOVCircle.Parent = ScreenGui

-- Если ID выше не загрузится, используем резервный вариант (белый круг Roblox)
if FOVCircle.Image == "" then
    FOVCircle.Image = "rbxassetid://2327072517"
end

-- Главная панель меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 260)
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
Title.Text = "  OWNER MENU (v1.3)"
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Конструктор кнопок
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
-- 2. УПРАВЛЕНИЕ И КЛИКИ
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

FOVButton.MouseButton1Click:Connect(function()
    if FOV_Radius == 100 then
        FOV_Radius = 150
    elseif FOV_Radius == 150 then
        FOV_Radius = 200
    elseif FOV_Radius == 200 then
        FOV_Radius = 100
    end
    FOVCircle.Size = UDim2.new(0, FOV_Radius * 2, 0, FOV_Radius * 2)
    FOVButton.Text = "FOV RADIUS: " .. tostring(FOV_Radius)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        Menu_Open = not Menu_Open
        MainFrame.Visible = Menu_Open
        if Aimbot_Enabled then
            FOVCircle.Visible = Menu_Open
        end
    end
end)

----------------------------------------------------------------
-- 3. ЛОГИКА СОРЕВНОВАТЕЛЬНОЙ ПРОВЕРКИ (БЕЗ ТИМЕЙТОВ)
----------------------------------------------------------------
local function isEnemy(player)
    if player == localPlayer then return false end
    
    -- Жесткая проверка команд через стандартный TeamService
    if localPlayer.Team ~= nil and player.Team ~= nil then
        return localPlayer.Team ~= player.Team
    end
    
    -- Проверка на случай кастомных цветов команд (без TeamService)
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

-- Основной цикл обновления кадров
RunService.RenderStepped:Connect(function()
    -- Ведем круг FOV строго по центру экрана (за курсором мыши)
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)

    -- Обновление ESP
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local highlight = character:FindFirstChild("ESPHighlight")
            
            if ESP_Enabled and isEnemy(player) and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
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

-- Поиск цели только в круге FOV
local function getClosestTargetInFOV()
    local closestPart = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local targetPart = getTargetPart(player.Character)
                
                if targetPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
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

-- Считывание зажатия ПКМ
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

-- Плавная наводка камеры
RunService.RenderStepped:Connect(function()
    if isAiming and Aimbot_Enabled then
        local target = getClosestTargetInFOV()
        if target then
            local targetCFrame = CFrame.new(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.2)
        end
    end
end)
