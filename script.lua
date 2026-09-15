local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- НАСТРОЙКИ ФУНКЦИЙ (по умолчанию включены)
local ESP_Enabled = true
local Aimbot_Enabled = true
local Menu_Open = true

local maxDistance = 500
local isAiming = false

----------------------------------------------------------------
-- 1. СОЗДАНИЕ ИНТЕРФЕЙСА (GUI) ПОЛНОСТЬЮ ИЗ КОДА
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
-- Попытка поместить в CoreGui, чтобы меню не пропадало при респавне. 
-- Если прав в Студии не хватит, автоматически упадет в PlayerGui.
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end
ScreenGui.Name = "CheatMenu_Roblox"
ScreenGui.ResetOnSpawn = false

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно перетаскивать мышкой
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "  OWNER MENU (v1.0)"
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Кнопка переключения ESP
local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(0, 180, 0, 35)
ESPButton.Position = UDim2.new(0, 20, 0, 55)
ESPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ESPButton.Text = "ESP: ON"
ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPButton.Font = Enum.Font.SourceSansBold
ESPButton.TextSize = 16
ESPButton.Parent = MainFrame

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 6)
BtnCorner1.Parent = ESPButton

-- Кнопка переключения Аимбота
local AimButton = Instance.new("TextButton")
AimButton.Size = UDim2.new(0, 180, 0, 35)
AimButton.Position = UDim2.new(0, 20, 0, 105)
AimButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
AimButton.Text = "AIMBOT: ON"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.Font = Enum.Font.SourceSansBold
AimButton.TextSize = 16
AimButton.Parent = MainFrame

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 6)
BtnCorner2.Parent = AimButton

-- Подсказка внизу меню (изменена на Z)
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
-- 2. ИНТЕРАКТИВНОСТЬ МЕНЮ (КЛИКИ И КЛАВИШИ)
----------------------------------------------------------------
-- Клик по кнопке ESP
ESPButton.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    if ESP_Enabled then
        ESPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        ESPButton.Text = "ESP: ON"
    else
        ESPButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        ESPButton.Text = "ESP: OFF"
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESPHighlight") then
                p.Character.ESPHighlight:Destroy()
            end
        end
    end
end)

-- Клик по кнопке Аимбота
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

-- Открытие/Закрытие меню по нажатию клавиши Z
UserInputService.InputBegan:Connect(function(input, processed)
    -- processed игнорирует нажатие, если игрок в этот момент пишет букву 'Z' в чат
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        Menu_Open = not Menu_Open
        MainFrame.Visible = Menu_Open
    end
end)

----------------------------------------------------------------
-- 3. СКРИПТОВАЯ ЧАСТЬ (ESP И AIMBOT) НА КЛИЕНТЕ
----------------------------------------------------------------

-- Функция создания подсветки
local function applyESP(character, player)
    if player == localPlayer then return end
    character:WaitForChild("Head", 10)
    
    RunService.RenderStepped:Connect(function()
        if ESP_Enabled and player.Character == character and character:FindFirstChild("Head") then
            if not character:FindFirstChild("ESPHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = character
                highlight.Parent = character
            end
        else
            if character:FindFirstChild("ESPHighlight") then
                character.ESPHighlight:Destroy()
            end
        end
    end)
end

local function monitorPlayer(player)
    if player.Character then applyESP(player.Character, player) end
    player.CharacterAdded:Connect(function(char)
        applyESP(char, player)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do monitorPlayer(p) end
Players.PlayerAdded:Connect(monitorPlayer)

-- Поиск цели для Аима
local function getClosestHead()
    local closestHead = nil
    local shortestDistance = maxDistance

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local head = player.Character.Head
                local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
                if myHead then
                    local distance = (myHead.Position - head.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestHead = head
                    end
                end
            end
        end
    end
    return closestHead
end

-- Управление зажатием ПКМ
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

-- Кадровая обработка аима
RunService.RenderStepped:Connect(function()
    if isAiming and Aimbot_Enabled then
        local targetHead = getClosestHead()
        if targetHead then
            local targetCFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.15)
        end
    end
end)

print("[Система] Меню админа загружено. Переключение на клавишу Z.")local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- НАСТРОЙКИ ФУНКЦИЙ (по умолчанию включены)
local ESP_Enabled = true
local Aimbot_Enabled = true
local Menu_Open = true

local maxDistance = 500
local isAiming = false

----------------------------------------------------------------
-- 1. СОЗДАНИЕ ИНТЕРФЕЙСА (GUI) ПОЛНОСТЬЮ ИЗ КОДА
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
-- Попытка поместить в CoreGui, чтобы меню не пропадало при респавне. 
-- Если прав в Студии не хватит, автоматически упадет в PlayerGui.
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end
ScreenGui.Name = "CheatMenu_Roblox"
ScreenGui.ResetOnSpawn = false

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно перетаскивать мышкой
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "  OWNER MENU (v1.0)"
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Кнопка переключения ESP
local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(0, 180, 0, 35)
ESPButton.Position = UDim2.new(0, 20, 0, 55)
ESPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ESPButton.Text = "ESP: ON"
ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPButton.Font = Enum.Font.SourceSansBold
ESPButton.TextSize = 16
ESPButton.Parent = MainFrame

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 6)
BtnCorner1.Parent = ESPButton

-- Кнопка переключения Аимбота
local AimButton = Instance.new("TextButton")
AimButton.Size = UDim2.new(0, 180, 0, 35)
AimButton.Position = UDim2.new(0, 20, 0, 105)
AimButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
AimButton.Text = "AIMBOT: ON"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.Font = Enum.Font.SourceSansBold
AimButton.TextSize = 16
AimButton.Parent = MainFrame

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 6)
BtnCorner2.Parent = AimButton

-- Подсказка внизу меню (изменена на Z)
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
-- 2. ИНТЕРАКТИВНОСТЬ МЕНЮ (КЛИКИ И КЛАВИШИ)
----------------------------------------------------------------
-- Клик по кнопке ESP
ESPButton.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    if ESP_Enabled then
        ESPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        ESPButton.Text = "ESP: ON"
    else
        ESPButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        ESPButton.Text = "ESP: OFF"
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESPHighlight") then
                p.Character.ESPHighlight:Destroy()
            end
        end
    end
end)

-- Клик по кнопке Аимбота
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

-- Открытие/Закрытие меню по нажатию клавиши Z
UserInputService.InputBegan:Connect(function(input, processed)
    -- processed игнорирует нажатие, если игрок в этот момент пишет букву 'Z' в чат
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        Menu_Open = not Menu_Open
        MainFrame.Visible = Menu_Open
    end
end)

----------------------------------------------------------------
-- 3. СКРИПТОВАЯ ЧАСТЬ (ESP И AIMBOT) НА КЛИЕНТЕ
----------------------------------------------------------------

-- Функция создания подсветки
local function applyESP(character, player)
    if player == localPlayer then return end
    character:WaitForChild("Head", 10)
    
    RunService.RenderStepped:Connect(function()
        if ESP_Enabled and player.Character == character and character:FindFirstChild("Head") then
            if not character:FindFirstChild("ESPHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = character
                highlight.Parent = character
            end
        else
            if character:FindFirstChild("ESPHighlight") then
                character.ESPHighlight:Destroy()
            end
        end
    end)
end

local function monitorPlayer(player)
    if player.Character then applyESP(player.Character, player) end
    player.CharacterAdded:Connect(function(char)
        applyESP(char, player)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do monitorPlayer(p) end
Players.PlayerAdded:Connect(monitorPlayer)

-- Поиск цели для Аима
local function getClosestHead()
    local closestHead = nil
    local shortestDistance = maxDistance

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local head = player.Character.Head
                local myHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
                if myHead then
                    local distance = (myHead.Position - head.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestHead = head
                    end
                end
            end
        end
    end
    return closestHead
end

-- Управление зажатием ПКМ
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

-- Кадровая обработка аима
RunService.RenderStepped:Connect(function()
    if isAiming and Aimbot_Enabled then
        local targetHead = getClosestHead()
        if targetHead then
            local targetCFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.15)
        end
    end
end)

print("[Система] Меню админа загружено. Переключение на клавишу Z.")