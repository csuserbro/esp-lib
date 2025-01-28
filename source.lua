-- ESP Library
local ESP = {}

-- Настройки
ESP.Settings = {
    Players = true,       -- Включить ESP для игроков
    Objects = false,      -- Включить ESP для объектов
    Names = true,         -- Показывать имена
    Boxes = true,         -- Показывать боксы
    Highlight = true,     -- Подсветка
    Distance = true,      -- Показывать дистанцию
    HealthText = true,    -- Показывать здоровье (только для игроков)
    Weapon = true,        -- Показывать оружие (только для игроков)
    TeamCheck = false,    -- Проверка команды
    MaxDistance = 200     -- Максимальная дистанция для ESP
}

-- Цвета
ESP.Colors = {
    Enemy = Color3.fromRGB(255, 0, 0),    -- Цвет врагов
    Ally = Color3.fromRGB(0, 255, 0),     -- Цвет союзников
    Object = Color3.fromRGB(0, 255, 255)  -- Цвет объектов
}

-- Командные настройки
ESP.TeamSettings = {
    LocalTeam = "",       -- Название вашей команды
    EnemyTeams = {}       -- Названия вражеских команд
}

-- Внутренние данные
ESP._connections = {}
ESP._objects = {}

-- Функция для создания текста
local function createText(parent, text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = parent
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14

    return billboard
end

-- Функция для создания бокса
local function createBox(part, color)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
    box.Adornee = part
    box.ZIndex = 5
    box.AlwaysOnTop = true
    box.Color3 = color
    box.Transparency = 0.5
    return box
end

-- Проверка на союзников
local function isAlly(player)
    if not ESP.Settings.TeamCheck or ESP.TeamSettings.LocalTeam == "" then
        return false
    end
    return player.Team and player.Team.Name == ESP.TeamSettings.LocalTeam
end

-- Функция для добавления ESP на игрока
local function addPlayerESP(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
    local humanoid = character:WaitForChild("Humanoid", 10)
    
    if not humanoidRootPart or not humanoid then return end

    local color = isAlly(player) and ESP.Colors.Ally or ESP.Colors.Enemy

    -- Создание текста имени
    if ESP.Settings.Names then
        local nameTag = createText(humanoidRootPart, player.Name, color)
        nameTag.Parent = humanoidRootPart
    end

    -- Создание бокса
    if ESP.Settings.Boxes then
        local box = createBox(humanoidRootPart, color)
        box.Parent = humanoidRootPart
    end

    -- Подсветка
    if ESP.Settings.Highlight then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = color
        highlight.OutlineColor = Color3.new(0, 0, 0)
        highlight.FillTransparency = 0.7
        highlight.Parent = character
    end

    -- Дистанция, здоровье и оружие
    game:GetService("RunService").RenderStepped:Connect(function()
        if humanoidRootPart and humanoid then
            local distance = (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude
            if distance <= ESP.Settings.MaxDistance then
                if ESP.Settings.Distance then
                    local distanceText = string.format("Distance: %.1f", distance)
                    humanoidRootPart.Name = distanceText
                end
                if ESP.Settings.HealthText then
                    local healthText = string.format("Health: %.0f%%", humanoid.Health / humanoid.MaxHealth * 100)
                    humanoidRootPart.Name = healthText
                end
                if ESP.Settings.Weapon then
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        humanoidRootPart.Name = "Weapon: " .. tool.Name
                    end
                end
            end
        end
    end)
end

-- Функция для добавления ESP на объект
local function addObjectESP(object)
    local color = ESP.Colors.Object

    -- Создание текста имени
    if ESP.Settings.Names then
        local nameTag = createText(object, object.Name, color)
        nameTag.Parent = object
    end

    -- Подсветка
    if ESP.Settings.Highlight then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = object
        highlight.FillColor = color
        highlight.OutlineColor = Color3.new(0, 0, 0)
        highlight.FillTransparency = 0.7
        highlight.Parent = object
    end
end

-- Запуск ESP
function ESP:Start(objects)
    -- Добавление ESP для игроков
    if ESP.Settings.Players then
        for _, player in pairs(game.Players:GetPlayers()) do
            addPlayerESP(player)
        end
        game.Players.PlayerAdded:Connect(addPlayerESP)
    end

    -- Добавление ESP для объектов
    if ESP.Settings.Objects and objects then
        for _, object in pairs(objects:GetChildren()) do
            addObjectESP(object)
        end
        objects.ChildAdded:Connect(addObjectESP)
    end
end

return ESP
