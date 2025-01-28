local ESP = {}
ESP.Settings = {
    Players = true, -- Включение ESP для игроков
    Objects = true, -- Включение ESP для объектов
    Names = true, -- Показывать имена
    Boxes = true, -- Показывать боксы
    Highlight = true, -- Подсветка
    HealthText = true, -- Отображать здоровье
    Distance = true, -- Показывать дистанцию
    Weapon = true, -- Показывать оружие
    TeamCheck = true, -- Проверка команды
    MaxDistance = 100, -- Максимальная дистанция отображения
    UpdateRate = 0.1, -- Частота обновления ESP в секундах (уменьшите для ещё меньшей нагрузки)
}

-- Настройки цветов
ESP.Colors = {
    Enemy = Color3.fromRGB(255, 0, 0), -- Красный для врагов
    Ally = Color3.fromRGB(0, 255, 0), -- Зеленый для союзников
    Object = Color3.fromRGB(0, 255, 255), -- Голубой для объектов
}

-- Названия команд для Team Check
ESP.TeamSettings = {
    LocalTeam = "Survival", -- Ваша команда
    EnemyTeams = {"Infected"} -- Вражеские команды
}

local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Функция для проверки команды
local function IsEnemy(playerTeam)
    if not playerTeam then return true end
    for _, enemyTeam in ipairs(ESP.TeamSettings.EnemyTeams) do
        if playerTeam == enemyTeam then
            return true
        end
    end
    return false
end

-- Рисование текста
local function DrawText(position, text, size, color)
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = text
    textLabel.TextSize = size
    textLabel.TextColor3 = color
    textLabel.BackgroundTransparency = 1
    textLabel.BorderSizePixel = 0
    textLabel.Position = UDim2.new(0, position.X, 0, position.Y)
    textLabel.Size = UDim2.new(0, 100, 0, 20)
    textLabel.Parent = game.CoreGui
    return textLabel
end

-- Основная функция ESP
function ESP:UpdatePlayers()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local distance = (camera.CFrame.Position - rootPart.Position).Magnitude

            -- Проверяем расстояние
            if distance > ESP.Settings.MaxDistance then
                continue
            end

            -- Проверяем команды
            local isEnemy = IsEnemy(player.Team and player.Team.Name)
            local color = isEnemy and ESP.Colors.Enemy or ESP.Colors.Ally

            -- Получаем экранные координаты
            local screenPosition, onScreen = camera:WorldToScreenPoint(rootPart.Position)

            if onScreen then
                if ESP.Settings.Names then
                    DrawText(Vector2.new(screenPosition.X, screenPosition.Y - 20), player.Name, 14, color)
                end
                if ESP.Settings.HealthText then
                    local health = math.floor(player.Character.Humanoid.Health)
                    DrawText(Vector2.new(screenPosition.X, screenPosition.Y + 20), "Health: " .. health, 12, color)
                end
                if ESP.Settings.Distance then
                    DrawText(Vector2.new(screenPosition.X, screenPosition.Y + 40), string.format("Distance: %.1f", distance), 12, color)
                end
                if ESP.Settings.Weapon then
                    local weapon = player.Character:FindFirstChildOfClass("Tool")
                    if weapon then
                        DrawText(Vector2.new(screenPosition.X, screenPosition.Y + 60), "Weapon: " .. weapon.Name, 12, ESP.Colors.Object)
                    end
                end
            end
        end
    end
end

function ESP:UpdateObjects(objectPath)
    if not objectPath then return end
    for _, object in pairs(objectPath:GetDescendants()) do
        if object:IsA("BasePart") then
            local distance = (camera.CFrame.Position - object.Position).Magnitude

            -- Проверяем расстояние
            if distance > ESP.Settings.MaxDistance then
                continue
            end

            -- Получаем экранные координаты
            local screenPosition, onScreen = camera:WorldToScreenPoint(object.Position)

            if onScreen then
                if ESP.Settings.Names then
                    DrawText(Vector2.new(screenPosition.X, screenPosition.Y - 20), object.Name, 14, ESP.Colors.Object)
                end
                if ESP.Settings.Distance then
                    DrawText(Vector2.new(screenPosition.X, screenPosition.Y + 20), string.format("Distance: %.1f", distance), 12, ESP.Colors.Object)
                end
            end
        end
    end
end

-- Запуск ESP
function ESP:Start(objectPath)
    spawn(function()
        while true do
            if ESP.Settings.Players then
                self:UpdatePlayers()
            end
            if ESP.Settings.Objects and objectPath then
                self:UpdateObjects(objectPath)
            end
            wait(ESP.Settings.UpdateRate)
        end
    end)
end

return ESP
