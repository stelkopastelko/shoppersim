
saveMenu = {}

-- Настройки на менюто
saveMenu.x = 260
saveMenu.y = 120
saveMenu.width = 1400
saveMenu.height = 840
saveMenu.isOpen = false
saveMenu.SlotCounts = 3

-- Съобщения и потвърждение за изтриване
saveMenu.message = ""
saveMenu.messageTimer = 0
saveMenu.deleteConfirmSlot = nil
saveMenu.deleteConfirmTimer = 0

-- Шрифт
saveMenu.Font = love.graphics.newFont(
    "assets/fontove/deliveryMenuFont.ttf",
    26
)

-- Цветове
local panelColor = {205/255, 185/255, 225/255}
local cardColor = {225/255, 210/255, 240/255}
local borderColor = {95/255, 65/255, 135/255}
local textColor = {165/255, 140/255, 195/255}
local titleColor = {75/255, 45/255, 105/255}

-- Размери на бутоните
local buttonWidth = 250
local buttonHeight = 60

-- Позиции на бутоните в слота
local buttonY = {
    load = 280,
    save = 350,
    delete = 420
}

-- Връща позицията на даден слот
local function getSlotPosition(i)
    local x = saveMenu.x + 100 + (i - 1) * 400
    local y = saveMenu.y + 180

    return x, y
end

-- Рисува бутон
local function drawButton(text, x, y)

    love.graphics.setColor(panelColor)
    love.graphics.rectangle(
        "fill",
        x, y,
        buttonWidth,
        buttonHeight
    )

    love.graphics.setColor(borderColor)
    love.graphics.rectangle(
        "line",
        x, y,
        buttonWidth,
        buttonHeight
    )

    love.graphics.setColor(textColor)
    love.graphics.printf(
        text,
        x,
        y + 18,
        buttonWidth,
        "center"
    )
end

-- Проверява дали е натиснат бутон
local function isButtonClicked(x, y, bx, by)
    return x >= bx
        and x <= bx + buttonWidth
        and y >= by
        and y <= by + buttonHeight
end

-- Отваря и затваря менюто
function saveMenu.toggle()

    saveMenu.isOpen = not saveMenu.isOpen

    if not saveMenu.isOpen then
        saveMenu.deleteConfirmSlot = nil
        saveMenu.deleteConfirmTimer = 0
    end
end

-- Показва временно съобщение
function saveMenu.showMessage(message)
    saveMenu.message = message
    saveMenu.messageTimer = 2.5
end

-- Обновява таймерите
function saveMenu.update(dt)

    if saveMenu.messageTimer > 0 then
        saveMenu.messageTimer = saveMenu.messageTimer - dt

        if saveMenu.messageTimer <= 0 then
            saveMenu.message = ""
        end
    end

    if saveMenu.deleteConfirmTimer > 0 then
        saveMenu.deleteConfirmTimer =
            saveMenu.deleteConfirmTimer - dt

        if saveMenu.deleteConfirmTimer <= 0 then
            saveMenu.deleteConfirmSlot = nil
        end
    end
end

-- Рисува Save менюто
function saveMenu.draw()

    if not saveMenu.isOpen then
        return
    end

    -- Запазва графичните настройки
    love.graphics.push("all")
    love.graphics.setFont(saveMenu.Font)

    -- Затъмнява фона
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle(
        "fill",
        0, 0, 1920, 1080
    )

    -- Сянка на панела
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle(
        "fill",
        saveMenu.x + 20,
        saveMenu.y + 10,
        saveMenu.width,
        saveMenu.height
    )

    -- Основен панел
    love.graphics.setColor(panelColor)
    love.graphics.rectangle(
        "fill",
        saveMenu.x,
        saveMenu.y,
        saveMenu.width,
        saveMenu.height
    )

    -- Рамка на панела
    love.graphics.setColor(borderColor)
    love.graphics.rectangle(
        "line",
        saveMenu.x,
        saveMenu.y,
        saveMenu.width,
        saveMenu.height
    )

    -- Заглавие
    love.graphics.setColor(titleColor)
    love.graphics.printf(
        "Save Files",
        saveMenu.x,
        saveMenu.y + 15,
        saveMenu.width,
        "center"
    )

    -- Рисува трите слота
    for i = 1, saveMenu.SlotCounts do

        local slotX, slotY = getSlotPosition(i)
        local buttonX = slotX + 50

        -- Фон на слота
        love.graphics.setColor(cardColor)
        love.graphics.rectangle(
            "fill",
            slotX,
            slotY,
            350,
            500
        )

        -- Рамка на слота
        love.graphics.setColor(borderColor)
        love.graphics.rectangle(
            "line",
            slotX,
            slotY,
            350,
            500
        )

        -- Номер на слота
        love.graphics.setColor(titleColor)
        love.graphics.printf(
            "Save Slot " .. i,
            slotX,
            slotY + 25,
            350,
            "center"
        )

        if saves.exists(i) then

            -- Съществуващ сейв
            love.graphics.setColor(textColor)
            love.graphics.printf(
                "Save Exists",
                slotX,
                slotY + 170,
                350,
                "center"
            )

            -- Load Game
            drawButton(
                "Load Game",
                buttonX,
                slotY + buttonY.load
            )

            -- Save Game
            drawButton(
                "Save Game",
                buttonX,
                slotY + buttonY.save
            )

            -- Delete / Confirm
            local deleteText = "Delete"

            if saveMenu.deleteConfirmSlot == i then
                deleteText = "Confirm"
            end

            drawButton(
                deleteText,
                buttonX,
                slotY + buttonY.delete
            )

        else

            -- Празен слот
            love.graphics.setColor(textColor)
            love.graphics.printf(
                "Empty Save",
                slotX,
                slotY + 170,
                350,
                "center"
            )

            -- New Game
            drawButton(
                "New Game",
                buttonX,
                slotY + buttonY.load
            )
        end
    end

    -- Временни съобщения
    love.graphics.setColor(textColor)
    love.graphics.printf(
        saveMenu.message,
        saveMenu.x,
        saveMenu.y + 780,
        saveMenu.width,
        "center"
    )

    -- Възстановява графичните настройки
    love.graphics.pop()
end

-- Запазва текущия прогрес
function saveMenu.saveCurrent()

    if not saves.currentDB then
        return true
    end

    -- Прочита информацията от базата
    local data, err = saves.read()

    if not data then
        return false, err
    end

    -- Обновява парите
    data.money = player.money
    data.inventory = shelves.exportInventory(data.inventory)
-- Взима текущите чакащи поръчки
data.pendingDeliveries = {}

for _, order in ipairs(delivery.orderQueue) do
    table.insert(data.pendingDeliveries, {
        productName = order.productName,
        timer = order.timer
    })
end

    -- Записва в базата
    return saves.update(data)
end

-- Обработва натискането на бутоните
function saveMenu.mousepressed(x, y, button)

    if not saveMenu.isOpen or button ~= 1 then
        return
    end

    for i = 1, saveMenu.SlotCounts do

        local slotX, slotY = getSlotPosition(i)
        local buttonX = slotX + 50

        if saves.exists(i) then

            -- LOAD GAME
            if isButtonClicked(
                x, y,
                buttonX,
                slotY + buttonY.load
            ) then

                local saved, saveError =
                    saveMenu.saveCurrent()

                if not saved then
                    saveMenu.showMessage(tostring(saveError))
                    return
                end

                -- Зарежда избрания сейв
                local data, err = saves.load(i)

                if not data then
                    saveMenu.showMessage(tostring(err))
                    return
                end

                player.money = data.money
                shelves.loadFromInventory(data.inventory)
                delivery.restoreOrders(data.pendingDeliveries)
                saveMenu.isOpen = false
                saveMenu.deleteConfirmSlot = nil
                saveMenu.deleteConfirmTimer = 0

                return
            end

            -- SAVE GAME
            if isButtonClicked(
                x, y,
                buttonX,
                slotY + buttonY.save
            ) then

                -- Записва само в активния слот
                if saves.currentSlot ~= i then
                    saveMenu.showMessage(
                        "Load this slot first"
                    )
                    return
                end

                local success, err =
                    saveMenu.saveCurrent()

                if success then
                    saveMenu.showMessage("Game Saved!")
                else
                    saveMenu.showMessage(tostring(err))
                end

                return
            end

            -- DELETE
            if isButtonClicked(
                x, y,
                buttonX,
                slotY + buttonY.delete
            ) then

                -- Първи клик: потвърждение
                if saveMenu.deleteConfirmSlot ~= i then

                    saveMenu.deleteConfirmSlot = i
                    saveMenu.deleteConfirmTimer = 3

                    saveMenu.showMessage(
                        "Press Again to Delete"
                    )

                    return
                end

                -- Втори клик: изтриване
                local success, err = saves.delete(i)

                if success then
                    saveMenu.showMessage("Save Deleted")
                else
                    saveMenu.showMessage(tostring(err))
                end

                saveMenu.deleteConfirmSlot = nil
                saveMenu.deleteConfirmTimer = 0

                return
            end

        else

            -- NEW GAME
            if isButtonClicked(
                x, y,
                buttonX,
                slotY + buttonY.load
            ) then

                -- Запазва предишната игра
                local saved, saveError =
                    saveMenu.saveCurrent()

                if not saved then
                    saveMenu.showMessage(tostring(saveError))
                    return
                end

                -- Създава нов сейв
                local created, createError =
                    saves.create(i)

                if not created then
                    saveMenu.showMessage(tostring(createError))
                    return
                end

                -- Зарежда новата игра
                local data, err = saves.load(i)

                if not data then
                    saveMenu.showMessage(tostring(err))
                    return
                end

                player.money = data.money
                shelves.loadFromInventory(data.inventory)
                delivery.restoreOrders(data.pendingDeliveries)
                saveMenu.isOpen = false
                saveMenu.deleteConfirmSlot = nil
                saveMenu.deleteConfirmTimer = 0

                return
            end
        end
    end
end
