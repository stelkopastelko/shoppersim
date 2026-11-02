
saveMenu = {}

saveMenu.x = 260
saveMenu.y = 120
saveMenu.width = 1400
saveMenu.height = 840
saveMenu.isOpen = false
saveMenu.SlotCounts = 3

saveMenu.message = ""
saveMenu.messageTimer = 0
saveMenu.deleteConfirmSlot = nil
saveMenu.deleteConfirmTimer = 0

saveMenu.Font = love.graphics.newFont(
    "assets/fontove/deliveryMenuFont.ttf",
    26
)

-- Отваря или затваря менюто
function saveMenu.toggle()

    saveMenu.isOpen = not saveMenu.isOpen

    if not saveMenu.isOpen then
        saveMenu.deleteConfirmSlot = nil
        saveMenu.deleteConfirmTimer = 0
    end
end

-- Показва съобщение за определено време
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

function saveMenu.draw()

    if saveMenu.isOpen == true then

        -- Затъмнява фона
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.rectangle("fill", 0, 0, 1920, 1080)

        -- Рисува сянката на панела
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle(
            "fill",
            saveMenu.x + 20,
            saveMenu.y + 10,
            saveMenu.width,
            saveMenu.height
        )

        -- Рисува основния панел
        love.graphics.setColor(
            205 / 255,
            185 / 255,
            225 / 255
        )

        love.graphics.rectangle(
            "fill",
            saveMenu.x,
            saveMenu.y,
            saveMenu.width,
            saveMenu.height
        )

        -- Добавя рамка на панела
        love.graphics.setColor(
            95 / 255,
            65 / 255,
            135 / 255
        )

        love.graphics.rectangle(
            "line",
            saveMenu.x,
            saveMenu.y,
            saveMenu.width,
            saveMenu.height
        )

        -- Заглавие на менюто
        love.graphics.setColor(
            75 / 255,
            45 / 255,
            105 / 255
        )

        love.graphics.setFont(saveMenu.Font)

        love.graphics.printf(
            "Save Files",
            saveMenu.x,
            saveMenu.y + 15,
            saveMenu.width,
            "center"
        )

        -- Създава картите за трите слота
        for i = 1, saveMenu.SlotCounts do

            local slotX = saveMenu.x + 100 + (i - 1) * 400
            local slotY = saveMenu.y + 180

            -- Фон на картата
            love.graphics.setColor(
                225 / 255,
                210 / 255,
                240 / 255
            )

            love.graphics.rectangle(
                "fill",
                slotX,
                slotY,
                350,
                500
            )

            -- Рамка на картата
            love.graphics.setColor(
                95 / 255,
                65 / 255,
                135 / 255
            )

            love.graphics.rectangle(
                "line",
                slotX,
                slotY,
                350,
                500
            )

            -- Показва номера на слота
            love.graphics.printf(
                "Save Slot " .. i,
                slotX,
                slotY + 25,
                350,
                "center"
            )

            -- Проверява дали слотът съдържа сейв
            if saves.exists(i) then

                -- Показва, че сейвът съществува
                love.graphics.setColor(
                    173 / 255,
                    141 / 255,
                    200 / 255
                )

                love.graphics.printf(
                    "Save Exists",
                    slotX,
                    slotY + 200,
                    350,
                    "center"
                )

                -- Бутон за зареждане
                love.graphics.setColor(
                    205 / 255,
                    185 / 255,
                    225 / 255
                )

                love.graphics.rectangle(
                    "fill",
                    slotX + 50,
                    slotY + 380,
                    250,
                    60
                )

                -- Рамка на бутона
                love.graphics.setColor(
                    95 / 255,
                    65 / 255,
                    135 / 255
                )

                love.graphics.rectangle(
                    "line",
                    slotX + 50,
                    slotY + 380,
                    250,
                    60
                )

                -- Текст на бутона
                love.graphics.setColor(
                    165 / 255,
                    140 / 255,
                    195 / 255
                )

                love.graphics.printf(
                    "Load Game",
                    slotX,
                    slotY + 400,
                    350,
                    "center"
                )

                -- Фон на Delete бутона
                love.graphics.setColor(
                    205 / 255,
                    185 / 255,
                    225 / 255
                )

                love.graphics.rectangle(
                    "fill",
                    slotX + 50,
                    slotY + 520,
                    250,
                    60
                )

                -- Рамка на Delete бутона
                love.graphics.setColor(
                    95 / 255,
                    65 / 255,
                    135 / 255
                )

                love.graphics.rectangle(
                    "line",
                    slotX + 50,
                    slotY + 520,
                    250,
                    60
                )

                -- Текст на Delete бутона
                love.graphics.setColor(
                    165 / 255,
                    140 / 255,
                    195 / 255
                )

                love.graphics.printf(
                    saveMenu.deleteConfirmSlot == i
                    and "Confirm"
                    or "Delete",
                    slotX + 3,
                    slotY + 535,
                    350,
                    "center"
                )

            else

                -- Показва, че слотът е празен
                love.graphics.setColor(
                    173 / 255,
                    141 / 255,
                    200 / 255
                )

                love.graphics.printf(
                    "Empty Save",
                    slotX,
                    slotY + 200,
                    350,
                    "center"
                )

                -- Бутон за започване на нова игра
                love.graphics.setColor(
                    205 / 255,
                    185 / 255,
                    225 / 255
                )

                love.graphics.rectangle(
                    "fill",
                    slotX + 50,
                    slotY + 380,
                    250,
                    60
                )

                -- Рамка на бутона
                love.graphics.setColor(
                    95 / 255,
                    65 / 255,
                    135 / 255
                )

                love.graphics.rectangle(
                    "line",
                    slotX + 50,
                    slotY + 380,
                    250,
                    60
                )

                -- Текст на бутона
                love.graphics.setColor(
                    165 / 255,
                    140 / 255,
                    195 / 255
                )

                love.graphics.printf(
                    "New game",
                    slotX + 7,
                    slotY + 400,
                    350,
                    "center"
                )
            end
        end

        -- Показва временните съобщения
        love.graphics.setColor(
            165 / 255,
            140 / 255,
            195 / 255
        )

        love.graphics.printf(
            saveMenu.message,
            saveMenu.x,
            saveMenu.y + 780,
            saveMenu.width,
            "center"
        )

        -- Връща цвета към нормалния
        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- Запазва текущия прогрес
function saveMenu.saveCurrent()

    if not saves.currentDB then
        return true
    end

    local data, err = saves.read()

    if not data then
        return false, err
    end

    data.money = player.money

    local success, updateError = saves.update(data)

    return success, updateError
end

-- Обработва натисканията на мишката
function saveMenu.mousepressed(x, y, button)

    if not saveMenu.isOpen or button ~= 1 then
        return
    end

    for i = 1, saveMenu.SlotCounts do

        local slotX = saveMenu.x + 100 + (i - 1) * 400
        local slotY = saveMenu.y + 180

        local buttonX = slotX + 50

        if saves.exists(i) then

            -- LOAD GAME
            if x >= buttonX and x <= buttonX + 250
            and y >= slotY + 380 and y <= slotY + 440 then

                local saved, saveError = saveMenu.saveCurrent()

                if not saved then
                    saveMenu.showMessage(tostring(saveError))
                    return
                end

                local data, err = saves.load(i)

                if not data then
                    saveMenu.showMessage(tostring(err))
                    return
                end

                player.money = data.money

                saveMenu.isOpen = false
                saveMenu.deleteConfirmSlot = nil

                return
            end

            -- DELETE
            if x >= buttonX and x <= buttonX + 250
            and y >= slotY + 520 and y <= slotY + 580 then

                -- Първото натискане иска потвърждение
                if saveMenu.deleteConfirmSlot ~= i then

                    saveMenu.deleteConfirmSlot = i
                    saveMenu.deleteConfirmTimer = 3

                    saveMenu.showMessage("Press Again to Delete")

                    return
                end

                -- Изтрива избрания сейв
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
            if x >= buttonX and x <= buttonX + 250
            and y >= slotY + 380 and y <= slotY + 440 then

                local saved, saveError = saveMenu.saveCurrent()

                if not saved then
                    saveMenu.showMessage(tostring(saveError))
                    return
                end

                -- Създава нов сейв
                local created, createError = saves.create(i)

                if not created then
                    saveMenu.showMessage(tostring(createError))
                    return
                end

                -- Зарежда новия сейв
                local data, err = saves.load(i)

                if not data then
                    saveMenu.showMessage(tostring(err))
                    return
                end

                player.money = data.money

                saveMenu.isOpen = false
                saveMenu.deleteConfirmSlot = nil

                return
            end
        end
    end
end
