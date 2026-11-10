
-- Зареждане на модулите
require("player")
require("npc")
require("shop")
require("customer")
require("map")
require("delivery")
require("database")
require("saves")
require("saveMenu")

local wf = require("libraries/windfield")


-- Размери на екрана
SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080


-- Настройки за смяна на картите
transitionAlpha = 0
transitioning = false
transitionSpeed = 2
transitionDirection = 1

nextMap = nil
nextX = 0
nextY = 0


-- Започва смяна на карта
function startMapTransition(mapPath, x, y)

    if transitioning then
        return
    end

    transitioning = true
    transitionDirection = 1

    nextMap = mapPath
    nextX = x
    nextY = y
end


-- Вземане на кашон от склада
local function pickUpNearbyBox()

    -- Играчът може да носи само един кашон
    if delivery.carriedBox ~= nil then
        return false
    end

    -- Намира близкия кашон
    local boxIndex, productName = delivery.getNearbyBox()

    if not boxIndex then
        return false
    end

    -- Запомня какъв кашон носи играчът
    delivery.carriedBox = productName

    -- Премахва кашона от склада
    table.remove(delivery.arrivedBoxes, boxIndex)

    -- Премахва старите колизии
    delivery.clearBoxColliders()

    -- Пренарежда колизиите на останалите кашони
    for i = 1, #delivery.arrivedBoxes do
        delivery.createBoxColliders(i, world)
    end

    return true
end


-- Стартиране на играта
function love.load()

    promptFont = love.graphics.newFont(18)

    -- Настройки на графиката
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setMode(
        SCREEN_WIDTH,
        SCREEN_HEIGHT
    )

    -- Физичен свят
    world = wf.newWorld(0, 0)

    -- Зарежда системите
    npc.load()
    player.load(world)

    database.load()

    -- Начална карта
    map.load(
        world,
        "assets/maps/shopmap.lua"
    )

    -- Система за доставки
    delivery.load()
    delivery.carriedBox = nil

    -- Фонова музика
    shopMusic = love.audio.newSource(
        "assets/music/soundtrack.ogg",
        "stream"
    )

    shopMusic:setVolume(0.05)
    shopMusic:setLooping(true)
    shopMusic:play()
end


-- Обновяване на играта
function love.update(dt)

    -- Обновява менютата и доставките
    saveMenu.update(dt)
    delivery.update(dt)

    -- Нормално движение
    if not transitioning
        and not delivery.MenuOpen
        and not saveMenu.isOpen then

        customer.update(dt)
        player.update(dt)
        npc.update()

    else

        -- Спира играча при отворено меню
        player.collider:setLinearVelocity(0, 0)
    end

    -- Обновява физиката
    world:update(dt)


    -- Граници на магазина
    if map.current == "assets/maps/shopmap.lua" then

        local x = player.collider:getX()
        local y = player.collider:getY()

        x = math.max(
            player.width / 2,
            math.min(
                SCREEN_WIDTH - player.width / 2,
                x
            )
        )

        y = math.max(
            player.height / 2,
            math.min(
                SCREEN_HEIGHT - player.height / 2,
                y
            )
        )

        player.collider:setPosition(x, y)
    end


    -- Смяна между магазина и склада
    if transitioning then

        -- Затъмняване
        if transitionDirection == 1 then

            transitionAlpha =
                transitionAlpha + transitionSpeed * dt

            if transitionAlpha >= 1 then

                transitionAlpha = 1

                -- Премахва колизиите на кашоните
                delivery.clearBoxColliders()

                -- Сменя картата
                map.changeMap(world, nextMap)

                -- Създава колизии, ако влизаме в склада
                if map.current == "assets/maps/storagemap.lua" then

                    for i = 1, #delivery.arrivedBoxes do

                        delivery.createBoxColliders(
                            i,
                            world
                        )
                    end
                end

                -- Премества играча
                player.collider:setPosition(
                    nextX,
                    nextY
                )

                transitionDirection = -1
            end

        -- Появяване на новата карта
        elseif transitionDirection == -1 then

            transitionAlpha =
                transitionAlpha - transitionSpeed * dt

            if transitionAlpha <= 0 then

                transitionAlpha = 0
                transitioning = false
                transitionDirection = 1

                nextMap = nil
            end
        end
    end


    -- Обновява координатите на играча
    player.x =
        player.collider:getX() - player.width / 2

    player.y =
        player.collider:getY() - player.height / 2
end


-- Рисуване на играта
function love.draw()

    -- Карта
    map.draw()

    -- Рисува оставените кашони
delivery.drawDroppedBoxes()

    -- Кашони в склада
    if map.current == "assets/maps/storagemap.lua" then
        delivery.DrawArrivedBoxes()
    end


    -- Играч
    player.draw()


    -- Рисува носения кашон
    if delivery.carriedBox then

        local scale = 0.15

        local boxWidth =
            delivery.frameWidth * scale

        local boxHeight =
            delivery.frameHeight * scale

        -- Позиция пред играча
        local boxX =
            player.x + player.width / 2 - boxWidth / 2

        local boxY =
            player.y + player.height / 2 - boxHeight / 2

        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.draw(
            delivery.productSheet,
            delivery.boxQuads[delivery.carriedBox],
            boxX,
            boxY,
            0,
            scale,
            scale
        )
    end


    -- Надпис за вземане на кашон
    if map.current == "assets/maps/storagemap.lua"
        and delivery.carriedBox == nil
        and not delivery.MenuOpen
        and not saveMenu.isOpen then

        local boxIndex, productName =
            delivery.getNearbyBox()

        if boxIndex then

            love.graphics.setFont(promptFont)
            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.print(
                "[E] Pick up " .. productName,
                player.x - 20,
                player.y - 40
            )
        end
    end


    -- NPC и клиенти
    -- npc.draw()
    -- customer.draw()


    -- Показва колизиите за тестване
    world:draw()


    -- Надпис за влизане в склада
    if map.current == "assets/maps/shopmap.lua"
        and player.x > 185
        and player.x < 270
        and player.y > 50
        and player.y < 100
        and player.direction == "up" then

        love.graphics.setFont(promptFont)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.print(
            "[E] Enter Storage",
            180,
            40
        )
    end


    -- Надпис за връщане в магазина
    if map.current == "assets/maps/storagemap.lua"
        and player.x > 910
        and player.x < 980
        and player.y > 690
        and player.y < 800
        and player.direction == "down" then

        love.graphics.setFont(promptFont)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.print(
            "[E] Enter Shop",
            961,
            697
        )
    end


    -- Пари на играча
    love.graphics.setFont(promptFont)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.print(
        "$" .. player.money,
        20,
        20
    )


    -- Меню за доставки
    delivery.draw()


    -- Ефект при смяна на карта
    love.graphics.setColor(
        0,
        0,
        0,
        transitionAlpha
    )

    love.graphics.rectangle(
        "fill",
        0,
        0,
        SCREEN_WIDTH,
        SCREEN_HEIGHT
    )

    love.graphics.setColor(1, 1, 1, 1)


    -- Save меню
    saveMenu.draw()


    -- Координати на играча
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.print(
        "X: " .. math.floor(player.x) ..
        " Y: " .. math.floor(player.y),
        20,
        50
    )
end


-- Обработка на клавиатурата
function love.keypressed(key)
   if key == "escape" then
        love.event.quit()
    end
    -- Без взаимодействия при смяна на картата
    if transitioning then
        return
    end

    -- Вземане на кашон с E

-- Вземане на кашон с E
if key == "e"
    and delivery.carriedBox == nil
    and not delivery.MenuOpen
    and not saveMenu.isOpen then

    -- Първо проверява оставените кашони
    local droppedIndex = delivery.getNearbyDroppedBox()

    if droppedIndex then

        delivery.pickUpDroppedBox(droppedIndex)

        return
    end

    -- След това проверява кашоните от доставките
    if map.current == "assets/maps/storagemap.lua" then

        if pickUpNearbyBox() then
            return
        end
    end
end

if key == "q"
    and delivery.carriedBox ~= nil
    and not delivery.MenuOpen
    and not saveMenu.isOpen then

    delivery.dropBox()
    return
end

    -- Разговор с NPC
    if npc.canIinteract == true
        and key == "e" then

        if npc.interacted == false then

            npc.interacted = true

        else

            if npc.dialogueStep < #dialogues.introOrder then

                if npc.currentspeaker == "npc" then

                    npc.currentLine =
                        npc.currentLine + 1

                else

                    npc.playerLine =
                        npc.playerLine + 1
                end

                npc.dialogueStep =
                    npc.dialogueStep + 1

                npc.currentspeaker =
                    dialogues.introOrder[npc.dialogueStep]

            else

                -- Приключва разговора
                npc.interacted = false
                npc.currentLine = 1
                npc.playerLine = 1
                npc.dialogueStep = 1

                npc.currentspeaker = "npc"
            end
        end
    end


    -- Магазин -> Склад
    if key == "e"
        and map.current == "assets/maps/shopmap.lua"
        and player.x > 177
        and player.x < 280
        and player.y > 50
        and player.y < 100 then

        startMapTransition(
            "assets/maps/storagemap.lua",
            941,
            697
        )

        return
    end


    -- Склад -> Магазин
    if key == "e"
        and map.current == "assets/maps/storagemap.lua"
        and player.x > 910
        and player.x < 980
        and player.y > 690
        and player.y < 800 then

        startMapTransition(
            "assets/maps/shopmap.lua",
            232,
            110
        )

        return
    end


    -- Меню за доставки
    if key == "tab" then

        delivery.MenuOpen =
            not delivery.MenuOpen
    end


    -- Затваряне на менюто за доставки
    if key == "escape"
        and delivery.MenuOpen then

        delivery.MenuOpen = false
    end


    -- Save меню
    if key == "v" then
        saveMenu.toggle()
    end
end


-- Обработка на мишката
function love.mousepressed(x, y, button)

    -- Save меню
    if saveMenu.isOpen then

        saveMenu.mousepressed(x, y, button)
        return
    end

    -- Меню за поръчки
    delivery.mousepressed(x, y, button)
end


-- Запазване при затваряне
function love.quit()

    local success, err = saveMenu.saveCurrent()

    if not success then

        love.window.showMessageBox(
            "Save Error",
            tostring(err),
            "error"
        )

        return true
    end

    saves.close()
end
